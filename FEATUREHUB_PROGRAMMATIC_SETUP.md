# FeatureHub Programmatic Flag Creation

## Overview

This guide explains how to create FeatureHub feature flags programmatically using the Admin API service, based on the [FeatureHub GitHub repository](https://github.com/featurehub-io/featurehub).

## Components

### 1. FeatureHub Admin Service

**Location**: `backend/app/services/featurehub_admin_service.py`

A service that provides programmatic access to FeatureHub Admin API for:
- Creating feature flags
- Setting feature flag values
- Managing applications and environments
- Bulk flag creation

### 2. Flag Creation Script

**Location**: `scripts/create-featurehub-flags.py`

A standalone script to create all default feature flags programmatically.

## Usage

### Option 1: Using the Script (Recommended)

```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra
python3 scripts/create-featurehub-flags.py
```

This script will:
1. Load configuration from `backend/.env.local`
2. Extract application and environment IDs from SDK key
3. Create all 29 default feature flags
4. Set their default values
5. Report results

### Option 2: Using the Service Programmatically

```python
from app.services.featurehub_admin_service import get_featurehub_admin_service

async def create_flags():
    admin_service = await get_featurehub_admin_service()
    
    # Create a single flag
    feature = await admin_service.create_or_update_feature(
        key="phone_auth_enabled",
        name="Phone Authentication",
        value=True,
        description="Enable phone number-based authentication",
        value_type="BOOLEAN"
    )
    
    # Create all default flags
    results = await admin_service.create_all_default_flags()
    
    print(f"Created: {len(results['created'])} flags")
    print(f"Failed: {len(results['failed'])} flags")
```

## API Authentication

FeatureHub Cloud Admin API requires authentication. The service uses:

1. **API Key**: From `FEATUREHUB_API_KEY` in `.env.local`
2. **SDK Key**: From `FEATUREHUB_SDK_KEY` in `.env.local` (extracts app/env IDs)

### SDK Key Format

The service supports multiple SDK key formats:
- `{app_id}/{env_id}/{key}` (3 parts)
- `{portfolio_id}/{app_id}/{env_id}/{key}` (4 parts)
- `{app_id}/{env_id}` (2 parts, no key)

Example: `4538b168-ba55-4ae8-a815-f99f03fd630a/IYGsPENvJifyLJZCXYdrsOToNTGke3*csNZJpKrCoMkHkmBkAyS`

### Authentication Methods

The service tries multiple authentication methods:
- `Authorization: Bearer {api_key}`
- `X-API-Key: {api_key}`

## Feature Flag Definitions

The service creates 29 feature flags organized by category:

### Authentication (6 flags)
- `phone_auth_enabled`
- `email_auth_enabled`
- `otp_verification_enabled`
- `biometric_auth_enabled`
- `mpin_auth_enabled`
- `agent_code_login_enabled`

### Core Features (5 flags)
- `dashboard_enabled`
- `policies_enabled`
- `payments_enabled` (default: false)
- `chat_enabled`
- `notifications_enabled`

### Presentation (6 flags)
- `presentation_carousel_enabled`
- `presentation_editor_enabled`
- `presentation_templates_enabled`
- `presentation_offline_mode_enabled`
- `presentation_analytics_enabled`
- `presentation_branding_enabled`

### Communication (3 flags)
- `whatsapp_integration_enabled`
- `chatbot_enabled`
- `callback_management_enabled`

### Analytics (3 flags)
- `analytics_enabled`
- `roi_dashboards_enabled`
- `smart_dashboards_enabled`

### Portal (3 flags)
- `portal_enabled`
- `data_import_enabled`
- `excel_template_config_enabled`

### Environment (3 flags)
- `debug_mode` (default: true for development)
- `enable_logging`
- `development_tools_enabled` (default: true for development)

## API Endpoints Used

Based on the [FeatureHub GitHub repository](https://github.com/featurehub-io/featurehub), the service uses FeatureHub Admin API endpoints:

- `GET /api/v2/portfolios` - List portfolios
- `GET /api/v2/portfolios/{portfolio}/applications` - List applications
- `GET /api/v2/portfolios/{portfolio}/applications/{app}/environments` - List environments
- `GET /api/v2/portfolios/{portfolio}/applications/{app}/features` - List features
- `POST /api/v2/portfolios/{portfolio}/applications/{app}/features` - Create feature
- `PUT /api/v2/portfolios/{portfolio}/applications/{app}/features/{feature}/values` - Set feature value

## Error Handling

The service handles common errors:
- **409 Conflict**: Feature already exists (returns existing feature)
- **401 Unauthorized**: Invalid API key
- **404 Not Found**: Application/environment not found
- **Network errors**: Logged and reported

## Troubleshooting

### API Key Issues

If you get authentication errors:
1. Verify `FEATUREHUB_API_KEY` in `.env.local`
2. Check API key format (should include portfolio/app/env IDs)
3. Ensure API key has admin permissions

### SDK Key Format

SDK key formats supported:
- `{app_id}/{env_id}/{key}` (e.g., `4538b168-ba55-4ae8-a815-f99f03fd630a/IYGsPENvJifyLJZCXYdrsOToNTGke3*csNZJpKrCoMkHkmBkAyS`)
- `{portfolio_id}/{app_id}/{env_id}/{key}` (e.g., `default/3f7a1a34-642b-4054-a82f-1ca2d14633ed/aH0l9TDXzauYq6rKQzVUPwbzmzGRqe*oPqyYqhUlVC50RxAzSmx`)

### Application/Environment Not Found

If application or environment IDs are incorrect:
1. Check SDK key format
2. Verify IDs in FeatureHub dashboard
3. Update `.env.local` with correct values

## Next Steps

After creating flags:

1. **Verify in Dashboard**:
   - Go to https://app.featurehub.io/dashboard
   - Check that all flags are created

2. **Restart Backend**:
   ```bash
   # Restart backend to load flags from FeatureHub
   docker-compose restart backend
   # Or if running locally:
   cd backend && uvicorn main:app --reload
   ```

3. **Test Integration**:
   ```bash
   curl http://localhost:8012/api/v1/feature-flags
   ```

## References

- [FeatureHub GitHub Repository](https://github.com/featurehub-io/featurehub)
- [FeatureHub Documentation](https://docs.featurehub.io)
- [FeatureHub Cloud Dashboard](https://app.featurehub.io/dashboard)

