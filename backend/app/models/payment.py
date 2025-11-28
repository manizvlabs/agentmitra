"""
Payment Model
=============

Database models for payment processing and transactions.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, DECIMAL, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.models.base import Base, TimestampMixin, AuditMixin


class PaymentTransaction(Base, TimestampMixin, AuditMixin):
    """Premium payment model"""

    __tablename__ = "premium_payments"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    policy_id = Column(UUID(as_uuid=True), ForeignKey("insurance_policies.id"), nullable=False, index=True)
    amount = Column(DECIMAL(10, 2), nullable=False)
    currency = Column(String(3), nullable=False, default="INR")
    gateway = Column(String(50), nullable=False)  # razorpay, stripe, etc.
    gateway_order_id = Column(String(255), nullable=True)
    gateway_payment_id = Column(String(255), nullable=True, index=True)
    status = Column(String(50), nullable=False, default="pending")  # pending, completed, failed, refunded
    gateway_response = Column(JSON, nullable=True)
    processed_at = Column(DateTime(timezone=True), nullable=True)
    refund_amount = Column(DECIMAL(10, 2), nullable=True)
    refund_reason = Column(Text, nullable=True)
    refund_processed_at = Column(DateTime(timezone=True), nullable=True)

    def __repr__(self):
        return f"<PaymentTransaction(id={self.id}, policy_id={self.policy_id}, amount={self.amount}, status={self.status})>"


class PaymentRefund(Base, TimestampMixin, AuditMixin):
    """Payment refund model"""

    __tablename__ = "payment_refunds"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    payment_id = Column(UUID(as_uuid=True), ForeignKey("premium_payments.id"), nullable=False, index=True)
    refund_id = Column(String(255), nullable=False)  # Gateway refund ID
    amount = Column(DECIMAL(10, 2), nullable=False)
    reason = Column(Text, nullable=True)
    gateway = Column(String(50), nullable=False)
    status = Column(String(50), nullable=False, default="processed")  # processed, failed
    gateway_response = Column(JSON, nullable=True)

    def __repr__(self):
        return f"<PaymentRefund(id={self.id}, payment_id={self.payment_id}, amount={self.amount})>"
