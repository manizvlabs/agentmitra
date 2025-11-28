"""
Portal Service API Router
=========================

Main API router for the Agent Configuration Portal.
Includes routes for agent management, data import, and administrative functions.
"""

from fastapi import APIRouter

from . import (
    auth,
    agents,
    data_import,
    dashboard,
    callbacks,
    content,
    health
)

# Create main API router
api_router = APIRouter(prefix="/api/v1", tags=["portal-api"])

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(agents.router, prefix="/agents", tags=["agents"])
api_router.include_router(data_import.router, prefix="/import", tags=["data-import"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
api_router.include_router(callbacks.router, prefix="/callbacks", tags=["callbacks"])
api_router.include_router(content.router, prefix="/content", tags=["content"])
api_router.include_router(health.router, tags=["health"])
