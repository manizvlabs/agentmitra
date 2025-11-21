"""
Insurance Provider Management API Endpoints
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
    require_role_level
)
from app.repositories.provider_repository import ProviderRepository
from app.models.shared import InsuranceProvider
from datetime import datetime

router = APIRouter()


class ProviderResponse(BaseModel):
    provider_id: str
    provider_code: str
    provider_name: str
    provider_type: Optional[str] = None
    description: Optional[str] = None
    license_number: Optional[str] = None
    regulatory_authority: Optional[str] = None
    established_year: Optional[int] = None
    headquarters: Optional[Dict[str, Any]] = None
    supported_languages: Optional[List[str]] = None
    status: str
    integration_status: str
    last_sync_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class ProviderCreateRequest(BaseModel):
    provider_code: str
    provider_name: str
    provider_type: str
    description: Optional[str] = None
    api_endpoint: Optional[str] = None
    webhook_url: Optional[str] = None
    license_number: Optional[str] = None
    regulatory_authority: Optional[str] = None
    established_year: Optional[int] = None
    headquarters: Optional[Dict[str, Any]] = None
    supported_languages: Optional[List[str]] = None
    business_hours: Optional[Dict[str, Any]] = None
    service_regions: Optional[List[str]] = None
    commission_structure: Optional[Dict[str, Any]] = None

    @validator('provider_code')
    def validate_provider_code(cls, v):
        if not v or not v.isupper() or not v.replace('_', '').replace('-', '').isalnum():
            raise ValueError('Provider code must be uppercase alphanumeric with underscores/hyphens')
        return v

    @validator('provider_type')
    def validate_provider_type(cls, v):
        valid_types = ['life_insurance', 'health_insurance', 'general_insurance']
        if v not in valid_types:
            raise ValueError(f'Provider type must be one of: {", ".join(valid_types)}')
        return v


class ProviderUpdateRequest(BaseModel):
    provider_name: Optional[str] = None
    provider_type: Optional[str] = None
    description: Optional[str] = None
    api_endpoint: Optional[str] = None
    webhook_url: Optional[str] = None
    license_number: Optional[str] = None
    regulatory_authority: Optional[str] = None
    established_year: Optional[int] = None
    headquarters: Optional[Dict[str, Any]] = None
    supported_languages: Optional[List[str]] = None
    business_hours: Optional[Dict[str, Any]] = None
    service_regions: Optional[List[str]] = None
    commission_structure: Optional[Dict[str, Any]] = None
    status: Optional[str] = None
    integration_status: Optional[str] = None


@router.get("/", response_model=List[ProviderResponse])
async def get_providers(
    status_filter: Optional[str] = Query(None, alias="status", description="Filter by status"),
    provider_type: Optional[str] = Query(None, description="Filter by provider type"),
    search: Optional[str] = Query(None, description="Search by name or code"),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get all insurance providers
    - All authenticated users can view providers
    - Supports filtering by status, type, and search
    """
    provider_repo = ProviderRepository(db)

    if search:
        # Search functionality
        providers = provider_repo.search_providers(search, status=status_filter)
    elif provider_type:
        # Filter by type
        providers = provider_repo.get_providers_by_type(provider_type)
    else:
        # Get all providers
        providers = provider_repo.get_all(status=status_filter)

    return [
        ProviderResponse(
            provider_id=str(p.provider_id),
            provider_code=p.provider_code,
            provider_name=p.provider_name,
            provider_type=p.provider_type,
            description=p.description,
            license_number=p.license_number,
            regulatory_authority=p.regulatory_authority,
            established_year=p.established_year,
            headquarters=p.headquarters,
            supported_languages=p.supported_languages,
            status=p.status,
            integration_status=p.integration_status,
            last_sync_at=p.last_sync_at,
            created_at=p.created_at,
            updated_at=p.updated_at
        )
        for p in providers
    ]


