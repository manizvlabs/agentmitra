"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, validator
from typing import Optional, List
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import auth_service
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    create_token_pair,
    refresh_access_token,
    validate_jwt_token,
    blacklist_token,
)
from app.core.auth import get_current_user_context, get_current_user_optional, UserContext, require_permission
from app.core.rate_limiter import otp_rate_limiter, auth_rate_limiter
from app.core.audit_logger import AuditLogger
from app.core.logging_config import get_logger
from app.services.otp_service import OTPService
from app.repositories.user_repository import UserRepository
from app.repositories.agent_repository import AgentRepository
from app.models.user import User
from datetime import datetime
from fastapi import Request

logger = get_logger(__name__)

router = APIRouter()
security = HTTPBearer()


class LoginRequest(BaseModel):
    phone_number: Optional[str] = None
    password: Optional[str] = None
    agent_code: Optional[str] = None


class OTPRequest(BaseModel):
    phone_number: Optional[str] = None
    email: Optional[str] = None


class OTPVerifyRequest(BaseModel):
    phone_number: Optional[str] = None
    email: Optional[str] = None
    otp: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900  # 15 minutes
    user: Optional[dict] = None
    permissions: Optional[List[str]] = None


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    # Initialize repositories
    user_repo = UserRepository(db)

    try:
        # Rate limiting
        ip_address = http_request.client.host if http_request.client else "unknown"
        user_agent = http_request.headers.get("user-agent")

        is_allowed, remaining = auth_rate_limiter.is_allowed(ip_address)
        if not is_allowed:
            await AuditLogger.log_login_attempt(
                db=db,
                user_id=None,
                phone_number=request.phone_number,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                method="rate_limited",
                error_message="Rate limit exceeded"
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded. Please try again later.",
                headers={"Retry-After": str(auth_rate_limiter.window_seconds)}
            )

        # Determine login method
        user = None
        login_method = "unknown"

        if request.agent_code:
            # Agent login - find agent by code
            agent_repo = AgentRepository(db)
            agent = agent_repo.get_by_code(request.agent_code)
            if agent and agent.user:
                user = agent.user
                login_method = "agent_code"
        elif request.phone_number:
            # Phone login - find user directly
            user = user_repo.get_by_phone(request.phone_number)
            login_method = "phone"

        if not user:
            await AuditLogger.log_login_attempt(
                db=db,
                user_id=None,
                phone_number=request.phone_number,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                method=login_method,
                error_message="User not found"
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials"
            )

        # Check if user account is active
        if hasattr(user, 'status') and user.status != 'active':
            await AuditLogger.log_login_attempt(
                db=db,
                user_id=str(user.user_id),
                phone_number=user.phone_number,
                ip_address=ip_address,
                user_agent=user_agent,
                success=False,
                method=login_method,
                error_message="Account not active"
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Account is not active"
            )

        # Verify password if provided (required for phone login)
        if request.password:
            if not user.password_hash:
                await AuditLogger.log_login_attempt(
                    db=db,
                    user_id=str(user.user_id),
                    phone_number=user.phone_number,
                    ip_address=ip_address,
                    user_agent=user_agent,
                    success=False,
                    method=login_method,
                    error_message="Password authentication not available"
                )
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Password authentication not available for this account"
                )

            if not verify_password(request.password, user.password_hash):
                # Log failed login attempt
                await AuditLogger.log_login_attempt(
                    db=db,
                    user_id=str(user.user_id),
                    phone_number=user.phone_number,
                    ip_address=ip_address,
                    user_agent=user_agent,
                    success=False,
                    method=login_method,
                    error_message="Invalid password"
                )
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid credentials"
                )

        # Get user roles and permissions for JWT token
        rbac_service = auth_service
        user_roles = rbac_service.get_user_roles(str(user.user_id), db)
        user_permissions = []

        # Get permissions for all user roles
        for role in user_roles:
            role_permissions = rbac_service.get_role_permissions(role, db)
            user_permissions.extend(role_permissions)

        # Remove duplicates
        user_permissions = list(set(user_permissions))

        # Generate tokens with roles and permissions
        token_data = {
            "sub": str(user.user_id),
            "phone_number": user.phone_number,
            "roles": user_roles,
            "permissions": user_permissions
        }
        access_token = create_access_token(token_data)
        refresh_token = create_refresh_token({"sub": str(user.user_id)})

        # Log successful login
        await AuditLogger.log_login_attempt(
            db=db,
            user_id=str(user.user_id),
            phone_number=user.phone_number,
            ip_address=ip_address,
            user_agent=user_agent,
            success=True,
            method=login_method
        )

        # Create user response object
        user_response = {
            "user_id": str(user.user_id),
            "email": user.email,
            "phone_number": user.phone_number,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "display_name": user.display_name,
            "role": user.role,
            "status": user.status or "active",
            "phone_verified": user.phone_verified,
            "email_verified": user.email_verified,
            "last_login_at": user.last_login_at,
            "created_at": user.created_at,
            "updated_at": user.updated_at
        }

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user=user_response,
            permissions=user_permissions
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error during authentication: {str(e)}"
        )


@router.post("/logout", response_model=dict)
async def logout(
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_optional)
):
    """
    Logout endpoint - clears authentication tokens
    For JWT, this is mainly for client-side cleanup since tokens are stateless
    """
    # Log the logout attempt
    ip_address = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent")

    if current_user and hasattr(current_user, 'user_id') and current_user.user_id:
        try:
            await AuditLogger.log_logout(
                db=db,
                user_id=str(current_user.user_id),
                ip_address=ip_address,
                user_agent=user_agent,
                success=True
            )
        except Exception as e:
            # Log audit failure but don't fail the logout
            logger.warning(f"Failed to log logout audit: {e}")

    # For JWT-based auth, logout is mainly client-side
    # In a more advanced setup, you could blacklist tokens here
    return {"message": "Successfully logged out", "success": True}
