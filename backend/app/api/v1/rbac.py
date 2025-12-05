"""
RBAC Management API Endpoints - Role-Based Access Control
"""
import logging
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, UUID4
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.auth import get_current_user_context, UserContext, auth_service
from app.core.audit_service import AuditService
from app.models.rbac import UserRole, Role, RolePermission, Permission

logger = logging.getLogger(__name__)

router = APIRouter()


# Request/Response Models
class RoleResponse(BaseModel):
    role_id: str
    role_name: str
    role_description: Optional[str]
    is_system_role: bool
    permissions: List[str]

class UserRoleResponse(BaseModel):
    user_id: str
    user_name: str
    user_email: str
    roles: List[str]
    permissions: List[str]

class AssignRoleRequest(BaseModel):
    user_id: str
    role_name: str

class RemoveRoleRequest(BaseModel):
    user_id: str
    role_name: str

class FeatureFlagRequest(BaseModel):
    flag_name: str
    enabled: bool
    tenant_id: Optional[str] = None

class FeatureFlagResponse(BaseModel):
    flag_id: str
    flag_name: str
    flag_description: Optional[str]
    flag_type: str
    is_enabled: bool
    tenant_id: Optional[str]
    created_at: str
    updated_at: str


# API Endpoints

@router.get("/roles", response_model=List[RoleResponse])
async def get_roles(
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Get all available roles with their permissions
    """
    if not current_user.has_permission("system.admin"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view roles"
        )

    try:
        roles_data = auth_service.get_all_roles(db)

        # Deduplicate roles by role_name (prefer system roles and keep the first occurrence)
        seen_names = set()
        unique_roles_data = []
        for role_data in roles_data:
            role_name = role_data['role_name']
            if role_name not in seen_names:
                seen_names.add(role_name)
                unique_roles_data.append(role_data)

        roles = []

        for role_data in unique_roles_data:
            permissions = auth_service.get_role_permissions(role_data['role_name'], db)
            roles.append(RoleResponse(
                role_id=role_data['role_id'],
                role_name=role_data['role_name'],
                role_description=role_data['description'],
                is_system_role=role_data['is_system_role'],
                permissions=permissions
            ))

        return roles

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve roles: {str(e)}"
        )


@router.get("/users/{user_id}/roles", response_model=UserRoleResponse)
async def get_user_roles(
    user_id: str,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Get roles and permissions for a specific user
    """
    if not current_user.has_permission("users.read") and current_user.user_id != user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view user roles"
        )

    try:
        from app.models.user import User

        user = db.query(User).filter(User.user_id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        roles = auth_service.get_user_roles(user_id, db)
        permissions = auth_service.get_user_permissions(user_id, db)

        return UserRoleResponse(
            user_id=user_id,
            user_name=user.full_name or f"{user.first_name} {user.last_name}".strip(),
            user_email=user.email,
            roles=roles,
            permissions=permissions
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve user roles: {str(e)}"
        )


@router.post("/users/assign-role")
async def assign_role_to_user(
    request: AssignRoleRequest,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Assign a role to a user
    """
    if not current_user.has_permission("users.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to assign roles"
        )

    try:
        success = auth_service.assign_role_to_user(
            user_id=request.user_id,
            role_name=request.role_name,
            assigned_by=current_user.user_id,
            db=db
        )

        if not success:
            # Log more details about the failure
            logger.error(f"Role assignment failed for user {request.user_id}, role {request.role_name}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to assign role"
            )

        return {"message": f"Role {request.role_name} assigned to user {request.user_id}"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Exception during role assignment: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to assign role: {str(e)}"
        )


@router.post("/users/remove-role")
async def remove_role_from_user(
    request: RemoveRoleRequest,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Remove a role from a user
    """
    if not current_user.has_permission("users.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to remove roles"
        )

    try:
        success = auth_service.remove_role_from_user(
            user_id=request.user_id,
            role_name=request.role_name,
            removed_by=current_user.user_id,
            db=db
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to remove role"
            )

        return {"message": f"Role {request.role_name} removed from user {request.user_id}"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove role: {str(e)}"
        )


@router.get("/permissions")
async def get_all_permissions(
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Get all available permissions
    """
    if not current_user.has_permission("system.admin"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view permissions"
        )

    try:
        permissions = db.query(Permission).all()
        return [{
            "permission_id": str(p.permission_id),
            "permission_name": p.permission_name,
            "resource_type": p.resource,
            "action": p.action,
            "description": p.permission_description
        } for p in permissions]

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve permissions: {str(e)}"
        )


@router.post("/feature-flags")
async def set_feature_flag(
    request: FeatureFlagRequest,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Enable/disable a feature flag
    """
    if not current_user.has_permission("feature_flags.update"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to manage feature flags"
        )

    try:
        success = auth_service.set_feature_flag(
            flag_name=request.flag_name,
            enabled=request.enabled,
            updated_by=current_user.user_id,
            tenant_id=request.tenant_id,
            db=db
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update feature flag"
            )

        return {
            "message": f"Feature flag {request.flag_name} {'enabled' if request.enabled else 'disabled'}",
            "flag_name": request.flag_name,
            "enabled": request.enabled
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update feature flag: {str(e)}"
        )


@router.get("/feature-flags", response_model=List[FeatureFlagResponse])
async def get_feature_flags(
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Get all feature flags
    """
    if not current_user.has_permission("feature_flags.read"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view feature flags"
        )

    try:
        from app.models.feature_flags import FeatureFlag

        query = db.query(FeatureFlag)
        if tenant_id:
            query = query.filter(FeatureFlag.tenant_id == tenant_id)

        flags = query.all()

        return [FeatureFlagResponse(
            flag_id=str(f.flag_id),
            flag_name=f.flag_name,
            flag_description=f.flag_description,
            flag_type=f.flag_type,
            is_enabled=f.is_enabled,
            tenant_id=str(f.tenant_id) if f.tenant_id else None,
            created_at=f.created_at.isoformat(),
            updated_at=f.updated_at.isoformat()
        ) for f in flags]

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve feature flags: {str(e)}"
        )


@router.get("/check-permission")
async def check_user_permission(
    permission: str,
    user_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Check if a user has a specific permission (for debugging/testing)
    """
    if not current_user.has_permission("system.admin"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to check user permissions"
        )

    check_user_id = user_id or current_user.user_id

    try:
        has_perm = auth_service.has_permission(check_user_id, permission, db)

        return {
            "user_id": check_user_id,
            "permission": permission,
            "has_permission": has_perm,
            "user_roles": auth_service.get_user_roles(check_user_id, db),
            "user_permissions": auth_service.get_user_permissions(check_user_id, db)
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check permission: {str(e)}"
        )


@router.get("/audit-log")
async def get_rbac_audit_log(
    limit: int = 50,
    offset: int = 0,
    action: Optional[str] = None,
    user_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """
    Get RBAC audit log entries
    """
    if not current_user.has_permission("audit.read"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view audit logs"
        )

    try:
        # Use raw SQL to avoid model import issues
        from sqlalchemy import text

        # Build the query dynamically
        sql = """
        SELECT audit_id, tenant_id, user_id, action, target_user_id,
               target_role_id, target_permission_id, target_flag_id,
               details, success, timestamp
        FROM lic_schema.rbac_audit_log
        WHERE 1=1
        """

        params = {}

        if action:
            sql += " AND action = :action"
            params['action'] = action

        if user_id:
            sql += " AND user_id = :user_id"
            params['user_id'] = user_id

        sql += " ORDER BY timestamp DESC LIMIT :limit OFFSET :offset"
        params['limit'] = limit
        params['offset'] = offset

        # Execute the query
        result = db.execute(text(sql), params)

        audit_entries = []
        for row in result:
            audit_entries.append({
                "audit_id": str(row.audit_id),
                "tenant_id": str(row.tenant_id) if row.tenant_id else None,
                "user_id": str(row.user_id) if row.user_id else None,
                "action": row.action,
                "target_user_id": str(row.target_user_id) if row.target_user_id else None,
                "target_role_id": str(row.target_role_id) if row.target_role_id else None,
                "details": row.details,
                "success": row.success,
                "timestamp": row.timestamp.isoformat() if row.timestamp else None
            })

        return audit_entries

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve audit log: {str(e)}"
        )
