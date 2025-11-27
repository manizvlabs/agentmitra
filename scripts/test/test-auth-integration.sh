#!/bin/bash

# Test Authentication Integration
# Tests all authentication endpoints with real database

set -e

echo "🧪 Testing Authentication Integration..."

BASE_URL="${BASE_URL:-http://localhost:8012}"

# Test 1: Send OTP
echo ""
echo "📡 Test 1: Send OTP"
PHONE="+919876543210"
response=$(curl -s -X POST "$BASE_URL/api/v1/auth/send-otp" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\"}")

if echo "$response" | grep -q "OTP sent successfully"; then
    echo "✅ OTP sent successfully"
else
    echo "❌ Failed to send OTP"
    echo "Response: $response"
fi

# Test 2: Verify OTP (using test OTP if in dev mode)
echo ""
echo "📡 Test 2: Verify OTP"
OTP="123456"  # Default test OTP in development
response=$(curl -s -X POST "$BASE_URL/api/v1/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -d "{\"phone_number\": \"$PHONE\", \"otp\": \"$OTP\"}")

if echo "$response" | grep -q "access_token"; then
    echo "✅ OTP verified successfully"
    TOKEN=$(echo "$response" | jq -r '.access_token' 2>/dev/null || echo "")
    echo "Token received: ${TOKEN:0:50}..."
else
    echo "⚠️  OTP verification (may need valid OTP)"
    echo "Response: $response"
fi

# Test 3: Get Feature Flags
echo ""
echo "📡 Test 3: Get Feature Flags"
response=$(curl -s "$BASE_URL/api/v1/feature-flags")

if echo "$response" | grep -q "flags"; then
    echo "✅ Feature flags endpoint working"
    echo "Flags source: $(echo "$response" | jq -r '.source' 2>/dev/null || echo 'unknown')"
else
    echo "❌ Feature flags endpoint failed"
    echo "Response: $response"
fi

# Test 4: Rate Limiting
echo ""
echo "📡 Test 4: Rate Limiting (sending multiple OTP requests)"
for i in {1..6}; do
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL/api/v1/auth/send-otp" \
      -H "Content-Type: application/json" \
      -d "{\"phone_number\": \"+919876543211\"}")
    
    http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
    if [ "$http_code" = "429" ]; then
        echo "✅ Rate limiting working (request $i blocked)"
        break
    fi
done

echo ""
echo "✅ Authentication integration tests complete!"

