"""
Role-Permission Association Model
"""
from sqlalchemy import Column, DateTime, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from ..base import Base


class RolePermission(Base):
    """Association between roles and permissions"""
    __tablename__ = "role_permissions"
    __table_args__ = {'schema': 'lic_schema'}

    role_permission_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'), nullable=False)
    permission_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.permissions.permission_id'), nullable=False)
    assigned_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    assigned_at = Column(DateTime, default=func.now())

    def __repr__(self):
        return f"<RolePermission(role_id={self.role_id}, permission_id={self.permission_id})>"
