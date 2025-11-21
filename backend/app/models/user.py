"""
User models
"""
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Text
from sqlalchemy.orm import relationship
from .base import Base, TimestampMixin


class User(Base, TimestampMixin):
    """User model"""
    __tablename__ = "users"

    user_id = Column(String, primary_key=True)
    phone_number = Column(String, unique=True, nullable=False, index=True)
    email = Column(String, unique=True, nullable=True, index=True)
    full_name = Column(String, nullable=True)
    agent_code = Column(String, unique=True, nullable=True, index=True)
    role = Column(String, nullable=False, default="customer")  # 'agent', 'customer', 'admin'
    is_verified = Column(Boolean, default=False, nullable=False)
    password_hash = Column(String, nullable=True)  # For password-based auth
    
    # Relationships
    sessions = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User(user_id={self.user_id}, phone_number={self.phone_number}, role={self.role})>"


class UserSession(Base, TimestampMixin):
    """User session model for tracking active sessions"""
    __tablename__ = "user_sessions"

    session_id = Column(String, primary_key=True)
    user_id = Column(String, ForeignKey("users.user_id"), nullable=False, index=True)
    access_token = Column(Text, nullable=False)
    refresh_token = Column(Text, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    device_info = Column(String, nullable=True)
    ip_address = Column(String, nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="sessions")

    def __repr__(self):
        return f"<UserSession(session_id={self.session_id}, user_id={self.user_id})>"

