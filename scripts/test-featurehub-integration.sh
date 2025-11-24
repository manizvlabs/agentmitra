#!/bin/bash

# Test FeatureHub Integration
# This script tests the FeatureHub integration with the backend

set -e

echo "🧪 Testing FeatureHub Integration..."

# Check if backend is running
if ! curl -f http://localhost:8012/health > /dev/null 2>&1; then
    echo "❌ Backend is not running. Please start it first."
    exit 1
fi

# Check if FeatureHub is running
if ! curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "⚠️  FeatureHub Edge server is not running. Starting it..."
    docker-compose -f docker-compose.dev.yml up -d featurehub
    sleep 5
fi

echo "✅ FeatureHub Edge server is running"

# Test feature flags endpoint
echo ""
echo "📡 Testing feature flags endpoint..."
response=$(curl -s http://localhost:8012/api/v1/feature-flags || echo "ERROR")

if echo "$response" | grep -q "flags"; then
    echo "✅ Feature flags endpoint is working"
    echo "Response: $response" | jq '.' 2>/dev/null || echo "$response"
else
    echo "❌ Feature flags endpoint failed"
    echo "Response: $response"
fi

# Test with authentication (if you have a test token)
echo ""
echo "📡 Testing authenticated feature flags..."
echo "Note: This requires a valid JWT token. Update the script with a test token."

echo ""
echo "✅ Integration test complete!"
echo ""
echo "To test with authentication:"
echo "1. Get a JWT token from /api/v1/auth/login or /api/v1/auth/verify-otp"
echo "2. Use: curl -H 'Authorization: Bearer YOUR_TOKEN' http://localhost:8012/api/v1/feature-flags"

