"""
Lead Management API Endpoints
=============================

API endpoints for:
- Comprehensive lead CRUD operations
- Lead qualification and conversion tracking
- Lead interaction management
- Lead analytics and scoring
"""

import logging
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, validator
from datetime import datetime
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context, require_permission
from app.repositories.lead_repository import LeadRepository, LeadInteractionRepository
from app.models.user import User
from app.models.lead import Lead, LeadInteraction

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/leads", tags=["leads"])


# Pydantic models for API
class LeadCreateRequest(BaseModel):
    """Request model for creating a new lead"""
    customer_name: str
    contact_number: str
    email: Optional[str] = None
    location: Optional[str] = None
    lead_source: str
    priority: Optional[str] = "medium"
    insurance_type: Optional[str] = None
    budget_range: Optional[str] = None
    coverage_required: Optional[float] = None
    agent_id: Optional[str] = None  # Will be set to current user's agent if not provided

    @validator('lead_source')
    def validate_lead_source(cls, v):
        valid_sources = ['website', 'referral', 'cold_call', 'social_media', 'email_campaign',
                        'whatsapp_campaign', 'event', 'partner', 'walk_in', 'other']
        if v not in valid_sources:
            raise ValueError(f'Lead source must be one of: {", ".join(valid_sources)}')
        return v

    @validator('priority')
    def validate_priority(cls, v):
        valid_priorities = ['high', 'medium', 'low']
        if v not in valid_priorities:
            raise ValueError(f'Priority must be one of: {", ".join(valid_priorities)}')
        return v


class LeadUpdateRequest(BaseModel):
    """Request model for updating a lead"""
    customer_name: Optional[str] = None
    contact_number: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None
    lead_source: Optional[str] = None
    priority: Optional[str] = None
    insurance_type: Optional[str] = None
    budget_range: Optional[str] = None
    coverage_required: Optional[float] = None

    @validator('lead_source')
    def validate_lead_source(cls, v):
        if v is None:
            return v
        valid_sources = ['website', 'referral', 'cold_call', 'social_media', 'email_campaign',
                        'whatsapp_campaign', 'event', 'partner', 'walk_in', 'other']
        if v not in valid_sources:
            raise ValueError(f'Lead source must be one of: {", ".join(valid_sources)}')
        return v

    @validator('priority')
    def validate_priority(cls, v):
        if v is None:
            return v
        valid_priorities = ['high', 'medium', 'low']
        if v not in valid_priorities:
            raise ValueError(f'Priority must be one of: {", ".join(valid_priorities)}')
        return v


class LeadResponse(BaseModel):
    """Response model for lead data"""
    lead_id: str
    agent_id: Optional[str]
    customer_name: str
    contact_number: str
    email: Optional[str]
    location: Optional[str]
    lead_source: str
    lead_status: str
    priority: str
    insurance_type: Optional[str]
    budget_range: Optional[str]
    coverage_required: Optional[float]
    conversion_score: float
    engagement_score: float
    potential_premium: float
    is_qualified: bool
    qualification_notes: Optional[str]
    disqualification_reason: Optional[str]
    created_at: str
    first_contact_at: Optional[str]
    last_contact_at: Optional[str]
    last_contact_method: Optional[str]
    next_followup_at: Optional[str]
    followup_count: int
    converted_at: Optional[str]
    converted_policy_id: Optional[str]
    conversion_value: Optional[float]

    class Config:
        from_attributes = True


class LeadSummaryResponse(BaseModel):
    """Summary response for lead listings"""
    lead_id: str
    customer_name: str
    contact_number: str
    email: Optional[str]
    lead_source: str
    lead_status: str
    priority: str
    insurance_type: Optional[str]
    created_at: str
    last_contact_at: Optional[str]
    agent_name: Optional[str]

    class Config:
        from_attributes = True


class LeadQualifyRequest(BaseModel):
    """Request model for lead qualification"""
    is_qualified: bool
    qualification_notes: Optional[str] = None
    disqualification_reason: Optional[str] = None


class LeadConvertRequest(BaseModel):
    """Request model for lead conversion"""
    converted_policy_id: str
    conversion_value: Optional[float] = None


