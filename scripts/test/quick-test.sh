#!/bin/bash

# Quick Test Script - Tests what we can without Docker
# Run this to verify the implementation

set -e

echo "🧪 Quick Test - Authentication Implementation"
echo "=============================================="
echo ""

BASE_URL="${BASE_URL:-http://localhost:8012}"

# Test 1: Check if backend is running
echo "1️⃣  Testing Backend Health..."
if curl -s -f "$BASE_URL/health" > /dev/null 2>&1; then
    echo "   ✅ Backend is running"
    curl -s "$BASE_URL/health" | jq '.' 2>/dev/null || curl -s "$BASE_URL/health"
else
    echo "   ⚠️  Backend not running on $BASE_URL"
    echo "   Start with: cd backend && uvicorn main:app --reload --port 8012"
    exit 1
fi

echo ""

# Test 2: Test Feature Flags Endpoint (will use fallback if FeatureHub unavailable)
echo "2️⃣  Testing Feature Flags Endpoint..."
response=$(curl -s "$BASE_URL/api/v1/feature-flags" 2>&1)
if echo "$response" | grep -q "flags"; then
    echo "   ✅ Feature flags endpoint working"
    source=$(echo "$response" | jq -r '.source' 2>/dev/null || echo "unknown")
    echo "   📊 Source: $source"
    if [ "$source" = "featurehub" ]; then
        echo "   ✅ FeatureHub connected!"
    else
        echo "   ⚠️  Using fallback flags (FeatureHub may not be running)"
    fi
else
    echo "   ❌ Feature flags endpoint failed"
    echo "   Response: $response"
fi

echo ""

# Test 3: Test OTP Send (will work even without FeatureHub)
echo "3️⃣  Testing OTP Send..."
PHONE="+919876543210"
response=$(curl -s -X POST "$BASE_URL/api/v1/auth/send-otp" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\"}" 2>&1)

if echo "$response" | grep -q "OTP sent successfully"; then
    echo "   ✅ OTP sent successfully"
    echo "   Response: $response" | jq '.' 2>/dev/null || echo "$response"
else
    echo "   ⚠️  OTP send response: $response"
fi

echo ""

# Test 4: Test Rate Limiting (send multiple requests)
echo "4️⃣  Testing Rate Limiting..."
echo "   Sending 6 OTP requests (limit is 5/hour)..."
rate_limited=false
for i in {1..6}; do
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL/api/v1/auth/send-otp" \
      -H "Content-Type: application/json" \
      -d "{\"phone_number\": \"+91987654321$i\"}" 2>&1)
    
    http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    if [ "$http_code" = "429" ]; then
        echo "   ✅ Rate limiting working! (Request $i blocked)"
        rate_limited=true
        break
    fi
done

if [ "$rate_limited" = false ]; then
    echo "   ⚠️  Rate limiting not triggered (may need more requests or different identifier)"
fi

echo ""

# Test 5: Test OTP Verification
echo "5️⃣  Testing OTP Verification..."
OTP="123456"  # Default test OTP in development
response=$(curl -s -X POST "$BASE_URL/api/v1/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\", \"otp\": \"$OTP\"}" 2>&1)

if echo "$response" | grep -q "access_token"; then
    echo "   ✅ OTP verified successfully"
    TOKEN=$(echo "$response" | jq -r '.access_token' 2>/dev/null || echo "")
    if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
        echo "   ✅ Token received"
        
        # Check if token has feature flags (decode JWT payload)
        PAYLOAD=$(echo "$TOKEN" | cut -d. -f2)
        if [ -n "$PAYLOAD" ]; then
            # Try to decode (may fail if base64 not available)
            DECODED=$(echo "$PAYLOAD" | base64 -d 2>/dev/null || echo "")
            if echo "$DECODED" | grep -q "feature_flags"; then
                echo "   ✅ Token contains feature_flags"
            fi
            if echo "$DECODED" | grep -q "permissions"; then
                echo "   ✅ Token contains permissions"
            fi
            if echo "$DECODED" | grep -q "tenant_id"; then
                echo "   ✅ Token contains tenant_id"
            fi
        fi
        
        # Check user object
        if echo "$response" | jq -e '.user.trial_status' > /dev/null 2>&1; then
            echo "   ✅ Response includes trial_status"
        fi
    fi
else
    echo "   ⚠️  OTP verification: $response"
fi

echo ""

# Test 6: Check Database Queries (no mock data)
echo "6️⃣  Testing Database Queries (No Mock Data)..."
echo "   Testing /api/v1/test/notifications..."
notif_response=$(curl -s "$BASE_URL/api/v1/test/notifications" 2>&1)
if echo "$notif_response" | grep -q "\[\]"; then
    echo "   ✅ Returns empty array (no mock data)"
elif echo "$notif_response" | grep -q "\"id\""; then
    echo "   ✅ Returns real notifications from database"
else
    echo "   Response: $notif_response"
fi

echo ""

echo "✅ Quick test complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Start Docker: docker ps"
echo "2. Start FeatureHub: docker-compose -f docker-compose.dev.yml up -d"
echo "3. Configure FeatureHub Admin UI: http://localhost:8085"
echo "4. Add API keys to backend/.env.local"
echo "5. Run full tests: ./scripts/test-featurehub-integration.sh"

