"""
Portal Authentication API
=========================

Authentication endpoints for the Agent Configuration Portal.
Handles agent login, session management, and authorization.
"""

from datetime import timedelta
from typing import Any, Dict
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel, EmailStr

from app.core.database import get_db
from app.core.config.settings import settings
from app.core.security import create_access_token, verify_password
from app.models.user import User
from app.repositories.user_repository import UserRepository

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


class TokenData(BaseModel):
    username: str = None


class UserLogin(BaseModel):
    username: str
    password: str


class AgentRegistration(BaseModel):
    email: EmailStr
    password: str
    first_name: str
    last_name: str
    phone_number: str
    business_name: str
    license_number: str


def authenticate_user(db: Session, username: str, password: str) -> User:
    """Authenticate user"""
    user_repo = UserRepository(db)
    user = user_repo.get_by_username_or_email(username)

    if not user:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    """Get current authenticated user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user_repo = UserRepository(db)
    user = user_repo.get_by_username(username)
    if user is None:
        raise credentials_exception
    return user


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """Agent login endpoint"""
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check if user has portal access (agent or admin roles)
    if user.role not in ["agent", "senior_agent", "admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Portal access required.",
        )

    access_token_expires = timedelta(minutes=settings.jwt_access_token_expire_minutes)
    access_token = create_access_token(
        data={"sub": user.username, "role": user.role, "user_id": str(user.id)},
        expires_delta=access_token_expires
    )

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": int(access_token_expires.total_seconds())
    }


@router.post("/register", response_model=Token)
async def register_agent(
    agent_data: AgentRegistration,
    db: Session = Depends(get_db)
):
    """Register new agent (admin only in production)"""
    # In development, allow self-registration
    # In production, this should require admin approval

    user_repo = UserRepository(db)

    # Check if user already exists
    existing_user = user_repo.get_by_email(agent_data.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Create new user with agent role
    from app.core.security import hash_password
    from uuid import uuid4
    from datetime import datetime

    new_user = User(
        id=uuid4(),
        email=agent_data.email,
        username=agent_data.email,  # Use email as username initially
        password_hash=hash_password(agent_data.password),
        first_name=agent_data.first_name,
        last_name=agent_data.last_name,
        phone_number=agent_data.phone_number,
        role="agent",
        status="pending_approval",  # Require admin approval
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )

    try:
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        # TODO: Send welcome email and approval notification

        # Auto-login after registration
        access_token_expires = timedelta(minutes=settings.jwt_access_token_expire_minutes)
        access_token = create_access_token(
            data={"sub": new_user.username, "role": new_user.role, "user_id": str(new_user.id)},
            expires_delta=access_token_expires
        )

        return {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": int(access_token_expires.total_seconds()),
            "message": "Registration successful. Please wait for admin approval."
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )


@router.get("/me")
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Get current user profile"""
    return {
        "id": str(current_user.id),
        "email": current_user.email,
        "username": current_user.username,
        "first_name": current_user.first_name,
        "last_name": current_user.last_name,
        "phone_number": current_user.phone_number,
        "role": current_user.role,
        "status": current_user.status,
        "created_at": current_user.created_at.isoformat() if current_user.created_at else None
    }


@router.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    """Logout endpoint (client-side token removal)"""
    return {"message": "Logged out successfully"}
