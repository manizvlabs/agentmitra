# Testing Guide - Authentication & FeatureHub Integration

## Prerequisites

1. **Docker** (for FeatureHub) - Start Docker Desktop
2. **Backend running** - Start the FastAPI backend
3. **Database** - PostgreSQL running on localhost:5432
4. **Redis** - Redis running on localhost:6379 (optional, falls back to memory)

## Step 1: Start Docker (Required for FeatureHub)

```bash
# Start Docker Desktop, then verify:
docker ps
```

## Step 2: Start FeatureHub Services

```bash
# Start FeatureHub
cd /Users/manish/Documents/GitHub/zero/agentmitra
docker-compose -f docker-compose.dev.yml up -d

# Check status
docker-compose -f docker-compose.dev.yml ps

# View logs
docker-compose -f docker-compose.dev.yml logs -f featurehub-edge
```

Wait for services to be healthy (about 30-60 seconds).

## Step 3: Configure FeatureHub

1. **Access Admin UI**: http://localhost:8085
2. **Create Account**: First user becomes admin
3. **Create Application**: 
   - Name: "Agent Mitra"
4. **Create Environment**:
   - Name: "development"
5. **Generate Keys**:
   - Copy API Key → `FEATUREHUB_API_KEY` in `.env.local`
   - Copy SDK Key → `FEATUREHUB_SDK_KEY` in `.env.local`

## Step 4: Start Backend

```bash
cd backend

# Create .env.local if not exists
cp .env.example .env.local

# Edit .env.local and add FeatureHub keys:
# FEATUREHUB_API_KEY=your-api-key
# FEATUREHUB_SDK_KEY=your-sdk-key

# Start backend
uvicorn main:app --reload --port 8012
```

## Step 5: Run Tests

### Test 1: FeatureHub Integration

```bash
# Test FeatureHub connectivity
curl http://localhost:8080/health

# Test feature flags endpoint
curl http://localhost:8012/api/v1/feature-flags | jq
```

### Test 2: Authentication Flow

```bash
# Send OTP
curl -X POST http://localhost:8012/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+919876543210"}'

# Verify OTP (use OTP from logs or 123456 in dev mode)
curl -X POST http://localhost:8012/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+919876543210", "otp": "123456"}'

# Check response - should include:
# - access_token
# - refresh_token
# - user.trial_status
# - Token should contain feature_flags, permissions, tenant_id
```

### Test 3: Rate Limiting

```bash
# Send multiple OTP requests (should be rate limited after 5)
for i in {1..6}; do
  echo "Request $i:"
  curl -s -w "\nHTTP: %{http_code}\n" -X POST http://localhost:8012/api/v1/auth/send-otp \
    -H "Content-Type: application/json" \
    -d '{"phone_number": "+919876543211"}' | tail -1
done
```

### Test 4: Feature Flags in JWT

```bash
# Get token from verify-otp response
TOKEN="your-access-token-here"

# Decode JWT (install jq and base64)
echo $TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | jq

# Should see:
# - feature_flags: {...}
# - permissions: [...]
# - tenant_id: "..."
```

## Step 6: Automated Testing

```bash
# Run test scripts
./scripts/test-featurehub-integration.sh
./scripts/test-auth-integration.sh

# Run pytest tests
cd backend
pytest tests/test_featurehub_integration.py -v
```

## Expected Results

### FeatureHub
- ✅ Edge server accessible at http://localhost:8080
- ✅ Admin UI accessible at http://localhost:8085
- ✅ Feature flags endpoint returns flags from FeatureHub
- ✅ Fallback flags work if FeatureHub unavailable

### Authentication
- ✅ OTP sent successfully
- ✅ OTP verified and tokens returned
- ✅ Tokens include feature_flags, permissions, tenant_id
- ✅ Rate limiting works (429 after limit)
- ✅ Audit logs created

### Database
- ✅ All endpoints return real data
- ✅ No mock data in responses

## Troubleshooting

### Docker Not Running
```bash
# Start Docker Desktop, then:
docker ps
```

### FeatureHub Not Starting
```bash
# Check logs
docker-compose -f docker-compose.dev.yml logs featurehub-edge

# Restart
docker-compose -f docker-compose.dev.yml restart
```

### Backend Errors
```bash
# Check backend logs
tail -f backend/logs/app.log

# Verify .env.local exists
ls -la backend/.env.local

# Check database connection
psql -h localhost -U agentmitra -d agentmitra_dev -c "SELECT 1;"
```

### FeatureHub Connection Failed
- Check `FEATUREHUB_URL` in `.env.local`
- Verify FeatureHub is running: `curl http://localhost:8080/health`
- System will use fallback flags if unavailable

## Verification Checklist

- [ ] Docker running
- [ ] FeatureHub services started
- [ ] FeatureHub Admin UI accessible
- [ ] API keys configured in `.env.local`
- [ ] Backend running on port 8012
- [ ] Database connected
- [ ] OTP sent successfully
- [ ] OTP verified successfully
- [ ] JWT token contains feature_flags
- [ ] Rate limiting works
- [ ] Audit logs created
- [ ] No mock data in responses

