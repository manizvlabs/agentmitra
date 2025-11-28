"""
Feature Flags API Endpoints
Provides endpoints for managing feature flags (Pioneer-compatible API)
"""

from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.services.feature_flag_service import get_feature_flag_service
from app.core.auth_middleware import require_permission
from app.core.logging_config import get_logger

logger = get_logger(__name__)

router = APIRouter()


@router.get("/user/{user_id}")
async def get_user_feature_flags(
    user_id: str,
    tenant_id: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user = Depends(require_permission("feature_flags.read"))
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
    current_user = Depends(require_permission("feature_flags.read"))
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
    current_user = Depends(require_permission("feature_flags.read"))
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
    current_user = Depends(require_permission("feature_flags.update"))
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
    current_user = Depends(require_permission("feature_flags.update"))
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
    current_user = Depends(require_permission("feature_flags.admin"))
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
    current_user = Depends(require_permission("feature_flags.update"))
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


# Pioneer-compatible API endpoints (matching Flutter expectations)

@router.get("/api/flags")
async def get_pioneer_flags():
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
async def create_pioneer_flag(flag_data: Dict[str, Any]):
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

        # Create flag in database
        from app.repositories.feature_flag_repository import FeatureFlagRepository
        from app.core.database import get_db
        db = next(get_db())
        repo = FeatureFlagRepository(db)

        success = await repo.create_flag(title, description, "BOOLEAN", is_active)

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
async def update_pioneer_flag(flag_id: str, flag_data: Dict[str, Any]):
    """Update a feature flag (Pioneer API format)"""
    try:
        flag_info = flag_data.get("flag", {})
        description = flag_info.get("description")
        is_active = flag_info.get("is_active")
        rollout = flag_info.get("rollout")

        # Extract title from flag_id (remove pioneer- prefix)
        title = flag_id.replace("pioneer-", "")

        # Update flag in database
        from app.repositories.feature_flag_repository import FeatureFlagRepository
        from app.core.database import get_db
        db = next(get_db())
        repo = FeatureFlagRepository(db)

        success = await repo.update_flag_value(title, bool(is_active) if is_active is not None else None)

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
async def delete_pioneer_flag(flag_id: str):
    """Delete a feature flag (Pioneer API format)"""
    try:
        # Extract title from flag_id (remove pioneer- prefix)
        title = flag_id.replace("pioneer-", "")

        # Delete flag from database
        from app.repositories.feature_flag_repository import FeatureFlagRepository
        from app.core.database import get_db
        db = next(get_db())
        repo = FeatureFlagRepository(db)

        success = await repo.delete_flag_override(title)

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
) -> Dict[str, bool]:
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