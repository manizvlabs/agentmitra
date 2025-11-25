"""
Shared schema models - accessible across all tenants
"""
from sqlalchemy import Column, String, Boolean, Integer, Text, TIMESTAMP, JSON, ARRAY, func, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from .base import Base


class InsuranceProvider(Base):
    """Insurance provider model - shared across tenants"""
    __tablename__ = "insurance_providers"

    provider_id = Column(UUID(as_uuid=True), primary_key=True)
    provider_code = Column(String(20), unique=True, nullable=False, index=True)
    provider_name = Column(String(255), nullable=False)
    provider_type = Column(String(50))  # 'life_insurance', 'health_insurance', 'general_insurance'
    description = Column(Text)

    # API Integration
    api_endpoint = Column(String(500))
    api_credentials = Column(JSONB)  # Encrypted sensitive data
    webhook_url = Column(String(500))
    webhook_secret = Column(String(255))

    # Business details
    license_number = Column(String(100))
    regulatory_authority = Column(String(100))  # IRDAI, etc.
    established_year = Column(Integer)
    headquarters = Column(JSONB)

    # Operational settings
    supported_languages = Column(ARRAY(String), default=['en'])
    business_hours = Column(JSONB)
    service_regions = Column(ARRAY(String))
    commission_structure = Column(JSONB)

    # Status and metadata
    status = Column(String(50), default='active')  # 'active', 'inactive', 'suspended', 'under_maintenance'
    integration_status = Column(String(50), default='pending')  # 'pending', 'testing', 'active'
    last_sync_at = Column(TIMESTAMP)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now())

    # Relationships
    # Note: Relationships to tenant-specific tables would need to be handled carefully
    # to avoid cross-schema references

    def __repr__(self):
        return f"<InsuranceProvider(provider_code={self.provider_code}, name={self.provider_name})>"


class Country(Base):
    """Country reference data"""
    __tablename__ = "countries"

    country_code = Column(String(3), primary_key=True)
    country_name = Column(String(100), nullable=False)
    currency_code = Column(String(3), nullable=False)
    phone_code = Column(String(10), nullable=False)
    timezone = Column(String(50), default='UTC')
    status = Column(String(20), default='active')


class Language(Base):
    """Language reference data"""
    __tablename__ = "languages"

    language_code = Column(String(10), primary_key=True)
    language_name = Column(String(100), nullable=False)
    native_name = Column(String(100), nullable=False)
    rtl = Column(Boolean, default=False)
    status = Column(String(20), default='active')


class InsuranceCategory(Base):
    """Insurance categories reference data"""
    __tablename__ = "insurance_categories"

    category_code = Column(String(50), primary_key=True)
    category_name = Column(String(255), nullable=False)
    category_type = Column(String(50))  # 'life', 'health', 'general'
    description = Column(Text)
    status = Column(String(20), default='active')


class WhatsappTemplate(Base):
    """WhatsApp message templates"""
    __tablename__ = "whatsapp_templates"

    template_id = Column(UUID(as_uuid=True), primary_key=True)
    template_name = Column(String(100), unique=True, nullable=False)
    category = Column(String(50), nullable=False)
    language = Column(String(10), default='en')
    content = Column(Text, nullable=False)
    variables = Column(JSONB)
    approval_status = Column(String(20), default='pending')


class Tenant(Base):
    """Tenant (insurance provider) configuration - matching lic_schema.tenants"""
    __tablename__ = "tenants"
    __table_args__ = {'schema': 'lic_schema'}

    tenant_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_code = Column(String(20), unique=True, nullable=False)
    tenant_name = Column(String(255), nullable=False)
    tenant_type = Column(String(50), nullable=False)  # 'insurance_provider', 'independent_agent', 'agent_network'
    schema_name = Column(String(100), unique=True)
    parent_tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'))
    status = Column(String(20), default='active')
    subscription_plan = Column(String(50))
    trial_end_date = Column(TIMESTAMP)
    max_users = Column(Integer, default=1000)
    storage_limit_gb = Column(Integer, default=10)
    api_rate_limit = Column(Integer, default=1000)

    # Contact information
    contact_email = Column(String(255))
    contact_phone = Column(String(20))
    business_address = Column(JSONB)

    # Branding and customization
    branding_settings = Column(JSONB)
    theme_settings = Column(JSONB)

    # Compliance and legal
    compliance_status = Column(JSONB)
    regulatory_approvals = Column(JSONB)

    # Metadata
    tenant_metadata = Column(JSONB)

    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now())

    # Relationships
    parent_tenant = relationship("Tenant", remote_side=[tenant_id], backref="child_tenants")
    feature_flags = relationship("FeatureFlag", back_populates="tenant", cascade="all, delete-orphan")

    @property
    def is_active(self):
        """Check if tenant is active"""
        return self.status == 'active'

    def __repr__(self):
        return f"<Tenant(tenant_code={self.tenant_code}, name={self.tenant_name})>"


class TenantConfig(Base):
    """Tenant-specific configuration"""
    __tablename__ = "tenant_config"
    __table_args__ = {'schema': 'lic_schema'}

    config_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)
    config_key = Column(String(100), nullable=False)
    config_value = Column(JSONB)
    config_type = Column(String(50), default='string')  # 'string', 'number', 'boolean', 'json'
    is_encrypted = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now())

    # Relationships
    tenant = relationship("Tenant", backref="configs")

    def __repr__(self):
        return f"<TenantConfig(tenant_id={self.tenant_id}, key={self.config_key})>"


class TenantUser(Base):
    """Many-to-many relationship between tenants and users"""
    __tablename__ = "tenant_users"
    __table_args__ = {'schema': 'lic_schema'}

    tenant_user_id = Column(UUID(as_uuid=True), primary_key=True, default=func.gen_random_uuid())
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'), nullable=False)
    role = Column(String(50), nullable=False)
    permissions = Column(JSONB)
    is_primary = Column(Boolean, default=False)
    joined_at = Column(TIMESTAMP, default=func.now())
    status = Column(String(20), default='active')

    # Relationships
    tenant = relationship("Tenant", backref="tenant_users")
    user = relationship("User", backref="tenant_memberships")

    @property
    def is_active(self):
        """Check if tenant user relationship is active"""
        return self.status == 'active'

    def __repr__(self):
        return f"<TenantUser(tenant_id={self.tenant_id}, user_id={self.user_id}, role={self.role})>"
