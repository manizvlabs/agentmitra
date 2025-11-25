"""
Feature Flags Models - Dynamic permission control system
"""
from sqlalchemy import Column, String, Boolean, DateTime, Text, UUID, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .base import Base


class FeatureFlag(Base):
    """Feature flag for dynamic permission control"""
    __tablename__ = "feature_flags"
    __table_args__ = {'schema': 'lic_schema'}

    flag_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    flag_name = Column(String(100), nullable=False, unique=True)
    flag_description = Column(Text)
    flag_type = Column(String(20), default='boolean')  # 'boolean', 'string', 'number', 'json'
    default_value = Column(Text)  # Default value when flag is enabled
    is_enabled = Column(Boolean, default=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    created_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=True)
    updated_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=True)

    # Relationships
    tenant = relationship("Tenant", back_populates="feature_flags")
    created_by_user = relationship("User", foreign_keys=[created_by])
    updated_by_user = relationship("User", foreign_keys=[updated_by])
    overrides = relationship("FeatureFlagOverride", back_populates="feature_flag")


class FeatureFlagOverride(Base):
    """Feature flag overrides for specific users/roles/tenants"""
    __tablename__ = "feature_flag_overrides"
    __table_args__ = {'schema': 'lic_schema'}

    override_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    flag_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.feature_flags.flag_id'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=True)
    role_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.roles.role_id'), nullable=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=True)
    override_value = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=True)

    # Relationships
    feature_flag = relationship("FeatureFlag", back_populates="overrides")
    user = relationship("User", foreign_keys=[user_id])
    role = relationship("Role", foreign_keys=[role_id])
    tenant = relationship("Tenant", foreign_keys=[tenant_id])
    updated_by_user = relationship("User", foreign_keys=[updated_by])
