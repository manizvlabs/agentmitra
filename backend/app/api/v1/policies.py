"""
Policy Management API Endpoints
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
from app.repositories.policy_repository import PolicyRepository, PolicyholderRepository, PaymentRepository
from app.models.policy import InsurancePolicy, Policyholder
from datetime import datetime, date

router = APIRouter()


class PolicyholderResponse(BaseModel):
    policyholder_id: str
    user_id: str
    agent_id: Optional[str] = None
    customer_id: Optional[str] = None
    salutation: Optional[str] = None
    marital_status: Optional[str] = None
    occupation: Optional[str] = None
    annual_income: Optional[float] = None
    education_level: Optional[str] = None
    preferred_language: Optional[str] = None
    onboarding_status: str
    total_interactions: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    # User information
    user_info: Optional[Dict[str, Any]] = None


class PolicyResponse(BaseModel):
    policy_id: str
    policy_number: str
    provider_policy_id: Optional[str] = None
    policyholder_id: str
    agent_id: str
    provider_id: str
    policy_type: str
    plan_name: str
    plan_code: Optional[str] = None
    category: Optional[str] = None
    sum_assured: float
    premium_amount: float
    premium_frequency: str
    premium_mode: Optional[str] = None
    application_date: date
    approval_date: Optional[date] = None
    start_date: date
    maturity_date: Optional[date] = None
    renewal_date: Optional[date] = None
    status: str
    sub_status: Optional[str] = None
    payment_status: str
    total_payments: Optional[int] = None
    outstanding_amount: Optional[float] = None
    next_payment_date: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    # Related information
    policyholder_info: Optional[Dict[str, Any]] = None
    agent_info: Optional[Dict[str, Any]] = None
    provider_info: Optional[Dict[str, Any]] = None


class PolicyCreateRequest(BaseModel):
    policy_number: str
    policyholder_id: str
    agent_id: str
    provider_id: str
    policy_type: str
    plan_name: str
    plan_code: Optional[str] = None
    category: str
    sum_assured: float
    premium_amount: float
    premium_frequency: str
    premium_mode: Optional[str] = None
    application_date: date
    start_date: date
    maturity_date: Optional[date] = None
    coverage_details: Optional[Dict[str, Any]] = None
    nominee_details: Optional[Dict[str, Any]] = None

    @validator('premium_frequency')
    def validate_premium_frequency(cls, v):
        valid_frequencies = ['monthly', 'quarterly', 'half_yearly', 'annual']
        if v not in valid_frequencies:
            raise ValueError(f'Premium frequency must be one of: {", ".join(valid_frequencies)}')
        return v

    @validator('category')
    def validate_category(cls, v):
        valid_categories = ['life', 'health', 'general']
        if v not in valid_categories:
            raise ValueError(f'Category must be one of: {", ".join(valid_categories)}')
        return v

    @validator('sum_assured')
    def validate_sum_assured(cls, v):
        if v <= 0:
            raise ValueError('Sum assured must be greater than 0')
        return v

    @validator('premium_amount')
    def validate_premium_amount(cls, v):
        if v <= 0:
            raise ValueError('Premium amount must be greater than 0')
        return v


class PolicyUpdateRequest(BaseModel):
    policy_type: Optional[str] = None
    plan_name: Optional[str] = None
    plan_code: Optional[str] = None
    category: Optional[str] = None
    sum_assured: Optional[float] = None
    premium_amount: Optional[float] = None
    premium_frequency: Optional[str] = None
    premium_mode: Optional[str] = None
    maturity_date: Optional[date] = None
    coverage_details: Optional[Dict[str, Any]] = None
    nominee_details: Optional[Dict[str, Any]] = None
    status: Optional[str] = None
    sub_status: Optional[str] = None
    payment_status: Optional[str] = None


@router.get("/", response_model=List[PolicyResponse])
async def get_policies(
    policyholder_id: Optional[str] = Query(None, description="Filter by policyholder ID"),
    agent_id: Optional[str] = Query(None, description="Filter by agent ID"),
    provider_id: Optional[str] = Query(None, description="Filter by provider ID"),
    status: Optional[str] = Query(None, description="Filter by policy status"),
    policy_type: Optional[str] = Query(None, description="Filter by policy type"),
    category: Optional[str] = Query(None, description="Filter by category"),
    policy_number: Optional[str] = Query(None, description="Search by policy number"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    offset: int = Query(0, ge=0, description="Number of results to skip"),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get policies with comprehensive filtering
    - Agents can see their own policies and policies of their policyholders
    - Policyholders can see their own policies
    - Admins can see all policies
    """
    policy_repo = PolicyRepository(db)

    # Build filters based on user permissions
    filters = {}

    if policy_number:
        filters["policy_number"] = policy_number
    if policyholder_id:
        filters["policyholder_id"] = policyholder_id
    if agent_id:
        filters["agent_id"] = agent_id
    if provider_id:
        filters["provider_id"] = provider_id
    if status:
        filters["status"] = status
    if policy_type:
        filters["policy_type"] = policy_type
    if category:
        filters["category"] = category

    # Apply role-based filtering
    if current_user.role in ["policyholder"]:
        # Policyholders can only see their own policies
        policyholder_repo = PolicyholderRepository(db)
        policyholder = policyholder_repo.get_by_user_id(current_user.user_id)
        if policyholder:
            filters["policyholder_id"] = str(policyholder.policyholder_id)
        else:
            return []  # No policyholder profile found
    elif current_user.role in ["junior_agent", "senior_agent"]:
        # Agents can see policies they created
        # TODO: Also allow agents to see policies of policyholders assigned to them
        filters["agent_id"] = current_user.user_id

    policies = policy_repo.search_policies(filters, limit=limit, offset=offset)

    response = []
    for policy in policies:
        policyholder_info = None
        agent_info = None
        provider_info = None

        if policy.policyholder and policy.policyholder.user:
            policyholder_info = {
                "full_name": policy.policyholder.user.full_name,
                "phone_number": policy.policyholder.user.phone_number,
                "email": policy.policyholder.user.email
            }

        if policy.agent and policy.agent.user:
            agent_info = {
                "full_name": policy.agent.user.full_name,
                "agent_code": policy.agent.agent_code
            }

        if policy.provider:
            provider_info = {
                "provider_name": policy.provider.provider_name,
                "provider_code": policy.provider.provider_code
            }

        response.append(PolicyResponse(
            policy_id=str(policy.policy_id),
            policy_number=policy.policy_number,
            provider_policy_id=policy.provider_policy_id,
            policyholder_id=str(policy.policyholder_id),
            agent_id=str(policy.agent_id),
            provider_id=str(policy.provider_id),
            policy_type=policy.policy_type,
            plan_name=policy.plan_name,
            plan_code=policy.plan_code,
            category=policy.category,
            sum_assured=float(policy.sum_assured),
            premium_amount=float(policy.premium_amount),
            premium_frequency=policy.premium_frequency,
            premium_mode=policy.premium_mode,
            application_date=policy.application_date,
            approval_date=policy.approval_date,
            start_date=policy.start_date,
            maturity_date=policy.maturity_date,
            renewal_date=policy.renewal_date,
            status=policy.status,
            sub_status=policy.sub_status,
            payment_status=policy.payment_status or "pending",
            total_payments=policy.total_payments,
            outstanding_amount=float(policy.outstanding_amount) if policy.outstanding_amount else 0,
            next_payment_date=policy.next_payment_date,
            created_at=policy.created_at,
            updated_at=policy.updated_at,
            policyholder_info=policyholder_info,
            agent_info=agent_info,
            provider_info=provider_info
        ))

    return response


