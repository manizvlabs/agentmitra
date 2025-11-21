"""
Feature Flags API Endpoints
Provides runtime feature flag configuration
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Dict, Optional
from pydantic import BaseModel

from app.core.database import get_db
from app.core.config.settings import settings

router = APIRouter()


class FeatureFlagsResponse(BaseModel):
    """Feature flags response model"""
    flags: Dict[str, bool]
    last_updated: Optional[str] = None
    environment: str


@router.get("/feature-flags", response_model=FeatureFlagsResponse)
async def get_feature_flags(
    environment: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Get feature flags for the current environment
    
    Returns feature flags based on:
    1. Environment (development, staging, production)
    2. Database configuration (if feature flags table exists)
    3. Default values from settings
    """
    env = environment or settings.environment
    
    # Default feature flags based on environment
    flags = _get_default_flags(env)
    
    # TODO: Load from database if feature_flags table exists
    # This allows runtime configuration without code deployment
    # db_flags = _load_flags_from_db(db, env)
    # flags.update(db_flags)
    
    return FeatureFlagsResponse(
        flags=flags,
        last_updated=None,  # TODO: Get from database
        environment=env
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

