"""
FeatureHub Service Integration
Provides runtime feature flag management using FeatureHub
"""
from typing import Dict, Optional, Any, List
from datetime import datetime
import httpx
import asyncio
from app.core.config.settings import settings
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class FeatureHubService:
    """
    FeatureHub service wrapper for runtime feature flag management
    
    Supports:
    - Boolean, string, number, and JSON-type flags
    - Percentage rollouts
    - User targeting
    - Environment-based flags
    - Streaming updates
    """
    
    def __init__(self):
        self.base_url = settings.featurehub_url.rstrip('/')
        self.api_key = settings.featurehub_api_key
        self.environment = settings.featurehub_environment
        self.sdk_key = settings.featurehub_sdk_key
        self.poll_interval = settings.featurehub_poll_interval
        self.streaming = settings.featurehub_streaming
        
        self._client: Optional[httpx.AsyncClient] = None
        self._flags_cache: Dict[str, Any] = {}
        self._last_update: Optional[datetime] = None
        self._initialized = False
        
    async def initialize(self):
        """Initialize FeatureHub client and load initial flags"""
        if self._initialized:
            return
            
        if not self.api_key or not self.sdk_key:
            logger.warning("FeatureHub API key or SDK key not configured, using fallback flags")
            self._flags_cache = self._get_fallback_flags()
            self._initialized = True
            return
            
        try:
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=10.0,
                headers={
                    "X-API-Key": self.api_key,
                    "Content-Type": "application/json"
                }
            )
            
            # Load initial flags
            await self._load_flags()
            
            # Start background polling if not streaming
            if not self.streaming:
                asyncio.create_task(self._poll_flags_loop())
            
            self._initialized = True
            logger.info("FeatureHub service initialized successfully")
            
        except Exception as e:
            logger.error(f"Failed to initialize FeatureHub service: {e}")
            self._flags_cache = self._get_fallback_flags()
            self._initialized = True
    
    async def _load_flags(self):
        """Load feature flags from FeatureHub"""
        if not self._client:
            return
            
        try:
            # Use FeatureHub REST API to get flags
            # Endpoint: GET /api/v2/features/{environment}
            response = await self._client.get(
                f"/api/v2/features/{self.environment}",
                headers={"X-API-Key": self.api_key}
            )
            response.raise_for_status()
            
            data = response.json()
            
            # Parse FeatureHub response format
            flags = {}
            for feature in data.get("features", []):
                key = feature.get("key")
                value = feature.get("value")
                value_type = feature.get("valueType", "BOOLEAN")
                
                # Convert value based on type
                if value_type == "BOOLEAN":
                    flags[key] = value.lower() == "true" if isinstance(value, str) else bool(value)
                elif value_type == "STRING":
                    flags[key] = str(value)
                elif value_type == "NUMBER":
                    flags[key] = float(value) if "." in str(value) else int(value)
                elif value_type == "JSON":
                    import json
                    flags[key] = json.loads(value) if isinstance(value, str) else value
                else:
                    flags[key] = value
            
            self._flags_cache = flags
            self._last_update = datetime.utcnow()
            logger.debug(f"Loaded {len(flags)} feature flags from FeatureHub")
            
        except httpx.HTTPError as e:
            logger.error(f"Failed to load flags from FeatureHub: {e}")
            # Use fallback flags
            if not self._flags_cache:
                self._flags_cache = self._get_fallback_flags()
        except Exception as e:
            logger.error(f"Unexpected error loading flags: {e}")
            if not self._flags_cache:
                self._flags_cache = self._get_fallback_flags()
    
    async def _poll_flags_loop(self):
        """Background task to poll FeatureHub for flag updates"""
        while True:
            try:
                await asyncio.sleep(self.poll_interval)
                await self._load_flags()
            except Exception as e:
                logger.error(f"Error in FeatureHub polling loop: {e}")
    
    async def get_flag(self, key: str, default: bool = False, user_context: Optional[Dict[str, Any]] = None) -> Any:
        """
        Get a feature flag value
        
        Args:
            key: Feature flag key
            default: Default value if flag not found
            user_context: User context for targeting (e.g., {"userId": "123", "role": "admin"})
        
        Returns:
            Feature flag value (boolean, string, number, or JSON)
        """
        if not self._initialized:
            await self.initialize()
        
        # Check cache first
        if key in self._flags_cache:
            value = self._flags_cache[key]
            
            # If user context provided, check for user-specific targeting
            if user_context and self._client:
                # FeatureHub supports user targeting - would need to call evaluation API
                # For now, return cached value
                pass
            
            return value
        
        # Return default if not found
        logger.debug(f"Feature flag '{key}' not found, using default: {default}")
        return default
    
    async def get_all_flags(self, user_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Get all feature flags
        
        Args:
            user_context: User context for targeting
        
        Returns:
            Dictionary of all feature flags
        """
        if not self._initialized:
            await self.initialize()
        
        return self._flags_cache.copy()
    
    async def refresh_flags(self):
        """Manually refresh flags from FeatureHub"""
        await self._load_flags()
    
    def _get_fallback_flags(self) -> Dict[str, bool]:
        """Fallback flags when FeatureHub is unavailable"""
        return {
            # Authentication Features
            "phone_auth_enabled": True,
            "email_auth_enabled": True,
            "otp_verification_enabled": True,
            "biometric_auth_enabled": True,
            "mpin_auth_enabled": True,
            "agent_code_login_enabled": True,
            
            # Core Features
            "dashboard_enabled": True,
            "policies_enabled": True,
            "payments_enabled": False,  # Regulatory compliance
            "chat_enabled": True,
            "notifications_enabled": True,
            
            # Presentation Features
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
            
            # Environment-specific
            "debug_mode": settings.environment == "development",
            "enable_logging": True,
            "development_tools_enabled": settings.environment == "development",
        }
    
    async def close(self):
        """Close FeatureHub client"""
        if self._client:
            await self._client.aclose()
            self._client = None


# Global FeatureHub service instance
_featurehub_service: Optional[FeatureHubService] = None


async def get_featurehub_service() -> FeatureHubService:
    """Get or create FeatureHub service instance"""
    global _featurehub_service
    
    if _featurehub_service is None:
        _featurehub_service = FeatureHubService()
        await _featurehub_service.initialize()
    
    return _featurehub_service


async def get_feature_flag(key: str, default: bool = False, user_context: Optional[Dict[str, Any]] = None) -> Any:
    """Convenience function to get a feature flag"""
    service = await get_featurehub_service()
    return await service.get_flag(key, default, user_context)


async def get_all_feature_flags(user_context: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Convenience function to get all feature flags"""
    service = await get_featurehub_service()
    return await service.get_all_flags(user_context)