class LeadInteractionCreateRequest(BaseModel):
    """Request model for creating lead interaction"""
    interaction_type: str
    interaction_method: Optional[str] = None
    duration_minutes: Optional[int] = None
    outcome: Optional[str] = None
    notes: Optional[str] = None
    next_action: Optional[str] = None
    next_action_date: Optional[datetime] = None

    @validator('interaction_type')
    def validate_interaction_type(cls, v):
        valid_types = ['call', 'email', 'whatsapp', 'meeting', 'visit', 'sms', 'social_media', 'other']
        if v not in valid_types:
            raise ValueError(f'Interaction type must be one of: {", ".join(valid_types)}')
        return v

    @validator('interaction_method')
    def validate_interaction_method(cls, v):
        if v is None:
            return v
        valid_methods = ['inbound', 'outbound']
        if v not in valid_methods:
            raise ValueError(f'Interaction method must be one of: {", ".join(valid_methods)}')
        return v


class LeadInteractionResponse(BaseModel):
    """Response model for lead interaction"""
    interaction_id: str
    lead_id: str
    agent_id: Optional[str]
    interaction_type: str
    interaction_method: Optional[str]
    duration_minutes: Optional[int]
    outcome: Optional[str]
    notes: Optional[str]
    next_action: Optional[str]
    next_action_date: Optional[str]
    created_at: str

    class Config:
        from_attributes = True


