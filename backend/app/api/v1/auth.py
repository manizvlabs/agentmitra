"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    verify_token,
)
from app.services.otp_service import OTPService
from app.repositories.user_repository import UserRepository
from datetime import timedelta

router = APIRouter()
security = HTTPBearer()


class LoginRequest(BaseModel):
    phone_number: str
    password: Optional[str] = None
    agent_code: Optional[str] = None


class OTPRequest(BaseModel):
    phone_number: str


class OTPVerifyRequest(BaseModel):
    phone_number: str
    otp: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int = 1800  # 30 minutes
    user: Optional[dict] = None


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """Login endpoint - supports phone/password or agent code"""
    user_repo = UserRepository(db)
    
    # Find user by phone number or agent code
    user = None
    if request.agent_code:
        # Agent code lookup goes through agents table
        user = user_repo.get_by_agent_code(request.agent_code)
    elif request.phone_number:
        user = user_repo.get_by_phone(request.phone_number)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    
    # Verify password if provided
    if request.password:
        if not user.password_hash or not verify_password(request.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid password"
            )
    
    # Create tokens (convert UUID to string for JWT)
    token_data = {
        "sub": str(user.user_id),
        "phone_number": user.phone_number,
        "role": user.role,
    }
    
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)
    
    # Create session
    user_repo.create_session(
        user_id=user.user_id,
        access_token=access_token,
        refresh_token=refresh_token,
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": 1800,
        "user": {
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": user.is_verified,
        }
    }


@router.post("/send-otp")
async def send_otp(request: OTPRequest, db: Session = Depends(get_db)):
    """Send OTP to phone number"""
    user_repo = UserRepository(db)
    
    # Check if user exists, if not create one
    user = user_repo.get_by_phone(request.phone_number)
    if not user:
        # Create new user
        user = user_repo.create({
            "phone_number": request.phone_number,
            "role": "policyholder",
            "is_verified": False,
        })
    
    # Generate and store OTP
    otp = OTPService.generate_and_store_otp(request.phone_number)
    
    return {
        "message": "OTP sent successfully",
        "phone_number": request.phone_number,
        "expires_in": OTPService.OTP_EXPIRY_MINUTES * 60
    }


@router.post("/verify-otp", response_model=TokenResponse)
async def verify_otp(request: OTPVerifyRequest, db: Session = Depends(get_db)):
    """Verify OTP and return tokens"""
    user_repo = UserRepository(db)
    
    # Verify OTP
    if not OTPService.verify_otp(request.phone_number, request.otp):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired OTP"
        )
    
    # Get or create user
    user = user_repo.get_by_phone(request.phone_number)
    if not user:
        user = user_repo.create({
            "phone_number": request.phone_number,
            "role": "policyholder",
            "is_verified": True,
        })
    else:
        # Mark user as verified
        user_repo.update(user.user_id, {"is_verified": True})
        user.is_verified = True
    
    # Create tokens (convert UUID to string for JWT)
    token_data = {
        "sub": str(user.user_id),
        "phone_number": user.phone_number,
        "role": user.role,
    }
    
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)
    
    # Create session
    user_repo.create_session(
        user_id=user.user_id,
        access_token=access_token,
        refresh_token=refresh_token,
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": 1800,
        "user": {
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": user.is_verified,
        }
    }


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest, db: Session = Depends(get_db)):
    """Refresh access token"""
    # Verify refresh token
    payload = verify_token(request.refresh_token, token_type="refresh")
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )
    
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload"
        )
    
    user_repo = UserRepository(db)
    user = user_repo.get_by_id(user_id)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    # Create new tokens (convert UUID to string for JWT)
    token_data = {
        "sub": str(user.user_id),
        "phone_number": user.phone_number,
        "role": user.role,
    }
    
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)
    
    # Update session
    user_repo.create_session(
        user_id=user.user_id,
        access_token=access_token,
        refresh_token=refresh_token,
    )
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": 1800,
    }


@router.post("/logout")
async def logout(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Logout endpoint"""
    token = credentials.credentials
    payload = verify_token(token)
    
    if payload:
        user_id = payload.get("sub")
        if user_id:
            user_repo = UserRepository(db)
            user_repo.deactivate_all_sessions(user_id)
    
    return {"message": "Logged out successfully"}
