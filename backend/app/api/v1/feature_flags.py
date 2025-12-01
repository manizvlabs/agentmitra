"""
Feature Flags API Endpoints
Provides endpoints for managing feature flags (Pioneer-compatible API)
"""

from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status, WebSocket
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.feature_flag_service import get_feature_flag_service
from app.core.auth_middleware import require_permission
from app.core.logging_config import get_logger
from app.core.websocket_manager import websocket_manager

logger = get_logger(__name__)

router = APIRouter()


@router.get("/user/{user_id}")
async def get_user_feature_flags(
    user_id: str,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
) -> Dict[str, bool]:
    """Get feature flags for a specific user"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        flags = await feature_flag_service.get_user_feature_flags(user_id, tenant_id)
        return flags
    except Exception as e:
        logger.error(f"Error getting user feature flags for {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get user feature flags"
        )


@router.get("/tenant/{tenant_id}")
async def get_tenant_feature_flags(
    tenant_id: str,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
) -> Dict[str, bool]:
    """Get feature flags for a specific tenant"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        flags = await feature_flag_service.get_tenant_feature_flags(tenant_id)
        return flags
    except Exception as e:
        logger.error(f"Error getting tenant feature flags for {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get tenant feature flags"
        )


@router.get("/all")
async def get_all_feature_flags(
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
) -> List[Dict[str, Any]]:
    """Get all available feature flags"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        flags = await feature_flag_service.get_all_feature_flags()
        return flags
    except Exception as e:
        logger.error(f"Error getting all feature flags: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get feature flags"
        )


@router.put("/user/{user_id}/{flag_name}")
async def update_user_feature_flag(
    user_id: str,
    flag_name: str,
    value: bool,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """Update a feature flag for a specific user"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        success = await feature_flag_service.update_feature_flag(flag_name, value, user_id, tenant_id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update feature flag {flag_name}"
            )

        # Broadcast real-time update to the affected user
        await websocket_manager.broadcast_feature_update(user_id, flag_name, value)

        return {"success": True, "message": f"Feature flag {flag_name} updated to {value}"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating user feature flag {flag_name} for {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update feature flag"
        )


@router.put("/tenant/{tenant_id}/{flag_name}")
async def update_tenant_feature_flag(
    tenant_id: str,
    flag_name: str,
    value: bool,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """Update a feature flag for a specific tenant"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        success = await feature_flag_service.update_feature_flag(flag_name, value, None, tenant_id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update feature flag {flag_name}"
            )

        return {"success": True, "message": f"Feature flag {flag_name} updated to {value}"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating tenant feature flag {flag_name} for {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update feature flag"
        )


@router.post("/create")
async def create_feature_flag(
    flag_name: str,
    description: str = "",
    flag_type: str = "boolean",
    default_value: Any = False,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """Create a new feature flag"""
    try:
        from app.repositories.feature_flag_repository import FeatureFlagRepository

        repo = FeatureFlagRepository(db)
        success = await repo.create_flag(flag_name, description, flag_type, default_value, tenant_id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Feature flag {flag_name} already exists or failed to create"
            )

        return {"success": True, "message": f"Feature flag {flag_name} created successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating feature flag {flag_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create feature flag"
        )


@router.delete("/override/user/{user_id}/{flag_name}")
async def delete_user_flag_override(
    user_id: str,
    flag_name: str,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """Delete a user-specific feature flag override"""
    try:
        from app.repositories.feature_flag_repository import FeatureFlagRepository

        repo = FeatureFlagRepository(db)
        success = await repo.delete_flag_override(flag_name, user_id, tenant_id)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Feature flag override not found for {flag_name}"
            )

        return {"success": True, "message": f"Feature flag override deleted for {flag_name}"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting user flag override {flag_name} for {user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete feature flag override"
        )


# WebSocket endpoint for real-time feature flag updates
@router.websocket("/ws/{user_id}")
async def feature_flag_websocket(websocket: WebSocket, user_id: str):
    """WebSocket endpoint for real-time feature flag updates"""
    await websocket_manager.connect(websocket, user_id)
    try:
        while True:
            # Keep connection alive and handle client messages/acknowledgments
            data = await websocket.receive_json()
            logger.debug(f"Received WebSocket message from user {user_id}: {data}")

            # Handle client acknowledgments or ping responses
            if data.get("type") == "ack":
                logger.debug(f"Received acknowledgment from user {user_id}")
            elif data.get("type") == "ping":
                # Respond to ping
                await websocket.send_json({"type": "pong", "timestamp": "now"})

    except Exception as e:
        logger.warning(f"WebSocket error for user {user_id}: {e}")
    finally:
        await websocket_manager.disconnect(websocket, user_id)


# Enhanced feature flag update endpoint with real-time broadcasting
@router.put("/update/{flag_name}")
async def update_feature_flag(
    flag_name: str,
    update_request: Dict[str, Any],
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """Update a feature flag with real-time broadcasting to affected users"""
    try:
        new_value = update_request.get("new_value")
        target_users = update_request.get("target_users", [])
        tenant_id = update_request.get("tenant_id")

        if new_value is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="new_value is required"
            )

        feature_flag_service = get_feature_flag_service(db)

        # Update feature flag in database
        if target_users:
            # Update for specific users
            success_count = 0
            for user_id in target_users:
                success = await feature_flag_service.update_feature_flag(flag_name, new_value, user_id, tenant_id)
                if success:
                    success_count += 1
                    # Broadcast real-time update to each affected user
                    await websocket_manager.broadcast_feature_update(user_id, flag_name, new_value)
        else:
            # Update globally or for tenant
            success = await feature_flag_service.update_feature_flag(flag_name, new_value, None, tenant_id)
            success_count = 1 if success else 0

            if success and not tenant_id:
                # Broadcast to all connected users for global updates
                await websocket_manager.broadcast_to_all_users(flag_name, new_value)

        if success_count == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to update feature flag {flag_name}"
            )

        return {
            "success": True,
            "message": f"Feature flag {flag_name} updated to {new_value}",
            "affected_users": len(target_users) if target_users else "all"
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating feature flag {flag_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update feature flag"
        )


# Pioneer-compatible API endpoints (matching Flutter expectations)

@router.get("/api/flags")
async def get_pioneer_flags(current_user = Depends(require_permission("system.admin"))):
    """Get all feature flags in Pioneer API format (for Flutter compatibility)"""
    try:
        feature_flag_service = get_feature_flag_service(None)  # No DB needed for fallback
        flags = await feature_flag_service._fetch_from_pioneer()

        # Convert to Pioneer API format that Flutter expects
        pioneer_flags = []
        for flag_name, is_active in flags.items():
            pioneer_flags.append({
                "id": f"pioneer-{flag_name}",  # Generate ID for compatibility
                "title": flag_name,
                "description": f"Feature flag: {flag_name}",
                "is_active": bool(is_active),
                "rollout": 100 if is_active else 0,
                "version": 1
            })

        return {"flags": pioneer_flags}
    except Exception as e:
        logger.error(f"Error getting Pioneer flags: {e}")
        # Return empty flags on error
        return {"flags": []}


@router.post("/flags")
async def create_pioneer_flag(flag_data: Dict[str, Any], current_user = Depends(require_permission("system.admin"))):
    """Create a new feature flag (Pioneer API format)"""
    try:
        flag_info = flag_data.get("flag", {})
        title = flag_info.get("title")
        description = flag_info.get("description", "")
        is_active = flag_info.get("is_active", False)
        rollout = flag_info.get("rollout", 0)

        if not title:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Flag title is required"
            )

        # Create flag in Pioneer database
        from app.repositories.pioneer_repository import PioneerRepository

        repo = PioneerRepository()

        success = repo.create_flag(title, description, is_active, rollout)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to create flag {title}"
            )

        # Return in Pioneer format
        return {
            "id": f"pioneer-{title}",
            "title": title,
            "description": description,
            "is_active": is_active,
            "rollout": rollout,
            "version": 1
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating Pioneer flag: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create feature flag"
        )


@router.put("/flags/{flag_id}")
async def update_pioneer_flag(flag_id: str, flag_data: Dict[str, Any], current_user = Depends(require_permission("system.admin"))):
    """Update a feature flag (Pioneer API format)"""
    try:
        flag_info = flag_data.get("flag", {})
        description = flag_info.get("description")
        is_active = flag_info.get("is_active")
        rollout = flag_info.get("rollout")

        # Extract title from flag_id (remove pioneer- prefix)
        title = flag_id.replace("pioneer-", "")

        # Update flag in Pioneer database
        from app.repositories.pioneer_repository import PioneerRepository

        repo = PioneerRepository()

        success = repo.update_flag(title, is_active, rollout, description)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Flag {title} not found"
            )

        # Return in Pioneer format
        return {
            "id": flag_id,
            "title": title,
            "description": description or f"Feature flag: {title}",
            "is_active": is_active,
            "rollout": rollout or 100,
            "version": 1
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating Pioneer flag {flag_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update feature flag"
        )


@router.delete("/flags/{flag_id}")
async def delete_pioneer_flag(flag_id: str, current_user = Depends(require_permission("system.admin"))):
    """Delete a feature flag (Pioneer API format)"""
    try:
        # Extract title from flag_id (remove pioneer- prefix)
        title = flag_id.replace("pioneer-", "")

        # Delete flag from Pioneer database
        from app.repositories.pioneer_repository import PioneerRepository

        repo = PioneerRepository()

        success = repo.delete_flag(title)

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Flag {title} not found"
            )

        return {"success": True, "message": f"Flag {title} deleted"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting Pioneer flag {flag_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete feature flag"
        )


@router.get("/check/{flag_name}")
async def check_feature_flag(
    flag_name: str,
    user_id: Optional[str] = None,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """Check if a specific feature flag is enabled"""
    try:
        feature_flag_service = get_feature_flag_service(db)
        is_enabled = await feature_flag_service.is_feature_enabled(flag_name, user_id, tenant_id)
        return {"flag_name": flag_name, "enabled": is_enabled}
    except Exception as e:
        logger.error(f"Error checking feature flag {flag_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to check feature flag"
        )


# Role-based access control endpoints
@router.post("/role-access")
async def manage_role_feature_access(
    role_name: str,
    feature_flags: Dict[str, bool],
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """
    Manage feature flag access for a specific role

    - **role_name**: Role name to update
    - **feature_flags**: Dictionary of feature flags and their enabled status
    """
    try:
        # Update feature flags for all users with this role
        from app.services.rbac_service import RBACService
        rbac_service = RBACService(db)
        users_with_role = rbac_service.get_users_by_role(role_name)

        success_count = 0
        feature_flag_service = get_feature_flag_service(db)

        for user in users_with_role:
            user_id = str(user['user_id'])
            user_success = True

            for flag_name, enabled in feature_flags.items():
                flag_success = await feature_flag_service.update_feature_flag(
                    flag_name, enabled, user_id
                )
                if not flag_success:
                    user_success = False

            if user_success:
                success_count += 1

                # Broadcast updates to user's WebSocket connections
                for flag_name, enabled in feature_flags.items():
                    await websocket_manager.broadcast_feature_update(user_id, flag_name, enabled)

        return {
            "success": True,
            "message": f"Updated feature access for {success_count}/{len(users_with_role)} users with role {role_name}",
            "updated_users": success_count,
            "total_users": len(users_with_role)
        }

    except Exception as e:
        logger.error(f"Error managing role feature access for {role_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update role feature access"
        )


@router.post("/broadcast/role/{role_name}")
async def broadcast_to_role(
    role_name: str,
    feature_key: str,
    new_value: bool,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """
    Broadcast feature flag update to all users with a specific role

    - **role_name**: Target role name
    - **feature_key**: Feature flag name
    - **new_value**: New boolean value for the feature flag
    """
    try:
        await websocket_manager.broadcast_to_role(role_name, feature_key, new_value, db)

        return {
            "success": True,
            "message": f"Broadcasted feature flag {feature_key}={new_value} to all users with role {role_name}"
        }

    except Exception as e:
        logger.error(f"Error broadcasting to role {role_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to broadcast to role"
        )


@router.post("/broadcast/tenant/{tenant_id}")
async def broadcast_to_tenant(
    tenant_id: str,
    feature_key: str,
    new_value: bool,
    current_user = Depends(require_permission("system.admin"))
):
    """
    Broadcast feature flag update to all users in a specific tenant

    - **tenant_id**: Target tenant ID
    - **feature_key**: Feature flag name
    - **new_value**: New boolean value for the feature flag
    """
    try:
        await websocket_manager.broadcast_to_tenant(tenant_id, feature_key, new_value)

        return {
            "success": True,
            "message": f"Broadcasted feature flag {feature_key}={new_value} to all users in tenant {tenant_id}"
        }

    except Exception as e:
        logger.error(f"Error broadcasting to tenant {tenant_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to broadcast to tenant"
        )


@router.get("/websocket/stats")
async def get_websocket_stats(
    current_user = Depends(require_permission("system.admin"))
):
    """
    Get WebSocket connection statistics
    """
    try:
        stats = await websocket_manager.get_active_users_count()

        return {
            "success": True,
            "data": stats
        }

    except Exception as e:
        logger.error(f"Error getting WebSocket stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get WebSocket statistics"
        )


@router.get("/role-access/{role_name}")
async def get_role_feature_access(
    role_name: str,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("system.admin"))
):
    """
    Get feature flag access configuration for a specific role

    - **role_name**: Role name to check
    """
    try:
        # Get a sample user with this role to check their feature flags
        from app.services.rbac_service import RBACService
        rbac_service = RBACService(db)
        users_with_role = rbac_service.get_users_by_role(role_name)

        if not users_with_role:
            return {
                "success": True,
                "data": {
                    "role_name": role_name,
                    "user_count": 0,
                    "feature_flags": {}
                }
            }

        # Get feature flags for the first user with this role
        sample_user_id = str(users_with_role[0]['user_id'])
        feature_flag_service = get_feature_flag_service(db)
        flags = await feature_flag_service.get_user_feature_flags(sample_user_id)

        return {
            "success": True,
            "data": {
                "role_name": role_name,
                "user_count": len(users_with_role),
                "sample_user_id": sample_user_id,
                "feature_flags": flags
            }
        }

    except Exception as e:
        logger.error(f"Error getting role feature access for {role_name}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get role feature access"
        )


@router.get("/access-control/rules")
async def get_access_control_rules(
    current_user = Depends(require_permission("system.admin"))
):
    """
    Get feature flag access control rules
    """
    access_rules = {
        "agent_only_features": [
            "agent_dashboard_enabled",
            "customer_management_enabled",
            "marketing_campaigns_enabled",
            "commission_tracking_enabled",
            "lead_management_enabled",
            "advanced_analytics_enabled",
            "team_management_enabled",
            "regional_oversight_enabled",
            "content_management_enabled",
            "roi_analytics_enabled"
        ],
        "customer_only_features": [
            "customer_dashboard_enabled",
            "policy_management_enabled",
            "premium_payments_enabled",
            "document_access_enabled"
        ],
        "admin_only_features": [
            "user_management_enabled",
            "feature_flag_control_enabled",
            "system_configuration_enabled",
            "audit_compliance_enabled",
            "financial_management_enabled",
            "tenant_management_enabled",
            "provider_administration_enabled"
        ],
        "permission_based_features": {
            "analytics:read": ["advanced_analytics_enabled", "roi_analytics_enabled"],
            "campaigns:read": ["marketing_campaigns_enabled"],
            "customers:read": ["customer_management_enabled"],
            "feature_flags:read": ["feature_flag_control_enabled"],
            "users:read": ["user_management_enabled"],
            "policies:read": ["policy_management_enabled"]
        }
    }

    return {
        "success": True,
        "data": access_rules
    }