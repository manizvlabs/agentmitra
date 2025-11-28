"""
Callback Management System Models
==================================

Enhanced callback models with priority scoring, SLA tracking, and comprehensive management features.
"""

from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, ForeignKey, DECIMAL, ARRAY, CheckConstraint, Float, Enum
from sqlalchemy.orm import foreign
from sqlalchemy.dialects.postgresql import UUID, JSONB, ENUM
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import uuid
import enum

from app.models.base import Base, TimestampMixin, AuditMixin


class CallbackRequest(Base):
    """Callback request model"""
    __tablename__ = "callback_requests"
    __table_args__ = {"schema": "lic_schema"}

    callback_request_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tenant_id = Column(UUID(as_uuid=True), nullable=False, default=uuid.UUID('00000000-0000-0000-0000-000000000000'))
    policyholder_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.policyholders.policyholder_id"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"))

    # Request details
    request_type = Column(String(100), nullable=False)
    description = Column(Text, nullable=False)
    priority = Column(String(20), default='low')
    priority_score = Column(DECIMAL(5, 2), default=0.00)
    status = Column(String(50), default='pending')

    # Customer contact information (cached)
    customer_name = Column(String(200), nullable=False)
    customer_phone = Column(String(20), nullable=False)
    customer_email = Column(String(255))

    # SLA and time management
    sla_hours = Column(Integer, default=24)
    created_at = Column(DateTime, default=datetime.utcnow)
    assigned_at = Column(DateTime)
    scheduled_at = Column(DateTime)
    due_at = Column(DateTime)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Source tracking
    source = Column(String(50), default='mobile')
    source_reference_id = Column(String(200))

    # Metadata and categorization
    tags = Column(ARRAY(String), default=[])
    category = Column(String(100))
    urgency_level = Column(String(20), default='medium')
    customer_value = Column(String(20), default='bronze')

    # Resolution details
    resolution = Column(Text)
    resolution_category = Column(String(100))
    satisfaction_rating = Column(Integer)

    # Audit fields
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    assigned_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    completed_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    last_updated_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    last_updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Constraints
    __table_args__ = (
        CheckConstraint('satisfaction_rating >= 1 AND satisfaction_rating <= 5', name='check_satisfaction_rating'),
    )
    
    # Relationships
    policyholder = relationship("Policyholder", foreign_keys=[policyholder_id], backref="callback_requests")
    agent = relationship("Agent", foreign_keys=[agent_id], backref="callback_requests")
    # Relationship - FK constraint managed by Flyway, specify join explicitly
    activities = relationship(
        "CallbackActivity", 
        primaryjoin="CallbackRequest.callback_request_id == CallbackActivity.callback_request_id",
        foreign_keys="[CallbackActivity.callback_request_id]",
        back_populates="callback_request", 
        cascade="all, delete-orphan"
    )


class CallbackActivity(Base, TimestampMixin):
    """Callback activity log"""
    __tablename__ = "callback_activities"
    __table_args__ = {"schema": "lic_schema"}

    callback_activity_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    # Foreign key constraint is managed by Flyway migrations, not SQLAlchemy
    # Using plain Column to avoid SQLAlchemy FK validation at import time
    # The actual FK constraint exists in the database (created by V23 migration)
    callback_request_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    agent_id = Column(UUID(as_uuid=True), index=True)
    
    # Activity details
    activity_type = Column(String(50), nullable=False)
    description = Column(Text, nullable=False)
    duration_minutes = Column(Integer)
    contact_method = Column(String(50))
    contact_outcome = Column(String(100))
    notes = Column(Text)
    activity_metadata = Column(JSONB, default={})
    
    # Relationships - FK constraints managed by Flyway, specify join explicitly
    callback_request = relationship(
        "CallbackRequest", 
        primaryjoin="CallbackActivity.callback_request_id == CallbackRequest.callback_request_id",
        foreign_keys="[CallbackActivity.callback_request_id]",
        back_populates="activities"
    )
    # Agent relationship - FK managed by Flyway
    agent = relationship(
        "Agent",
        primaryjoin="CallbackActivity.agent_id == Agent.agent_id",
        foreign_keys="[CallbackActivity.agent_id]",
        backref="callback_activities"
    )


# Enhanced Callback Management Models

