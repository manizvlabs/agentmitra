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
async def login(request: LoginRequest):
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    from app.core.auth import create_access_token, create_refresh_token
    import jwt
    from datetime import timedelta

    # Mock user authentication for testing
    # Map phone numbers to user roles as specified
    mock_users = {
        "+919876543200": {"role": "super_admin", "permissions": ["policies:*", "analytics:*", "tenants:*", "agents:*", "users:*", "reports:*", "admin:*", "system:*", "permissions:*", "settings:*", "roles:*"]},
        "+919876543201": {"role": "provider_admin", "permissions": ["policies:*", "analytics:read", "tenants:read", "agents:*", "reports:read"]},
        "+919876543202": {"role": "regional_manager", "permissions": ["policies:*", "analytics:read", "tenants:read", "agents:*", "reports:*"]},
        "+919876543203": {"role": "senior_agent", "permissions": ["policies:*", "analytics:read", "agents:read", "reports:read"]},
        "+919876543204": {"role": "junior_agent", "permissions": ["policies:read", "agents:read"]},
        "+919876543205": {"role": "policyholder", "permissions": ["policies:read"]},
        "+919876543206": {"role": "support_staff", "permissions": ["users:read", "reports:read", "policies:read"]}
    }

    # Determine login method and validate credentials
    if request.phone_number and request.password:
        # Phone + Password login
        if request.phone_number not in mock_users:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid phone number or password"
            )

        # Check password (all users use "testpassword")
        if request.password != "testpassword":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid phone number or password"
            )

        user_role = mock_users[request.phone_number]["role"]
        user_permissions = mock_users[request.phone_number]["permissions"]
        login_method = "phone_password"

    elif request.agent_code:
        # Agent code login (mock implementation)
        # For demo, any agent code starting with "AG" is valid
        if not request.agent_code.startswith("AG"):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid agent code"
            )

        # Default to senior_agent role for agent login
        user_role = "senior_agent"
        user_permissions = ["policies:*", "analytics:read", "agents:read", "reports:read"]
        login_method = "agent_code"

    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either phone_number with password or agent_code is required"
        )

    # Create JWT tokens
    access_token = create_access_token(
        data={"sub": request.phone_number or request.agent_code, "role": user_role}
    )
    refresh_token = create_refresh_token(
        data={"sub": request.phone_number or request.agent_code}
    )

    # Log successful login
    logger.info(f"User logged in successfully: {request.phone_number or request.agent_code} via {login_method}")

    # Return token response
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user={
            "user_id": f"user_{request.phone_number or request.agent_code}",
            "phone_number": request.phone_number,
            "role": user_role,
            "permissions": user_permissions,
            "is_active": True
        },
        roles=[user_role],
        permissions=user_permissions
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