@router.get("/{provider_id}", response_model=ProviderResponse)
async def get_provider(
    provider_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get specific insurance provider by ID
    - All authenticated users can view provider details
    """
    provider_repo = ProviderRepository(db)
    provider = provider_repo.get_by_id(provider_id)

    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance provider not found"
        )

    return ProviderResponse(
        provider_id=str(provider.provider_id),
        provider_code=provider.provider_code,
        provider_name=provider.provider_name,
        provider_type=provider.provider_type,
        description=provider.description,
        license_number=provider.license_number,
        regulatory_authority=provider.regulatory_authority,
        established_year=provider.established_year,
        headquarters=provider.headquarters,
        supported_languages=provider.supported_languages,
        status=provider.status,
        integration_status=provider.integration_status,
        last_sync_at=provider.last_sync_at,
        created_at=provider.created_at,
        updated_at=provider.updated_at
    )


@router.post("/", response_model=ProviderResponse)
async def create_provider(
    provider_data: ProviderCreateRequest,
    current_user: UserContext = Depends(require_permission("providers.create")),
    db: Session = Depends(get_db)
):
    """
    Create a new insurance provider
    - Only super admins can create providers
    """
    provider_repo = ProviderRepository(db)

    # Check if provider code already exists
    existing_provider = provider_repo.get_by_code(provider_data.provider_code)
    if existing_provider:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provider code already exists"
        )

    # Create the provider
    provider = provider_repo.create(provider_data.dict())

    return ProviderResponse(
        provider_id=str(provider.provider_id),
        provider_code=provider.provider_code,
        provider_name=provider.provider_name,
        provider_type=provider.provider_type,
        description=provider.description,
        license_number=provider.license_number,
        regulatory_authority=provider.regulatory_authority,
        established_year=provider.established_year,
        headquarters=provider.headquarters,
        supported_languages=provider.supported_languages,
        status=provider.status,
        integration_status=provider.integration_status,
        created_at=provider.created_at,
        updated_at=provider.updated_at
    )


@router.put("/{provider_id}", response_model=ProviderResponse)
async def update_provider(
    provider_id: str,
    provider_data: ProviderUpdateRequest,
    current_user: UserContext = Depends(require_permission("providers.update")),
    db: Session = Depends(get_db)
):
    """
    Update insurance provider information
    - Only admins can update provider information
    """
    provider_repo = ProviderRepository(db)
    provider = provider_repo.get_by_id(provider_id)

    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance provider not found"
        )

    # Update the provider
    update_data = provider_data.dict(exclude_unset=True)
    updated_provider = provider_repo.update(provider_id, update_data)

    if not updated_provider:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update provider"
        )

    return ProviderResponse(
        provider_id=str(updated_provider.provider_id),
        provider_code=updated_provider.provider_code,
        provider_name=updated_provider.provider_name,
        provider_type=updated_provider.provider_type,
        description=updated_provider.description,
        license_number=updated_provider.license_number,
        regulatory_authority=updated_provider.regulatory_authority,
        established_year=updated_provider.established_year,
        headquarters=updated_provider.headquarters,
        supported_languages=updated_provider.supported_languages,
        status=updated_provider.status,
        integration_status=updated_provider.integration_status,
        last_sync_at=updated_provider.last_sync_at,
        created_at=updated_provider.created_at,
        updated_at=updated_provider.updated_at
    )


@router.delete("/{provider_id}")
async def delete_provider(
    provider_id: str,
    current_user: UserContext = Depends(require_permission("providers.delete")),
    db: Session = Depends(get_db)
):
    """
    Delete insurance provider (soft delete)
    - Only super admins can delete providers
    """
    provider_repo = ProviderRepository(db)

    # Check if provider exists
    provider = provider_repo.get_by_id(provider_id)
    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance provider not found"
        )

    # Soft delete
    success = provider_repo.delete(provider_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete provider"
        )

    return {"message": "Provider deleted successfully", "provider_id": provider_id}


@router.get("/code/{provider_code}", response_model=ProviderResponse)
async def get_provider_by_code(
    provider_code: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get insurance provider by code
    - All authenticated users can view provider details by code
    """
    provider_repo = ProviderRepository(db)
    provider = provider_repo.get_by_code(provider_code)

    if not provider:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Insurance provider not found"
        )

    return ProviderResponse(
        provider_id=str(provider.provider_id),
        provider_code=provider.provider_code,
        provider_name=provider.provider_name,
        provider_type=provider.provider_type,
        description=provider.description,
        license_number=provider.license_number,
        regulatory_authority=provider.regulatory_authority,
        established_year=provider.established_year,
        headquarters=provider.headquarters,
        supported_languages=provider.supported_languages,
        status=provider.status,
        integration_status=provider.integration_status,
        last_sync_at=provider.last_sync_at,
        created_at=provider.created_at,
        updated_at=provider.updated_at
    )
