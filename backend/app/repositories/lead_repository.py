"""
Lead repository for database operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func
from typing import Optional, List, Dict, Any
from datetime import datetime
from app.models.lead import Lead, LeadInteraction
from app.models.user import User
import uuid


class LeadRepository:
    """Repository for lead operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, lead_id) -> Optional[Lead]:
        """Get lead by ID"""
        if isinstance(lead_id, str):
            try:
                lead_id = uuid.UUID(lead_id)
            except ValueError:
                return None
        return self.db.query(Lead).filter(Lead.lead_id == lead_id).first()

    def get_by_agent(self, agent_id, status: Optional[str] = None, limit: int = 20, offset: int = 0) -> List[Lead]:
        """Get leads by agent ID"""
        if isinstance(agent_id, str):
            try:
                agent_id = uuid.UUID(agent_id)
            except ValueError:
                return []

        query = self.db.query(Lead).filter(Lead.lead_id.isnot(None))  # Ensure not deleted

        # Filter by agent if specified
        if agent_id:
            query = query.filter(Lead.agent_id == agent_id)

        # Filter by status if specified
        if status:
            query = query.filter(Lead.lead_status == status)

        return query.order_by(Lead.created_at.desc()).limit(limit).offset(offset).all()

    def get_all(self, filters: Dict[str, Any] = None, limit: int = 20, offset: int = 0) -> List[Lead]:
        """Get all leads with optional filters"""
        query = self.db.query(Lead).filter(Lead.lead_id.isnot(None))  # Ensure not deleted

        if filters:
            # Agent filter
            if "agent_id" in filters:
                agent_id = filters["agent_id"]
                if isinstance(agent_id, str):
                    try:
                        agent_id = uuid.UUID(agent_id)
                    except ValueError:
                        pass
                query = query.filter(Lead.agent_id == agent_id)

            # Status filter
            if "status" in filters:
                query = query.filter(Lead.lead_status == filters["status"])

            # Priority filter
            if "priority" in filters:
                query = query.filter(Lead.priority == filters["priority"])

            # Lead source filter
            if "lead_source" in filters:
                query = query.filter(Lead.lead_source == filters["lead_source"])

            # Insurance type filter
            if "insurance_type" in filters:
                query = query.filter(Lead.insurance_type.ilike(f"%{filters['insurance_type']}%"))

            # Date range filters
            if "created_from" in filters:
                query = query.filter(Lead.created_at >= filters["created_from"])
            if "created_to" in filters:
                query = query.filter(Lead.created_at <= filters["created_to"])

            # Search by customer name or contact
            if "search" in filters:
                search_term = f"%{filters['search']}%"
                query = query.filter(
                    or_(
                        Lead.customer_name.ilike(search_term),
                        Lead.contact_number.ilike(search_term),
                        Lead.email.ilike(search_term)
                    )
                )

        return query.order_by(Lead.created_at.desc()).limit(limit).offset(offset).all()

    def create(self, lead_data: dict) -> Lead:
        """Create a new lead"""
        lead = Lead(
            agent_id=lead_data.get("agent_id"),
            customer_name=lead_data.get("customer_name"),
            contact_number=lead_data.get("contact_number"),
            email=lead_data.get("email"),
            location=lead_data.get("location"),
            lead_source=lead_data.get("lead_source"),
            lead_status=lead_data.get("lead_status", "new"),
            priority=lead_data.get("priority", "medium"),
            insurance_type=lead_data.get("insurance_type"),
            budget_range=lead_data.get("budget_range"),
            coverage_required=lead_data.get("coverage_required"),
            conversion_score=lead_data.get("conversion_score", 0),
            engagement_score=lead_data.get("engagement_score", 0),
            potential_premium=lead_data.get("potential_premium", 0),
            created_by=lead_data.get("created_by"),
            updated_by=lead_data.get("created_by")
        )

        self.db.add(lead)
        self.db.commit()
        self.db.refresh(lead)
        return lead

    def update(self, lead_id, lead_data: dict) -> Optional[Lead]:
        """Update lead"""
        lead = self.get_by_id(lead_id)
        if not lead:
            return None

        # Update fields
        update_fields = [
            'customer_name', 'contact_number', 'email', 'location', 'lead_source',
            'lead_status', 'priority', 'insurance_type', 'budget_range', 'coverage_required',
            'conversion_score', 'engagement_score', 'potential_premium', 'is_qualified',
            'qualification_notes', 'disqualification_reason', 'first_contact_at',
            'last_contact_at', 'last_contact_method', 'next_followup_at', 'followup_count',
            'response_time_hours', 'converted_at', 'converted_policy_id', 'conversion_value',
            'updated_by'
        ]

        for field in update_fields:
            if field in lead_data:
                setattr(lead, field, lead_data[field])

        lead.updated_at = datetime.utcnow()

        self.db.commit()
        self.db.refresh(lead)
        return lead

    def delete(self, lead_id) -> bool:
        """Soft delete lead (set lead_id to null or status to inactive)"""
        lead = self.get_by_id(lead_id)
        if not lead:
            return False

        # Soft delete by setting status to inactive
        lead.lead_status = "inactive"
        lead.updated_at = datetime.utcnow()

        self.db.commit()
        return True

    def qualify_lead(self, lead_id, is_qualified: bool, notes: str = None, reason: str = None) -> Optional[Lead]:
        """Qualify or disqualify a lead"""
        lead = self.get_by_id(lead_id)
        if not lead:
            return None

        lead.is_qualified = is_qualified
        if is_qualified:
            lead.qualification_notes = notes
            lead.disqualification_reason = None
        else:
            lead.qualification_notes = None
            lead.disqualification_reason = reason

        lead.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(lead)
        return lead

    def convert_lead(self, lead_id, policy_id: str, conversion_value: float = None) -> Optional[Lead]:
        """Convert lead to policy"""
        lead = self.get_by_id(lead_id)
        if not lead:
            return None

        if isinstance(policy_id, str):
            try:
                policy_id = uuid.UUID(policy_id)
            except ValueError:
                return None

        lead.lead_status = "converted"
        lead.converted_at = datetime.utcnow()
        lead.converted_policy_id = policy_id
        lead.conversion_value = conversion_value
        lead.updated_at = datetime.utcnow()

        self.db.commit()
        self.db.refresh(lead)
        return lead

    def get_lead_count_by_agent(self, agent_id) -> Dict[str, int]:
        """Get lead counts by status for an agent"""
        if isinstance(agent_id, str):
            try:
                agent_id = uuid.UUID(agent_id)
            except ValueError:
                return {}

        result = self.db.query(
            Lead.lead_status,
            func.count(Lead.lead_id).label('count')
        ).filter(
            Lead.agent_id == agent_id,
            Lead.lead_status != "inactive"
        ).group_by(Lead.lead_status).all()

        return {status: count for status, count in result}


