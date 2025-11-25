"""
User models - matching lic_schema database structure
"""
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Text, DateTime, Date, DECIMAL, func
from sqlalchemy.dialects.postgresql import UUID, JSONB, INET, ARRAY
from sqlalchemy.orm import relationship
from sqlalchemy import Enum as SQLEnum
import enum
from .base import Base, TimestampMixin


class UserRoleEnum(str, enum.Enum):
    """User role enumeration"""
    super_admin = "super_admin"
    insurance_provider_admin = "insurance_provider_admin"
    regional_manager = "regional_manager"
    senior_agent = "senior_agent"
    junior_agent = "junior_agent"
    policyholder = "policyholder"
    support_staff = "support_staff"
    guest = "guest"


class UserStatusEnum(str, enum.Enum):
    """User status enumeration"""
    active = "active"
    inactive = "inactive"
    suspended = "suspended"
    pending_verification = "pending_verification"
    deactivated = "deactivated"


class User(Base, TimestampMixin):
    """User model matching lic_schema.users"""
    __tablename__ = "users"
    __table_args__ = {'schema': 'lic_schema'}

    user_id = Column(UUID(as_uuid=True), primary_key=True)
    tenant_id = Column(UUID(as_uuid=True), nullable=False, default='00000000-0000-0000-0000-000000000000')
    email = Column(String(255), unique=True, nullable=True, index=True)
    phone_number = Column(String(15), unique=True, nullable=True, index=True)
    username = Column(String(100), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=False)
    password_salt = Column(String(255), nullable=True)
    password_changed_at = Column(DateTime, nullable=True)

    # Profile information
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    display_name = Column(String(255), nullable=True)
    avatar_url = Column(String(500), nullable=True)
    date_of_birth = Column(Date, nullable=True)
    gender = Column(String(20), nullable=True)

    # Contact details
    address = Column(JSONB, nullable=True)
    emergency_contact = Column(JSONB, nullable=True)

    # Account settings
    language_preference = Column(String(10), default='en', nullable=True)
    timezone = Column(String(50), default='Asia/Kolkata', nullable=True)
    theme_preference = Column(String(20), default='light', nullable=True)
    notification_preferences = Column(JSONB, nullable=True)

    # Authentication
    email_verified = Column(Boolean, default=False, nullable=True)
    phone_verified = Column(Boolean, default=False, nullable=True)
    email_verification_token = Column(String(255), nullable=True)
    email_verification_expires = Column(DateTime, nullable=True)
    password_reset_token = Column(String(255), nullable=True)
    password_reset_expires = Column(DateTime, nullable=True)

    # Security
    mfa_enabled = Column(Boolean, default=False, nullable=True)
    mfa_secret = Column(String(255), nullable=True)
    biometric_enabled = Column(Boolean, default=False, nullable=True)
    last_login_at = Column(DateTime, nullable=True)
    login_attempts = Column(Integer, default=0, nullable=True)
    locked_until = Column(DateTime, nullable=True)

    # Account status
    role = Column(String, nullable=False)  # Using String to match enum type
    status = Column(String, default='active', nullable=True)  # Using String to match enum type
    trial_end_date = Column(DateTime, nullable=True)
    subscription_plan = Column(String(50), nullable=True)
    subscription_status = Column(String(20), default='trial', nullable=True)

    # Audit fields
    created_by = Column(UUID(as_uuid=True), nullable=True)
    updated_by = Column(UUID(as_uuid=True), nullable=True)
    deactivated_at = Column(DateTime, nullable=True)
    deactivated_reason = Column(Text, nullable=True)
    
    # Relationships
    sessions = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")
    notification_settings = relationship("NotificationSettings", back_populates="user", cascade="all, delete-orphan")
    device_tokens = relationship("DeviceToken", back_populates="user", cascade="all, delete-orphan")

    @property
    def full_name(self):
        """Get full name from first_name and last_name"""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.display_name or ""

    @property
    def is_verified(self):
        """Check if user is verified (phone or email)"""
        return self.phone_verified or self.email_verified

    # Relationships - RBAC relationships causing TextClause error

    def __repr__(self):
        return f"<User(user_id={self.user_id}, phone_number={self.phone_number}, role={self.role})>"


class UserSession(Base):
    """User session model matching lic_schema.user_sessions"""
    __tablename__ = "user_sessions"
    __table_args__ = {'schema': 'lic_schema'}

    session_id = Column(UUID(as_uuid=True), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    session_token = Column(Text, unique=True, nullable=False)  # Changed to Text for JWT tokens
    refresh_token = Column(Text, unique=True, nullable=True)  # Changed to Text for JWT tokens
    device_info = Column(JSONB, nullable=True)
    ip_address = Column(INET, nullable=True)
    user_agent = Column(Text, nullable=True)
    location_info = Column(JSONB, nullable=True)
    expires_at = Column(DateTime, nullable=False)
    last_activity_at = Column(DateTime, default=func.now(), nullable=True)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="sessions")

    @property
    def is_active(self):
        """Check if session is active"""
        from datetime import datetime
        return self.expires_at > datetime.utcnow()

    def __repr__(self):
        return f"<UserSession(session_id={self.session_id}, user_id={self.user_id})>"
