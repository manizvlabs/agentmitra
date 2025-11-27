# Pioneer Integration Guide

## Overview

Agent Mitra backend now integrates with Pioneer for runtime feature flag management. This allows dynamic feature toggling without code deployments, supporting percentage rollouts, user targeting, and real-time updates via Server-Sent Events (SSE).

## Configuration

### Environment Variables

Add these to your `.env.local` file:

```bash
# Pioneer Configuration
PIONEER_SCOUT_URL=http://localhost:4002
PIONEER_SDK_KEY=your-sdk-key-here
PIONEER_ENVIRONMENT=development
PIONEER_POLL_INTERVAL=30
PIONEER_STREAMING=true
```

### Setting Up Pioneer

1. **Start Pioneer Server**:
   ```bash
   # Pioneer server should be running on port 4002
   # Scout endpoint: http://localhost:4002
   ```

2. **Get SDK Key**:
   - Access Pioneer Admin UI
   - Create an application and environment
   - Generate SDK key (e.g., `4cbeeba0-37e8-45fc-b306-32c0cd497c92`)

3. **Configure Flags**:
   - Create feature flags in the Pioneer Admin UI
   - Set default values and targeting rules
   - Enable percentage rollouts if needed

## Usage

### In API Endpoints

```python
from app.services.pioneer_service import get_feature_flag

# Check a feature flag
if await get_feature_flag("payments_enabled", default=False):
    # Process payment
    pass
```

### In Authentication

Feature flags are automatically included in JWT tokens:

```python
# Flags are fetched from Pioneer during login/OTP verification
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

Pioneer supports user-specific targeting:

```python
user_context = {
    "userId": "user_123",
    "role": "admin",
    "email": "user@example.com"
}

flags = await get_all_feature_flags(user_context=user_context)
```

## Feature Flag Types

Pioneer supports:
- **Boolean**: `true`/`false`
- **String**: Text values
- **Number**: Numeric values
- **JSON**: Complex objects

## Fallback Behavior

If Pioneer is unavailable, the system falls back to default flags defined in `pioneer_service.py`. This ensures the application continues to function even if Pioneer is down.

## API Endpoints

### Get Feature Flags
```
GET /api/v1/feature-flags
```

Returns all feature flags for the current user/environment.

## Migration from Hardcoded Flags

All hardcoded feature flags have been moved to Pioneer. The system will:
1. Try to fetch flags from Pioneer via SSE (Server-Sent Events)
2. Fall back to default flags if Pioneer is unavailable
3. Include flags in JWT tokens for client-side access

## Monitoring

- Pioneer service logs initialization and errors
- Flag updates are logged for debugging
- Fallback usage is logged when Pioneer is unavailable
- SSE connection status is monitored

## Best Practices

1. **Always provide defaults**: Feature flags should have sensible defaults
2. **Use user context**: Leverage user targeting for gradual rollouts
3. **Monitor fallbacks**: Watch logs for Pioneer connectivity issues
4. **Test flags**: Use staging environment to test flag changes before production
5. **SSE Connection**: Pioneer uses SSE for real-time updates - ensure Scout endpoint is accessible

