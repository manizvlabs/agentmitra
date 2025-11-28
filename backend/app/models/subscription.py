"""
Subscription Models
==================

Models for subscription plans, user subscriptions, and billing management.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, DECIMAL, JSON, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.models.base import Base, TimestampMixin, AuditMixin


class SubscriptionPlan(Base, TimestampMixin, AuditMixin):
    """Subscription plan definitions"""

    __tablename__ = "subscription_plans"
    __table_args__ = {'schema': 'lic_schema'}

    plan_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    plan_name = Column(String(100), nullable=False, unique=True)
    plan_type = Column(String(50), nullable=False)  # 'agent', 'customer', 'enterprise'
    display_name = Column(String(255), nullable=False)
    description = Column(Text)
    price_monthly = Column(DECIMAL(10, 2))
    price_yearly = Column(DECIMAL(10, 2))
    currency = Column(String(3), default="INR")
    features = Column(JSON)  # Array of feature names included
    limitations = Column(JSON)  # Usage limits and restrictions
    max_users = Column(Integer)
    max_storage_gb = Column(Integer)
    max_policies = Column(Integer)
    is_active = Column(Boolean, default=True)
    is_popular = Column(Boolean, default=False)
    sort_order = Column(Integer, default=0)
    trial_days = Column(Integer, default=14)

    # Payment gateway IDs
    stripe_price_id_monthly = Column(String(255))
    stripe_price_id_yearly = Column(String(255))
    razorpay_plan_id_monthly = Column(String(255))
    razorpay_plan_id_yearly = Column(String(255))

    # Relationships
    subscriptions = relationship("UserSubscription", back_populates="plan")

    def __repr__(self):
        return f"<SubscriptionPlan(plan_id='{self.plan_id}', name='{self.plan_name}', type='{self.plan_type}')>"


class UserSubscription(Base, TimestampMixin, AuditMixin):
    """User subscription records"""

    __tablename__ = "user_subscriptions"
    __table_args__ = {'schema': 'lic_schema'}

    subscription_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    plan_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.subscription_plans.plan_id"), nullable=False)
    billing_cycle = Column(String(20), default="monthly")  # 'monthly', 'yearly'
    status = Column(String(50), default="active")  # 'active', 'past_due', 'canceled', 'incomplete'

    # Period tracking
    current_period_start = Column(DateTime)
    current_period_end = Column(DateTime)
    trial_start = Column(DateTime)
    trial_end = Column(DateTime)

    # Cancellation
    cancel_at_period_end = Column(Boolean, default=False)
    canceled_at = Column(DateTime)

    # Payment gateway IDs
    stripe_subscription_id = Column(String(255))
    razorpay_subscription_id = Column(String(255))
    payment_method_id = Column(String(255))

    # Billing info
    last_payment_date = Column(DateTime)
    next_payment_date = Column(DateTime)
    amount = Column(DECIMAL(10, 2))
    currency = Column(String(3), default="INR")
    discount_amount = Column(DECIMAL(10, 2), default=0)
    tax_amount = Column(DECIMAL(10, 2), default=0)

    # Relationships
    user = relationship("User", back_populates="subscriptions")
    plan = relationship("SubscriptionPlan", back_populates="subscriptions")
    billing_history = relationship("SubscriptionBillingHistory", back_populates="subscription")
    changes = relationship("SubscriptionChange", back_populates="subscription")

    def __repr__(self):
        return f"<UserSubscription(subscription_id='{self.subscription_id}', user_id='{self.user_id}', status='{self.status}')>"


class SubscriptionBillingHistory(Base, TimestampMixin):
    """Billing history for subscriptions"""

    __tablename__ = "subscription_billing_history"
    __table_args__ = {'schema': 'lic_schema'}

    billing_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    subscription_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.user_subscriptions.subscription_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    amount = Column(DECIMAL(10, 2), nullable=False)
    currency = Column(String(3), default="INR")
    billing_date = Column(DateTime, server_default=func.now())
    billing_period_start = Column(DateTime)
    billing_period_end = Column(DateTime)
    payment_gateway = Column(String(50))  # 'stripe', 'razorpay', 'manual'
    gateway_transaction_id = Column(String(255))
    status = Column(String(50), default="paid")  # 'paid', 'failed', 'pending', 'refunded'
    invoice_url = Column(String(500))
    receipt_url = Column(String(500))
    failure_reason = Column(Text)
    metadata = Column(JSON)

    # Relationships
    subscription = relationship("UserSubscription", back_populates="billing_history")
    user = relationship("User", back_populates="billing_history")

    def __repr__(self):
        return f"<SubscriptionBillingHistory(billing_id='{self.billing_id}', amount={self.amount}, status='{self.status}')>"


class SubscriptionChange(Base, TimestampMixin):
    """Subscription change history (upgrades/downgrades)"""

    __tablename__ = "subscription_changes"
    __table_args__ = {'schema': 'lic_schema'}

    change_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    subscription_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.user_subscriptions.subscription_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    from_plan_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.subscription_plans.plan_id"))
    to_plan_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.subscription_plans.plan_id"), nullable=False)
    change_type = Column(String(50))  # 'upgrade', 'downgrade', 'plan_change'
    effective_date = Column(DateTime, server_default=func.now())
    proration_amount = Column(DECIMAL(10, 2))
    billing_cycle_change = Column(Boolean, default=False)
    initiated_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    reason = Column(Text)
    metadata = Column(JSON)

    # Relationships
    subscription = relationship("UserSubscription", back_populates="changes")
    user = relationship("User", back_populates="subscription_changes")
    from_plan = relationship("SubscriptionPlan", foreign_keys=[from_plan_id])
    to_plan = relationship("SubscriptionPlan", foreign_keys=[to_plan_id])
    initiator = relationship("User", foreign_keys=[initiated_by])

    def __repr__(self):
        return f"<SubscriptionChange(change_id='{self.change_id}', type='{self.change_type}', from_plan='{self.from_plan_id}', to_plan='{self.to_plan_id}')>"
