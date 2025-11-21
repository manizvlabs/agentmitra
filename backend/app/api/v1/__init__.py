"""
Agent Mitra - API v1 Router
Main API router that combines all endpoint routers
"""

from fastapi import APIRouter
from . import auth, users, policies, presentations, chat, analytics, feature_flags, health

# Create main API router
api_router = APIRouter(prefix="/api/v1", tags=["api"])

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(policies.router, prefix="/policies", tags=["policies"])
api_router.include_router(presentations.router, prefix="/presentations", tags=["presentations"])
api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
api_router.include_router(feature_flags.router, tags=["feature-flags"])
api_router.include_router(health.router, prefix="/health", tags=["health"])

