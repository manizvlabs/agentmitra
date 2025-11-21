#!/bin/bash

# API Endpoint Testing Script
# Tests all backend API endpoints

BASE_URL="http://localhost:8012"
API_BASE="$BASE_URL/api/v1"

echo "=========================================="
echo "Agent Mitra API Endpoint Testing"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Test function
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_status=$5
    
    echo -n "Testing $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        echo "$body" | python3 -m json.tool 2>/dev/null | head -10 || echo "$body"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC} (Expected HTTP $expected_status, got $http_code)"
        echo "$body"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# 1. Health Check
echo "1. Health Check Endpoints"
echo "-------------------------"
test_endpoint "Root Health" "GET" "$BASE_URL/health" "" "200"
test_endpoint "API Health" "GET" "$API_BASE/health" "" "200"
echo ""

# 2. Authentication Endpoints
echo "2. Authentication Endpoints"
echo "----------------------------"
test_endpoint "Send OTP" "POST" "$API_BASE/auth/send-otp" '{"phone_number": "+919876543212"}' "200"

# Get OTP from service (for testing)
echo -e "${YELLOW}Note: OTP verification requires actual OTP from send-otp response${NC}"
echo ""

test_endpoint "Login with Agent Code" "POST" "$API_BASE/auth/login" '{"phone_number": "+919876543210", "agent_code": "AGENT001"}' "200"

# Extract token for authenticated requests
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"phone_number": "+919876543210", "agent_code": "AGENT001"}' "$API_BASE/auth/login")
ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)

if [ -n "$ACCESS_TOKEN" ]; then
    echo -e "${GREEN}✓ Successfully obtained access token${NC}"
    echo ""
    
    # Test authenticated endpoints
    echo "3. Presentation Endpoints (Authenticated)"
    echo "-----------------------------------------"
    test_endpoint "Get Active Presentation" "GET" "$API_BASE/presentations/agent/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/active" "" "200"
    test_endpoint "Get All Presentations" "GET" "$API_BASE/presentations/agent/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" "" "200"
    test_endpoint "Get Templates" "GET" "$API_BASE/presentations/templates" "" "200"
    echo ""
    
    # Test logout
    echo "4. Logout"
    echo "---------"
    test_endpoint "Logout" "POST" "$API_BASE/auth/logout" "" "200" "-H" "Authorization: Bearer $ACCESS_TOKEN"
else
    echo -e "${RED}✗ Failed to obtain access token${NC}"
    FAILED=$((FAILED + 1))
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed${NC}"
    exit 1
fi

