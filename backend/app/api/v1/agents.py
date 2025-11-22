"""
Agent Management API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, Query, status
from pydantic import BaseModel, validator
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import (
    get_current_user_context,
    UserContext,
    require_permission,
    require_any_permission,
    require_role_level
)
from app.repositories.agent_repository import AgentRepository
from app.repositories.user_repository import UserRepository
from app.models.agent import Agent
from datetime import datetime, date

router = APIRouter()


class AgentResponse(BaseModel):
    agent_id: str
    user_id: str
    provider_id: Optional[str] = None
    agent_code: str
    license_number: Optional[str] = None
    license_expiry_date: Optional[date] = None
    license_issuing_authority: Optional[str] = None
    business_name: Optional[str] = None
    business_address: Optional[Dict[str, Any]] = None
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None
    territory: Optional[str] = None
    operating_regions: Optional[List[str]] = None
    experience_years: Optional[int] = None
    specializations: Optional[List[str]] = None
    commission_rate: Optional[float] = None
    whatsapp_business_number: Optional[str] = None
    business_email: Optional[str] = None
    website: Optional[str] = None
    total_policies_sold: Optional[int] = None
    total_premium_collected: Optional[float] = None
    active_policyholders: Optional[int] = None
    customer_satisfaction_score: Optional[float] = None
    status: str
    verification_status: str
    approved_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    # User information
    user_info: Optional[Dict[str, Any]] = None


class AgentCreateRequest(BaseModel):
    user_id: str
    provider_id: Optional[str] = None
    agent_code: str
    license_number: Optional[str] = None
    license_expiry_date: Optional[date] = None
    license_issuing_authority: Optional[str] = None
    business_name: Optional[str] = None
    business_address: Optional[Dict[str, Any]] = None
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None
    territory: Optional[str] = None
    operating_regions: Optional[List[str]] = None
    experience_years: Optional[int] = None
    specializations: Optional[List[str]] = None
    commission_rate: Optional[float] = None
    whatsapp_business_number: Optional[str] = None
    business_email: Optional[str] = None
    website: Optional[str] = None

    @validator('agent_code')
    def validate_agent_code(cls, v):
        if not v or not v.replace('-', '').replace('_', '').isalnum():
            raise ValueError('Agent code must be alphanumeric with hyphens/underscores')
        return v

    @validator('gst_number')
    def validate_gst(cls, v):
        if v and len(v) != 15:
            raise ValueError('GST number must be 15 characters')
        return v

    @validator('pan_number')
    def validate_pan(cls, v):
        if v and len(v) != 10:
            raise ValueError('PAN number must be 10 characters')
        return v


class AgentUpdateRequest(BaseModel):
    provider_id: Optional[str] = None
    license_number: Optional[str] = None
    license_expiry_date: Optional[date] = None
    license_issuing_authority: Optional[str] = None
    business_name: Optional[str] = None
    business_address: Optional[Dict[str, Any]] = None
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None
    territory: Optional[str] = None
    operating_regions: Optional[List[str]] = None
    experience_years: Optional[int] = None
    specializations: Optional[List[str]] = None
    commission_rate: Optional[float] = None
    whatsapp_business_number: Optional[str] = None
    business_email: Optional[str] = None
    website: Optional[str] = None
    status: Optional[str] = None


@router.get("/", response_model=List[AgentResponse])
async def get_agents(
    status_filter: Optional[str] = Query(None, alias="status", description="Filter by status"),
    verification_status: Optional[str] = Query(None, description="Filter by verification status"),
    territory: Optional[str] = Query(None, description="Filter by territory"),
    provider_id: Optional[str] = Query(None, description="Filter by provider ID"),
    search: Optional[str] = Query(None, description="Search by name, code, or business"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
    current_user: UserContext = Depends(require_any_permission(["agents.read", "agents.approve"])),
    db: Session = Depends(get_db)
):
    """
    Get all agents with filtering and search
    - Requires agents.read or agents.approve permission
    - Supports comprehensive filtering and search
    """
    agent_repo = AgentRepository(db)

    filters = {}
    if status_filter:
        filters["status"] = status_filter
    if verification_status:
        filters["verification_status"] = verification_status
    if territory:
        filters["territory"] = territory
    if provider_id:
        filters["provider_id"] = provider_id
    if search:
        filters["search"] = search

    agents = agent_repo.search_agents(filters, limit=limit, offset=offset)

    response = []
    for agent in agents:
        user_info = None
        if agent.user:
            user_info = {
                "full_name": agent.user.full_name,
                "phone_number": agent.user.phone_number,
                "email": agent.user.email,
                "role": agent.user.role
            }

        response.append(AgentResponse(
            agent_id=str(agent.agent_id),
            user_id=str(agent.user_id),
            provider_id=str(agent.provider_id) if agent.provider_id else None,
            agent_code=agent.agent_code,
            license_number=agent.license_number,
            license_expiry_date=agent.license_expiry_date,
            license_issuing_authority=agent.license_issuing_authority,
            business_name=agent.business_name,
            business_address=agent.business_address,
            gst_number=agent.gst_number,
            pan_number=agent.pan_number,
            territory=agent.territory,
            operating_regions=agent.operating_regions,
            experience_years=agent.experience_years,
            specializations=agent.specializations,
            commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
            whatsapp_business_number=agent.whatsapp_business_number,
            business_email=agent.business_email,
            website=agent.website,
            total_policies_sold=agent.total_policies_sold,
            total_premium_collected=float(agent.total_premium_collected) if agent.total_premium_collected else None,
            active_policyholders=agent.active_policyholders,
            customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
            status=agent.status or "active",
            verification_status=agent.verification_status or "pending",
            approved_at=agent.approved_at,
            created_at=agent.created_at,
            updated_at=agent.updated_at,
            user_info=user_info
        ))

    return response


@router.get("/profile", response_model=AgentResponse)
async def get_agent_profile(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get current agent's profile
    - Agents can view their own profile
    """
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_user_id(current_user.user_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent profile not found"
        )

    return AgentResponse(
        agent_id=str(agent.agent_id),
        user_id=str(agent.user_id),
        provider_id=str(agent.provider_id) if agent.provider_id else None,
        agent_code=agent.agent_code,
        license_number=agent.license_number,
        license_expiry_date=agent.license_expiry_date,
        license_issuing_authority=agent.license_issuing_authority,
        business_name=agent.business_name,
        business_address=agent.business_address,
        gst_number=agent.gst_number,
        pan_number=agent.pan_number,
        territory=agent.territory,
        operating_regions=agent.operating_regions,
        experience_years=agent.experience_years,
        specializations=agent.specializations,
        commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
        whatsapp_business_number=agent.whatsapp_business_number,
        business_email=agent.business_email,
        website=agent.website,
        total_policies_sold=agent.total_policies_sold,
        total_premium_collected=float(agent.total_premium_collected) if agent.total_premium_collected else None,
        active_policyholders=agent.active_policyholders,
        customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
        status=agent.status,
        verification_status=agent.verification_status,
        approved_at=agent.approved_at,
        created_at=agent.created_at,
        updated_at=agent.updated_at,
        user_info={
            "full_name": agent.user.full_name,
            "phone_number": agent.user.phone_number,
            "email": agent.user.email
        } if agent.user else None,
        provider_info={
            "provider_name": agent.provider.provider_name,
            "provider_code": agent.provider.provider_code
        } if agent.provider else None
    )


