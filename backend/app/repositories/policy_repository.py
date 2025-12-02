"""
Policy repository for database operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import Optional, List
from app.models.policy import Policyholder, InsurancePolicy, PremiumPayment
from app.models.user import User
import uuid
from datetime import datetime, date


class PolicyholderRepository:
    """Repository for policyholder operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, policyholder_id) -> Optional[Policyholder]:
        """Get policyholder by ID"""
        if isinstance(policyholder_id, str):
            try:
                policyholder_id = uuid.UUID(policyholder_id)
            except ValueError:
                return None
        return self.db.query(Policyholder).filter(Policyholder.policyholder_id == policyholder_id).first()

    def get_by_user_id(self, user_id) -> Optional[Policyholder]:
        """Get policyholder by user ID"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                return None
        return self.db.query(Policyholder).filter(Policyholder.user_id == user_id).first()

    def get_all(self, limit: int = 20, offset: int = 0) -> List[Policyholder]:
        """Get all policyholders with pagination"""
        return self.db.query(Policyholder).order_by(Policyholder.created_at.desc()).limit(limit).offset(offset).all()

    def create(self, policyholder_data: dict) -> Policyholder:
        """Create a new policyholder"""
        policyholder = Policyholder(
            user_id=policyholder_data.get("user_id"),
            agent_id=policyholder_data.get("agent_id"),
            customer_id=policyholder_data.get("customer_id"),
            salutation=policyholder_data.get("salutation"),
            marital_status=policyholder_data.get("marital_status"),
            occupation=policyholder_data.get("occupation"),
            annual_income=policyholder_data.get("annual_income"),
            education_level=policyholder_data.get("education_level"),
            risk_profile=policyholder_data.get("risk_profile"),
            investment_horizon=policyholder_data.get("investment_horizon"),
            communication_preferences=policyholder_data.get("communication_preferences"),
            marketing_consent=policyholder_data.get("marketing_consent", True),
            family_members=policyholder_data.get("family_members"),
            nominee_details=policyholder_data.get("nominee_details"),
            bank_details=policyholder_data.get("bank_details"),
            investment_portfolio=policyholder_data.get("investment_portfolio"),
            preferred_contact_time=policyholder_data.get("preferred_contact_time"),
            preferred_language=policyholder_data.get("preferred_language", "en"),
            digital_literacy_score=policyholder_data.get("digital_literacy_score"),
            engagement_score=policyholder_data.get("engagement_score"),
            onboarding_status=policyholder_data.get("onboarding_status", "completed"),
            churn_risk_score=policyholder_data.get("churn_risk_score")
        )
        self.db.add(policyholder)
        self.db.commit()
        self.db.refresh(policyholder)
        return policyholder

    def update(self, policyholder_id, policyholder_data: dict) -> Optional[Policyholder]:
        """Update policyholder information"""
        policyholder = self.get_by_id(policyholder_id)
        if not policyholder:
            return None

        # Update fields
        updateable_fields = [
            'agent_id', 'customer_id', 'salutation', 'marital_status', 'occupation',
            'annual_income', 'education_level', 'risk_profile', 'investment_horizon',
            'communication_preferences', 'marketing_consent', 'family_members',
            'nominee_details', 'bank_details', 'investment_portfolio',
            'preferred_contact_time', 'preferred_language', 'digital_literacy_score',
            'engagement_score', 'onboarding_status', 'churn_risk_score',
            'last_interaction_at', 'total_interactions'
        ]

        for field in updateable_fields:
            if field in policyholder_data:
                setattr(policyholder, field, policyholder_data[field])

        self.db.commit()
        self.db.refresh(policyholder)
        return policyholder

    def delete(self, policyholder_id) -> bool:
        """Delete policyholder"""
        policyholder = self.get_by_id(policyholder_id)
        if not policyholder:
            return False

        self.db.delete(policyholder)
        self.db.commit()
        return True

    def get_by_agent(self, agent_id, limit: int = 20, offset: int = 0) -> List[Policyholder]:
        """Get policyholders by agent ID"""
        if isinstance(agent_id, str):
            try:
                agent_id = uuid.UUID(agent_id)
            except ValueError:
                return []

        return self.db.query(Policyholder).filter(Policyholder.agent_id == agent_id).order_by(Policyholder.created_at.desc()).limit(limit).offset(offset).all()


class PolicyRepository:
    """Repository for insurance policy operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, policy_id) -> Optional[InsurancePolicy]:
        """Get policy by ID"""
        if isinstance(policy_id, str):
            try:
                policy_id = uuid.UUID(policy_id)
            except ValueError:
                return None
        return self.db.query(InsurancePolicy).filter(InsurancePolicy.policy_id == policy_id).first()

    def get_by_policy_number(self, policy_number: str) -> Optional[InsurancePolicy]:
        """Get policy by policy number"""
        return self.db.query(InsurancePolicy).filter(InsurancePolicy.policy_number == policy_number).first()

    def get_by_policyholder(self, policyholder_id, status: Optional[str] = None) -> List[InsurancePolicy]:
        """Get policies by policyholder"""
        if isinstance(policyholder_id, str):
            try:
                policyholder_id = uuid.UUID(policyholder_id)
            except ValueError:
                return []

        query = self.db.query(InsurancePolicy).filter(InsurancePolicy.policyholder_id == policyholder_id)
        if status:
            query = query.filter(InsurancePolicy.status == status)

        return query.order_by(InsurancePolicy.created_at.desc()).all()

    def get_by_agent(self, agent_id, status: Optional[str] = None) -> List[InsurancePolicy]:
        """Get policies by agent"""
        if isinstance(agent_id, str):
            try:
                agent_id = uuid.UUID(agent_id)
            except ValueError:
                return []

        query = self.db.query(InsurancePolicy).filter(InsurancePolicy.agent_id == agent_id)
        if status:
            query = query.filter(InsurancePolicy.status == status)

        return query.order_by(InsurancePolicy.created_at.desc()).all()

    def search_policies(self, filters: dict, limit: int = 20, offset: int = 0) -> List[InsurancePolicy]:
        """Search and filter policies"""
        query = self.db.query(InsurancePolicy).join(Policyholder, InsurancePolicy.policyholder_id == Policyholder.policyholder_id)

        # Apply filters
        if "policy_number" in filters:
            query = query.filter(InsurancePolicy.policy_number.ilike(f"%{filters['policy_number']}%"))

        if "policyholder_id" in filters:
            policyholder_id = filters["policyholder_id"]
            if isinstance(policyholder_id, str):
                try:
                    policyholder_id = uuid.UUID(policyholder_id)
                except ValueError:
                    pass
            query = query.filter(InsurancePolicy.policyholder_id == policyholder_id)

        if "agent_id" in filters:
            agent_id = filters["agent_id"]
            if isinstance(agent_id, str):
                try:
                    agent_id = uuid.UUID(agent_id)
                except ValueError:
                    pass
            query = query.filter(InsurancePolicy.agent_id == agent_id)

        if "provider_id" in filters:
            provider_id = filters["provider_id"]
            if isinstance(provider_id, str):
                try:
                    provider_id = uuid.UUID(provider_id)
                except ValueError:
                    pass
            query = query.filter(InsurancePolicy.provider_id == provider_id)

        if "status" in filters:
            query = query.filter(InsurancePolicy.status == filters["status"])

        if "policy_type" in filters:
            query = query.filter(InsurancePolicy.policy_type == filters["policy_type"])

        if "category" in filters:
            query = query.filter(InsurancePolicy.category == filters["category"])

        # Apply ordering
        query = query.order_by(InsurancePolicy.created_at.desc())

        # Apply pagination
        return query.limit(limit).offset(offset).all()

    def get_all(self, limit: int = 20, offset: int = 0) -> List[InsurancePolicy]:
        """Get all policies with pagination"""
        return self.db.query(InsurancePolicy)\
            .order_by(InsurancePolicy.created_at.desc())\
            .limit(limit)\
            .offset(offset)\
            .all()

    def create(self, policy_data: dict) -> InsurancePolicy:
        """Create a new insurance policy"""
        policy = InsurancePolicy(
            policy_number=policy_data.get("policy_number"),
            provider_policy_id=policy_data.get("provider_policy_id"),
            policyholder_id=policy_data.get("policyholder_id"),
            agent_id=policy_data.get("agent_id"),
            provider_id=policy_data.get("provider_id"),
            policy_type=policy_data.get("policy_type"),
            plan_name=policy_data.get("plan_name"),
            plan_code=policy_data.get("plan_code"),
            category=policy_data.get("category"),
            sum_assured=policy_data.get("sum_assured"),
            premium_amount=policy_data.get("premium_amount"),
            premium_frequency=policy_data.get("premium_frequency"),
            premium_mode=policy_data.get("premium_mode"),
            application_date=policy_data.get("application_date"),
            approval_date=policy_data.get("approval_date"),
            start_date=policy_data.get("start_date"),
            maturity_date=policy_data.get("maturity_date"),
            renewal_date=policy_data.get("renewal_date"),
            status=policy_data.get("status", "draft"),
            sub_status=policy_data.get("sub_status"),
            payment_status=policy_data.get("payment_status", "pending"),
            coverage_details=policy_data.get("coverage_details"),
            exclusions=policy_data.get("exclusions"),
            terms_and_conditions=policy_data.get("terms_and_conditions"),
            policy_document_url=policy_data.get("policy_document_url"),
            application_form_url=policy_data.get("application_form_url"),
            medical_reports=policy_data.get("medical_reports"),
            nominee_details=policy_data.get("nominee_details"),
            assignee_details=policy_data.get("assignee_details"),
            created_by=policy_data.get("created_by"),
            approved_by=policy_data.get("approved_by")
        )
        self.db.add(policy)
        self.db.commit()
        self.db.refresh(policy)
        return policy

    def update(self, policy_id, policy_data: dict) -> Optional[InsurancePolicy]:
        """Update policy information"""
        policy = self.get_by_id(policy_id)
        if not policy:
            return None

        # Update fields
        updateable_fields = [
            'provider_policy_id', 'policy_type', 'plan_name', 'plan_code', 'category',
            'sum_assured', 'premium_amount', 'premium_frequency', 'premium_mode',
            'approval_date', 'start_date', 'maturity_date', 'renewal_date',
            'status', 'sub_status', 'payment_status', 'coverage_details',
            'exclusions', 'terms_and_conditions', 'policy_document_url',
            'application_form_url', 'medical_reports', 'nominee_details',
            'assignee_details', 'approved_by', 'last_payment_date',
            'next_payment_date', 'total_payments', 'outstanding_amount'
        ]

        for field in updateable_fields:
            if field in policy_data:
                setattr(policy, field, policy_data[field])

        self.db.commit()
        self.db.refresh(policy)
        return policy

    def delete(self, policy_id) -> bool:
        """Delete policy (soft delete by setting status)"""
        policy = self.get_by_id(policy_id)
        if not policy:
            return False

        # Soft delete - set to cancelled status
        policy.status = 'cancelled'
        self.db.commit()
        return True

    def approve_policy(self, policy_id, approved_by: str) -> bool:
        """Approve a policy"""
        policy = self.get_by_id(policy_id)
        if not policy:
            return False

        policy.status = 'approved'
        policy.approval_date = date.today()
        if approved_by:
            try:
                policy.approved_by = uuid.UUID(approved_by)
            except ValueError:
                pass

        self.db.commit()
        return True

    def activate_policy(self, policy_id) -> bool:
        """Activate an approved policy"""
        policy = self.get_by_id(policy_id)
        if not policy or policy.status != 'approved':
            return False

        policy.status = 'active'
        self.db.commit()
        return True


