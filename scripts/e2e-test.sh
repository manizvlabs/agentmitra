#!/bin/bash
# End-to-End Testing Script for Authentication & FeatureHub Integration

set -e

BASE_URL="${BASE_URL:-http://localhost:8012}"
FEATUREHUB_URL="${FEATUREHUB_URL:-http://localhost:8071}"

echo "=========================================="
echo "End-to-End Testing - Authentication & FeatureHub"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAILED${NC}: $2"
        ((FAILED++))
    fi
}

# 1. Check FeatureHub Health
echo "1. Testing FeatureHub Health..."
if curl -f -s "$FEATUREHUB_URL/health" > /dev/null 2>&1; then
    test_result 0 "FeatureHub Edge is healthy"
else
    test_result 1 "FeatureHub Edge is not accessible"
fi
echo ""

# 2. Check Backend Health
echo "2. Testing Backend Health..."
if curl -f -s "$BASE_URL/health" > /dev/null 2>&1; then
    test_result 0 "Backend is healthy"
else
    test_result 1 "Backend is not accessible"
    echo -e "${YELLOW}⚠️  Start backend with: cd backend && uvicorn main:app --reload --port 8012${NC}"
    exit 1
fi
echo ""

# 3. Test Feature Flags Endpoint
echo "3. Testing Feature Flags Endpoint..."
FLAGS_RESPONSE=$(curl -s "$BASE_URL/api/v1/feature-flags" 2>&1)
if echo "$FLAGS_RESPONSE" | grep -q "feature_flags\|phone_auth_enabled"; then
    test_result 0 "Feature flags endpoint returns data"
    echo "   Response preview: $(echo "$FLAGS_RESPONSE" | head -c 100)..."
else
    test_result 1 "Feature flags endpoint failed"
    echo "   Response: $FLAGS_RESPONSE"
fi
echo ""

# 4. Test OTP Send Endpoint
echo "4. Testing OTP Send Endpoint..."
OTP_SEND_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/send-otp" \
    -H "Content-Type: application/json" \
    -d '{"phone_number": "+919876543210"}' 2>&1)
if echo "$OTP_SEND_RESPONSE" | grep -q "success\|message\|otp"; then
    test_result 0 "OTP send endpoint works"
    echo "   Response: $(echo "$OTP_SEND_RESPONSE" | head -c 150)..."
else
    test_result 1 "OTP send endpoint failed"
    echo "   Response: $OTP_SEND_RESPONSE"
fi
echo ""

# 5. Test Rate Limiting (5 requests)
echo "5. Testing Rate Limiting..."
RATE_LIMIT_PASSED=true
for i in {1..6}; do
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/send-otp" \
        -H "Content-Type: application/json" \
        -d "{\"phone_number\": \"+9198765432$i\"}" 2>&1)
    
    if [ $i -le 5 ]; then
        if echo "$RESPONSE" | grep -q "success\|message\|otp\|rate_limit"; then
            echo "   Request $i: ✅ Allowed"
        else
            echo "   Request $i: ⚠️  Unexpected response"
        fi
    else
        if echo "$RESPONSE" | grep -q "rate_limit\|too many\|429"; then
            echo "   Request $i: ✅ Rate Limited (expected)"
        else
            echo "   Request $i: ❌ Not rate limited (unexpected)"
            RATE_LIMIT_PASSED=false
        fi
    fi
done

if [ "$RATE_LIMIT_PASSED" = true ]; then
    test_result 0 "Rate limiting works correctly"
else
    test_result 1 "Rate limiting may not be working"
fi
echo ""

# 6. Test Login Endpoint (if user exists)
echo "6. Testing Login Endpoint..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"phone_number": "+919876543210", "password": "test123"}' 2>&1)
if echo "$LOGIN_RESPONSE" | grep -q "access_token\|token\|error\|invalid"; then
    test_result 0 "Login endpoint responds"
    echo "   Response preview: $(echo "$LOGIN_RESPONSE" | head -c 150)..."
else
    test_result 1 "Login endpoint failed"
    echo "   Response: $LOGIN_RESPONSE"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi

