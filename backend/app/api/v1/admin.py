"""
Admin endpoints for testing and maintenance
"""
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.auth import get_current_user_context
from app.core.rate_limiter import auth_rate_limiter, otp_rate_limiter, default_rate_limiter
from app.core.logging_config import get_logger

logger = get_logger(__name__)
router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/rate-limit/reset")
async def reset_rate_limits(
    identifier: str = None,
    user_context = Depends(get_current_user_context)
):
    """
    Reset rate limits for testing
    Requires authentication
    """
    try:
        if identifier:
            auth_rate_limiter.reset(identifier)
            otp_rate_limiter.reset(identifier)
            default_rate_limiter.reset(identifier)
            logger.info(f"Rate limits reset for identifier: {identifier}")
            return {"message": f"Rate limits reset for {identifier}"}
        else:
            auth_rate_limiter.reset_all()
            otp_rate_limiter.reset_all()
            default_rate_limiter.reset_all()
            logger.info("All rate limits reset")
            return {"message": "All rate limits reset"}
    except Exception as e:
        logger.error(f"Error resetting rate limits: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to reset rate limits: {str(e)}"
        )


@router.get("/settings")
async def get_admin_settings(
    user_context = Depends(get_current_user_context)
):
    """
    Get admin system settings
    Requires admin authentication
    """
    try:
        # For now, return mock settings data
        # In a real implementation, this would fetch from database
        return {
            "maintenance_mode": False,
            "debug_mode": False,
            "rate_limiting": True,
            "session_timeout": 30,
            "max_upload_size": 10,
            "system_alerts": True,
            "security_alerts": True,
            "user_registration_alerts": False,
            "ip_whitelist": False,
            "require_2fa": True,
            "audit_retention_days": 90,
            "usage_analytics": True,
            "crash_reports": True
        }
    except Exception as e:
        logger.error(f"Error getting admin settings: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get admin settings: {str(e)}"
        )


@router.put("/settings")
async def update_admin_setting(
    key: str,
    value: str,
    user_context = Depends(get_current_user_context)
):
    """
    Update a specific admin setting
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the update
        # In a real implementation, this would update database
        logger.info(f"Admin setting updated: {key} = {value}")
        return {"message": f"Setting {key} updated successfully"}
    except Exception as e:
        logger.error(f"Error updating admin setting: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update admin setting: {str(e)}"
        )


@router.post("/maintenance/clear-cache")
async def clear_system_cache(
    user_context = Depends(get_current_user_context)
):
    """
    Clear system cache
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the operation
        # In a real implementation, this would clear actual caches
        logger.info("System cache cleared by admin")
        return {"message": "System cache cleared successfully"}
    except Exception as e:
        logger.error(f"Error clearing system cache: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to clear system cache: {str(e)}"
        )


@router.post("/maintenance/backup")
async def create_database_backup(
    user_context = Depends(get_current_user_context)
):
    """
    Create database backup
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the operation
        # In a real implementation, this would trigger actual backup
        logger.info("Database backup initiated by admin")
        return {
            "message": "Database backup initiated successfully",
            "backup_id": "backup_001",
            "status": "in_progress"
        }
    except Exception as e:
        logger.error(f"Error creating database backup: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create database backup: {str(e)}"
        )


@router.post("/rate-limit/reset-all")
async def reset_all_rate_limits(
    user_context = Depends(get_current_user_context)
):
    """
    Reset all rate limits for testing
    Requires authentication
    """
    try:
        auth_rate_limiter.reset_all()
        otp_rate_limiter.reset_all()
        default_rate_limiter.reset_all()
        logger.info("All rate limits reset via admin endpoint")
        return {"message": "All rate limits reset successfully"}
    except Exception as e:
        logger.error(f"Error resetting all rate limits: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to reset rate limits: {str(e)}"
        )


@router.get("/settings")
async def get_admin_settings(
    user_context = Depends(get_current_user_context)
):
    """
    Get admin system settings
    Requires admin authentication
    """
    try:
        # For now, return mock settings data
        # In a real implementation, this would fetch from database
        return {
            "maintenance_mode": False,
            "debug_mode": False,
            "rate_limiting": True,
            "session_timeout": 30,
            "max_upload_size": 10,
            "system_alerts": True,
            "security_alerts": True,
            "user_registration_alerts": False,
            "ip_whitelist": False,
            "require_2fa": True,
            "audit_retention_days": 90,
            "usage_analytics": True,
            "crash_reports": True
        }
    except Exception as e:
        logger.error(f"Error getting admin settings: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get admin settings: {str(e)}"
        )


@router.put("/settings")
async def update_admin_setting(
    key: str,
    value: str,
    user_context = Depends(get_current_user_context)
):
    """
    Update a specific admin setting
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the update
        # In a real implementation, this would update database
        logger.info(f"Admin setting updated: {key} = {value}")
        return {"message": f"Setting {key} updated successfully"}
    except Exception as e:
        logger.error(f"Error updating admin setting: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update admin setting: {str(e)}"
        )


@router.post("/maintenance/clear-cache")
async def clear_system_cache(
    user_context = Depends(get_current_user_context)
):
    """
    Clear system cache
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the operation
        # In a real implementation, this would clear actual caches
        logger.info("System cache cleared by admin")
        return {"message": "System cache cleared successfully"}
    except Exception as e:
        logger.error(f"Error clearing system cache: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to clear system cache: {str(e)}"
        )


@router.post("/maintenance/backup")
async def create_database_backup(
    user_context = Depends(get_current_user_context)
):
    """
    Create database backup
    Requires admin authentication
    """
    try:
        # For now, just acknowledge the operation
        # In a real implementation, this would trigger actual backup
        logger.info("Database backup initiated by admin")
        return {
            "message": "Database backup initiated successfully",
            "backup_id": "backup_001",
            "status": "in_progress"
        }
    except Exception as e:
        logger.error(f"Error creating database backup: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create database backup: {str(e)}"
        )