class PaymentRepository:
    """Repository for premium payment operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, payment_id) -> Optional[PremiumPayment]:
        """Get payment by ID"""
        if isinstance(payment_id, str):
            try:
                payment_id = uuid.UUID(payment_id)
            except ValueError:
                return None
        return self.db.query(PremiumPayment).filter(PremiumPayment.payment_id == payment_id).first()

    def get_by_policy(self, policy_id) -> List[PremiumPayment]:
        """Get payments by policy ID"""
        if isinstance(policy_id, str):
            try:
                policy_id = uuid.UUID(policy_id)
            except ValueError:
                return []

        return self.db.query(PremiumPayment).filter(
            PremiumPayment.policy_id == policy_id
        ).order_by(PremiumPayment.payment_date.desc()).all()

    def create(self, payment_data: dict) -> PremiumPayment:
        """Create a new premium payment"""
        payment = PremiumPayment(
            policy_id=payment_data.get("policy_id"),
            policyholder_id=payment_data.get("policyholder_id"),
            amount=payment_data.get("amount"),
            payment_date=payment_data.get("payment_date"),
            due_date=payment_data.get("due_date"),
            payment_method=payment_data.get("payment_method"),
            transaction_id=payment_data.get("transaction_id"),
            payment_gateway=payment_data.get("payment_gateway"),
            status=payment_data.get("status", "pending"),
            failure_reason=payment_data.get("failure_reason"),
            payment_details=payment_data.get("payment_details"),
            receipt_url=payment_data.get("receipt_url"),
            processed_by=payment_data.get("processed_by")
        )
        self.db.add(payment)
        self.db.commit()
        self.db.refresh(payment)
        return payment

    def update_status(self, payment_id, status: str, failure_reason: Optional[str] = None) -> bool:
        """Update payment status"""
        payment = self.get_by_id(payment_id)
        if not payment:
            return False

        payment.status = status
        if failure_reason:
            payment.failure_reason = failure_reason

        self.db.commit()
        return True
