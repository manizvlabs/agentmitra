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
# Import campaign models lazily if they exist
try:
    from .campaign import Campaign, CampaignTrigger, CampaignExecution, CampaignTemplate, CampaignResponse
except ImportError:
    Campaign = None
    CampaignTrigger = None
    CampaignExecution = None
    CampaignTemplate = None
    CampaignResponse = None
# Import callback models lazily to avoid SQLAlchemy FK validation issues at import time
# These models are only used in specific endpoints, not core functionality
# Temporarily disabled to avoid table conflicts
# try:
#     from .callback import CallbackRequest, CallbackActivity
# except Exception as e:
#     # If callback models fail to import (e.g., FK validation), log but don't fail
#     # They can be imported later when actually needed
#     import warnings
#     warnings.warn(f"Callback models could not be imported: {e}. They will be imported lazily when needed.")
#     CallbackRequest = None
#     CallbackActivity = None
CallbackRequest = None
CallbackActivity = None
from .shared import (
    InsuranceProvider, Country, Language, InsuranceCategory,
    WhatsappTemplate, Tenant
)

# Import new analytics models
try:
    from .lead import Lead
    from .customer_retention import CustomerRetentionAnalytics
    from .revenue_forecast import RevenueForecastScenario
    from .quotes import DailyQuote, QuoteSharingAnalytics, QuotePerformance
    from .subscription import UserSubscription, SubscriptionBillingHistory, SubscriptionChange
    from .trial import TrialSubscription, TrialEngagement
except ImportError:
    Lead = None
    CustomerRetentionAnalytics = None
    RevenueForecastScenario = None
    DailyQuote = None
    QuoteSharingAnalytics = None
    QuotePerformance = None
    TrialSubscription = None
    TrialEngagement = None
    UserSubscription = None
    SubscriptionBillingHistory = None
    SubscriptionChange = None

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
try:
    from .rbac import Role, Permission, RolePermission, UserRole
except ImportError:
    Role = None
    Permission = None
    RolePermission = None
    UserRole = None

try:
    from .feature_flags import FeatureFlag, FeatureFlagOverride
except ImportError:
    FeatureFlag = None
    FeatureFlagOverride = None
# from .rbac_audit import RbacAuditLog  # Enable later

# DO NOT configure mappers here - it will be done in main.py after all imports
# Configuring mappers during import causes relationship resolution errors

