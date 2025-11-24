"""
Callback Request Management Models
"""
from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, ForeignKey, DECIMAL, ARRAY, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB, ENUM
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from .base import Base, TimestampMixin


class CallbackRequest(Base, TimestampMixin):
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
    assigned_at = Column(DateTime)
    scheduled_at = Column(DateTime)
    due_at = Column(DateTime)
    started_at = Column(DateTime)
    completed_at = Column(DateTime)
    
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
    activities = relationship("CallbackActivity", primaryjoin="CallbackRequest.callback_request_id == CallbackActivity.callback_request_id", back_populates="callback_request", cascade="all, delete-orphan")


class CallbackActivity(Base, TimestampMixin):
    """Callback activity log"""
    __tablename__ = "callback_activities"
    __table_args__ = {"schema": "lic_schema"}

    callback_activity_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    callback_request_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.callback_requests.callback_request_id"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"))
    
    # Activity details
    activity_type = Column(String(50), nullable=False)
    description = Column(Text, nullable=False)
    duration_minutes = Column(Integer)
    contact_method = Column(String(50))
    contact_outcome = Column(String(100))
    notes = Column(Text)
    activity_metadata = Column(JSONB, default={})
    
    # Relationships
    callback_request = relationship("CallbackRequest", primaryjoin="CallbackActivity.callback_request_id == CallbackRequest.callback_request_id", back_populates="activities")
    agent = relationship("Agent", foreign_keys=[agent_id], backref="callback_activities")

