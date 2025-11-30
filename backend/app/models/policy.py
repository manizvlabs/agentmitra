"""
Policy models - matching lic_schema database structure
"""
from sqlalchemy import Column, String, Boolean, Integer, Text, Date, TIMESTAMP, DECIMAL, JSON, func, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy import Enum as SQLEnum
import enum
from .base import Base, TimestampMixin


class PolicyStatusEnum(str, enum.Enum):
    """Policy status enumeration"""
    draft = "draft"
    pending_approval = "pending_approval"
    under_review = "under_review"
    medical_check = "medical_check"
    approved = "approved"
    active = "active"
    lapsed = "lapsed"
    surrendered = "surrendered"
    matured = "matured"
    cancelled = "cancelled"
    rejected = "rejected"


class Policyholder(Base, TimestampMixin):
    """Policyholder model matching lic_schema.policyholders"""
    __tablename__ = "policyholders"
    __table_args__ = {'schema': 'lic_schema'}

    policyholder_id = Column(UUID(as_uuid=True), primary_key=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id", ondelete="CASCADE"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"))

    # Personal information
    customer_id = Column(String(100))  # Provider-specific customer ID
    salutation = Column(String(10))
    marital_status = Column(String(20))
    occupation = Column(String(100))
    annual_income = Column(DECIMAL(12, 2))
    education_level = Column(String(50))

    # Risk profile and preferences
    risk_profile = Column(JSONB)  # Risk tolerance, investment preferences
    investment_horizon = Column(String(20))
    communication_preferences = Column(JSONB)  # Email, SMS, WhatsApp preferences
    marketing_consent = Column(Boolean, default=True)

    # Family information
    family_members = Column(JSONB)  # Spouse, children, dependents
    nominee_details = Column(JSONB)

    # Financial information
    bank_details = Column(JSONB)  # Encrypted sensitive data
    investment_portfolio = Column(JSONB)

    # Behavioral data
    preferred_contact_time = Column(String(20))  # 'morning', 'afternoon', 'evening'
    preferred_language = Column(String(10), default='en')
    digital_literacy_score = Column(Integer)  # 1-10 scale
    engagement_score = Column(DECIMAL(3, 2))  # Calculated engagement metric

    # Status and lifecycle
    onboarding_status = Column(String(50), default='completed')
    churn_risk_score = Column(DECIMAL(3, 2))
    last_interaction_at = Column(TIMESTAMP)
    total_interactions = Column(Integer, default=0)

    # Relationships
    user = relationship("User", foreign_keys=[user_id])
    agent = relationship("Agent", foreign_keys=[agent_id])
    policies = relationship("InsurancePolicy", back_populates="policyholder")

    def __repr__(self):
        return f"<Policyholder(policyholder_id={self.policyholder_id}, user_id={self.user_id})>"


class InsurancePolicy(Base, TimestampMixin):
    """Insurance policy model matching lic_schema.insurance_policies"""
    __tablename__ = "insurance_policies"
    __table_args__ = {'schema': 'lic_schema'}

    policy_id = Column(UUID(as_uuid=True), primary_key=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)
    policy_number = Column(String(100), unique=True, nullable=False)
    provider_policy_id = Column(String(100))  # Provider's internal ID

    # Relationships
    policyholder_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.policyholders.policyholder_id"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"), nullable=False)
    provider_id = Column(UUID(as_uuid=True), ForeignKey("insurance_providers.provider_id"), nullable=False)

    # Policy details
    policy_type = Column(String(100), nullable=False)  # 'term_life', 'whole_life', 'ulip', etc.
    plan_name = Column(String(255), nullable=False)
    plan_code = Column(String(50))
    category = Column(String(50))  # 'life', 'health', 'general'

    # Financial details
    sum_assured = Column(DECIMAL(15, 2), nullable=False)
    premium_amount = Column(DECIMAL(12, 2), nullable=False)
    premium_frequency = Column(String(20), nullable=False)  # 'monthly', 'quarterly', 'half_yearly', 'annual'
    premium_mode = Column(String(20))  # 'regular', 'single', 'limited_pay'

    # Dates
    application_date = Column(Date, nullable=False)
    approval_date = Column(Date)
    start_date = Column(Date, nullable=False)
    maturity_date = Column(Date)
    renewal_date = Column(Date)

    # Status and lifecycle
    status = Column(String, nullable=False)  # Using String to match enum type
    sub_status = Column(String(50))  # 'under_review', 'medical_check', 'approved', etc.
    payment_status = Column(String(50), default='pending')

    # Coverage details
    coverage_details = Column(JSONB)  # Riders, additional benefits
    exclusions = Column(JSONB)
    terms_and_conditions = Column(JSONB)

    # Documents
    policy_document_url = Column(String(500))
    application_form_url = Column(String(500))
    medical_reports = Column(JSONB)

    # Beneficiaries
    nominee_details = Column(JSONB)
    assignee_details = Column(JSONB)

    # Audit and tracking
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    approved_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))
    last_payment_date = Column(TIMESTAMP)
    next_payment_date = Column(TIMESTAMP)
    total_payments = Column(Integer, default=0)
    outstanding_amount = Column(DECIMAL(12, 2), default=0)

    # Relationships
    policyholder = relationship("Policyholder", back_populates="policies")
    agent = relationship("Agent", foreign_keys=[agent_id])
    provider = relationship("InsuranceProvider", foreign_keys=[provider_id])
    payments = relationship("PremiumPayment", back_populates="policy")

    def __repr__(self):
        return f"<InsurancePolicy(policy_id={self.policy_id}, policy_number={self.policy_number}, status={self.status})>"


