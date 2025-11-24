# FeatureHub Integration Guide

## Overview

Agent Mitra backend now integrates with FeatureHub for runtime feature flag management. This allows dynamic feature toggling without code deployments, supporting percentage rollouts, user targeting, and real-time updates.

## Configuration

### Environment Variables

Add these to your `.env.local` file:

```bash
# FeatureHub Configuration
FEATUREHUB_URL=http://localhost:8080
FEATUREHUB_API_KEY=your-api-key-here
FEATUREHUB_ENVIRONMENT=development
FEATUREHUB_SDK_KEY=your-sdk-key-here
FEATUREHUB_POLL_INTERVAL=30
FEATUREHUB_STREAMING=true
```

### Setting Up FeatureHub

1. **Self-Hosted Setup (Docker)**:
   ```bash
   docker run -d -p 8080:8080 featurehub/edge:latest
   ```

2. **Get API Keys**:
   - Access FeatureHub Admin UI at `http://localhost:8080`
   - Create an application and environment
   - Generate API key and SDK key

3. **Configure Flags**:
   - Create feature flags in the Admin UI
   - Set default values and targeting rules
   - Enable percentage rollouts if needed

## Usage

### In API Endpoints

```python
from app.services.featurehub_service import get_feature_flag

# Check a feature flag
if await get_feature_flag("payments_enabled", default=False):
    # Process payment
    pass
```

### In Authentication

Feature flags are automatically included in JWT tokens:

```python
# Flags are fetched from FeatureHub during login/OTP verification
# Included in token payload:
{
    "feature_flags": {
        "payments_enabled": true,
        "chat_enabled": true,
        ...
    }
}
```

### User Targeting

FeatureHub supports user-specific targeting:

```python
user_context = {
    "userId": "user_123",
    "role": "admin",
    "email": "user@example.com"
}

flags = await get_all_feature_flags(user_context=user_context)
```

## Feature Flag Types

FeatureHub supports:
- **Boolean**: `true`/`false`
- **String**: Text values
- **Number**: Numeric values
- **JSON**: Complex objects

## Fallback Behavior

If FeatureHub is unavailable, the system falls back to default flags defined in `featurehub_service.py`. This ensures the application continues to function even if FeatureHub is down.

## API Endpoints

### Get Feature Flags
```
GET /api/v1/feature-flags
```

Returns all feature flags for the current user/environment.

## Migration from Hardcoded Flags

All hardcoded feature flags have been moved to FeatureHub. The system will:
1. Try to fetch flags from FeatureHub
2. Fall back to default flags if FeatureHub is unavailable
3. Include flags in JWT tokens for client-side access

## Monitoring

- FeatureHub service logs initialization and errors
- Flag updates are logged for debugging
- Fallback usage is logged when FeatureHub is unavailable

## Best Practices

1. **Always provide defaults**: Feature flags should have sensible defaults
2. **Use user context**: Leverage user targeting for gradual rollouts
3. **Monitor fallbacks**: Watch logs for FeatureHub connectivity issues
4. **Test flags**: Use staging environment to test flag changes before production

