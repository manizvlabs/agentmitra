"""
Trial Subscription Models
"""
from sqlalchemy import Column, String, Date, TIMESTAMP, Boolean, Integer, DECIMAL, JSON, UUID, ForeignKey, func
from sqlalchemy.orm import relationship
from app.models.base import Base, TimestampMixin, AuditMixin


class TrialSubscription(Base, TimestampMixin, AuditMixin):
    """Trial subscriptions with enhanced tracking"""

    __tablename__ = "trial_subscriptions"

    trial_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    plan_type = Column(String(50), default="policyholder_trial")
    trial_start_date = Column(TIMESTAMP, server_default=func.now())
    trial_end_date = Column(TIMESTAMP)
    actual_conversion_date = Column(TIMESTAMP)
    conversion_plan = Column(String(50))
    trial_status = Column(String(50), default="active")  # 'active', 'expired', 'converted', 'cancelled'
    extension_days = Column(Integer, default=0)
    reminder_sent = Column(Boolean, default=False)

    # Relationships
    user = relationship("User", back_populates="trial_subscriptions", foreign_keys=[user_id])
    engagement_data = relationship("TrialEngagement", back_populates="trial")

    def __repr__(self):
        return f"<TrialSubscription(trial_id='{self.trial_id}', user_id='{self.user_id}', status='{self.trial_status}')>"


class TrialEngagement(Base, TimestampMixin):
    """Trial user engagement tracking"""

    __tablename__ = "trial_engagement"

    engagement_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    trial_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.trial_subscriptions.trial_id", ondelete="CASCADE"), nullable=False)
    feature_used = Column(String(100))
    engagement_type = Column(String(50))  # 'view', 'interaction', 'completion'
    engagement_metadata = Column(JSON)
    engaged_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    trial = relationship("TrialSubscription", back_populates="engagement_data")

    def __repr__(self):
        return f"<TrialEngagement(trial_id='{self.trial_id}', feature='{self.feature_used}')>"