@router.get("/{agent_id}", response_model=AgentResponse)
async def get_agent(
    agent_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get specific agent by ID
    - Agents can view their own profile
    - Managers can view agents in their territory
    - Admins can view any agent
    """
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    # Check permissions
    can_view = (
        current_user.user_id == str(agent.user_id) or  # Own profile
        current_user.has_role_level("regional_manager") or  # Managers can view
        current_user.has_permission("agents.read")  # Admins can view
    )

    if not can_view:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this agent"
        )

    user_info = None
    if agent.user:
        user_info = {
            "full_name": agent.user.full_name,
            "phone_number": agent.user.phone_number,
            "email": agent.user.email,
            "role": agent.user.role
        }

    return AgentResponse(
        agent_id=str(agent.agent_id),
        user_id=str(agent.user_id),
        provider_id=str(agent.provider_id) if agent.provider_id else None,
        agent_code=agent.agent_code,
        license_number=agent.license_number,
        license_expiry_date=agent.license_expiry_date,
        license_issuing_authority=agent.license_issuing_authority,
        business_name=agent.business_name,
        business_address=agent.business_address,
        gst_number=agent.gst_number,
        pan_number=agent.pan_number,
        territory=agent.territory,
        operating_regions=agent.operating_regions,
        experience_years=agent.experience_years,
        specializations=agent.specializations,
        commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
        whatsapp_business_number=agent.whatsapp_business_number,
        business_email=agent.business_email,
        website=agent.website,
        total_policies_sold=agent.total_policies_sold,
        total_premium_collected=float(agent.total_premium_collected) if agent.total_premium_collected else None,
        active_policyholders=agent.active_policyholders,
        customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
        status=agent.status or "active",
        verification_status=agent.verification_status or "pending",
        approved_at=agent.approved_at,
        created_at=agent.created_at,
        updated_at=agent.updated_at,
        user_info=user_info
    )


@router.post("/", response_model=AgentResponse)
async def create_agent(
    agent_data: AgentCreateRequest,
    current_user: UserContext = Depends(require_permission("agents.create")),
    db: Session = Depends(get_db)
):
    """
    Create a new agent
    - Only admins can create agents
    """
    agent_repo = AgentRepository(db)
    user_repo = UserRepository(db)

    # Check if agent code already exists
    existing_agent = agent_repo.get_by_agent_code(agent_data.agent_code)
    if existing_agent:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Agent code already exists"
        )

    # Check if user exists and is not already an agent
    user = user_repo.get_by_id(agent_data.user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    existing_agent_for_user = agent_repo.get_by_user_id(agent_data.user_id)
    if existing_agent_for_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is already registered as an agent"
        )

    # Create the agent
    agent = agent_repo.create(agent_data.dict())

    return AgentResponse(
        agent_id=str(agent.agent_id),
        user_id=str(agent.user_id),
        provider_id=str(agent.provider_id) if agent.provider_id else None,
        agent_code=agent.agent_code,
        license_number=agent.license_number,
        license_expiry_date=agent.license_expiry_date,
        license_issuing_authority=agent.license_issuing_authority,
        business_name=agent.business_name,
        business_address=agent.business_address,
        gst_number=agent.gst_number,
        pan_number=agent.pan_number,
        territory=agent.territory,
        operating_regions=agent.operating_regions,
        experience_years=agent.experience_years,
        specializations=agent.specializations,
        commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
        whatsapp_business_number=agent.whatsapp_business_number,
        business_email=agent.business_email,
        website=agent.website,
        status=agent.status or "active",
        verification_status=agent.verification_status or "pending",
        created_at=agent.created_at,
        updated_at=agent.updated_at
    )


@router.put("/{agent_id}", response_model=AgentResponse)
async def update_agent(
    agent_id: str,
    agent_data: AgentUpdateRequest,
    current_user: UserContext = Depends(require_any_permission(["agents.update", "agents.approve"])),
    db: Session = Depends(get_db)
):
    """
    Update agent information
    - Agents can update their own profile (limited fields)
    - Managers can update agents in their territory
    - Admins can update any agent
    """
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    # Check permissions
    is_owner = current_user.user_id == str(agent.user_id)
    can_update = (
        is_owner or
        current_user.has_permission("agents.update") or
        (current_user.has_role("regional_manager") and agent.territory == getattr(current_user, 'territory', None))
    )

    if not can_update:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this agent"
        )

    # Filter fields based on permissions
    update_data = agent_data.dict(exclude_unset=True)

    if is_owner and not current_user.has_role_level("regional_manager"):
        # Owners can only update certain fields
        allowed_fields = {
            'business_name', 'business_address', 'business_email', 'website',
            'whatsapp_business_number', 'territory', 'operating_regions'
        }
        update_data = {k: v for k, v in update_data.items() if k in allowed_fields}

    # Update the agent
    updated_agent = agent_repo.update(agent_id, update_data)
    if not updated_agent:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update agent"
        )

    user_info = None
    if updated_agent.user:
        user_info = {
            "full_name": updated_agent.user.full_name,
            "phone_number": updated_agent.user.phone_number,
            "email": updated_agent.user.email,
            "role": updated_agent.user.role
        }

    return AgentResponse(
        agent_id=str(updated_agent.agent_id),
        user_id=str(updated_agent.user_id),
        provider_id=str(updated_agent.provider_id) if updated_agent.provider_id else None,
        agent_code=updated_agent.agent_code,
        license_number=updated_agent.license_number,
        license_expiry_date=updated_agent.license_expiry_date,
        license_issuing_authority=updated_agent.license_issuing_authority,
        business_name=updated_agent.business_name,
        business_address=updated_agent.business_address,
        gst_number=updated_agent.gst_number,
        pan_number=updated_agent.pan_number,
        territory=updated_agent.territory,
        operating_regions=updated_agent.operating_regions,
        experience_years=updated_agent.experience_years,
        specializations=updated_agent.specializations,
        commission_rate=float(updated_agent.commission_rate) if updated_agent.commission_rate else None,
        whatsapp_business_number=updated_agent.whatsapp_business_number,
        business_email=updated_agent.business_email,
        website=updated_agent.website,
        total_policies_sold=updated_agent.total_policies_sold,
        total_premium_collected=float(updated_agent.total_premium_collected) if updated_agent.total_premium_collected else None,
        active_policyholders=updated_agent.active_policyholders,
        customer_satisfaction_score=float(updated_agent.customer_satisfaction_score) if updated_agent.customer_satisfaction_score else None,
        status=updated_agent.status or "active",
        verification_status=updated_agent.verification_status or "pending",
        approved_at=updated_agent.approved_at,
        created_at=updated_agent.created_at,
        updated_at=updated_agent.updated_at,
        user_info=user_info
    )


@router.post("/{agent_id}/approve")
async def approve_agent(
    agent_id: str,
    current_user: UserContext = Depends(require_permission("agents.approve")),
    db: Session = Depends(get_db)
):
    """
    Approve agent verification
    - Only managers and admins can approve agents
    """
    agent_repo = AgentRepository(db)

    success = agent_repo.approve_agent(agent_id, current_user.user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    return {"message": "Agent approved successfully", "agent_id": agent_id}


@router.post("/{agent_id}/reject")
async def reject_agent(
    agent_id: str,
    current_user: UserContext = Depends(require_permission("agents.approve")),
    db: Session = Depends(get_db)
):
    """
    Reject agent verification
    - Only managers and admins can reject agents
    """
    agent_repo = AgentRepository(db)

    success = agent_repo.reject_agent(agent_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    return {"message": "Agent rejected", "agent_id": agent_id}


@router.delete("/{agent_id}")
async def delete_agent(
    agent_id: str,
    current_user: UserContext = Depends(require_permission("agents.delete")),
    db: Session = Depends(get_db)
):
    """
    Delete agent (soft delete)
    - Only super admins can delete agents
    """
    agent_repo = AgentRepository(db)

    success = agent_repo.delete(agent_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    return {"message": "Agent deleted successfully", "agent_id": agent_id}


@router.get("/code/{agent_code}", response_model=AgentResponse)
async def get_agent_by_code(
    agent_code: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get agent by agent code
    - All authenticated users can search agents by code
    """
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_agent_code(agent_code)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    user_info = None
    if agent.user:
        user_info = {
            "full_name": agent.user.full_name,
            "phone_number": agent.user.phone_number,
            "email": agent.user.email,
            "role": agent.user.role
        }

    return AgentResponse(
        agent_id=str(agent.agent_id),
        user_id=str(agent.user_id),
        provider_id=str(agent.provider_id) if agent.provider_id else None,
        agent_code=agent.agent_code,
        license_number=agent.license_number,
        license_expiry_date=agent.license_expiry_date,
        license_issuing_authority=agent.license_issuing_authority,
        business_name=agent.business_name,
        business_address=agent.business_address,
        gst_number=agent.gst_number,
        pan_number=agent.pan_number,
        territory=agent.territory,
        operating_regions=agent.operating_regions,
        experience_years=agent.experience_years,
        specializations=agent.specializations,
        commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
        whatsapp_business_number=agent.whatsapp_business_number,
        business_email=agent.business_email,
        website=agent.website,
        total_policies_sold=agent.total_policies_sold,
        total_premium_collected=float(agent.total_premium_collected) if agent.total_premium_collected else None,
        active_policyholders=agent.active_policyholders,
        customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
        status=agent.status or "active",
        verification_status=agent.verification_status or "pending",
        approved_at=agent.approved_at,
        created_at=agent.created_at,
        updated_at=agent.updated_at,
        user_info=user_info
    )


@router.get("/pending/verification", response_model=List[AgentResponse])
async def get_pending_verification_agents(
    current_user: UserContext = Depends(require_permission("agents.approve")),
    db: Session = Depends(get_db)
):
    """
    Get agents pending verification
    - Only managers and admins can view pending agents
    """
    agent_repo = AgentRepository(db)
    agents = agent_repo.get_pending_verification_agents()

    response = []
    for agent in agents:
        user_info = None
        if agent.user:
            user_info = {
                "full_name": agent.user.full_name,
                "phone_number": agent.user.phone_number,
                "email": agent.user.email,
                "role": agent.user.role
            }

        response.append(AgentResponse(
            agent_id=str(agent.agent_id),
            user_id=str(agent.user_id),
            provider_id=str(agent.provider_id) if agent.provider_id else None,
            agent_code=agent.agent_code,
            license_number=agent.license_number,
            license_expiry_date=agent.license_expiry_date,
            license_issuing_authority=agent.license_issuing_authority,
            business_name=agent.business_name,
            business_address=agent.business_address,
            gst_number=agent.gst_number,
            pan_number=agent.pan_number,
            territory=agent.territory,
            operating_regions=agent.operating_regions,
            experience_years=agent.experience_years,
            specializations=agent.specializations,
            commission_rate=float(agent.commission_rate) if agent.commission_rate else None,
            whatsapp_business_number=agent.whatsapp_business_number,
            business_email=agent.business_email,
            website=agent.website,
            total_policies_sold=agent.total_policies_sold,
            total_premium_collected=float(agent.total_premium_collected) if agent.total_premium_collected else None,
            active_policyholders=agent.active_policyholders,
            customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
            status=agent.status or "active",
            verification_status=agent.verification_status or "pending",
            approved_at=agent.approved_at,
            created_at=agent.created_at,
            updated_at=agent.updated_at,
            user_info=user_info
        ))

    return response
