"""
Customer retention analytics model
"""
from sqlalchemy import Column, String, Integer, Float, DateTime, Text, Boolean, UUID, ForeignKey, JSON, func
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import ENUM, JSONB

from app.models.base import Base

# Enums
customer_risk_level_enum = ENUM('high', 'medium', 'low', name='customer_risk_level_enum')
retention_status_enum = ENUM('active', 'at_risk', 'churned', 'recovered', 'lost', name='retention_status_enum')


class CustomerRetentionAnalytics(Base):
    __tablename__ = "customer_retention_analytics"
    __table_args__ = {'schema': 'lic_schema'}

    retention_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    customer_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.policyholders.policyholder_id'))

    # Risk assessment
    risk_level = Column(customer_risk_level_enum, default='low')
    risk_score = Column(Float, default=0)
    churn_probability = Column(Float, default=0)

    # Risk factors (JSON array for flexibility)
    risk_factors = Column(JSONB, default=list)
    engagement_score = Column(Float, default=0)

    # Financial metrics
    premium_value = Column(Float)
    lifetime_value = Column(Float)
    days_since_last_payment = Column(Integer, default=0)

    # Activity metrics
    days_since_last_contact = Column(Integer, default=0)
    complaints_count = Column(Integer, default=0)
    support_queries_count = Column(Integer, default=0)
    missed_payments_count = Column(Integer, default=0)

    # Policy information
    policy_age_months = Column(Integer)
    policy_count = Column(Integer, default=1)
    policy_type = Column(String(100))

    # Retention actions
    last_retention_action_at = Column(DateTime)
    retention_plan = Column(JSONB)
    retention_success_probability = Column(Float, default=0)

    # Status tracking
    status = Column(retention_status_enum, default='active')
    status_changed_at = Column(DateTime, default=func.now())

    # Agent assignment
    assigned_agent_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.agents.agent_id'))

    # Audit fields
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())

    # Relationships
    customer = relationship("Policyholder")
    assigned_agent = relationship("Agent")
