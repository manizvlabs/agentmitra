# Pioneer Quick Start Guide

## Setup Pioneer

### Option 1: Using Docker Compose (Recommended)

```bash
# Start Pioneer services
docker-compose -f docker-compose.dev.yml up -d

# Check status
docker-compose -f docker-compose.dev.yml ps

# View logs
docker-compose -f docker-compose.dev.yml logs -f pioneer
```

### Option 2: Manual Setup

```bash
# Ensure Pioneer server is running on port 4002
# Scout endpoint: http://localhost:4002
```

## Access Pioneer

- **Scout Server (SSE)**: http://localhost:4002
- **Admin UI**: Check Pioneer documentation for admin URL

## Initial Configuration

1. **Access Pioneer Admin UI**
2. **Create Account**: First user becomes admin
3. **Create Application**: 
   - Name: "Agent Mitra"
   - Description: "Insurance Agent Management Platform"
4. **Create Environment**:
   - Name: "development"
   - Type: "development"
5. **Generate SDK Key**:
   - SDK Key: Copy to `PIONEER_SDK_KEY` in `.env.local`
   - Scout URL: Set `PIONEER_SCOUT_URL=http://localhost:4002` in `.env.local`

## Create Feature Flags

In Pioneer Admin UI, create these flags:

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

1. **Check Logs**: Look for "Pioneer initialized successfully"
2. **Test Flags**: Call `/api/v1/feature-flags` endpoint
3. **Check Tokens**: Login and verify JWT contains `feature_flags` field
4. **Verify SSE**: Check that SSE connection to Scout endpoint is established

## Troubleshooting

### Pioneer Not Available
- System falls back to default flags
- Check logs for connection errors
- Verify `PIONEER_SCOUT_URL` in `.env.local`

### Flags Not Updating
- Check Pioneer Admin UI for flag changes
- Verify SDK key is correct
- Check SSE connection to Scout endpoint (http://localhost:4002)
- Verify Scout endpoint is accessible

### SSE Connection Issues
- Ensure Pioneer Scout is running on port 4002
- Check firewall settings
- Verify Scout URL is correct in configuration
- Check browser console for SSE connection errors

## Production Setup

For production, use Pioneer with:
- Proper SSL/TLS
- Secure SDK keys
- Environment-specific configurations
- Monitoring and alerts
- SSE endpoint accessible from client applications

