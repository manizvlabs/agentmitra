"""
Permission Model
"""
from sqlalchemy import Column, String, Boolean, DateTime, TEXT, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from ..base import Base


class Permission(Base):
    """Permissions in the RBAC system"""
    __tablename__ = "permissions"
    __table_args__ = {'schema': 'lic_schema'}

    permission_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    permission_name = Column(String(100), unique=True, nullable=False)
    permission_description = Column(TEXT)
    resource = Column(String(100), nullable=False)  # e.g., 'users', 'policies', 'agents'
    action = Column(String(50), nullable=False)     # e.g., 'create', 'read', 'update', 'delete'
    is_system_permission = Column(Boolean, default=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())

    # No relationships needed for JSONB permissions approach

    def __repr__(self):
        return f"<Permission(permission_name={self.permission_name})>"
