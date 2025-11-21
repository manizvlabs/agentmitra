"""
Shared schema models - accessible across all tenants
"""
from sqlalchemy import Column, String, Boolean, Integer, Text, TIMESTAMP, JSON, ARRAY, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from .base import Base


class InsuranceProvider(Base):
    """Insurance provider model - shared across tenants"""
    __tablename__ = "insurance_providers"
    __table_args__ = {'schema': 'shared'}

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
    __table_args__ = {'schema': 'shared'}

    country_code = Column(String(3), primary_key=True)
    country_name = Column(String(100), nullable=False)
    currency_code = Column(String(3), nullable=False)
    phone_code = Column(String(10), nullable=False)
    timezone = Column(String(50), default='UTC')
    status = Column(String(20), default='active')


class Language(Base):
    """Language reference data"""
    __tablename__ = "languages"
    __table_args__ = {'schema': 'shared'}

    language_code = Column(String(10), primary_key=True)
    language_name = Column(String(100), nullable=False)
    native_name = Column(String(100), nullable=False)
    rtl = Column(Boolean, default=False)
    status = Column(String(20), default='active')


class InsuranceCategory(Base):
    """Insurance categories reference data"""
    __tablename__ = "insurance_categories"
    __table_args__ = {'schema': 'shared'}

    category_code = Column(String(50), primary_key=True)
    category_name = Column(String(255), nullable=False)
    category_type = Column(String(50))  # 'life', 'health', 'general'
    description = Column(Text)
    status = Column(String(20), default='active')


class WhatsappTemplate(Base):
    """WhatsApp message templates"""
    __tablename__ = "whatsapp_templates"
    __table_args__ = {'schema': 'shared'}

    template_id = Column(UUID(as_uuid=True), primary_key=True)
    template_name = Column(String(100), unique=True, nullable=False)
    category = Column(String(50), nullable=False)
    language = Column(String(10), default='en')
    content = Column(Text, nullable=False)
    variables = Column(JSONB)
    approval_status = Column(String(20), default='pending')


class Tenant(Base):
    """Tenant (insurance provider) configuration"""
    __tablename__ = "tenants"
    __table_args__ = {'schema': 'shared'}

    tenant_code = Column(String(20), primary_key=True)
    tenant_name = Column(String(255), nullable=False)
    tenant_type = Column(String(50), default='insurance_provider')
    schema_name = Column(String(100), nullable=False)
    status = Column(String(20), default='active')
    subscription_plan = Column(String(50))
    max_users = Column(Integer)
    storage_limit_gb = Column(Integer)
    api_rate_limit = Column(Integer)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now())
