"""
FeatureHub Admin API Service
Provides programmatic management of FeatureHub feature flags
"""
from typing import Dict, Optional, Any, List
import httpx
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class FeatureHubAdminService:
    """
    FeatureHub Admin API service for programmatic feature flag management
    
    Uses FeatureHub Admin API to:
    - Create applications and environments
    - Create feature flags
    - Update feature flag values
    - Manage feature flag configurations
    """
    
    def __init__(self):
        # FeatureHub Cloud Admin SDK base URL (preferred)
        # Format: https://app.featurehub.io/vanilla/{id}
        self.admin_base_url = (settings.featurehub_admin_sdk_url or 
                               os.getenv("FEATUREHUB_ADMIN_SDK_URL") or 
                               settings.featurehub_url).rstrip('/')
        self.api_key = settings.featurehub_api_key
        self.sdk_key = settings.featurehub_sdk_key
        # Service account access token for Admin API
        self.admin_token = settings.featurehub_admin_token or os.getenv("FEATUREHUB_ADMIN_TOKEN")
        
        # Extract application and environment IDs from SDK key
        # Format can be: {portfolio_id}/{application_id}/{environment_id}/{key} OR {application_id}/{environment_id}/{key}
        if self.sdk_key:
            parts = self.sdk_key.split('/')
            if len(parts) >= 3:
                # Check if first part is 'default' or a portfolio ID
                if parts[0] == 'default' or len(parts) == 4:
                    # Format: portfolio/app_id/env_id/key
                    self.portfolio_id = parts[0] if parts[0] != 'default' else None
                    self.application_id = parts[1]
                    self.environment_id = parts[2]
                else:
                    # Format: app_id/env_id/key
                    self.portfolio_id = None
                    self.application_id = parts[0]
                    self.environment_id = parts[1]
            elif len(parts) == 2:
                # Format: app_id/env_id (no key part)
                self.portfolio_id = None
                self.application_id = parts[0]
                self.environment_id = parts[1]
            else:
                self.portfolio_id = None
                self.application_id = None
                self.environment_id = None
        else:
            self.portfolio_id = None
            self.application_id = None
            self.environment_id = None
        
        self._client: Optional[httpx.AsyncClient] = None
    
    async def initialize(self):
        """Initialize HTTP client for Admin API"""
        if self._client:
            return
        
        # FeatureHub Cloud Admin API uses service account access token
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        # Use admin token (service account access token) if available
        # Otherwise fall back to API key
        if self.admin_token:
            headers["Authorization"] = f"Bearer {self.admin_token}"
            logger.info("Using FeatureHub Admin service account token")
        elif self.api_key:
            headers["Authorization"] = f"Bearer {self.api_key}"
            headers["X-API-Key"] = self.api_key
            logger.info("Using FeatureHub API key (fallback)")
        else:
            logger.warning("No authentication token configured for Admin API")
        
        self._client = httpx.AsyncClient(
            base_url=self.admin_base_url,
            timeout=30.0,
            headers=headers,
            follow_redirects=True
        )
        logger.info(f"FeatureHub Admin service initialized with base URL: {self.admin_base_url}")
    
    async def get_portfolios(self) -> List[Dict[str, Any]]:
        """Get all portfolios"""
        await self.initialize()
        try:
            response = await self._client.get(
                "/api/v2/portfolios",
                headers={"Authorization": f"Bearer {self.api_key}"}
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Failed to get portfolios: {e}")
            return []
    
    async def get_applications(self, portfolio_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get all applications in a portfolio"""
        await self.initialize()
        try:
            portfolio = portfolio_id or self.portfolio_id or "default"
            response = await self._client.get(f"/api/v2/portfolios/{portfolio}/applications")
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Failed to get applications: {e.response.status_code} - {e.response.text[:200]}")
            return []
        except Exception as e:
            logger.error(f"Failed to get applications: {e}")
            return []
    
    async def get_environments(self, application_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get all environments for an application"""
        await self.initialize()
        try:
            app_id = application_id or self.application_id
            portfolio = self.portfolio_id or "default"
            
            response = await self._client.get(
                f"/api/v2/portfolios/{portfolio}/applications/{app_id}/environments"
            )
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Failed to get environments: {e.response.status_code} - {e.response.text[:200]}")
            return []
        except Exception as e:
            logger.error(f"Failed to get environments: {e}")
            return []
    
    async def get_features(self, application_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get all features for an application"""
        await self.initialize()
        try:
            app_id = application_id or self.application_id
            portfolio = self.portfolio_id or "default"
            
            response = await self._client.get(
                f"/api/v2/portfolios/{portfolio}/applications/{app_id}/features"
            )
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            logger.error(f"Failed to get features: {e.response.status_code} - {e.response.text[:200]}")
            return []
        except Exception as e:
            logger.error(f"Failed to get features: {e}")
            return []
    
    async def create_feature(
        self,
        key: str,
        name: str,
        description: Optional[str] = None,
        value_type: str = "BOOLEAN",
        application_id: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Create a new feature flag
        
        Args:
            key: Feature flag key (e.g., "phone_auth_enabled")
            name: Human-readable name
            description: Optional description
            value_type: Feature type (BOOLEAN, STRING, NUMBER, JSON)
            application_id: Application ID (uses default if not provided)
        
        Returns:
            Created feature object or None if failed
        """
        await self.initialize()
        
        app_id = application_id or self.application_id
        portfolio = self.portfolio_id or "default"
        
        if not app_id:
            logger.error("Application ID not available. Cannot create feature.")
            return None
        
        try:
            payload = {
                "key": key,
                "name": name,
                "description": description or f"Feature flag for {name}",
                "valueType": value_type
            }
            
            response = await self._client.post(
                f"/api/v2/portfolios/{portfolio}/applications/{app_id}/features",
                json=payload
            )
            response.raise_for_status()
            
            feature = response.json()
            logger.info(f"Created feature flag: {key}")
            return feature
            
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 409:
                logger.warning(f"Feature flag '{key}' already exists")
                # Try to get existing feature
                features = await self.get_features(app_id)
                for feature in features:
                    if feature.get("key") == key:
                        return feature
            else:
                logger.error(f"Failed to create feature '{key}': {e.response.status_code} - {e.response.text}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error creating feature '{key}': {e}")
            return None
    
    async def set_feature_value(
        self,
        feature_id: str,
        environment_id: Optional[str] = None,
        value: Any = None,
        application_id: Optional[str] = None
    ) -> bool:
        """
        Set feature flag value for an environment
        
        Args:
            feature_id: Feature ID
            environment_id: Environment ID (uses default if not provided)
            value: Feature value (boolean, string, number, or JSON)
            application_id: Application ID
        
        Returns:
            True if successful, False otherwise
        """
        await self.initialize()
        
        app_id = application_id or self.application_id
        env_id = environment_id or self.environment_id
        portfolio = self.portfolio_id or "default"
        
        if not app_id or not env_id:
            logger.error("Application ID or Environment ID not available")
            return False
        
        try:
            # Convert value to string format expected by FeatureHub
            if isinstance(value, bool):
                value_str = "true" if value else "false"
            elif isinstance(value, dict):
                import json
                value_str = json.dumps(value)
            else:
                value_str = str(value)
            
            payload = {
                "value": value_str,
                "environmentId": env_id
            }
            
            response = await self._client.put(
                f"/api/v2/portfolios/{portfolio}/applications/{app_id}/features/{feature_id}/values",
                json=payload
            )
            response.raise_for_status()
            
            logger.info(f"Set feature '{feature_id}' value to '{value_str}' in environment '{env_id}'")
            return True
            
        except Exception as e:
            logger.error(f"Failed to set feature value: {e}")
            return False
    
    async def create_or_update_feature(
        self,
        key: str,
        name: str,
        value: Any,
        description: Optional[str] = None,
        value_type: str = "BOOLEAN",
        application_id: Optional[str] = None,
        environment_id: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Create a feature flag and set its value in one operation
        
        Args:
            key: Feature flag key
            name: Human-readable name
            value: Default value
            description: Optional description
            value_type: Feature type
            application_id: Application ID
            environment_id: Environment ID
        
        Returns:
            Created/updated feature object
        """
        # Create feature
        feature = await self.create_feature(
            key=key,
            name=name,
            description=description,
            value_type=value_type,
            application_id=application_id
        )
        
        if feature and feature.get("id"):
            # Set feature value
            await self.set_feature_value(
                feature_id=feature["id"],
                environment_id=environment_id,
                value=value,
                application_id=application_id
            )
        
        return feature
    
    async def create_all_default_flags(
        self,
        application_id: Optional[str] = None,
        environment_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Create all default feature flags programmatically
        
        Returns:
            Dictionary with creation results
        """
        from app.services.featurehub_service import FeatureHubService
        
        # Get default flags
        service = FeatureHubService()
        default_flags = service._get_fallback_flags()
        
        results = {
            "created": [],
            "updated": [],
            "failed": [],
            "skipped": []
        }
        
        # Feature flag definitions with metadata
        flag_definitions = {
            # Authentication Features
            "phone_auth_enabled": {
                "name": "Phone Authentication",
                "description": "Enable phone number-based authentication",
                "type": "BOOLEAN",
                "default": True
            },
            "email_auth_enabled": {
                "name": "Email Authentication",
                "description": "Enable email-based authentication",
                "type": "BOOLEAN",
                "default": True
            },
            "otp_verification_enabled": {
                "name": "OTP Verification",
                "description": "Enable OTP verification for authentication",
                "type": "BOOLEAN",
                "default": True
            },
            "biometric_auth_enabled": {
                "name": "Biometric Authentication",
                "description": "Enable biometric authentication (fingerprint, face ID)",
                "type": "BOOLEAN",
                "default": True
            },
            "mpin_auth_enabled": {
                "name": "MPIN Authentication",
                "description": "Enable MPIN-based authentication",
                "type": "BOOLEAN",
                "default": True
            },
            "agent_code_login_enabled": {
                "name": "Agent Code Login",
                "description": "Enable agent code-based login",
                "type": "BOOLEAN",
                "default": True
            },
            # Core Features
            "dashboard_enabled": {
                "name": "Dashboard",
                "description": "Enable dashboard functionality",
                "type": "BOOLEAN",
                "default": True
            },
            "policies_enabled": {
                "name": "Policies",
                "description": "Enable policy management features",
                "type": "BOOLEAN",
                "default": True
            },
            "payments_enabled": {
                "name": "Payments",
                "description": "Enable payment processing (regulatory compliance required)",
                "type": "BOOLEAN",
                "default": False
            },
            "chat_enabled": {
                "name": "Chat",
                "description": "Enable chat functionality",
                "type": "BOOLEAN",
                "default": True
            },
            "notifications_enabled": {
                "name": "Notifications",
                "description": "Enable push notifications",
                "type": "BOOLEAN",
                "default": True
            },
            # Presentation Features
            "presentation_carousel_enabled": {
                "name": "Presentation Carousel",
                "description": "Enable presentation carousel feature",
                "type": "BOOLEAN",
                "default": True
            },
            "presentation_editor_enabled": {
                "name": "Presentation Editor",
                "description": "Enable presentation editor",
                "type": "BOOLEAN",
                "default": True
            },
            "presentation_templates_enabled": {
                "name": "Presentation Templates",
                "description": "Enable presentation templates",
                "type": "BOOLEAN",
                "default": True
            },
            "presentation_offline_mode_enabled": {
                "name": "Presentation Offline Mode",
                "description": "Enable offline mode for presentations",
                "type": "BOOLEAN",
                "default": True
            },
            "presentation_analytics_enabled": {
                "name": "Presentation Analytics",
                "description": "Enable analytics for presentations",
                "type": "BOOLEAN",
                "default": True
            },
            "presentation_branding_enabled": {
                "name": "Presentation Branding",
                "description": "Enable branding customization for presentations",
                "type": "BOOLEAN",
                "default": True
            },
            # Communication Features
            "whatsapp_integration_enabled": {
                "name": "WhatsApp Integration",
                "description": "Enable WhatsApp integration",
                "type": "BOOLEAN",
                "default": True
            },
            "chatbot_enabled": {
                "name": "Chatbot",
                "description": "Enable chatbot functionality",
                "type": "BOOLEAN",
                "default": True
            },
            "callback_management_enabled": {
                "name": "Callback Management",
                "description": "Enable callback management features",
                "type": "BOOLEAN",
                "default": True
            },
            # Analytics Features
            "analytics_enabled": {
                "name": "Analytics",
                "description": "Enable analytics features",
                "type": "BOOLEAN",
                "default": True
            },
            "roi_dashboards_enabled": {
                "name": "ROI Dashboards",
                "description": "Enable ROI dashboard features",
                "type": "BOOLEAN",
                "default": True
            },
            "smart_dashboards_enabled": {
                "name": "Smart Dashboards",
                "description": "Enable smart dashboard features",
                "type": "BOOLEAN",
                "default": True
            },
            # Portal Features
            "portal_enabled": {
                "name": "Portal",
                "description": "Enable portal features",
                "type": "BOOLEAN",
                "default": True
            },
            "data_import_enabled": {
                "name": "Data Import",
                "description": "Enable data import functionality",
                "type": "BOOLEAN",
                "default": True
            },
            "excel_template_config_enabled": {
                "name": "Excel Template Configuration",
                "description": "Enable Excel template configuration",
                "type": "BOOLEAN",
                "default": True
            },
            # Environment-specific
            "debug_mode": {
                "name": "Debug Mode",
                "description": "Enable debug mode (development only)",
                "type": "BOOLEAN",
                "default": settings.environment == "development"
            },
            "enable_logging": {
                "name": "Enable Logging",
                "description": "Enable application logging",
                "type": "BOOLEAN",
                "default": True
            },
            "development_tools_enabled": {
                "name": "Development Tools",
                "description": "Enable development tools (development only)",
                "type": "BOOLEAN",
                "default": settings.environment == "development"
            },
        }
        
        for key, value in default_flags.items():
            flag_def = flag_definitions.get(key, {
                "name": key.replace("_", " ").title(),
                "description": f"Feature flag for {key}",
                "type": "BOOLEAN",
                "default": value
            })
            
            try:
                feature = await self.create_or_update_feature(
                    key=key,
                    name=flag_def["name"],
                    value=value,
                    description=flag_def["description"],
                    value_type=flag_def["type"],
                    application_id=application_id,
                    environment_id=environment_id
                )
                
                if feature:
                    results["created"].append(key)
                else:
                    results["failed"].append(key)
                    
            except Exception as e:
                logger.error(f"Failed to create feature '{key}': {e}")
                results["failed"].append(key)
        
        return results
    
    async def close(self):
        """Close HTTP client"""
        if self._client:
            await self._client.aclose()
            self._client = None


# Global admin service instance
_admin_service: Optional[FeatureHubAdminService] = None


async def get_featurehub_admin_service() -> FeatureHubAdminService:
    """Get or create FeatureHub Admin service instance"""
    global _admin_service
    
    if _admin_service is None:
        _admin_service = FeatureHubAdminService()
        await _admin_service.initialize()
    
    return _admin_service

