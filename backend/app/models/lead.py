"""
Lead model for lead management and scoring
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, Text, Boolean, UUID, ForeignKey, func
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ENUM

from app.models.base import Base

# Enums
lead_status_enum = ENUM('new', 'contacted', 'qualified', 'quoted', 'converted', 'lost', 'inactive', name='lead_status_enum')
lead_source_enum = ENUM('website', 'referral', 'cold_call', 'social_media', 'email_campaign',
                       'whatsapp_campaign', 'event', 'partner', 'walk_in', 'other', name='lead_source_enum')
lead_priority_enum = ENUM('high', 'medium', 'low', name='lead_priority_enum')

interaction_type_enum = ENUM('call', 'email', 'whatsapp', 'meeting', 'visit', 'sms', 'social_media', 'other', name='interaction_type_enum')
interaction_method_enum = ENUM('inbound', 'outbound', name='interaction_method_enum')


class Lead(Base):
    __tablename__ = "leads"
    __table_args__ = {'schema': 'lic_schema'}

    lead_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    agent_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.agents.agent_id'))

    # Customer information
    customer_name = Column(String(255), nullable=False)
    contact_number = Column(String(20), nullable=False)
    email = Column(String(255))
    location = Column(String(255))

    # Lead details
    lead_source = Column(lead_source_enum, nullable=False)
    lead_status = Column(lead_status_enum, default='new')
    priority = Column(lead_priority_enum, default='medium')

    # Insurance requirements
    insurance_type = Column(String(100))
    budget_range = Column(String(50))
    coverage_required = Column(Float)

    # Lead scoring and analytics
    conversion_score = Column(Float, default=0)
    engagement_score = Column(Float, default=0)
    potential_premium = Column(Float, default=0)

    # Lead qualification
    is_qualified = Column(Boolean, default=False)
    qualification_notes = Column(Text)
    disqualification_reason = Column(Text)

    # Timeline tracking
    created_at = Column(DateTime, default=func.now())
    first_contact_at = Column(DateTime)
    last_contact_at = Column(DateTime)
    last_contact_method = Column(String(50))

    # Follow-up scheduling
    next_followup_at = Column(DateTime)
    followup_count = Column(Integer, default=0)
    response_time_hours = Column(Float)

    # Conversion tracking
    converted_at = Column(DateTime)
    converted_policy_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.insurance_policies.policy_id'))
    conversion_value = Column(Float)

    # Audit fields
    created_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    updated_by = Column(UUID(as_uuid=True), ForeignKey('lic_schema.users.user_id'))
    updated_at = Column(DateTime, default=func.now())

    # Relationships
    agent = relationship("Agent", back_populates="leads")
    created_by_user = relationship("User", foreign_keys=[created_by])
    updated_by_user = relationship("User", foreign_keys=[updated_by])
    converted_policy = relationship("InsurancePolicy", foreign_keys=[converted_policy_id])
    interactions = relationship("LeadInteraction", back_populates="lead")


class LeadInteraction(Base):
    __tablename__ = "lead_interactions"
    __table_args__ = {'schema': 'lic_schema'}

    interaction_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    lead_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.leads.lead_id'), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.agents.agent_id'))

    # Interaction details
    interaction_type = Column(interaction_type_enum, nullable=False)
    interaction_method = Column(interaction_method_enum)
    duration_minutes = Column(Integer)
    outcome = Column(String(255))
    notes = Column(Text)

    # Follow-up
    next_action = Column(Text)
    next_action_date = Column(DateTime)

    # Audit
    created_at = Column(DateTime, default=func.now())

    # Relationships
    lead = relationship("Lead", back_populates="interactions")
    agent = relationship("Agent", back_populates="lead_interactions")