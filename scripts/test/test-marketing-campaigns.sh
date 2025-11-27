#!/bin/bash
# Test script for Marketing Campaigns and Callback Management implementation

set -e

echo "=========================================="
echo "Testing Marketing Campaigns Implementation"
echo "=========================================="

API_BASE_URL="${API_BASE_URL:-http://localhost:8012}"
API_VERSION="/api/v1"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to test API endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local description=$5
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "  Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${AUTH_TOKEN:-test-token}" 2>/dev/null || echo -e "\n000")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${AUTH_TOKEN:-test-token}" \
            -d "$data" 2>/dev/null || echo -e "\n000")
    elif [ "$method" = "PUT" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PUT "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${AUTH_TOKEN:-test-token}" \
            -d "$data" 2>/dev/null || echo -e "\n000")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ] || [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        echo "  Response: $(echo "$body" | head -c 200)..."
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗ FAILED${NC} (Expected: $expected_status, Got: $http_code)"
        echo "  Response: $body"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Check if API is running
echo -e "\n${YELLOW}Checking API health...${NC}"
if curl -s "$API_BASE_URL/health" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ API is running${NC}"
else
    echo -e "${RED}✗ API is not running at $API_BASE_URL${NC}"
    echo "Please start the API server first"
    exit 1
fi

# Test Campaign Endpoints
echo -e "\n${YELLOW}=== Testing Campaign Endpoints ===${NC}"

test_endpoint "GET" "/campaigns" "" "200" "List campaigns"
test_endpoint "GET" "/campaigns/templates" "" "200" "Get campaign templates"
test_endpoint "GET" "/campaigns/recommendations" "" "200" "Get campaign recommendations"

# Test Callback Endpoints
echo -e "\n${YELLOW}=== Testing Callback Endpoints ===${NC}"

test_endpoint "GET" "/callbacks" "" "200" "List callback requests"
test_endpoint "GET" "/callbacks?status=pending" "" "200" "List pending callbacks"
test_endpoint "GET" "/callbacks?priority=high" "" "200" "List high priority callbacks"

# Summary
echo -e "\n=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo "=========================================="

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed${NC}"
    exit 1
fi

