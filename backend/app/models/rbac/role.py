"""
Role Model
"""
from sqlalchemy import Column, String, Boolean, Integer, DateTime, TEXT, func, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..base import Base


class Role(Base):
    """User roles in the RBAC system"""
    __tablename__ = "roles"
    __table_args__ = {'schema': 'lic_schema'}

    role_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    role_name = Column(String(100), unique=True, nullable=False)
    role_description = Column(TEXT)
    is_system_role = Column(Boolean, default=False)
    permissions = Column(JSON)  # JSONB field containing permission strings
    created_at = Column(DateTime, default=func.now())

    # No relationships needed since permissions are stored as JSONB

    def __repr__(self):
        return f"<Role(role_name={self.role_name})>"
