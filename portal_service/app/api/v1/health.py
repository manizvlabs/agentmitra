"""
Portal Health Check API
=======================

Health check endpoints for the Agent Configuration Portal.
"""

from fastapi import APIRouter
from app.core.database import check_db_connection

router = APIRouter()


@router.get("/health")
async def portal_health():
    """Portal service health check"""
    try:
        # Check database connection
        db_status = check_db_connection()

        # Check main API connectivity
        # This would make a request to the main API

        return {
            "status": "healthy" if db_status["status"] == "healthy" else "degraded",
            "service": "agent-portal",
            "version": "1.0.0",
            "components": {
                "database": db_status,
                "main_api": {"status": "unknown"},  # Would be checked
                "storage": {"status": "healthy"}  # Would be checked
            }
        }

    except Exception as e:
        return {
            "status": "unhealthy",
            "service": "agent-portal",
            "error": str(e)
        }


@router.get("/ready")
async def readiness_check():
    """Kubernetes readiness probe"""
    try:
        db_status = check_db_connection()
        is_ready = db_status["status"] == "healthy"

        return {
            "ready": is_ready,
            "database": db_status["status"]
        }

    except Exception:
        return {
            "ready": False,
            "database": "error"
        }
