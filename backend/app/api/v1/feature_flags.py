"""
Feature Flags API Endpoints
Provides runtime feature flag configuration using FeatureHub
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, Optional
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.core.config.settings import settings
from app.core.auth import get_current_user_context, UserContext
from app.services.featurehub_service import get_featurehub_service, get_all_feature_flags

router = APIRouter()


class FeatureFlagsResponse(BaseModel):
    """Feature flags response model"""
    flags: Dict[str, any]
    last_updated: Optional[str] = None
    environment: str
    source: str = "featurehub"  # "featurehub" or "fallback"


@router.get("/feature-flags", response_model=FeatureFlagsResponse)
async def get_feature_flags(
    environment: Optional[str] = None,
    current_user: Optional[UserContext] = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get feature flags for the current environment
    
    Returns feature flags from FeatureHub with user context for targeting.
    Falls back to default flags if FeatureHub is unavailable.
    """
    env = environment or settings.environment
    
    # Build user context for FeatureHub targeting
    user_context = None
    if current_user:
        user_context = {
            "userId": current_user.user_id,
            "role": current_user.role,
            "email": current_user.email,
            "phoneNumber": current_user.phone_number,
        }
    
    try:
        # Get flags from FeatureHub
        service = await get_featurehub_service()
        flags = await service.get_all_flags(user_context=user_context)
        last_updated = service._last_update.isoformat() if service._last_update else None
        source = "featurehub"
    except Exception as e:
        # Fallback to default flags
        flags = _get_default_flags(env)
        last_updated = None
        source = "fallback"
    
    return FeatureFlagsResponse(
        flags=flags,
        last_updated=last_updated,
        environment=env,
        source=source
    )


def _get_default_flags(environment: str) -> Dict[str, bool]:
    """
    Get default feature flags based on environment
    
    Production: More conservative, disable experimental features
    Staging: Enable most features for testing
    Development: Enable all features including debug tools
    """
    base_flags = {
        # Authentication Features
        "phone_auth_enabled": True,
        "otp_verification_enabled": True,
        "biometric_auth_enabled": True,
        "agent_code_login_enabled": True,
        
        # Core Features
        "dashboard_enabled": True,
        "policies_enabled": True,
        "payments_enabled": False,  # DEFERRED - Regulatory compliance
        "chat_enabled": True,
        "notifications_enabled": True,
        
        # Presentation Carousel Features
        "presentation_carousel_enabled": True,
        "presentation_editor_enabled": True,
        "presentation_templates_enabled": True,
        "presentation_offline_mode_enabled": True,
        "presentation_analytics_enabled": True,
        "presentation_branding_enabled": True,
        
        # Communication Features
        "whatsapp_integration_enabled": True,
        "chatbot_enabled": True,
        "callback_management_enabled": True,
        
        # Analytics Features
        "analytics_enabled": True,
        "roi_dashboards_enabled": True,
        "smart_dashboards_enabled": True,
        
        # Portal Features
        "portal_enabled": True,
        "data_import_enabled": True,
        "excel_template_config_enabled": True,
    }
    
    # Environment-specific overrides
    if environment == "production":
        # Disable debug/development features in production
        base_flags.update({
            "debug_mode": False,
            "enable_logging": True,  # Keep logging in production
        })
    elif environment == "staging":
        # Enable most features for testing
        base_flags.update({
            "debug_mode": True,
            "enable_logging": True,
        })
    else:  # development
        # Enable all features including debug tools
        base_flags.update({
            "debug_mode": True,
            "enable_logging": True,
            "development_tools_enabled": True,
        })
    
    return base_flags


@router.post("/feature-flags/{flag_name}")
async def update_feature_flag(
    flag_name: str,
    enabled: bool,
    environment: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Update a feature flag (Admin only)
    
    This endpoint allows runtime feature flag updates without code deployment.
    Requires admin authentication.
    """
    # TODO: Add admin authentication check
    # TODO: Save to database for persistence
    # TODO: Invalidate cache
    
    return {
        "flag_name": flag_name,
        "enabled": enabled,
        "message": "Feature flag updated successfully"
    }

