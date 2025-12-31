"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, validator
from typing import Optional, List
from sqlalchemy.orm import Session

from app.core.logging_config import get_logger
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
    expires_in: int
    user: UserResponse


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