@router.get("/{policy_id}", response_model=PolicyResponse)
async def get_policy(
    policy_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get specific policy details
    - Policyholders can view their own policies
    - Agents can view policies they created
    - Admins can view any policy
    """
    policy_repo = PolicyRepository(db)
    policy = policy_repo.get_by_id(policy_id)

    if not policy:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found"
        )

    # Check permissions
    can_view = False

    if current_user.role == "policyholder":
        # Check if policy belongs to current user
        policyholder_repo = PolicyholderRepository(db)
        policyholder = policyholder_repo.get_by_user_id(current_user.user_id)
        can_view = policyholder and str(policy.policyholder_id) == str(policyholder.policyholder_id)
    elif current_user.role in ["junior_agent", "senior_agent"]:
        # Check if agent created this policy
        can_view = str(policy.agent_id) == current_user.user_id
    else:
        # Admins can view any policy
        can_view = current_user.has_role_level("regional_manager")

    if not can_view:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this policy"
        )

    # Build response with related information
    policyholder_info = None
    agent_info = None
    provider_info = None

    if policy.policyholder and policy.policyholder.user:
        policyholder_info = {
            "full_name": policy.policyholder.user.full_name,
            "phone_number": policy.policyholder.user.phone_number,
            "email": policy.policyholder.user.email
        }

    if policy.agent and policy.agent.user:
        agent_info = {
            "full_name": policy.agent.user.full_name,
            "agent_code": policy.agent.agent_code
        }

    if policy.provider:
        provider_info = {
            "provider_name": policy.provider.provider_name,
            "provider_code": policy.provider.provider_code
        }

    return PolicyResponse(
        policy_id=str(policy.policy_id),
        policy_number=policy.policy_number,
        provider_policy_id=policy.provider_policy_id,
        policyholder_id=str(policy.policyholder_id),
        agent_id=str(policy.agent_id),
        provider_id=str(policy.provider_id),
        policy_type=policy.policy_type,
        plan_name=policy.plan_name,
        plan_code=policy.plan_code,
        category=policy.category,
        sum_assured=float(policy.sum_assured),
        premium_amount=float(policy.premium_amount),
        premium_frequency=policy.premium_frequency,
        premium_mode=policy.premium_mode,
        application_date=policy.application_date,
        approval_date=policy.approval_date,
        start_date=policy.start_date,
        maturity_date=policy.maturity_date,
        renewal_date=policy.renewal_date,
        status=policy.status,
        sub_status=policy.sub_status,
        payment_status=policy.payment_status or "pending",
        total_payments=policy.total_payments,
        outstanding_amount=float(policy.outstanding_amount) if policy.outstanding_amount else 0,
        next_payment_date=policy.next_payment_date,
        created_at=policy.created_at,
        updated_at=policy.updated_at,
        policyholder_info=policyholder_info,
        agent_info=agent_info,
        provider_info=provider_info
    )


@router.post("/", response_model=PolicyResponse)
async def create_policy(
    policy_data: PolicyCreateRequest,
    current_user: UserContext = Depends(require_any_permission(["policies.create", "policies.update"])),
    db: Session = Depends(get_db)
):
    """
    Create a new insurance policy
    - Only agents and managers can create policies
    """
    policy_repo = PolicyRepository(db)

    # Check if policy number already exists
    existing_policy = policy_repo.get_by_policy_number(policy_data.policy_number)
    if existing_policy:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Policy number already exists"
        )

    # Validate that policyholder exists
    policyholder_repo = PolicyholderRepository(db)
    policyholder = policyholder_repo.get_by_id(policy_data.policyholder_id)
    if not policyholder:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policyholder not found"
        )

    # For agents, ensure they can only create policies for their assigned policyholders
    if current_user.role in ["junior_agent", "senior_agent"]:
        if str(policyholder.agent_id) != current_user.user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Agents can only create policies for their assigned policyholders"
            )

    # Create the policy
    policy_dict = policy_data.dict()
    policy_dict["created_by"] = current_user.user_id

    policy = policy_repo.create(policy_dict)

    # Build response
    policyholder_info = None
    agent_info = None
    provider_info = None

    if policy.policyholder and policy.policyholder.user:
        policyholder_info = {
            "full_name": policy.policyholder.user.full_name,
            "phone_number": policy.policyholder.user.phone_number,
            "email": policy.policyholder.user.email
        }

    if policy.agent and policy.agent.user:
        agent_info = {
            "full_name": policy.agent.user.full_name,
            "agent_code": policy.agent.agent_code
        }

    if policy.provider:
        provider_info = {
            "provider_name": policy.provider.provider_name,
            "provider_code": policy.provider.provider_code
        }

    return PolicyResponse(
        policy_id=str(policy.policy_id),
        policy_number=policy.policy_number,
        provider_policy_id=policy.provider_policy_id,
        policyholder_id=str(policy.policyholder_id),
        agent_id=str(policy.agent_id),
        provider_id=str(policy.provider_id),
        policy_type=policy.policy_type,
        plan_name=policy.plan_name,
        plan_code=policy.plan_code,
        category=policy.category,
        sum_assured=float(policy.sum_assured),
        premium_amount=float(policy.premium_amount),
        premium_frequency=policy.premium_frequency,
        premium_mode=policy.premium_mode,
        application_date=policy.application_date,
        approval_date=policy.approval_date,
        start_date=policy.start_date,
        maturity_date=policy.maturity_date,
        renewal_date=policy.renewal_date,
        status=policy.status,
        sub_status=policy.sub_status,
        payment_status=policy.payment_status or "pending",
        total_payments=policy.total_payments,
        outstanding_amount=float(policy.outstanding_amount) if policy.outstanding_amount else 0,
        next_payment_date=policy.next_payment_date,
        created_at=policy.created_at,
        updated_at=policy.updated_at,
        policyholder_info=policyholder_info,
        agent_info=agent_info,
        provider_info=provider_info
    )


@router.put("/{policy_id}", response_model=PolicyResponse)
async def update_policy(
    policy_id: str,
    policy_data: PolicyUpdateRequest,
    current_user: UserContext = Depends(require_any_permission(["policies.update", "policies.approve"])),
    db: Session = Depends(get_db)
):
    """
    Update policy information
    - Agents can update policies they created (limited fields)
    - Managers can update policies in their territory
    - Admins can update any policy
    """
    policy_repo = PolicyRepository(db)
    policy = policy_repo.get_by_id(policy_id)

    if not policy:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found"
        )

    # Check permissions
    is_owner_agent = str(policy.agent_id) == current_user.user_id
    can_update = (
        is_owner_agent or
        current_user.has_permission("policies.update") or
        (current_user.has_role("regional_manager") and hasattr(policy.agent, 'territory'))
    )

    if not can_update:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this policy"
        )

    # Filter fields based on permissions and policy status
    update_data = policy_data.dict(exclude_unset=True)

    # Agents can only update certain fields and only for draft/pending policies
    if is_owner_agent and not current_user.has_role_level("regional_manager"):
        allowed_fields = [
            'coverage_details', 'nominee_details'
        ]
        # Only allow updates for non-active policies
        if policy.status in ['active', 'matured']:
            allowed_fields = []  # No updates allowed for active policies

        update_data = {k: v for k, v in update_data.items() if k in allowed_fields}

    # Update the policy
    updated_policy = policy_repo.update(policy_id, update_data)
    if not updated_policy:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update policy"
        )

    # Build response (same as get_policy)
    policyholder_info = None
    agent_info = None
    provider_info = None

    if updated_policy.policyholder and updated_policy.policyholder.user:
        policyholder_info = {
            "full_name": updated_policy.policyholder.user.full_name,
            "phone_number": updated_policy.policyholder.user.phone_number,
            "email": updated_policy.policyholder.user.email
        }

    if updated_policy.agent and updated_policy.agent.user:
        agent_info = {
            "full_name": updated_policy.agent.user.full_name,
            "agent_code": updated_policy.agent.agent_code
        }

    if updated_policy.provider:
        provider_info = {
            "provider_name": updated_policy.provider.provider_name,
            "provider_code": updated_policy.provider.provider_code
        }

    return PolicyResponse(
        policy_id=str(updated_policy.policy_id),
        policy_number=updated_policy.policy_number,
        provider_policy_id=updated_policy.provider_policy_id,
        policyholder_id=str(updated_policy.policyholder_id),
        agent_id=str(updated_policy.agent_id),
        provider_id=str(updated_policy.provider_id),
        policy_type=updated_policy.policy_type,
        plan_name=updated_policy.plan_name,
        plan_code=updated_policy.plan_code,
        category=updated_policy.category,
        sum_assured=float(updated_policy.sum_assured),
        premium_amount=float(updated_policy.premium_amount),
        premium_frequency=updated_policy.premium_frequency,
        premium_mode=updated_policy.premium_mode,
        application_date=updated_policy.application_date,
        approval_date=updated_policy.approval_date,
        start_date=updated_policy.start_date,
        maturity_date=updated_policy.maturity_date,
        renewal_date=updated_policy.renewal_date,
        status=updated_policy.status,
        sub_status=updated_policy.sub_status,
        payment_status=updated_policy.payment_status or "pending",
        total_payments=updated_policy.total_payments,
        outstanding_amount=float(updated_policy.outstanding_amount) if updated_policy.outstanding_amount else 0,
        next_payment_date=updated_policy.next_payment_date,
        created_at=updated_policy.created_at,
        updated_at=updated_policy.updated_at,
        policyholder_info=policyholder_info,
        agent_info=agent_info,
        provider_info=provider_info
    )


@router.post("/{policy_id}/approve")
async def approve_policy(
    policy_id: str,
    current_user: UserContext = Depends(require_permission("policies.approve")),
    db: Session = Depends(get_db)
):
    """
    Approve a policy application
    - Only managers and admins can approve policies
    """
    policy_repo = PolicyRepository(db)

    success = policy_repo.approve_policy(policy_id, current_user.user_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found or cannot be approved"
        )

    return {"message": "Policy approved successfully", "policy_id": policy_id}


@router.post("/{policy_id}/activate")
async def activate_policy(
    policy_id: str,
    current_user: UserContext = Depends(require_permission("policies.approve")),
    db: Session = Depends(get_db)
):
    """
    Activate an approved policy
    - Only managers and admins can activate policies
    """
    policy_repo = PolicyRepository(db)

    success = policy_repo.activate_policy(policy_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found or cannot be activated"
        )

    return {"message": "Policy activated successfully", "policy_id": policy_id}


@router.delete("/{policy_id}")
async def delete_policy(
    policy_id: str,
    current_user: UserContext = Depends(require_permission("policies.delete")),
    db: Session = Depends(get_db)
):
    """
    Delete policy (soft delete)
    - Only super admins can delete policies
    """
    policy_repo = PolicyRepository(db)

    success = policy_repo.delete(policy_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found"
        )

    return {"message": "Policy cancelled successfully", "policy_id": policy_id}


@router.get("/number/{policy_number}", response_model=PolicyResponse)
async def get_policy_by_number(
    policy_number: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get policy by policy number
    - All authenticated users can search by policy number (will check permissions)
    """
    policy_repo = PolicyRepository(db)
    policy = policy_repo.get_by_policy_number(policy_number)

    if not policy:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found"
        )

    # Use the same permission check as get_policy
    can_view = False

    if current_user.role == "policyholder":
        policyholder_repo = PolicyholderRepository(db)
        policyholder = policyholder_repo.get_by_user_id(current_user.user_id)
        can_view = policyholder and str(policy.policyholder_id) == str(policyholder.policyholder_id)
    elif current_user.role in ["junior_agent", "senior_agent"]:
        can_view = str(policy.agent_id) == current_user.user_id
    else:
        can_view = current_user.has_role_level("regional_manager")

    if not can_view:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view this policy"
        )

    # Return the same response as get_policy
    policyholder_info = None
    agent_info = None
    provider_info = None

    if policy.policyholder and policy.policyholder.user:
        policyholder_info = {
            "full_name": policy.policyholder.user.full_name,
            "phone_number": policy.policyholder.user.phone_number,
            "email": policy.policyholder.user.email
        }

    if policy.agent and policy.agent.user:
        agent_info = {
            "full_name": policy.agent.user.full_name,
            "agent_code": policy.agent.agent_code
        }

    if policy.provider:
        provider_info = {
            "provider_name": policy.provider.provider_name,
            "provider_code": policy.provider.provider_code
        }

    return PolicyResponse(
        policy_id=str(policy.policy_id),
        policy_number=policy.policy_number,
        provider_policy_id=policy.provider_policy_id,
        policyholder_id=str(policy.policyholder_id),
        agent_id=str(policy.agent_id),
        provider_id=str(policy.provider_id),
        policy_type=policy.policy_type,
        plan_name=policy.plan_name,
        plan_code=policy.plan_code,
        category=policy.category,
        sum_assured=float(policy.sum_assured),
        premium_amount=float(policy.premium_amount),
        premium_frequency=policy.premium_frequency,
        premium_mode=policy.premium_mode,
        application_date=policy.application_date,
        approval_date=policy.approval_date,
        start_date=policy.start_date,
        maturity_date=policy.maturity_date,
        renewal_date=policy.renewal_date,
        status=policy.status,
        sub_status=policy.sub_status,
        payment_status=policy.payment_status or "pending",
        total_payments=policy.total_payments,
        outstanding_amount=float(policy.outstanding_amount) if policy.outstanding_amount else 0,
        next_payment_date=policy.next_payment_date,
        created_at=policy.created_at,
        updated_at=policy.updated_at,
        policyholder_info=policyholder_info,
        agent_info=agent_info,
        provider_info=provider_info
    )

