"""
Tenant Management API Endpoints - Automated tenant provisioning
"""
from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks, status
from pydantic import BaseModel, validator, EmailStr
from typing import Optional, Dict, List, Any
from sqlalchemy.orm import Session
from app.core.database import get_db, SessionLocal
from app.core.tenant_middleware import get_tenant_context, get_tenant_service
from app.core.tenant_service import TenantService
from app.core.audit_service import AuditService
from app.core.auth import get_current_user_context, UserContext, require_permission
from datetime import datetime

router = APIRouter()


# Request/Response Models
class TenantCreateRequest(BaseModel):
    """Request model for creating a new tenant"""
    tenant_code: str
    tenant_name: str
    tenant_type: str  # 'insurance_provider', 'independent_agent', 'agent_network'
    subscription_plan: Optional[str] = 'trial'
    max_users: Optional[int] = 100
    storage_limit_gb: Optional[int] = 5
    api_rate_limit: Optional[int] = 1000

    # Contact information
    contact_email: Optional[EmailStr] = None
    contact_phone: Optional[str] = None
    business_address: Optional[Dict[str, Any]] = None

    # Admin user provisioning
    admin_phone: str
    admin_email: Optional[EmailStr] = None
    admin_first_name: Optional[str] = None
    admin_last_name: Optional[str] = None

    # Additional metadata
    regulatory_approvals: Optional[Dict[str, Any]] = None
    metadata: Optional[Dict[str, Any]] = None

    @validator('tenant_code')
    def validate_tenant_code(cls, v):
        if not v or not v.strip():
            raise ValueError('Tenant code cannot be empty')
        if not v.replace('_', '').replace('-', '').isalnum():
            raise ValueError('Tenant code must contain only alphanumeric characters, underscores, and hyphens')
        if len(v) < 2 or len(v) > 20:
            raise ValueError('Tenant code must be between 2 and 20 characters')
        return v.upper()

    @validator('tenant_type')
    def validate_tenant_type(cls, v):
        valid_types = ['insurance_provider', 'independent_agent', 'agent_network']
        if v not in valid_types:
            raise ValueError(f'Tenant type must be one of: {valid_types}')
        return v


class TenantResponse(BaseModel):
    """Response model for tenant information"""
    tenant_id: str
    tenant_code: str
    tenant_name: str
    tenant_type: str
    status: str
    subscription_plan: Optional[str]
    max_users: Optional[int]
    storage_limit_gb: Optional[int]
    api_rate_limit: Optional[int]
    created_at: datetime


class TenantProvisioningStatus(BaseModel):
    """Status response for tenant provisioning"""
    tenant_id: str
    status: str  # 'provisioning', 'active', 'failed'
    admin_user_id: Optional[str]
    admin_tenant_user_id: Optional[str]
    provisioned_at: datetime
    error_message: Optional[str]


# API Endpoints

@router.post("/", response_model=TenantProvisioningStatus)
async def create_tenant(
    request: TenantCreateRequest,
    background_tasks: BackgroundTasks,
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service),
    db: Session = Depends(get_db)
):
    """
    Create a new tenant with automated provisioning

    This endpoint:
    1. Validates tenant creation data
    2. Creates tenant record with default configurations
    3. Provisions admin user and assigns permissions
    4. Sets up initial tenant settings and compliance data
    5. Sends welcome notifications
    """
    try:
        # Only super admins can create tenants
        if not current_user.has_permission("tenants.create"):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to create tenants"
            )

        # Prepare tenant data
        tenant_data = {
            'tenant_code': request.tenant_code,
            'tenant_name': request.tenant_name,
            'tenant_type': request.tenant_type,
            'subscription_plan': request.subscription_plan,
            'max_users': request.max_users,
            'storage_limit_gb': request.storage_limit_gb,
            'api_rate_limit': request.api_rate_limit,
            'contact_email': request.contact_email,
            'contact_phone': request.contact_phone,
            'business_address': request.business_address,
            'regulatory_approvals': request.regulatory_approvals,
            'metadata': request.metadata
        }

        # Prepare admin data
        admin_data = {
            'phone_number': request.admin_phone,
            'email': request.admin_email,
            'first_name': request.admin_first_name,
            'last_name': request.admin_last_name,
            'tenant_type': request.tenant_type,
            'tenant_name': request.tenant_name
        }

        # Create tenant
        tenant_context = tenant_service.create_tenant(tenant_data)

        # Provision admin user
        admin_provisioning = tenant_service.provision_tenant_admin(
            tenant_context['tenant_id'],
            admin_data
        )

        # Log the provisioning
        audit_service = AuditService(tenant_service)
        audit_service.log_tenant_activity(
            tenant_id=tenant_context['tenant_id'],
            user_id=current_user.user_id,
            action='tenant_provisioned',
            resource_type='system',
            resource_id=tenant_context['tenant_id'],
            details={
                'provisioned_by': current_user.user_id,
                'tenant_type': request.tenant_type,
                'subscription_plan': request.subscription_plan,
                'admin_user_id': admin_provisioning['user_id']
            },
            ip_address=getattr(current_user, 'ip_address', None)
        )

        return TenantProvisioningStatus(
            tenant_id=tenant_context['tenant_id'],
            status='active',
            admin_user_id=admin_provisioning['user_id'],
            admin_tenant_user_id=admin_provisioning['tenant_user_id'],
            provisioned_at=datetime.utcnow(),
            error_message=None
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        # Log the error
        logger.error(f"Tenant creation failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Tenant creation failed"
        )


@router.get("/", response_model=List[TenantResponse])
async def list_tenants(
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service)
):
    """
    List all tenants (super admin only)
    """
    if not current_user.has_permission("tenants.read"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view tenants"
        )

    try:
        # For now, return all tenants - in production, you might want pagination
        # This is a simplified implementation
        with SessionLocal() as session:
            from app.models.shared import Tenant
            tenants = session.query(Tenant).all()

            return [
                TenantResponse(
                    tenant_id=str(tenant.tenant_id),
                    tenant_code=tenant.tenant_code,
                    tenant_name=tenant.tenant_name,
                    tenant_type=tenant.tenant_type,
                    status=tenant.status,
                    subscription_plan=tenant.subscription_plan,
                    max_users=tenant.max_users,
                    storage_limit_gb=tenant.storage_limit_gb,
                    api_rate_limit=tenant.api_rate_limit,
                    created_at=tenant.created_at,
                )
                for tenant in tenants
            ]

    except Exception as e:
        logger.error(f"Failed to list tenants: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve tenants"
        )


