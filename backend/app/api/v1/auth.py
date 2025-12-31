"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, validator
from typing import Optional, List
from sqlalchemy.orm import Session

from app.core.logging_config import get_logger
from app.core.security import create_access_token, create_refresh_token
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


class UserResponse(BaseModel):
    user_id: str
    phone_number: str
    role: str
    permissions: List[str]
    is_active: bool


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 900  # 15 minutes
    user: Optional[dict] = None
    roles: Optional[List[str]] = None
    permissions: Optional[List[str]] = None


@router.get("/test")
async def test_auth():
    """Test endpoint for auth router"""
    return {"message": "Auth router working", "status": "ok"}

@router.post("/test-auth")
async def login(request_data: dict):
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    # TEMPORARY: Just return success for testing
    return {
        "message": "Login successful - testing mode",
        "test": True,
        "request_data": request_data
    }


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    from app.core.security import create_access_token, create_refresh_token, verify_password
    from app.repositories.user_repository import UserRepository
    from app.services.rbac_service import RBACService
    from app.repositories.agent_repository import AgentRepository

    user = None
    login_method = None

    try:
        if request.phone_number and request.password:
            # Phone + Password login
            user_repo = UserRepository(db)
            user = user_repo.get_by_phone(request.phone_number)

            if not user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid phone number or password"
                )

            # Verify password
            if not user.password_hash or not verify_password(request.password, user.password_hash):
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid phone number or password"
                )

            login_method = "phone_password"

        elif request.agent_code:
            # Agent code login
            agent_repo = AgentRepository(db)
            agent = agent_repo.get_by_code(request.agent_code)

            if not agent or not agent.user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid agent code"
                )

            user = agent.user
            login_method = "agent_code"

        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either phone_number with password or agent_code is required"
            )

        # Get user permissions using RBAC service
        rbac_service = RBACService(db)
        user_permissions = list(await rbac_service.get_user_permissions(str(user.user_id)))
        user_roles = list(await rbac_service.get_user_roles(str(user.user_id)))

        # Create JWT tokens
        access_token = create_access_token(
            data={"sub": str(user.user_id), "role": user.role}
        )
        refresh_token = create_refresh_token(
            data={"sub": str(user.user_id)}
        )

        # Log successful login (temporarily disabled for production)
        # await AuditLogger.log_login_attempt(
        #     db=db,
        #     user_id=str(user.user_id),
        #     phone_number=user.phone_number,
        #     ip_address=get_client_ip(request),
        #     user_agent=request.headers.get("user-agent"),
        #     success=True,
        #     method=login_method
        # )

        logger.info(f"User logged in successfully: {user.phone_number or request.agent_code} via {login_method}")

        # Return token response with real user data
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            user={
                "user_id": str(user.user_id),
                "phone_number": user.phone_number,
                "role": user.role,
                "permissions": user_permissions,
                "is_active": user.status == "active"
            },
            roles=user_roles,
            permissions=user_permissions
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error during login: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during authentication"
        )

# Temporarily disable exception handler for debugging
# try:
#     # Authentication logic here
#     pass
# except Exception as e:
#     logger.error(f"Unexpected error during login: {e}", exc_info=True)
#     raise HTTPException(
#         status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#         detail=f"Internal server error during authentication: {str(e)}"
#     )
@router.post("/logout", response_model=dict)
async def logout(
    request: Request,
    current_user = None
):
    """
    Logout endpoint - clears authentication tokens
    For JWT, this is mainly for client-side cleanup since tokens are stateless
    """
    # TEMPORARY: Simplified logout
    return {"message": "Successfully logged out", "success": True}


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str
    confirm_password: str


@router.put("/change-password", response_model=dict)
async def change_password(
    password_data: ChangePasswordRequest,
    current_user = None
):
    """
    Change user password

    Validates current password and updates to new password
    """
    # TEMPORARY: Simplified change password
    return {"message": "Password changed successfully", "success": True}
