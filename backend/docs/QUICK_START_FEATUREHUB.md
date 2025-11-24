# FeatureHub Quick Start Guide

## Setup FeatureHub

### Option 1: Using Docker Compose (Recommended)

```bash
# Start FeatureHub services
docker-compose -f docker-compose.dev.yml up -d

# Check status
docker-compose -f docker-compose.dev.yml ps

# View logs
docker-compose -f docker-compose.dev.yml logs -f featurehub-edge
```

### Option 2: Using Setup Script

```bash
./scripts/setup-featurehub.sh
```

## Access FeatureHub

- **Edge Server**: http://localhost:8080
- **Admin UI**: http://localhost:8085

## Initial Configuration

1. **Access Admin UI**: Open http://localhost:8085
2. **Create Account**: First user becomes admin
3. **Create Application**: 
   - Name: "Agent Mitra"
   - Description: "Insurance Agent Management Platform"
4. **Create Environment**:
   - Name: "development"
   - Type: "development"
5. **Generate Keys**:
   - API Key: Copy to `FEATUREHUB_API_KEY` in `.env.local`
   - SDK Key: Copy to `FEATUREHUB_SDK_KEY` in `.env.local`

## Create Feature Flags

In FeatureHub Admin UI, create these flags:

### Authentication Flags
- `phone_auth_enabled` (Boolean, default: true)
- `email_auth_enabled` (Boolean, default: true)
- `otp_verification_enabled` (Boolean, default: true)
- `biometric_auth_enabled` (Boolean, default: true)
- `mpin_auth_enabled` (Boolean, default: true)

### Core Feature Flags
- `dashboard_enabled` (Boolean, default: true)
- `policies_enabled` (Boolean, default: true)
- `payments_enabled` (Boolean, default: false)
- `chat_enabled` (Boolean, default: true)
- `notifications_enabled` (Boolean, default: true)

## Test Integration

```bash
# Test feature flags endpoint
curl http://localhost:8012/api/v1/feature-flags

# Test with authentication
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8012/api/v1/feature-flags
```

## Verify Integration

1. **Check Logs**: Look for "FeatureHub service initialized successfully"
2. **Test Flags**: Call `/api/v1/feature-flags` endpoint
3. **Check Tokens**: Login and verify JWT contains `feature_flags` field

## Troubleshooting

### FeatureHub Not Available
- System falls back to default flags
- Check logs for connection errors
- Verify `FEATUREHUB_URL` in `.env.local`

### Flags Not Updating
- Check FeatureHub Admin UI for flag changes
- Verify API key is correct
- Check polling interval (default: 30 seconds)

### Docker Issues
- Ensure Docker is running: `docker ps`
- Check container logs: `docker-compose -f docker-compose.dev.yml logs`
- Restart services: `docker-compose -f docker-compose.dev.yml restart`

## Production Setup

For production, use FeatureHub Cloud or self-hosted with:
- Proper SSL/TLS
- Secure API keys
- Environment-specific configurations
- Monitoring and alerts

