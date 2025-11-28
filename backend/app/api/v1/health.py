"""
Health check endpoints with detailed monitoring
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any
import psutil
import time
from app.core.database import get_db, check_db_connection, get_db_stats
from app.core.config.settings import settings
from app.core.logging_config import get_logger
from app.core.monitoring import monitoring

router = APIRouter()
logger = get_logger(__name__)


@router.get("/health/database")
async def database_health(db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    Detailed database health check with connection pool stats
    """
    try:
        # Check database connection
        db_status = check_db_connection()
        db_stats = get_db_stats()

        response = {
            "status": db_status["status"],
            "database": {
                "connection": db_status,
                "pool_stats": db_stats,
                "schema": "lic_schema",  # Primary schema being used
            },
            "timestamp": time.time(),
        }

        if db_status["status"] != "healthy":
            logger.error(f"Database health check failed: {db_status}")
            raise HTTPException(
                status_code=503,
                detail="Database connection unhealthy"
            )

        return response

    except Exception as e:
        logger.error(f"Database health check error: {e}")
        raise HTTPException(
            status_code=503,
            detail=f"Database health check failed: {str(e)}"
        )


@router.get("/health/system")
async def system_health() -> Dict[str, Any]:
    """
    System health check with resource monitoring
    """
    try:
        # Memory usage
        memory = psutil.virtual_memory()
        memory_info = {
            "total_gb": round(memory.total / (1024**3), 2),
            "available_gb": round(memory.available / (1024**3), 2),
            "used_gb": round(memory.used / (1024**3), 2),
            "usage_percent": memory.percent,
        }

        # CPU usage
        cpu_info = {
            "usage_percent": psutil.cpu_percent(interval=1),
            "cores": psutil.cpu_count(),
            "cores_logical": psutil.cpu_count(logical=True),
        }

        # Disk usage
        disk = psutil.disk_usage('/')
        disk_info = {
            "total_gb": round(disk.total / (1024**3), 2),
            "free_gb": round(disk.free / (1024**3), 2),
            "used_gb": round(disk.used / (1024**3), 2),
            "usage_percent": disk.percent,
        }

        return {
            "status": "healthy",
            "system": {
                "memory": memory_info,
                "cpu": cpu_info,
                "disk": disk_info,
            },
            "environment": settings.environment,
            "timestamp": time.time(),
        }

    except Exception as e:
        logger.error(f"System health check error: {e}")
        return {
            "status": "degraded",
            "error": str(e),
            "timestamp": time.time(),
        }


@router.get("/health/comprehensive")
async def comprehensive_health(db: Session = Depends(get_db)) -> Dict[str, Any]:
    """
    Comprehensive health check including all components
    """
    try:
        # Database health
        db_status = check_db_connection()
        db_stats = get_db_stats()

        # System health
        memory = psutil.virtual_memory()
        cpu_percent = psutil.cpu_percent(interval=0.5)

        # Application health
        app_health = {
            "environment": settings.environment,
            "debug_mode": settings.debug,
            "uptime_seconds": time.time() - psutil.boot_time(),
        }

        overall_status = "healthy"
        if db_status["status"] != "healthy":
            overall_status = "degraded"
        if memory.percent > 90 or cpu_percent > 95:
            overall_status = "critical"

        return {
            "status": overall_status,
            "components": {
                "database": {
                    "status": db_status["status"],
                    "response_time_ms": db_status.get("response_time_ms"),
                    "pool_stats": db_stats,
                },
                "system": {
                    "memory_usage_percent": memory.percent,
                    "cpu_usage_percent": cpu_percent,
                    "disk_usage_percent": psutil.disk_usage('/').percent,
                },
                "application": app_health,
            },
            "timestamp": time.time(),
        }

    except Exception as e:
        logger.error(f"Comprehensive health check error: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": time.time(),
        }


@router.get("/metrics")
async def get_metrics() -> str:
    """
    Prometheus metrics endpoint
    Returns metrics in Prometheus format for monitoring
    """
    try:
        return await monitoring.get_metrics()
    except Exception as e:
        logger.error(f"Metrics endpoint error: {e}")
        return f"# Error generating metrics: {str(e)}"


@router.get("/health/monitoring")
async def monitoring_health() -> Dict[str, Any]:
    """
    Detailed monitoring health check with all component statuses
    """
    try:
        health_status = await monitoring.health_check()

        return {
            "status": health_status.status,
            "timestamp": health_status.timestamp,
            "checks": health_status.checks,
            "version": settings.app_version,
            "environment": settings.environment
        }

    except Exception as e:
        logger.error(f"Monitoring health check error: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": time.time(),
        }
