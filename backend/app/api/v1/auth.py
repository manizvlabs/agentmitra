"""
Authentication API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel, validator
from typing import Optional
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import (
    verify_password,
    get_password_hash,
    create_token_pair,
    refresh_access_token,
    validate_jwt_token,
    blacklist_token,
)
from app.core.auth import get_current_user_context, UserContext, require_permission
from app.services.otp_service import OTPService
from app.repositories.user_repository import UserRepository
from datetime import datetime

router = APIRouter()
security = HTTPBearer()


class LoginRequest(BaseModel):
    phone_number: Optional[str] = None
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
    """
    Login endpoint - supports multiple authentication methods:
    1. Phone + Password (for registered users)
    2. Agent Code (for agents)
    """
    user_repo = UserRepository(db)

    # Find user by phone number or agent code
    user = None
    login_method = None

    if request.agent_code:
        # Agent code login - find agent through agent table
        user = user_repo.get_by_agent_code(request.agent_code)
        login_method = "agent_code"
    elif request.phone_number:
        # Phone login - find user directly
        user = user_repo.get_by_phone(request.phone_number)
        login_method = "phone"
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either phone_number or agent_code must be provided"
        )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )

    # Check if user account is active
    if hasattr(user, 'status') and user.status != 'active':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is not active"
        )

    # Verify password if provided (required for phone login)
    if request.password:
        if not user.password_hash:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Password authentication not available for this account"
            )

        if not verify_password(request.password, user.password_hash):
            # TODO: Implement failed login attempt tracking
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid password"
            )
    elif login_method == "phone":
        # Phone login without password - not allowed
        print("Phone login attempted without password")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password is required for phone number login"
        )

    # Create token pair
    user_data = {
        "user_id": str(user.user_id),
        "phone_number": user.phone_number,
        "role": user.role,
        "email": user.email,
    }

    token_response = create_token_pair(user_data)

    # Create session in database
    try:
        user_repo.create_session(
            user_id=user.user_id,
            access_token=token_response["access_token"],
            refresh_token=token_response["refresh_token"],
        )
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to create session: {e}")

    # Update last login timestamp
    try:
        user_repo.update(user.user_id, {"last_login_at": datetime.utcnow()})
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to update last login: {e}")

    # Return token response with user info
    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=token_response["refresh_token"],
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
        user={
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": getattr(user, 'phone_verified', False),
            "email": user.email,
        }
    )


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
            "phone_verified": True,
            "status": "active",
        })
    else:
        # Mark user as verified
        user_repo.update(user.user_id, {"phone_verified": True})

    # Create token pair
    user_data = {
        "user_id": str(user.user_id),
        "phone_number": user.phone_number,
        "role": user.role,
        "email": user.email,
    }

    token_response = create_token_pair(user_data)

    # Create session in database
    try:
        user_repo.create_session(
            user_id=user.user_id,
            access_token=token_response["access_token"],
            refresh_token=token_response["refresh_token"],
        )
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to create session: {e}")

    # Update last login timestamp
    try:
        user_repo.update(user.user_id, {"last_login_at": datetime.utcnow()})
    except Exception as e:
        # Log error but don't fail login
        print(f"Failed to update last login: {e}")

    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=token_response["refresh_token"],
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
        user={
            "user_id": str(user.user_id),
            "phone_number": user.phone_number,
            "full_name": user.full_name,
            "role": user.role,
            "is_verified": getattr(user, 'phone_verified', False),
            "email": user.email,
        }
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(request: RefreshTokenRequest, db: Session = Depends(get_db)):
    """Refresh access token using valid refresh token"""
    # Verify refresh token with enhanced validation
    token_response = refresh_access_token(request.refresh_token)
    if not token_response:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )

    # Get user information (optional, for user data in response)
    user_repo = UserRepository(db)
    # Extract user_id from the refresh token payload
    refresh_payload = validate_jwt_token(request.refresh_token, "refresh")
    if refresh_payload:
        user_id = refresh_payload.get("sub")
        user = user_repo.get_by_id(user_id) if user_id else None

        if user:
            return TokenResponse(
                access_token=token_response["access_token"],
                refresh_token=request.refresh_token,  # Return same refresh token
                token_type=token_response["token_type"],
                expires_in=token_response["expires_in"],
                user={
                    "user_id": str(user.user_id),
                    "phone_number": user.phone_number,
                    "full_name": user.full_name,
                    "role": user.role,
                    "is_verified": getattr(user, 'phone_verified', False),
                    "email": user.email,
                }
            )

    # Return token response without user data if user lookup fails
    return TokenResponse(
        access_token=token_response["access_token"],
        refresh_token=request.refresh_token,
        token_type=token_response["token_type"],
        expires_in=token_response["expires_in"],
    )


@router.post("/logout")
async def logout(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Logout endpoint - blacklist current access token"""
    # Blacklist the current access token
    auth_header = current_user.token_data.get("token")
    if auth_header:
        blacklist_token(auth_header)

    # Invalidate user sessions (optional - could be done in background)
    # For now, just return success

    return {"message": "Logged out successfully"}


@router.get("/sessions")
async def get_sessions(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get user's active sessions"""
    user_repo = UserRepository(db)
    sessions = user_repo.get_user_sessions(current_user.user_id)

    return {
        "sessions": [
            {
                "session_id": str(session.session_id),
                "created_at": session.created_at.isoformat(),
                "expires_at": session.expires_at.isoformat(),
                "is_current": False,  # TODO: Implement current session detection
            }
            for session in sessions
            if session.is_active
        ]
    }


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Delete specific session"""
    user_repo = UserRepository(db)

    # Verify session belongs to user
    session = user_repo.get_session_by_id(session_id)
    if not session or str(session.user_id) != current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found"
        )

    # Deactivate session
    user_repo.deactivate_session(session_id)

    return {"message": "Session deleted successfully"}


@router.delete("/sessions")
async def delete_all_sessions(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Delete all user sessions except current"""
    user_repo = UserRepository(db)

    # Deactivate all sessions for user
    user_repo.deactivate_user_sessions(current_user.user_id)

    return {"message": "All sessions deleted successfully"}
    token = credentials.credentials
    payload = verify_token(token)
    
    if payload:
        user_id = payload.get("sub")
        if user_id:
            user_repo = UserRepository(db)
            user_repo.deactivate_all_sessions(user_id)
    
    return {"message": "Logged out successfully"}
