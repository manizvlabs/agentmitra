"""
Test FeatureHub Integration
"""
import pytest
from unittest.mock import AsyncMock, patch
from app.services.featurehub_service import FeatureHubService, get_feature_flag


@pytest.mark.asyncio
async def test_featurehub_service_initialization():
    """Test FeatureHub service initialization"""
    service = FeatureHubService()
    await service.initialize()
    
    # Should have fallback flags if FeatureHub unavailable
    assert service._flags_cache is not None
    assert len(service._flags_cache) > 0


@pytest.mark.asyncio
async def test_get_feature_flag():
    """Test getting a feature flag"""
    flag = await get_feature_flag("phone_auth_enabled", default=True)
    assert isinstance(flag, bool)


@pytest.mark.asyncio
async def test_get_all_feature_flags():
    """Test getting all feature flags"""
    from app.services.featurehub_service import get_all_feature_flags
    
    flags = await get_all_feature_flags()
    assert isinstance(flags, dict)
    assert "phone_auth_enabled" in flags


@pytest.mark.asyncio
async def test_featurehub_fallback():
    """Test that fallback flags work when FeatureHub is unavailable"""
    service = FeatureHubService()
    # Simulate FeatureHub unavailable
    service._initialized = True
    service._flags_cache = service._get_fallback_flags()
    
    flag = await service.get_flag("phone_auth_enabled", default=False)
    assert isinstance(flag, bool)