class LeadInteractionRepository:
    """Repository for lead interaction operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, interaction_id) -> Optional[LeadInteraction]:
        """Get interaction by ID"""
        if isinstance(interaction_id, str):
            try:
                interaction_id = uuid.UUID(interaction_id)
            except ValueError:
                return None
        return self.db.query(LeadInteraction).filter(LeadInteraction.interaction_id == interaction_id).first()

    def get_by_lead(self, lead_id, limit: int = 50, offset: int = 0) -> List[LeadInteraction]:
        """Get interactions for a lead"""
        if isinstance(lead_id, str):
            try:
                lead_id = uuid.UUID(lead_id)
            except ValueError:
                return []

        return self.db.query(LeadInteraction).filter(
            LeadInteraction.lead_id == lead_id
        ).order_by(LeadInteraction.created_at.desc()).limit(limit).offset(offset).all()

    def create(self, interaction_data: dict) -> LeadInteraction:
        """Create a new interaction"""
        interaction = LeadInteraction(
            lead_id=interaction_data.get("lead_id"),
            agent_id=interaction_data.get("agent_id"),
            interaction_type=interaction_data.get("interaction_type"),
            interaction_method=interaction_data.get("interaction_method"),
            duration_minutes=interaction_data.get("duration_minutes"),
            outcome=interaction_data.get("outcome"),
            notes=interaction_data.get("notes"),
            next_action=interaction_data.get("next_action"),
            next_action_date=interaction_data.get("next_action_date")
        )

        self.db.add(interaction)
        self.db.commit()
        self.db.refresh(interaction)

        # Update lead's last contact information
        self._update_lead_contact_info(interaction.lead_id, interaction.interaction_type)

        return interaction

    def _update_lead_contact_info(self, lead_id, interaction_type: str):
        """Update lead's contact tracking information"""
        lead_repo = LeadRepository(self.db)
        lead = lead_repo.get_by_id(lead_id)
        if lead:
            lead.last_contact_at = datetime.utcnow()
            lead.last_contact_method = interaction_type
            lead.followup_count = (lead.followup_count or 0) + 1
            self.db.commit()
