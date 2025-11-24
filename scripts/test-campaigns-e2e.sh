#!/bin/bash
# End-to-end test for Marketing Campaigns feature

set -e

echo "=========================================="
echo "End-to-End Marketing Campaigns Test"
echo "=========================================="

API_BASE_URL="${API_BASE_URL:-http://localhost:8012}"
API_VERSION="/api/v1"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    local token=$6
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "  Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" 2>/dev/null || echo -e "\n000")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data" 2>/dev/null || echo -e "\n000")
    elif [ "$method" = "PUT" ]; then
        response=$(curl -s -w "\n%{http_code}" -X PUT "$API_BASE_URL$API_VERSION$endpoint" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data" 2>/dev/null || echo -e "\n000")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ] || [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "  ${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        if [ "$http_code" != "204" ]; then
            echo "  Response preview: $(echo "$body" | head -c 200)..."
        fi
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
    exit 1
fi

# Get agent info
echo -e "\n${YELLOW}Getting test agent info...${NC}"
AGENT_INFO=$(curl -s "$API_BASE_URL$API_VERSION/test/agent/profile" 2>/dev/null || echo "")
if [ -z "$AGENT_INFO" ] || echo "$AGENT_INFO" | grep -q "No agents"; then
    echo -e "${RED}✗ No agents found${NC}"
    exit 1
fi

AGENT_CODE=$(echo "$AGENT_INFO" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('agent_code', ''))" 2>/dev/null || echo "")

if [ -z "$AGENT_CODE" ]; then
    echo -e "${RED}✗ Could not extract agent_code${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found agent_code: $AGENT_CODE${NC}"

# Authenticate - wait a bit if rate limited
echo -e "\n${YELLOW}Authenticating...${NC}"
LOGIN_RESPONSE=""
for i in {1..3}; do
    LOGIN_RESPONSE=$(curl -s -X POST "$API_BASE_URL$API_VERSION/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"agent_code\": \"$AGENT_CODE\"}" 2>/dev/null || echo "")
    
    if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
        break
    elif echo "$LOGIN_RESPONSE" | grep -q "Rate limit"; then
        echo -e "${YELLOW}  Rate limited, waiting 10 seconds...${NC}"
        sleep 10
    else
        echo -e "${YELLOW}  Login attempt $i failed, response: $LOGIN_RESPONSE${NC}"
        if [ $i -lt 3 ]; then
            sleep 2
        fi
    fi
done

# Extract token
AUTH_TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('access_token', ''))" 2>/dev/null || echo "")

if [ -z "$AUTH_TOKEN" ]; then
    echo -e "${RED}✗ Authentication failed${NC}"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo -e "${GREEN}✓ Authentication successful${NC}"

# Test Campaign Endpoints
echo -e "\n${BLUE}=== Testing Campaign Endpoints ===${NC}"

test_endpoint "GET" "/campaigns" "" "200" "List all campaigns" "$AUTH_TOKEN"
test_endpoint "GET" "/campaigns/templates" "" "200" "Get campaign templates" "$AUTH_TOKEN"
test_endpoint "GET" "/campaigns/recommendations" "" "200" "Get campaign recommendations" "$AUTH_TOKEN"

# Get first campaign ID for detailed tests
CAMPAIGNS_RESPONSE=$(curl -s -X GET "$API_BASE_URL$API_VERSION/campaigns" \
    -H "Authorization: Bearer $AUTH_TOKEN" 2>/dev/null || echo "{}")

CAMPAIGN_ID=$(echo "$CAMPAIGNS_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data and len(data['data']) > 0:
        print(data['data'][0].get('campaign_id', ''))
except:
    pass
" 2>/dev/null || echo "")

if [ ! -z "$CAMPAIGN_ID" ]; then
    test_endpoint "GET" "/campaigns/$CAMPAIGN_ID" "" "200" "Get campaign details" "$AUTH_TOKEN"
    test_endpoint "GET" "/campaigns/$CAMPAIGN_ID/analytics" "" "200" "Get campaign analytics" "$AUTH_TOKEN"
fi

# Test Callback Endpoints
echo -e "\n${BLUE}=== Testing Callback Endpoints ===${NC}"

test_endpoint "GET" "/callbacks" "" "200" "List all callback requests" "$AUTH_TOKEN"
test_endpoint "GET" "/callbacks?status=pending" "" "200" "List pending callbacks" "$AUTH_TOKEN"
test_endpoint "GET" "/callbacks?priority=high" "" "200" "List high priority callbacks" "$AUTH_TOKEN"

# Get first callback ID for detailed tests
CALLBACKS_RESPONSE=$(curl -s -X GET "$API_BASE_URL$API_VERSION/callbacks" \
    -H "Authorization: Bearer $AUTH_TOKEN" 2>/dev/null || echo "{}")

CALLBACK_ID=$(echo "$CALLBACKS_RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'data' in data and len(data['data']) > 0:
        print(data['data'][0].get('callback_request_id', ''))
except:
    pass
" 2>/dev/null || echo "")

if [ ! -z "$CALLBACK_ID" ]; then
    test_endpoint "GET" "/callbacks/$CALLBACK_ID" "" "200" "Get callback details" "$AUTH_TOKEN"
fi

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
    echo -e "\n${YELLOW}Some tests failed${NC}"
    exit 1
fi

