"""
Feature Flag Service - Integration with Pioneer
Provides dynamic feature toggling capabilities
"""

import logging
from typing import Dict, Any, Optional, List
from sqlalchemy.orm import Session
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class FeatureFlagService:
    """Feature flag service with Pioneer integration"""

    def __init__(self, db: Session):
        self.db = db
        self.pioneer_url = getattr(settings, 'pioneer_url', None)
        self.pioneer_api_key = getattr(settings, 'pioneer_api_key', None)
        self.http_client = httpx.AsyncClient(timeout=5.0)

        # Fallback feature flags when Pioneer is not available
        self.fallback_flags = {
            # Customer Portal Flags
            "customer_dashboard_enabled": True,
            "policy_management_enabled": True,
            "premium_payments_enabled": True,
            "document_access_enabled": True,
            "communication_tools_enabled": True,
            "learning_center_enabled": True,
            "profile_management_enabled": True,
            "whatsapp_integration_enabled": True,
            "chatbot_assistance_enabled": True,
            "video_tutorials_enabled": True,

            # Agent Portal Flags
            "agent_dashboard_enabled": True,
            "customer_management_enabled": True,
            "marketing_campaigns_enabled": True,
            "content_management_enabled": True,
            "roi_analytics_enabled": True,
            "commission_tracking_enabled": True,
            "lead_management_enabled": True,
            "advanced_analytics_enabled": True,
            "team_management_enabled": True,
            "regional_oversight_enabled": True,

            # Administrative Flags
            "user_management_enabled": True,
            "feature_flag_control_enabled": True,
            "system_configuration_enabled": True,
            "audit_compliance_enabled": True,
            "financial_management_enabled": True,
            "tenant_management_enabled": True,
            "provider_administration_enabled": True,

            # System-wide Flags
            "phone_auth_enabled": True,
            "email_auth_enabled": True,
            "otp_verification_enabled": True,
            "biometric_auth_enabled": True,
            "mpin_auth_enabled": True,
            "agent_code_login_enabled": True,
            "dashboard_enabled": True,
            "policies_enabled": True,
            "payments_enabled": False,  # Disabled by default
            "chat_enabled": True,
            "notifications_enabled": True,
            "presentation_carousel_enabled": True,
            "presentation_editor_enabled": True,
            "presentation_templates_enabled": True,
            "presentation_offline_mode_enabled": True,
            "presentation_analytics_enabled": True,
            "presentation_branding_enabled": True,
            "whatsapp_integration_enabled": True,
            "chatbot_enabled": True,
            "callback_management_enabled": True,
            "analytics_enabled": True,
            "roi_dashboards_enabled": True,
            "smart_dashboards_enabled": True,
            "portal_enabled": True,
            "data_import_enabled": True,
            "excel_template_config_enabled": True,
            "debug_mode": True,
            "enable_logging": True,
            "development_tools_enabled": True,
        }

    def _is_pioneer_configured(self) -> bool:
        """Check if Pioneer is properly configured"""
        return bool(self.pioneer_url and self.pioneer_api_key)

    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=1, max=10))
    async def _fetch_from_pioneer(self, user_id: Optional[str] = None,
                                 tenant_id: Optional[str] = None,
                                 user_properties: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Fetch feature flags from Pioneer (matching Flutter expectations)"""
        if not self._is_pioneer_configured():
            logger.warning("Pioneer not configured, using fallback flags")
            return self.fallback_flags

        try:
            # Pioneer API uses GET /api/flags to get all flags (matching Flutter expectation)
            response = await self.http_client.get(
                f"{self.pioneer_url}/api/flags"
            )

            if response.status_code == 200:
                api_response = response.json()
                flags_data = {}

                # Pioneer returns flags in this format:
                # {"flags": [{"id": "1", "title": "flag_name", "is_active": true, "rollout": 100, ...}]}
                if isinstance(api_response, dict) and "flags" in api_response:
                    for flag in api_response["flags"]:
                        if isinstance(flag, dict) and "title" in flag:
                            flag_name = flag["title"]
                            # Pioneer uses 'is_active' as the boolean value
                            flags_data[flag_name] = flag.get("is_active", False)

                    logger.info(f"Successfully fetched {len(flags_data)} feature flags from Pioneer")
                    return flags_data
                else:
                    logger.error(f"Unexpected Pioneer API response format: {api_response}")
                    return self.fallback_flags
            else:
                logger.error(f"Pioneer API error: {response.status_code} - {response.text}")
                return self.fallback_flags

        except Exception as e:
            logger.error(f"Error fetching flags from Pioneer: {e}")
            return self.fallback_flags

    async def get_user_feature_flags(self, user_id: str,
                                   tenant_id: Optional[str] = None,
                                   user_properties: Optional[Dict[str, Any]] = None) -> Dict[str, bool]:
        """Get feature flags for a specific user"""
        try:
            # Try to get flags from Pioneer first
            pioneer_flags = await self._fetch_from_pioneer(user_id, tenant_id, user_properties)

            # If we got flags from Pioneer, apply role-based filtering
            if pioneer_flags and len(pioneer_flags) > 0:
                return await self._apply_role_based_filtering(pioneer_flags, user_id, tenant_id)

            # Fallback to database lookup with role-based filtering
            database_flags = await self._get_database_flags(user_id, tenant_id)
            return await self._apply_role_based_filtering(database_flags, user_id, tenant_id)

        except Exception as e:
            logger.error(f"Error getting feature flags for user {user_id}: {e}")
            return self.fallback_flags

    async def _get_database_flags(self, user_id: str, tenant_id: Optional[str] = None) -> Dict[str, bool]:
        """Get feature flags from database (fallback)"""
        try:
            from app.repositories.feature_flag_repository import FeatureFlagRepository

            repo = FeatureFlagRepository(self.db)
            flags = await repo.get_user_flags(user_id, tenant_id)

            # Convert to boolean values
            result = {}
            for flag in flags:
                result[flag['flag_name']] = bool(flag.get('value', flag.get('default_value', False)))

            # Merge with fallback flags for any missing flags
            for flag_name, default_value in self.fallback_flags.items():
                if flag_name not in result:
                    result[flag_name] = default_value

            return result

        except Exception as e:
            logger.error(f"Error getting database flags: {e}")
            return self.fallback_flags

    async def _apply_role_based_filtering(self, flags: Dict[str, bool], user_id: str,
                                         tenant_id: Optional[str] = None) -> Dict[str, bool]:
        """Apply role-based access control to feature flags"""
        try:
            # Get user roles and permissions
            user_roles = await self._get_user_roles(user_id)
            user_permissions = await self._get_user_permissions(user_id)

            # Define role-based feature flag restrictions
            role_restrictions = {
                # Features restricted to agents only
                'agent_only_features': [
                    'agent_dashboard_enabled',
                    'customer_management_enabled',
                    'marketing_campaigns_enabled',
                    'commission_tracking_enabled',
                    'lead_management_enabled',
                    'advanced_analytics_enabled',
                    'team_management_enabled',
                    'regional_oversight_enabled',
                    'content_management_enabled',
                    'roi_analytics_enabled'
                ],

                # Features restricted to customers only
                'customer_only_features': [
                    'customer_dashboard_enabled',
                    'policy_management_enabled',
                    'premium_payments_enabled',
                    'document_access_enabled'
                ],

                # Admin-only features
                'admin_only_features': [
                    'user_management_enabled',
                    'feature_flag_control_enabled',
                    'system_configuration_enabled',
                    'audit_compliance_enabled',
                    'financial_management_enabled',
                    'tenant_management_enabled',
                    'provider_administration_enabled'
                ],

                # Permission-based features
                'permission_based_features': {
                    'analytics:read': ['advanced_analytics_enabled', 'roi_analytics_enabled'],
                    'campaigns:read': ['marketing_campaigns_enabled'],
                    'customers:read': ['customer_management_enabled'],
                    'feature_flags:read': ['feature_flag_control_enabled'],
                    'users:read': ['user_management_enabled'],
                    'policies:read': ['policy_management_enabled']
                }
            }

            filtered_flags = flags.copy()

            # Apply role-based restrictions
            user_role_names = [role['name'] for role in user_roles]

            # Check if user is agent
            is_agent = any(role in ['senior_agent', 'junior_agent', 'regional_manager', 'provider_admin'] for role in user_role_names)

            # Check if user is customer/policyholder
            is_customer = 'policyholder' in user_role_names

            # Check if user is admin
            is_admin = any(role in ['super_admin', 'provider_admin', 'regional_manager'] for role in user_role_names)

            # Apply restrictions based on roles
            for flag_name in role_restrictions['agent_only_features']:
                if flag_name in filtered_flags and not is_agent:
                    filtered_flags[flag_name] = False

            for flag_name in role_restrictions['customer_only_features']:
                if flag_name in filtered_flags and not is_customer:
                    filtered_flags[flag_name] = False

            for flag_name in role_restrictions['admin_only_features']:
                if flag_name in filtered_flags and not is_admin:
                    filtered_flags[flag_name] = False

            # Apply permission-based restrictions
            for permission, restricted_flags in role_restrictions['permission_based_features'].items():
                if permission not in user_permissions:
                    for flag_name in restricted_flags:
                        if flag_name in filtered_flags:
                            filtered_flags[flag_name] = False

            # Special handling for trial users
            trial_status = await self._get_user_trial_status(user_id)
            if trial_status and not trial_status.get('can_access_features', True):
                # Disable premium features for expired trials
                premium_features = [
                    'advanced_analytics_enabled',
                    'marketing_campaigns_enabled',
                    'team_management_enabled',
                    'roi_analytics_enabled',
                    'whatsapp_integration_enabled'
                ]
                for flag_name in premium_features:
                    if flag_name in filtered_flags:
                        filtered_flags[flag_name] = False

            return filtered_flags

        except Exception as e:
            logger.error(f"Error applying role-based filtering for user {user_id}: {e}")
            return flags  # Return original flags if filtering fails

    async def _get_user_roles(self, user_id: str) -> List[Dict[str, Any]]:
        """Get user roles"""
        try:
            from app.services.rbac_service import RBACService
            rbac_service = RBACService(self.db)
            return rbac_service.get_user_roles(user_id)
        except Exception as e:
            logger.error(f"Error getting user roles for {user_id}: {e}")
            return []

    async def _get_user_permissions(self, user_id: str) -> List[str]:
        """Get user permissions"""
        try:
            from app.services.rbac_service import RBACService
            rbac_service = RBACService(self.db)
            roles = await self._get_user_roles(user_id)
            permissions = []
            for role in roles:
                role_permissions = rbac_service.get_role_permissions(role['name'])
                permissions.extend(role_permissions)
            return list(set(permissions))  # Remove duplicates
        except Exception as e:
            logger.error(f"Error getting user permissions for {user_id}: {e}")
            return []

    async def _get_user_trial_status(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user trial status"""
        try:
            from app.core.trial_subscription import TrialSubscriptionService
            trial_service = TrialSubscriptionService()
            # Get user object
            from app.repositories.user_repository import UserRepository
            user_repo = UserRepository(self.db)
            user = user_repo.get_by_id(user_id)
            if user:
                return trial_service.check_trial_status(user)
        except Exception as e:
            logger.error(f"Error getting trial status for user {user_id}: {e}")
        return None

    async def is_feature_enabled(self, flag_name: str, user_id: Optional[str] = None,
                               tenant_id: Optional[str] = None,
                               user_properties: Optional[Dict[str, Any]] = None) -> bool:
        """Check if a specific feature flag is enabled"""
        flags = await self.get_user_feature_flags(user_id, tenant_id, user_properties)
        return flags.get(flag_name, self.fallback_flags.get(flag_name, False))

    async def get_tenant_feature_flags(self, tenant_id: str) -> Dict[str, bool]:
        """Get feature flags for a specific tenant"""
        try:
            # Try Pioneer first
            pioneer_flags = await self._fetch_from_pioneer(None, tenant_id, {"tenant_context": True})

            if pioneer_flags and len(pioneer_flags) > 0:
                return pioneer_flags

            # Fallback to database
            from app.repositories.feature_flag_repository import FeatureFlagRepository
            repo = FeatureFlagRepository(self.db)
            flags = await repo.get_tenant_flags(tenant_id)

            result = {}
            for flag in flags:
                result[flag['flag_name']] = bool(flag.get('value', flag.get('default_value', False)))

            # Merge with fallback flags
            for flag_name, default_value in self.fallback_flags.items():
                if flag_name not in result:
                    result[flag_name] = default_value

            return result

        except Exception as e:
            logger.error(f"Error getting tenant feature flags for {tenant_id}: {e}")
            return self.fallback_flags

    async def update_feature_flag(self, flag_name: str, value: bool,
                                user_id: Optional[str] = None,
                                tenant_id: Optional[str] = None) -> bool:
        """Update a feature flag value"""
        try:
            from app.repositories.feature_flag_repository import FeatureFlagRepository

            repo = FeatureFlagRepository(self.db)
            success = await repo.update_flag_value(flag_name, value, user_id, tenant_id)

            if success:
                logger.info(f"Updated feature flag {flag_name} to {value} for user {user_id}, tenant {tenant_id}")
            else:
                logger.warning(f"Failed to update feature flag {flag_name}")

            return success

        except Exception as e:
            logger.error(f"Error updating feature flag {flag_name}: {e}")
            return False

    async def get_all_feature_flags(self) -> List[Dict[str, Any]]:
        """Get all available feature flags"""
        try:
            from app.repositories.feature_flag_repository import FeatureFlagRepository

            repo = FeatureFlagRepository(self.db)
            return await repo.get_all_flags()

        except Exception as e:
            logger.error(f"Error getting all feature flags: {e}")
            return []


# Global feature flag service instance
_feature_flag_service: Optional[FeatureFlagService] = None

def get_feature_flag_service(db: Session) -> FeatureFlagService:
    """Get or create feature flag service instance"""
    global _feature_flag_service
    if _feature_flag_service is None or _feature_flag_service.db != db:
        _feature_flag_service = FeatureFlagService(db)
    return _feature_flag_service
