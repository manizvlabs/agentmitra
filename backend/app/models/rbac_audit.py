"""
RBAC Audit Log Model - Authorization action tracking
"""
from sqlalchemy import Column, String, Boolean, DateTime, UUID, ForeignKey, JSON, Integer, Text, text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class RbacAuditLog(Base):
    """RBAC audit log for tracking authorization actions"""
    __tablename__ = "rbac_audit_log"
    __table_args__ = {'schema': 'lic_schema'}

    audit_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'))
    user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    action = Column(String(50), nullable=False)  # 'role_assigned', 'role_removed', 'permission_checked', 'feature_flag_changed'
    target_user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))  # User affected by action
    target_role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'))  # Role affected by action
    target_permission_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.permissions.permission_id'))  # Permission affected
    target_flag_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.feature_flags.flag_id'))  # Feature flag affected
    details = Column(JSON)  # Additional context
    success = Column(Boolean, default=True)
    ip_address = Column(text('inet'), nullable=True)
    user_agent = Column(Text)
    timestamp = Column(DateTime, default=func.now())

    # Relationships
    tenant = relationship("Tenant", foreign_keys=[tenant_id])
    user = relationship("User", foreign_keys=[user_id])
    target_user = relationship("User", foreign_keys=[target_user_id])
    target_role = relationship("Role", foreign_keys=[target_role_id])
    target_permission = relationship("Permission", foreign_keys=[target_permission_id])
    target_flag = relationship("FeatureFlag", foreign_keys=[target_flag_id])