class PriorityLevel(enum.Enum):
    """Callback priority levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class CallbackStatus(enum.Enum):
    """Callback status"""
    PENDING = "pending"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"
    ESCALATED = "escalated"


class CallbackSource(enum.Enum):
    """Callback source"""
    CUSTOMER_PORTAL = "customer_portal"
    AGENT_PORTAL = "agent_portal"
    WHATSAPP = "whatsapp"
    PHONE = "phone"
    EMAIL = "email"
    CHATBOT = "chatbot"


class Callback(Base, TimestampMixin, AuditMixin):
    """Enhanced callback model with SLA tracking"""

    __tablename__ = "callbacks_enhanced"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    callback_id = Column(String(50), unique=True, nullable=False, index=True)

    # Customer information
    customer_name = Column(String(255), nullable=False)
    customer_phone = Column(String(20), nullable=False, index=True)
    customer_email = Column(String(255), nullable=True)

    # Callback details
    subject = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=True)  # policy, claim, complaint, inquiry, etc.
    sub_category = Column(String(100), nullable=True)

    # Priority and scoring
    priority = Column(Enum(PriorityLevel), nullable=False, default=PriorityLevel.MEDIUM)
    priority_score = Column(Float, nullable=False, default=0.0)  # Calculated priority score
    urgency_factors = Column(JSONB, nullable=True)  # Factors affecting priority

    # Status and assignment
    status = Column(Enum(CallbackStatus), nullable=False, default=CallbackStatus.PENDING)
    assigned_to = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    assigned_at = Column(DateTime(timezone=True), nullable=True)
    assigned_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)

    # Source and channel
    source = Column(Enum(CallbackSource), nullable=False)
    source_reference = Column(String(255), nullable=True)  # Message ID, call ID, etc.

    # SLA tracking
    sla_target_minutes = Column(Integer, nullable=True)  # Target resolution time
    sla_started_at = Column(DateTime(timezone=True), nullable=True)
    sla_breached_at = Column(DateTime(timezone=True), nullable=True)
    sla_met = Column(Boolean, nullable=True)

    # Resolution
    resolved_at = Column(DateTime(timezone=True), nullable=True)
    resolved_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    resolution_notes = Column(Text, nullable=True)
    resolution_category = Column(String(100), nullable=True)

    # Escalation
    escalated = Column(Boolean, default=False)
    escalated_at = Column(DateTime(timezone=True), nullable=True)
    escalated_to = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    escalation_reason = Column(Text, nullable=True)

    # Follow-up
    follow_up_required = Column(Boolean, default=False)
    follow_up_date = Column(DateTime(timezone=True), nullable=True)
    follow_up_notes = Column(Text, nullable=True)

    # Additional metadata
    tags = Column(JSONB, nullable=True)
    callback_metadata = Column(JSONB, nullable=True)

    def __repr__(self):
        return f"<Callback(id={self.id}, callback_id={self.callback_id}, priority={self.priority.value}, status={self.status.value})>"


class CallbackHistory(Base, TimestampMixin):
    """Callback history log"""

    __tablename__ = "callback_history"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    callback_id = Column(UUID(as_uuid=True), ForeignKey("callbacks_enhanced.id"), nullable=False, index=True)

    # Change tracking
    previous_status = Column(Enum(CallbackStatus), nullable=True)
    new_status = Column(Enum(CallbackStatus), nullable=True)
    previous_assigned_to = Column(UUID(as_uuid=True), nullable=True)
    new_assigned_to = Column(UUID(as_uuid=True), nullable=True)

    # Action details
    action = Column(String(100), nullable=False)  # assigned, status_changed, resolved, escalated, etc.
    action_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    action_notes = Column(Text, nullable=True)

    # Metadata
    callback_metadata = Column(JSONB, nullable=True)

    def __repr__(self):
        return f"<CallbackHistory(id={self.id}, callback_id={self.callback_id}, action={self.action})>"


class CallbackSLA(Base, TimestampMixin):
    """SLA configuration for different callback types"""

    __tablename__ = "callback_sla"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())

    # SLA criteria
    category = Column(String(100), nullable=True)
    priority = Column(Enum(PriorityLevel), nullable=False)
    source = Column(Enum(CallbackSource), nullable=True)

    # SLA targets
    response_time_minutes = Column(Integer, nullable=False)  # Initial response time
    resolution_time_minutes = Column(Integer, nullable=False)  # Full resolution time

    # Business hours (JSON with days and hours)
    business_hours = Column(JSONB, nullable=True)

    # Escalation rules
    auto_escalate_after_minutes = Column(Integer, nullable=True)
    escalate_to_role = Column(String(50), nullable=True)

    # Active flag
    is_active = Column(Boolean, default=True)

    def __repr__(self):
        return f"<CallbackSLA(id={self.id}, priority={self.priority.value}, resolution_time={self.resolution_time_minutes})>"


class CallbackAnalytics(Base, TimestampMixin):
    """Analytics data for callbacks"""

    __tablename__ = "callback_analytics"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())

    # Time period
    date = Column(DateTime(timezone=True), nullable=False, index=True)
    period = Column(String(20), nullable=False)  # daily, weekly, monthly

    # Metrics
    total_callbacks = Column(Integer, nullable=False, default=0)
    resolved_callbacks = Column(Integer, nullable=False, default=0)
    avg_resolution_time_minutes = Column(Float, nullable=True)
    sla_compliance_rate = Column(Float, nullable=True)  # Percentage

    # Breakdown by priority
    high_priority_callbacks = Column(Integer, nullable=False, default=0)
    high_priority_resolved = Column(Integer, nullable=False, default=0)

    # Breakdown by source
    whatsapp_callbacks = Column(Integer, nullable=False, default=0)
    phone_callbacks = Column(Integer, nullable=False, default=0)
    portal_callbacks = Column(Integer, nullable=False, default=0)

    # Agent performance
    avg_first_response_time = Column(Float, nullable=True)
    callbacks_per_agent = Column(Float, nullable=True)

    def __repr__(self):
        return f"<CallbackAnalytics(id={self.id}, date={self.date.date()}, total_callbacks={self.total_callbacks})>"
