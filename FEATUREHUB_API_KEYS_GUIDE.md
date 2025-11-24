# FeatureHub API Keys Guide

## How to Get FeatureHub API Keys

### Option 1: FeatureHub Cloud (Recommended for Quick Start)

1. **Sign up for FeatureHub Cloud**:
   - Go to https://www.featurehub.io/
   - Sign up for a free account
   - Access the FeatureHub dashboard

2. **Create an Application**:
   - In the dashboard, create a new application (e.g., "Agent Mitra")
   - Add a description

3. **Create an Environment**:
   - Create an environment (e.g., "development", "staging", "production")
   - Select the environment type

4. **Generate API Keys**:
   - Go to your application → Environments → Select your environment
   - Click on "API Keys" or "SDK Keys"
   - Generate a new SDK key (for client-side) or API key (for server-side)
   - Copy the key

5. **Configure in Backend**:
   - Add to `backend/.env.local`:
   ```bash
   FEATUREHUB_URL=https://your-instance.featurehub.io
   FEATUREHUB_API_KEY=your-api-key-here
   FEATUREHUB_SDK_KEY=your-sdk-key-here
   FEATUREHUB_ENVIRONMENT=development
   ```

### Option 2: Self-Hosted FeatureHub Admin UI

Since we have FeatureHub Edge running, you can set up the Admin UI:

1. **Start FeatureHub Admin** (if image available):
   ```bash
   docker-compose -f docker-compose.dev.yml up -d featurehub-admin
   ```

2. **Access Admin UI**:
   - Open http://localhost:8085
   - Create your first admin account
   - Create an application
   - Create an environment
   - Generate API/SDK keys

3. **Configure Keys**:
   - Add to `backend/.env.local`:
   ```bash
   FEATUREHUB_URL=http://localhost:8071
   FEATUREHUB_API_KEY=your-api-key-from-admin-ui
   FEATUREHUB_SDK_KEY=your-sdk-key-from-admin-ui
   FEATUREHUB_ENVIRONMENT=development
   ```

### Option 3: Use FeatureHub Edge Directly (Without Admin UI)

If Admin UI is not available, you can:

1. **Use FeatureHub Cloud** (easiest option)
2. **Use FeatureHub Edge with Manual Configuration**:
   - FeatureHub Edge can work with pre-configured flags
   - Requires API keys from FeatureHub Cloud or Admin UI
   - Edge acts as a proxy/cache layer

## Current Setup Status

### What's Running:
- ✅ FeatureHub Edge: Running on port 8071
- ✅ Backend: Running on port 8012
- ✅ FeatureHub DB: Running on port 5433
- ⚠️ FeatureHub Admin: Not running (image not available)

### Current Configuration:
- **FeatureHub URL**: `http://localhost:8071` (configured)
- **API Keys**: Not configured (using fallback flags)
- **Flags**: 29 fallback flags active

## Quick Start: Get API Keys from FeatureHub Cloud

### Step 1: Sign Up
1. Visit https://www.featurehub.io/
2. Click "Sign Up" or "Get Started"
3. Create your account

### Step 2: Create Application
1. After login, click "Create Application"
2. Name: "Agent Mitra"
3. Description: "Insurance Agent Management Platform"

### Step 3: Create Environment
1. Click on your application
2. Click "Add Environment"
3. Name: "development"
4. Type: "Development"

### Step 4: Get SDK Key
1. Click on the "development" environment
2. Go to "SDK Keys" tab
3. Click "Generate SDK Key"
4. Copy the key (starts with something like `default/xxxxx/xxxxx`)

### Step 5: Configure in Backend
Create or edit `backend/.env.local`:
```bash
# FeatureHub Configuration
FEATUREHUB_URL=https://your-instance.featurehub.io
FEATUREHUB_API_KEY=your-api-key-here
FEATUREHUB_SDK_KEY=default/your-app-id/your-env-id/your-key
FEATUREHUB_ENVIRONMENT=development
FEATUREHUB_POLL_INTERVAL=30
FEATUREHUB_STREAMING=true
```

### Step 6: Restart Backend
```bash
# Restart backend to load new environment variables
docker-compose restart backend
# Or if running locally:
cd backend && uvicorn main:app --reload
```

## Verify Configuration

After adding API keys, test the integration:

```bash
# Test FeatureHub connection
curl http://localhost:8012/api/v1/feature-flags

# Check backend logs for FeatureHub initialization
docker logs agentmitra_backend | grep -i featurehub
```

## Troubleshooting

### If API keys don't work:
1. **Check URL**: Ensure `FEATUREHUB_URL` points to correct instance
2. **Check Keys**: Verify keys are correct and not expired
3. **Check Environment**: Ensure environment name matches
4. **Check Logs**: Look for errors in backend logs

### If using FeatureHub Cloud:
- URL format: `https://your-instance.featurehub.io`
- SDK key format: `default/app-id/env-id/key`

### If using Self-Hosted:
- URL format: `http://localhost:8071` (Edge) or `http://localhost:8085` (Admin)
- Keys generated from Admin UI

## Alternative: Continue with Fallback Flags

If you don't want to set up FeatureHub right now:
- ✅ System works with 29 fallback flags
- ✅ All features functional
- ✅ Can add FeatureHub later without code changes
- ⚠️ Flags are static (can't change without code deployment)

## Next Steps

1. **Choose Option**: FeatureHub Cloud (easiest) or Self-Hosted Admin UI
2. **Get API Keys**: Follow steps above
3. **Configure**: Add to `backend/.env.local`
4. **Restart**: Restart backend service
5. **Test**: Verify flags are loading from FeatureHub

## Resources

- FeatureHub Documentation: https://docs.featurehub.io/
- FeatureHub Cloud: https://www.featurehub.io/
- FeatureHub GitHub: https://github.com/featurehub-io