@router.get("/{tenant_id}", response_model=TenantResponse)
async def get_tenant(
    tenant_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service)
):
    """
    Get tenant details
    """
    if not current_user.has_permission("tenants.read"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view tenant details"
        )

    try:
        tenant_context = tenant_service.get_tenant_context(tenant_id)

        return TenantResponse(
            tenant_id=tenant_context['tenant_id'],
            tenant_code=tenant_context['tenant_code'],
            tenant_name=tenant_context['tenant_name'],
            tenant_type=tenant_context['tenant_type'],
            status=tenant_context['status'],
            subscription_plan=tenant_context['subscription_plan'],
            max_users=tenant_context['max_users'],
            storage_limit_gb=tenant_context['storage_limit_gb'],
            api_rate_limit=tenant_context['api_rate_limit'],
            created_at=datetime.fromisoformat(tenant_context.get('created_at', datetime.utcnow().isoformat())),
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        logger.error(f"Failed to get tenant {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve tenant"
        )


@router.put("/{tenant_id}/deactivate")
async def deactivate_tenant(
    tenant_id: str,
    reason: Optional[str] = None,
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service)
):
    """
    Deactivate a tenant
    """
    if not current_user.has_permission("tenants.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to deactivate tenants"
        )

    try:
        success = tenant_service.deactivate_tenant(tenant_id, reason)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to deactivate tenant"
            )

        # Audit the deactivation
        audit_service = AuditService(tenant_service)
        audit_service.log_tenant_activity(
            tenant_id=tenant_id,
            user_id=current_user.user_id,
            action='tenant_deactivated',
            resource_type='system',
            resource_id=tenant_id,
            details={
                'deactivated_by': current_user.user_id,
                'reason': reason
            },
            ip_address=getattr(current_user, 'ip_address', None)
        )

        return {"message": "Tenant deactivated successfully", "tenant_id": tenant_id}

    except Exception as e:
        logger.error(f"Failed to deactivate tenant {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to deactivate tenant"
        )


@router.put("/{tenant_id}/reactivate")
async def reactivate_tenant(
    tenant_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service)
):
    """
    Reactivate a deactivated tenant
    """
    if not current_user.has_permission("tenants.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to reactivate tenants"
        )

    try:
        success = tenant_service.reactivate_tenant(tenant_id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to reactivate tenant"
            )

        # Audit the reactivation
        audit_service = AuditService(tenant_service)
        audit_service.log_tenant_activity(
            tenant_id=tenant_id,
            user_id=current_user.user_id,
            action='tenant_reactivated',
            resource_type='system',
            resource_id=tenant_id,
            details={'reactivated_by': current_user.user_id},
            ip_address=getattr(current_user, 'ip_address', None)
        )

        return {"message": "Tenant reactivated successfully", "tenant_id": tenant_id}

    except Exception as e:
        logger.error(f"Failed to reactivate tenant {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to reactivate tenant"
        )


@router.post("/{tenant_id}/config")
async def update_tenant_config(
    tenant_id: str,
    config_key: str,
    config_value: Any,
    config_type: Optional[str] = 'string',
    current_user: UserContext = Depends(get_current_user_context),
    tenant_service: TenantService = Depends(get_tenant_service)
):
    """
    Update tenant configuration
    """
    if not current_user.has_permission("tenants.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update tenant configuration"
        )

    try:
        tenant_service.update_tenant_config(tenant_id, config_key, config_value, config_type)

        # Audit the config update
        audit_service = AuditService(tenant_service)
        audit_service.log_tenant_activity(
            tenant_id=tenant_id,
            user_id=current_user.user_id,
            action='tenant_config_updated',
            resource_type='system',
            resource_id=tenant_id,
            details={
                'config_key': config_key,
                'config_type': config_type,
                'updated_by': current_user.user_id
            },
            ip_address=getattr(current_user, 'ip_address', None)
        )

        return {"message": "Tenant configuration updated successfully"}

    except Exception as e:
        logger.error(f"Failed to update tenant config {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update tenant configuration"
        )
