"""
Agent model - matching lic_schema database structure
"""
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Text, Date, DECIMAL, DateTime
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship
from .base import Base, TimestampMixin


class Agent(Base, TimestampMixin):
    """Agent model matching lic_schema.agents"""
    __tablename__ = "agents"
    __table_args__ = {'schema': 'lic_schema'}

    agent_id = Column(UUID(as_uuid=True), primary_key=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    provider_id = Column(UUID(as_uuid=True), ForeignKey("shared.insurance_providers.provider_id"), nullable=True)

    # Agent identification
    agent_code = Column(String(50), unique=True, nullable=False)
    license_number = Column(String(100), unique=True, nullable=True)
    license_expiry_date = Column(Date, nullable=True)
    license_issuing_authority = Column(String(100), nullable=True)

    # Business information
    business_name = Column(String(255), nullable=True)
    business_address = Column(JSONB, nullable=True)
    gst_number = Column(String(15), nullable=True)
    pan_number = Column(String(10), nullable=True)

    # Operational details
    territory = Column(String(255), nullable=True)
    operating_regions = Column(ARRAY(Text), nullable=True)
    experience_years = Column(Integer, nullable=True)
    specializations = Column(ARRAY(Text), nullable=True)

    # Commission structure
    commission_rate = Column(DECIMAL(5, 2), nullable=True)
    commission_structure = Column(JSONB, nullable=True)
    performance_bonus_structure = Column(JSONB, nullable=True)

    # Communication
    whatsapp_business_number = Column(String(15), nullable=True)
    business_email = Column(String(255), nullable=True)
    website = Column(String(500), nullable=True)

    # Performance metrics
    total_policies_sold = Column(Integer, default=0, nullable=True)
    total_premium_collected = Column(DECIMAL(15, 2), default=0, nullable=True)
    active_policyholders = Column(Integer, default=0, nullable=True)
    customer_satisfaction_score = Column(DECIMAL(3, 2), nullable=True)

    # Hierarchy
    parent_agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"), nullable=True)
    hierarchy_level = Column(Integer, default=1, nullable=True)
    sub_agents_count = Column(Integer, default=0, nullable=True)

    # Status
    status = Column(String, default='active', nullable=True)  # Using String to match enum type
    verification_status = Column(String(50), default='pending', nullable=True)
    approved_at = Column(DateTime, nullable=True)
    approved_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)
    
    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    presentations = relationship("Presentation", back_populates="agent")

    def __repr__(self):
        return f"<Agent(agent_id={self.agent_id}, agent_code={self.agent_code}, status={self.status})>"