class PremiumPayment(Base, TimestampMixin):
    """Premium payment model matching lic_schema.premium_payments"""
    __tablename__ = "premium_payments"
    __table_args__ = {'schema': 'lic_schema'}

    payment_id = Column(UUID(as_uuid=True), primary_key=True)
    policy_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.insurance_policies.policy_id"))
    policyholder_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.policyholders.policyholder_id"))

    # Payment details
    amount = Column(DECIMAL(12, 2), nullable=False)
    currency = Column(String(3), default='INR')
    payment_date = Column(TIMESTAMP, default=func.now())
    due_date = Column(TIMESTAMP)
    grace_period_days = Column(Integer, default=30)

    # Payment method
    payment_method = Column(String(50))  # 'upi', 'net_banking', 'credit_card', etc.
    payment_gateway = Column(String(50))  # 'razorpay', 'paytm', 'phonepe'
    gateway_transaction_id = Column(String(255))
    gateway_response = Column(JSONB)

    # Status tracking
    status = Column(String(50), default='pending')
    failure_reason = Column(Text)
    retry_count = Column(Integer, default=0)

    # Reconciliation
    reconciled = Column(Boolean, default=False)
    reconciled_at = Column(TIMESTAMP)
    reconciled_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"))

    # Additional metadata
    ip_address = Column(String(50))
    user_agent = Column(Text)
    device_info = Column(JSONB)

    # Relationships
    policy = relationship("InsurancePolicy", back_populates="payments")

    def __repr__(self):
        return f"<PremiumPayment(payment_id={self.payment_id}, amount={self.amount}, status={self.status})>"


class Commission(Base, TimestampMixin):
    """Commission tracking for agents"""
    __tablename__ = "commissions"
    __table_args__ = {'schema': 'lic_schema'}

    commission_id = Column(UUID(as_uuid=True), primary_key=True)
    tenant_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.tenants.tenant_id'), nullable=False)

    # Commission details
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"), nullable=False)
    policy_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.insurance_policies.policy_id"), nullable=False)
    payment_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.premium_payments.payment_id"), nullable=False)

    # Commission calculation
    commission_amount = Column(DECIMAL(10, 2), nullable=False)
    commission_rate = Column(DECIMAL(5, 2))  # Percentage
    commission_type = Column(String(20), nullable=False)  # 'first_year', 'renewal', 'bonus'

    # Payment status
    status = Column(String(20), default='pending')  # 'pending', 'paid', 'cancelled'
    paid_date = Column(TIMESTAMP)
    payment_reference = Column(String(255))

    # Audit
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now())

    # Relationships
    tenant = relationship("Tenant", backref="commissions")
    agent = relationship("Agent", backref="commissions")
    policy = relationship("InsurancePolicy", backref="commissions")
    payment = relationship("PremiumPayment", backref="commissions")

    @property
    def is_paid(self):
        """Check if commission has been paid"""
        return self.status == 'paid'

    def __repr__(self):
        return f"<Commission(commission_id={self.commission_id}, agent_id={self.agent_id}, amount={self.commission_amount}, status={self.status})>"
