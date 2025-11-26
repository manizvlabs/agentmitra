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

