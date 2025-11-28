#!/bin/bash

# Comprehensive API Testing Script
# Tests all backend API endpoints with detailed output

BASE_URL="http://localhost:8012"
API_BASE="$BASE_URL/api/v1"

echo "=========================================="
echo "Agent Mitra - Comprehensive API Testing"
echo "=========================================="
echo "Base URL: $BASE_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    local headers=$5
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Test: $name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "Method: $method"
    echo "Endpoint: $endpoint"
    [ -n "$data" ] && echo "Data: $data"
    echo ""
    
    if [ "$method" = "GET" ]; then
        if [ -n "$headers" ]; then
            response=$(curl -s -w "\n%{http_code}" -H "$headers" "$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" "$endpoint")
        fi
    else
        if [ -n "$headers" ]; then
            response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -H "$headers" -d "$data" "$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$endpoint")
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    echo "Response (HTTP $http_code):"
    echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo ""
}

# 1. Health Checks
echo -e "${YELLOW}1. HEALTH CHECK ENDPOINTS${NC}"
echo "=========================================="
test_endpoint "Root Health Check" "GET" "$BASE_URL/health" ""
test_endpoint "API Health Check" "GET" "$API_BASE/health" ""
echo ""

# 2. Authentication
echo -e "${YELLOW}2. AUTHENTICATION ENDPOINTS${NC}"
echo "=========================================="
test_endpoint "Send OTP" "POST" "$API_BASE/auth/send-otp" '{"phone_number": "+919876543212"}'

# Login and get token
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Login to get access token${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"phone_number": "+919876543210", "agent_code": "AGENT001"}' "$API_BASE/auth/login")
echo "$LOGIN_RESPONSE" | python3 -m json.tool

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('access_token', ''))" 2>/dev/null)

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "None" ]; then
    echo -e "${GREEN}✓ Successfully obtained access token${NC}"
    echo ""
    
    # 3. Presentation Endpoints
    echo -e "${YELLOW}3. PRESENTATION ENDPOINTS${NC}"
    echo "=========================================="
    test_endpoint "Get Active Presentation" "GET" "$API_BASE/presentations/agent/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/active" ""
    test_endpoint "Get All Presentations" "GET" "$API_BASE/presentations/agent/b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" ""
    test_endpoint "Get Templates" "GET" "$API_BASE/presentations/templates" ""
    echo ""
    
    # 4. Logout
    echo -e "${YELLOW}4. LOGOUT${NC}"
    echo "=========================================="
    test_endpoint "Logout" "POST" "$API_BASE/auth/logout" "" "Authorization: Bearer $ACCESS_TOKEN"
    echo ""
else
    echo -e "${RED}✗ Failed to obtain access token${NC}"
    FAILED=$((FAILED + 1))
fi

# 5. Test with different agent code
echo -e "${YELLOW}5. ALTERNATIVE LOGIN METHODS${NC}"
echo "=========================================="
test_endpoint "Login with Password" "POST" "$API_BASE/auth/login" '{"phone_number": "+919876543210", "password": "password123"}'
echo ""

# Summary
echo "=========================================="
echo -e "${YELLOW}TEST SUMMARY${NC}"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "Total: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi

