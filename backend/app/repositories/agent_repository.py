"""
Agent repository for database operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import Optional, List
from app.models.agent import Agent
from app.models.user import User
import uuid
from datetime import datetime


class AgentRepository:
    """Repository for agent-related database operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, agent_id) -> Optional[Agent]:
        """Get agent by ID (UUID or string)"""
        if isinstance(agent_id, str):
            try:
                agent_id = uuid.UUID(agent_id)
            except ValueError:
                return None
        return self.db.query(Agent).filter(Agent.agent_id == agent_id).first()

    def get_by_user_id(self, user_id) -> Optional[Agent]:
        """Get agent by user ID"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                return None
        return self.db.query(Agent).filter(Agent.user_id == user_id).first()

    def get_by_agent_code(self, agent_code: str) -> Optional[Agent]:
        """Get agent by agent code"""
        return self.db.query(Agent).filter(Agent.agent_code == agent_code).first()

    def get_by_license_number(self, license_number: str) -> Optional[Agent]:
        """Get agent by license number"""
        return self.db.query(Agent).filter(Agent.license_number == license_number).first()

    def get_all(self, status: Optional[str] = None) -> List[Agent]:
        """Get all agents, optionally filtered by status"""
        query = self.db.query(Agent)
        if status:
            query = query.filter(Agent.status == status)
        return query.order_by(Agent.created_at.desc()).all()

    def search_agents(self, filters: dict, limit: int = 20, offset: int = 0) -> List[Agent]:
        """Search and filter agents with pagination"""
        query = self.db.query(Agent).join(User, Agent.user_id == User.user_id)

        # Apply search filter
        if "search" in filters:
            search_term = f"%{filters['search']}%"
            query = query.filter(
                or_(
                    User.first_name.ilike(search_term),
                    User.last_name.ilike(search_term),
                    User.display_name.ilike(search_term),
                    User.email.ilike(search_term),
                    Agent.agent_code.ilike(search_term),
                    Agent.business_name.ilike(search_term)
                )
            )

        # Apply filters
        if "status" in filters:
            query = query.filter(Agent.status == filters["status"])

        if "verification_status" in filters:
            query = query.filter(Agent.verification_status == filters["verification_status"])

        if "territory" in filters:
            query = query.filter(Agent.territory == filters["territory"])

        if "provider_id" in filters:
            provider_id = filters["provider_id"]
            if isinstance(provider_id, str):
                try:
                    provider_id = uuid.UUID(provider_id)
                except ValueError:
                    pass
            query = query.filter(Agent.provider_id == provider_id)

        # Apply ordering
        query = query.order_by(Agent.created_at.desc())

        # Apply pagination
        return query.limit(limit).offset(offset).all()

    def create(self, agent_data: dict) -> Agent:
        """Create a new agent"""
        agent = Agent(
            agent_id=uuid.uuid4(),
            user_id=agent_data.get("user_id"),
            provider_id=agent_data.get("provider_id"),
            agent_code=agent_data.get("agent_code"),
            license_number=agent_data.get("license_number"),
            license_expiry_date=agent_data.get("license_expiry_date"),
            license_issuing_authority=agent_data.get("license_issuing_authority"),
            business_name=agent_data.get("business_name"),
            business_address=agent_data.get("business_address"),
            gst_number=agent_data.get("gst_number"),
            pan_number=agent_data.get("pan_number"),
            territory=agent_data.get("territory"),
            operating_regions=agent_data.get("operating_regions"),
            experience_years=agent_data.get("experience_years"),
            specializations=agent_data.get("specializations"),
            commission_rate=agent_data.get("commission_rate"),
            commission_structure=agent_data.get("commission_structure"),
            performance_bonus_structure=agent_data.get("performance_bonus_structure"),
            whatsapp_business_number=agent_data.get("whatsapp_business_number"),
            business_email=agent_data.get("business_email"),
            website=agent_data.get("website"),
            status=agent_data.get("status", "active"),
            verification_status=agent_data.get("verification_status", "pending")
        )
        self.db.add(agent)
        self.db.commit()
        self.db.refresh(agent)
        return agent

    def update(self, agent_id, agent_data: dict) -> Optional[Agent]:
        """Update agent information"""
        agent = self.get_by_id(agent_id)
        if not agent:
            return None

        # Update fields
        updateable_fields = [
            'provider_id', 'license_number', 'license_expiry_date', 'license_issuing_authority',
            'business_name', 'business_address', 'gst_number', 'pan_number', 'territory',
            'operating_regions', 'experience_years', 'specializations', 'commission_rate',
            'commission_structure', 'performance_bonus_structure', 'whatsapp_business_number',
            'business_email', 'website', 'status', 'verification_status', 'approved_at', 'approved_by'
        ]

        for field in updateable_fields:
            if field in agent_data:
                setattr(agent, field, agent_data[field])

        # Update performance metrics if provided
        performance_fields = ['total_policies_sold', 'total_premium_collected',
                            'active_policyholders', 'customer_satisfaction_score']
        for field in performance_fields:
            if field in agent_data:
                setattr(agent, field, agent_data[field])

        self.db.commit()
        self.db.refresh(agent)
        return agent

    def delete(self, agent_id) -> bool:
        """Delete agent (soft delete by setting status to inactive)"""
        agent = self.get_by_id(agent_id)
        if not agent:
            return False

        # Soft delete
        agent.status = 'inactive'
        self.db.commit()
        return True

    def approve_agent(self, agent_id, approved_by: str) -> bool:
        """Approve agent verification"""
        agent = self.get_by_id(agent_id)
        if not agent:
            return False

        agent.verification_status = 'approved'
        agent.approved_at = datetime.utcnow()
        if approved_by:
            try:
                agent.approved_by = uuid.UUID(approved_by)
            except ValueError:
                pass

        self.db.commit()
        return True

    def reject_agent(self, agent_id) -> bool:
        """Reject agent verification"""
        agent = self.get_by_id(agent_id)
        if not agent:
            return False

        agent.verification_status = 'rejected'
        self.db.commit()
        return True

    def get_agents_by_provider(self, provider_id, status: Optional[str] = None) -> List[Agent]:
        """Get agents by insurance provider"""
        if isinstance(provider_id, str):
            try:
                provider_id = uuid.UUID(provider_id)
            except ValueError:
                return []

        query = self.db.query(Agent).filter(Agent.provider_id == provider_id)
        if status:
            query = query.filter(Agent.status == status)

        return query.order_by(Agent.created_at.desc()).all()

    def get_agents_by_territory(self, territory: str, status: Optional[str] = None) -> List[Agent]:
        """Get agents by territory"""
        query = self.db.query(Agent).filter(Agent.territory == territory)
        if status:
            query = query.filter(Agent.status == status)

        return query.order_by(Agent.created_at.desc()).all()

    def get_pending_verification_agents(self) -> List[Agent]:
        """Get agents pending verification"""
        return self.db.query(Agent).filter(
            Agent.verification_status == 'pending'
        ).order_by(Agent.created_at.desc()).all()