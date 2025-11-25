"""
Database Models
"""
from .base import Base
from .user import User, UserSession
from .agent import Agent
from .presentation import Presentation, Slide, PresentationTemplate
from .policy import Policyholder, InsurancePolicy, PremiumPayment
from .notification import Notification, NotificationSettings, DeviceToken
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

