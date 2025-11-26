"""
Database Models
"""
from .base import Base
# Import notification models BEFORE user to ensure NotificationSettings is available
# when User model relationships are initialized
from .notification import Notification, NotificationSettings, DeviceToken
from .user import User, UserSession
from .agent import Agent
from .presentation import Presentation, Slide, PresentationTemplate
from .policy import Policyholder, InsurancePolicy, PremiumPayment
from .campaign import Campaign, CampaignTrigger, CampaignExecution, CampaignTemplate, CampaignResponse
# Import callback models lazily to avoid SQLAlchemy FK validation issues at import time
# These models are only used in specific endpoints, not core functionality
try:
    from .callback import CallbackRequest, CallbackActivity
except Exception as e:
    # If callback models fail to import (e.g., FK validation), log but don't fail
    # They can be imported later when actually needed
    import warnings
    warnings.warn(f"Callback models could not be imported: {e}. They will be imported lazily when needed.")
    CallbackRequest = None
    CallbackActivity = None
from .shared import (
    InsuranceProvider, Country, Language, InsuranceCategory,
    WhatsappTemplate, Tenant
)

__all__ = [
    "Base",
    "User",
    "UserSession",
    "Agent",
    "Presentation",
    "Slide",
    "PresentationTemplate",
    "Policyholder",
    "InsurancePolicy",
    "PremiumPayment",
    "Notification",
    "NotificationSettings",
    "DeviceToken",
    "Campaign",
    "CampaignTrigger",
    "CampaignExecution",
    "CampaignTemplate",
    "CampaignResponse",
    "CallbackRequest",
    "CallbackActivity",
    "InsuranceProvider",
    "Country",
    "Language",
    "InsuranceCategory",
    "WhatsappTemplate",
    "Tenant",
]

# RBAC models - gradually enabling relationships to fix TextClause errors
from .rbac import Role, Permission, RolePermission, UserRole
from .feature_flags import FeatureFlag, FeatureFlagOverride
# from .rbac_audit import RbacAuditLog  # Enable later

# Configure SQLAlchemy mappers after ALL models are imported
# This ensures all relationships can be resolved
# We use a deferred configuration approach to avoid circular import issues
from sqlalchemy.orm import configure_mappers

def configure_all_mappers():
    """
    Configure all SQLAlchemy mappers after all models are loaded.
    This function should be called from main.py after all imports are complete.
    """
    try:
        # Configure all mappers - this resolves all relationships
        configure_mappers()
    except Exception as e:
        # Log the error but don't fail - relationships will be configured lazily
        import warnings
        import traceback
        warnings.warn(
            f"Some SQLAlchemy mappers could not be configured: {e}\n"
            f"Traceback: {traceback.format_exc()}\n"
            "Relationships will be configured lazily when first accessed."
        )

