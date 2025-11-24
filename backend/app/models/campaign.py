"""
Campaign Management Models
"""
from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, ForeignKey, DECIMAL, ARRAY, JSON, Enum as SQLEnum
from sqlalchemy.dialects.postgresql import UUID, JSONB, ENUM
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from .base import Base, TimestampMixin


class Campaign(Base, TimestampMixin):
    """Marketing campaign model"""
    __tablename__ = "campaigns"
    __table_args__ = {"schema": "lic_schema"}

    campaign_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"), nullable=False)
    
    # Campaign basic information
    campaign_name = Column(String(255), nullable=False)
    campaign_type = Column(String(50), nullable=False)  # 'acquisition', 'retention', 'upselling', 'behavioral'
    campaign_goal = Column(String(100))
    description = Column(Text)
    
    # Campaign content
    subject = Column(String(500))
    message = Column(Text, nullable=False)
    message_template_id = Column(UUID(as_uuid=True))
    personalization_tags = Column(ARRAY(String))
    attachments = Column(JSONB)
    
    # Channel configuration
    primary_channel = Column(String(50), nullable=False, default='whatsapp')
    channels = Column(ARRAY(String))
    
    # Targeting and segmentation
    target_audience = Column(String(50), default='all')
    selected_segments = Column(ARRAY(String))
    targeting_rules = Column(JSONB)
    estimated_reach = Column(Integer, default=0)
    
    # Scheduling
    schedule_type = Column(String(50), default='immediate')
    scheduled_at = Column(DateTime)
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    
    # Automation
    is_automated = Column(Boolean, default=False)
    automation_triggers = Column(JSONB)
    
    # Budget and cost
    budget = Column(DECIMAL(12, 2), default=0)
    estimated_cost = Column(DECIMAL(12, 2), default=0)
    cost_per_recipient = Column(DECIMAL(10, 4), default=0)
    
    # A/B Testing
    ab_testing_enabled = Column(Boolean, default=False)
    ab_test_variants = Column(JSONB)
    
    # Status and lifecycle
    status = Column(String(50), default='draft')
    launched_at = Column(DateTime)
    paused_at = Column(DateTime)
    completed_at = Column(DateTime)
    
    # Performance metrics (denormalized)
    total_sent = Column(Integer, default=0)
    total_delivered = Column(Integer, default=0)
    total_opened = Column(Integer, default=0)
    total_clicked = Column(Integer, default=0)
    total_converted = Column(Integer, default=0)
    total_revenue = Column(DECIMAL(15, 2), default=0)
    roi_percentage = Column(DECIMAL(5, 2), default=0)
    
    # Audit fields
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    updated_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    
    # Relationships
    agent = relationship("Agent", backref="campaigns")
    triggers = relationship("CampaignTrigger", back_populates="campaign", cascade="all, delete-orphan")
    executions = relationship("CampaignExecution", back_populates="campaign", cascade="all, delete-orphan")
    responses = relationship("CampaignResponse", back_populates="campaign", cascade="all, delete-orphan")


class CampaignTrigger(Base, TimestampMixin):
    """Campaign automation trigger model"""
    __tablename__ = "campaign_triggers"
    __table_args__ = {"schema": "lic_schema"}

    trigger_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.campaigns.campaign_id"), nullable=False)
    
    # Trigger configuration
    trigger_type = Column(String(100), nullable=False)
    trigger_value = Column(String(255))
    additional_conditions = Column(JSONB)
    
    # Trigger status
    is_active = Column(Boolean, default=True)
    
    # Relationships
    campaign = relationship("Campaign", back_populates="triggers")


class CampaignExecution(Base, TimestampMixin):
    """Individual campaign execution to a customer"""
    __tablename__ = "campaign_executions"
    __table_args__ = {"schema": "lic_schema"}

    execution_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    campaign_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.campaigns.campaign_id"), nullable=False)
    policyholder_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.policyholders.policyholder_id"), nullable=False)
    
    # Execution details
    channel = Column(String(50), nullable=False)
    personalized_content = Column(JSONB)
    sent_at = Column(DateTime)
    delivered_at = Column(DateTime)
    opened_at = Column(DateTime)
    clicked_at = Column(DateTime)
    
    # Status tracking
    status = Column(String(50), default='pending')
    failure_reason = Column(Text)
    
    # Conversion tracking
    converted = Column(Boolean, default=False)
    conversion_value = Column(DECIMAL(12, 2))
    conversion_type = Column(String(100))
    
    # Device and context
    device_info = Column(JSONB)
    ip_address = Column(String(45))
    user_agent = Column(Text)
    
    # Relationships
    campaign = relationship("Campaign", back_populates="executions")
    policyholder = relationship("Policyholder", backref="campaign_executions")
    responses = relationship("CampaignResponse", back_populates="execution", cascade="all, delete-orphan")


class CampaignTemplate(Base, TimestampMixin):
    """Pre-built campaign template"""
    __tablename__ = "campaign_templates"
    __table_args__ = {"schema": "lic_schema"}

    template_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Template details
    template_name = Column(String(255), nullable=False)
    description = Column(Text)
    category = Column(String(50), nullable=False)
    
    # Template content
    subject_template = Column(String(500))
    message_template = Column(Text, nullable=False)
    personalization_tags = Column(ARRAY(String))
    suggested_channels = Column(ARRAY(String))
    
    # Template metadata
    usage_count = Column(Integer, default=0)
    average_roi = Column(DECIMAL(5, 2))
    total_ratings = Column(Integer, default=0)
    average_rating = Column(DECIMAL(3, 2))
    
    # Preview
    preview_image_url = Column(String(500))
    
    # Availability
    is_public = Column(Boolean, default=False)
    is_system_template = Column(Boolean, default=False)
    status = Column(String(50), default='active')
    
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))


class CampaignResponse(Base, TimestampMixin):
    """Customer response to campaign"""
    __tablename__ = "campaign_responses"
    __table_args__ = {"schema": "lic_schema"}

    response_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    execution_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.campaign_executions.execution_id"), nullable=False)
    campaign_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.campaigns.campaign_id"), nullable=False)
    policyholder_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.policyholders.policyholder_id"), nullable=False)
    
    # Response details
    response_type = Column(String(50), nullable=False)
    response_text = Column(Text)
    response_channel = Column(String(50))
    
    # Metadata
    sentiment_score = Column(DECIMAL(3, 2))
    requires_followup = Column(Boolean, default=False)
    
    # Relationships
    execution = relationship("CampaignExecution", back_populates="responses")
    campaign = relationship("Campaign", back_populates="responses")
    policyholder = relationship("Policyholder", backref="campaign_responses")