@router.post("/", response_model=LeadResponse)
async def create_lead(
    lead_data: LeadCreateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Create a new lead

    - **customer_name**: Full name of the potential customer
    - **contact_number**: Phone number for contact
    - **email**: Email address (optional)
    - **location**: Customer location (optional)
    - **lead_source**: How the lead was generated
    - **priority**: Lead priority level (high/medium/low)
    - **insurance_type**: Type of insurance interested in (optional)
    - **budget_range**: Budget range for insurance (optional)
    - **coverage_required**: Required coverage amount (optional)
    """
    try:
        lead_repo = LeadRepository(db)

        # Prepare lead data
        lead_dict = lead_data.dict()

        # If no agent_id provided, assign to current user's agent (if they are an agent)
        if not lead_dict.get("agent_id"):
            # Check if current user is an agent
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            agent = agent_repo.get_by_user_id(str(current_user.user_id))
            if agent:
                lead_dict["agent_id"] = str(agent.agent_id)

        # Set audit fields
        lead_dict["created_by"] = str(current_user.user_id)

        # Create lead
        lead = lead_repo.create(lead_dict)

        return LeadResponse(
            lead_id=str(lead.lead_id),
            agent_id=str(lead.agent_id) if lead.agent_id else None,
            customer_name=lead.customer_name,
            contact_number=lead.contact_number,
            email=lead.email,
            location=lead.location,
            lead_source=lead.lead_source,
            lead_status=lead.lead_status,
            priority=lead.priority,
            insurance_type=lead.insurance_type,
            budget_range=lead.budget_range,
            coverage_required=lead.coverage_required,
            conversion_score=lead.conversion_score or 0,
            engagement_score=lead.engagement_score or 0,
            potential_premium=lead.potential_premium or 0,
            is_qualified=lead.is_qualified or False,
            qualification_notes=lead.qualification_notes,
            disqualification_reason=lead.disqualification_reason,
            created_at=lead.created_at.isoformat(),
            first_contact_at=lead.first_contact_at.isoformat() if lead.first_contact_at else None,
            last_contact_at=lead.last_contact_at.isoformat() if lead.last_contact_at else None,
            last_contact_method=lead.last_contact_method,
            next_followup_at=lead.next_followup_at.isoformat() if lead.next_followup_at else None,
            followup_count=lead.followup_count or 0,
            converted_at=lead.converted_at.isoformat() if lead.converted_at else None,
            converted_policy_id=str(lead.converted_policy_id) if lead.converted_policy_id else None,
            conversion_value=lead.conversion_value
        )

    except Exception as e:
        logger.error(f"Failed to create lead: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to create lead: {str(e)}")


@router.get("/", response_model=Dict[str, Any])
async def list_leads(
    agent_id: Optional[str] = Query(None, description="Filter by agent ID"),
    status: Optional[str] = Query(None, description="Filter by lead status"),
    priority: Optional[str] = Query(None, description="Filter by priority"),
    lead_source: Optional[str] = Query(None, description="Filter by lead source"),
    insurance_type: Optional[str] = Query(None, description="Filter by insurance type"),
    search: Optional[str] = Query(None, description="Search in customer name, phone, email"),
    created_from: Optional[datetime] = Query(None, description="Created from date"),
    created_to: Optional[datetime] = Query(None, description="Created to date"),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    List leads with filtering and pagination

    - **agent_id**: Filter by specific agent
    - **status**: Filter by lead status (new, contacted, qualified, quoted, converted, lost, inactive)
    - **priority**: Filter by priority (high, medium, low)
    - **lead_source**: Filter by lead source
    - **insurance_type**: Filter by insurance type
    - **search**: Search in customer name, phone, email
    - **created_from/to**: Date range filters
    - **limit/offset**: Pagination parameters
    """
    try:
        lead_repo = LeadRepository(db)

        # Build filters
        filters = {}
        if agent_id:
            filters["agent_id"] = agent_id
        if status:
            filters["status"] = status
        if priority:
            filters["priority"] = priority
        if lead_source:
            filters["lead_source"] = lead_source
        if insurance_type:
            filters["insurance_type"] = insurance_type
        if search:
            filters["search"] = search
        if created_from:
            filters["created_from"] = created_from
        if created_to:
            filters["created_to"] = created_to

        # Get leads
        leads = lead_repo.get_all(filters=filters, limit=limit, offset=offset)

        # Convert to response format
        lead_summaries = []
        for lead in leads:
            agent_name = None
            if lead.agent and lead.agent.user:
                agent_name = f"{lead.agent.user.first_name or ''} {lead.agent.user.last_name or ''}".strip()

            summary = LeadSummaryResponse(
                lead_id=str(lead.lead_id),
                customer_name=lead.customer_name,
                contact_number=lead.contact_number,
                email=lead.email,
                lead_source=lead.lead_source,
                lead_status=lead.lead_status,
                priority=lead.priority,
                insurance_type=lead.insurance_type,
                created_at=lead.created_at.isoformat(),
                last_contact_at=lead.last_contact_at.isoformat() if lead.last_contact_at else None,
                agent_name=agent_name
            )
            lead_summaries.append(summary)

        return {
            "success": True,
            "data": {
                "leads": [summary.dict() for summary in lead_summaries],
                "total": len(lead_summaries),
                "limit": limit,
                "offset": offset
            }
        }

    except Exception as e:
        logger.error(f"Failed to list leads: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to list leads: {str(e)}")


@router.get("/{lead_id}", response_model=LeadResponse)
async def get_lead(
    lead_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get lead by ID

    - **lead_id**: Lead identifier
    """
    try:
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions - users can only see leads they own or admin permissions
        if lead.agent_id:
            # Get current user's agent ID
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            current_agent = agent_repo.get_by_user_id(str(current_user.user_id))

            if not current_agent or str(lead.agent_id) != str(current_agent.agent_id):
                # Check if user has permission to view other leads
                if not current_user.has_permission("leads.read"):
                    raise HTTPException(status_code=403, detail="Access denied. You can only view your own leads.")

        return LeadResponse(
            lead_id=str(lead.lead_id),
            agent_id=str(lead.agent_id) if lead.agent_id else None,
            customer_name=lead.customer_name,
            contact_number=lead.contact_number,
            email=lead.email,
            location=lead.location,
            lead_source=lead.lead_source,
            lead_status=lead.lead_status,
            priority=lead.priority,
            insurance_type=lead.insurance_type,
            budget_range=lead.budget_range,
            coverage_required=lead.coverage_required,
            conversion_score=lead.conversion_score or 0,
            engagement_score=lead.engagement_score or 0,
            potential_premium=lead.potential_premium or 0,
            is_qualified=lead.is_qualified or False,
            qualification_notes=lead.qualification_notes,
            disqualification_reason=lead.disqualification_reason,
            created_at=lead.created_at.isoformat(),
            first_contact_at=lead.first_contact_at.isoformat() if lead.first_contact_at else None,
            last_contact_at=lead.last_contact_at.isoformat() if lead.last_contact_at else None,
            last_contact_method=lead.last_contact_method,
            next_followup_at=lead.next_followup_at.isoformat() if lead.next_followup_at else None,
            followup_count=lead.followup_count or 0,
            converted_at=lead.converted_at.isoformat() if lead.converted_at else None,
            converted_policy_id=str(lead.converted_policy_id) if lead.converted_policy_id else None,
            conversion_value=lead.conversion_value
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to get lead: {str(e)}")


@router.put("/{lead_id}", response_model=LeadResponse)
async def update_lead(
    lead_id: str,
    lead_data: LeadUpdateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update lead information

    - **lead_id**: Lead identifier
    """
    try:
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id:
            # Get current user's agent ID
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            current_agent = agent_repo.get_by_user_id(str(current_user.user_id))

            if not current_agent or str(lead.agent_id) != str(current_agent.agent_id):
                # Check if user has permission to update other leads
                if not current_user.has_permission("leads.update"):
                    raise HTTPException(status_code=403, detail="Access denied. You can only update your own leads.")

        # Update lead
        update_data = lead_data.dict(exclude_unset=True)
        update_data["updated_by"] = str(current_user.user_id)

        updated_lead = lead_repo.update(lead_id, update_data)
        if not updated_lead:
            raise HTTPException(status_code=500, detail="Failed to update lead")

        return await get_lead(lead_id, current_user, db)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to update lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to update lead: {str(e)}")


@router.delete("/{lead_id}")
async def delete_lead(
    lead_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Delete lead (soft delete)

    - **lead_id**: Lead identifier
    """
    try:
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id and str(lead.agent_id) != str(current_user.user_id):
            if not current_user.has_permission("leads.delete"):
                raise HTTPException(status_code=403, detail="Access denied. You can only delete your own leads.")

        # Soft delete
        success = lead_repo.delete(lead_id)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to delete lead")

        return {
            "success": True,
            "message": "Lead deleted successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to delete lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to delete lead: {str(e)}")


@router.put("/{lead_id}/qualify")
async def qualify_lead(
    lead_id: str,
    qualify_data: LeadQualifyRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Qualify or disqualify a lead

    - **lead_id**: Lead identifier
    - **is_qualified**: Whether the lead is qualified
    - **qualification_notes**: Notes for qualified leads
    - **disqualification_reason**: Reason for disqualification
    """
    try:
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id:
            # Get current user's agent ID
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            current_agent = agent_repo.get_by_user_id(str(current_user.user_id))

            if not current_agent or str(lead.agent_id) != str(current_agent.agent_id):
                # Check if user has permission to update other leads
                if not current_user.has_permission("leads.update"):
                    raise HTTPException(status_code=403, detail="Access denied. You can only qualify your own leads.")

        # Qualify/disqualify lead
        updated_lead = lead_repo.qualify_lead(
            lead_id,
            qualify_data.is_qualified,
            qualify_data.qualification_notes,
            qualify_data.disqualification_reason
        )

        if not updated_lead:
            raise HTTPException(status_code=500, detail="Failed to qualify lead")

        return {
            "success": True,
            "message": f"Lead {'qualified' if qualify_data.is_qualified else 'disqualified'} successfully",
            "data": {
                "is_qualified": updated_lead.is_qualified,
                "qualification_notes": updated_lead.qualification_notes,
                "disqualification_reason": updated_lead.disqualification_reason
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to qualify lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to qualify lead: {str(e)}")


@router.put("/{lead_id}/convert")
async def convert_lead(
    lead_id: str,
    convert_data: LeadConvertRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Convert lead to policy

    - **lead_id**: Lead identifier
    - **converted_policy_id**: ID of the policy created from this lead
    - **conversion_value**: Value of the conversion (optional)
    """
    try:
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id and str(lead.agent_id) != str(current_user.user_id):
            if not current_user.has_permission("leads.update"):
                raise HTTPException(status_code=403, detail="Access denied. You can only convert your own leads.")

        # Convert lead
        updated_lead = lead_repo.convert_lead(
            lead_id,
            convert_data.converted_policy_id,
            convert_data.conversion_value
        )

        if not updated_lead:
            raise HTTPException(status_code=500, detail="Failed to convert lead")

        return {
            "success": True,
            "message": "Lead converted successfully",
            "data": {
                "lead_status": updated_lead.lead_status,
                "converted_at": updated_lead.converted_at.isoformat(),
                "converted_policy_id": str(updated_lead.converted_policy_id),
                "conversion_value": updated_lead.conversion_value
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to convert lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to convert lead: {str(e)}")


@router.post("/{lead_id}/interactions", response_model=LeadInteractionResponse)
async def create_lead_interaction(
    lead_id: str,
    interaction_data: LeadInteractionCreateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Add interaction to a lead

    - **lead_id**: Lead identifier
    """
    try:
        # Verify lead exists and user has access
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id:
            # Get current user's agent ID
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            current_agent = agent_repo.get_by_user_id(str(current_user.user_id))

            if not current_agent or str(lead.agent_id) != str(current_agent.agent_id):
                # Check if user has permission to update other leads
                if not current_user.has_permission("leads.update"):
                    raise HTTPException(status_code=403, detail="Access denied. You can only add interactions to your own leads.")

        # Get agent ID for the interaction
        agent_id = None
        if lead.agent_id:
            agent_id = str(lead.agent_id)

        # Create interaction
        interaction_repo = LeadInteractionRepository(db)
        interaction_dict = interaction_data.dict()
        interaction_dict["lead_id"] = lead_id
        interaction_dict["agent_id"] = agent_id

        interaction = interaction_repo.create(interaction_dict)

        return LeadInteractionResponse(
            interaction_id=str(interaction.interaction_id),
            lead_id=str(interaction.lead_id),
            agent_id=str(interaction.agent_id) if interaction.agent_id else None,
            interaction_type=interaction.interaction_type,
            interaction_method=interaction.interaction_method,
            duration_minutes=interaction.duration_minutes,
            outcome=interaction.outcome,
            notes=interaction.notes,
            next_action=interaction.next_action,
            next_action_date=interaction.next_action_date.isoformat() if interaction.next_action_date else None,
            created_at=interaction.created_at.isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to create interaction for lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to create interaction: {str(e)}")


@router.get("/{lead_id}/interactions")
async def get_lead_interactions(
    lead_id: str,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get interactions for a lead

    - **lead_id**: Lead identifier
    - **limit/offset**: Pagination parameters
    """
    try:
        # Verify lead exists and user has access
        lead_repo = LeadRepository(db)
        lead = lead_repo.get_by_id(lead_id)

        if not lead:
            raise HTTPException(status_code=404, detail="Lead not found")

        # Check permissions
        if lead.agent_id:
            # Get current user's agent ID
            from app.repositories.agent_repository import AgentRepository
            agent_repo = AgentRepository(db)
            current_agent = agent_repo.get_by_user_id(str(current_user.user_id))

            if not current_agent or str(lead.agent_id) != str(current_agent.agent_id):
                # Check if user has permission to view other leads
                if not current_user.has_permission("leads.read"):
                    raise HTTPException(status_code=403, detail="Access denied. You can only view interactions for your own leads.")

        # Get interactions
        interaction_repo = LeadInteractionRepository(db)
        interactions = interaction_repo.get_by_lead(lead_id, limit=limit, offset=offset)

        # Convert to response format
        interaction_responses = []
        for interaction in interactions:
            response = LeadInteractionResponse(
                interaction_id=str(interaction.interaction_id),
                lead_id=str(interaction.lead_id),
                agent_id=str(interaction.agent_id) if interaction.agent_id else None,
                interaction_type=interaction.interaction_type,
                interaction_method=interaction.interaction_method,
                duration_minutes=interaction.duration_minutes,
                outcome=interaction.outcome,
                notes=interaction.notes,
                next_action=interaction.next_action,
                next_action_date=interaction.next_action_date.isoformat() if interaction.next_action_date else None,
                created_at=interaction.created_at.isoformat()
            )
            interaction_responses.append(response)

        return {
            "success": True,
            "data": {
                "interactions": [resp.dict() for resp in interaction_responses],
                "total": len(interaction_responses),
                "limit": limit,
                "offset": offset
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get interactions for lead {lead_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to get interactions: {str(e)}")
