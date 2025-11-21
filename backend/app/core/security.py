"""
Security utilities for authentication and authorization
"""
from datetime import datetime, timedelta
from typing import Optional, Dict
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config.settings import settings
import secrets
import random
import bcrypt

# Password hashing context - simplified for compatibility
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash using bcrypt directly for compatibility"""
    try:
        # Try using bcrypt directly first (more reliable)
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        # Fallback to passlib if direct bcrypt fails
        try:
            return pwd_context.verify(plain_password, hashed_password)
        except Exception:
            return False


def get_password_hash(password: str) -> str:
    """Hash a password"""
    try:
        # Use bcrypt directly for consistency
        return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    except Exception:
        # Fallback to passlib
        return pwd_context.hash(password)


def create_access_token(data: Dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(
            minutes=settings.jwt_access_token_expire_minutes
        )
    
    to_encode.update({"exp": expire, "type": "access"})
    encoded_jwt = jwt.encode(
        to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm
    )
    return encoded_jwt


def create_refresh_token(data: Dict) -> str:
    """Create JWT refresh token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(
        days=settings.jwt_refresh_token_expire_days
    )
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(
        to_encode, settings.jwt_secret_key, algorithm=settings.jwt_algorithm
    )
    return encoded_jwt


def verify_token(token: str, token_type: str = "access") -> Optional[Dict]:
    """Verify and decode JWT token"""
    try:
        payload = jwt.decode(
            token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm]
        )
        
        # Check token type
        if payload.get("type") != token_type:
            return None
            
        return payload
    except JWTError:
        return None


def generate_otp(length: int = 6) -> str:
    """Generate a random OTP"""
    return "".join([str(random.randint(0, 9)) for _ in range(length)])


def generate_otp_secret() -> str:
    """Generate a secret for OTP storage"""
    return secrets.token_urlsafe(32)


# Token blacklist for logout functionality
_token_blacklist = set()


def blacklist_token(token: str) -> None:
    """Add token to blacklist (for logout)"""
    _token_blacklist.add(token)


def is_token_blacklisted(token: str) -> bool:
    """Check if token is blacklisted"""
    return token in _token_blacklist


def clear_expired_blacklist_tokens() -> None:
    """
    Clear expired tokens from blacklist
    Should be called periodically or on application startup
    """
    # In production, this would use Redis or database
    # For now, we'll implement a simple cleanup
    pass


def validate_jwt_token(token: str, token_type: str = "access") -> Optional[Dict]:
    """
    Enhanced JWT token validation with blacklist checking
    """
    # Check if token is blacklisted
    if is_token_blacklisted(token):
        return None

    # Verify token
    payload = verify_token(token, token_type)
    if not payload:
        return None

    return payload


def create_token_pair(user_data: Dict) -> Dict[str, str]:
    """
    Create both access and refresh tokens for a user
    """
    token_data = {
        "sub": str(user_data.get("user_id", "")),
        "phone_number": user_data.get("phone_number", ""),
        "role": user_data.get("role", ""),
        "email": user_data.get("email", ""),
    }

    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
        "expires_in": settings.jwt_access_token_expire_minutes * 60,
    }


def refresh_access_token(refresh_token: str) -> Optional[Dict[str, str]]:
    """
    Create new access token from valid refresh token
    """
    # Validate refresh token
    payload = validate_jwt_token(refresh_token, "refresh")
    if not payload:
        return None

    # Create new access token with same data
    token_data = {
        "sub": payload.get("sub"),
        "phone_number": payload.get("phone_number", ""),
        "role": payload.get("role", ""),
        "email": payload.get("email", ""),
    }

    access_token = create_access_token(token_data)

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.jwt_access_token_expire_minutes * 60,
    }


def extract_token_from_header(authorization_header: str) -> Optional[str]:
    """
    Extract token from Authorization header
    Expected format: "Bearer <token>"
    """
    if not authorization_header or not authorization_header.startswith("Bearer "):
        return None

    try:
        token = authorization_header.split(" ")[1]
        return token
    except IndexError:
        return None

