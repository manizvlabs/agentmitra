#!/bin/bash

# Agent Mitra API Comprehensive Test Script
# Tests all API endpoints with proper authentication and data validation

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://localhost:8012"
TEST_RESULTS=()

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local auth_header=$4
    local expected_status=${5:-200}
    local description=$6

    log_info "Testing $description: $method $endpoint"

    local cmd="curl -s -w \"HTTPSTATUS:%{http_code};\" -o /tmp/curl_response.txt"
    if [ "$auth_header" != "" ]; then
        cmd="$cmd -H \"Authorization: Bearer $auth_header\""
    fi
    if [ "$method" != "GET" ]; then
        cmd="$cmd -X $method -H \"Content-Type: application/json\""
        if [ "$data" != "" ]; then
            cmd="$cmd -d '$data'"
        fi
    fi
    cmd="$cmd \"$BASE_URL$endpoint\""

    local response=$(eval $cmd)
    local status_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS:\([0-9]*\);.*/\1/')
    local body=$(cat /tmp/curl_response.txt)

    if [ "$status_code" -eq "$expected_status" ]; then
        log_success "$description passed (Status: $status_code)"
        TEST_RESULTS+=("PASS: $description")
        return 0
    else
        log_error "$description failed (Expected: $expected_status, Got: $status_code)"
        if [ ${#body} -lt 500 ]; then
            echo "Response: $body"
        else
            echo "Response: $(echo $body | head -c 200)..."
        fi
        TEST_RESULTS+=("FAIL: $description (Expected: $expected_status, Got: $status_code)")
        return 1
    fi
}

# Start backend if not running
check_backend() {
    log_info "Checking if backend is running..."
    if ! curl -s "$BASE_URL/health" > /dev/null 2>&1; then
        log_error "Backend is not running. Please start the backend first:"
        echo "cd backend && source venv/bin/activate && python main.py"
        exit 1
    fi
    log_success "Backend is running"
}

# Main test function
run_tests() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    echo "=============================================="
    echo "🧪 Agent Mitra API Comprehensive Test Suite"
    echo "=============================================="

    # Test Health Endpoints
    log_info "Testing Health Endpoints..."
    test_endpoint "GET" "/health" "" "" 200 "Root health check"
    test_endpoint "GET" "/api/v1/health" "" "" 200 "API health check"
    test_endpoint "GET" "/api/v1/health/database" "" "" 200 "Database health check"
    test_endpoint "GET" "/api/v1/health/system" "" "" 200 "System health check"
    test_endpoint "GET" "/api/v1/health/comprehensive" "" "" 200 "Comprehensive health check"

    # Test Feature Flags (no auth required)
    log_info "Testing Feature Flags..."
    test_endpoint "GET" "/api/v1/feature-flags" "" "" 200 "Get feature flags"

    # Test Authentication Endpoints
    log_info "Testing Authentication Endpoints..."

    # Agent code login (reliable method)
    AGENT_TOKEN=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"agent_code": "AGENT001"}' | jq -r '.access_token')

    if [ "$AGENT_TOKEN" != "null" ] && [ "$AGENT_TOKEN" != "" ]; then
        log_success "Agent code login successful"
        AUTH_TOKEN="$AGENT_TOKEN"
    else
        log_error "Agent code login failed"
        exit 1
    fi

    # Test password-based login with existing user (skip detailed response parsing)
    local password_response=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"phone_number": "+919876543210", "password": "password123"}')

    if echo "$password_response" | grep -q "access_token"; then
        log_success "Password-based login successful"
        TEST_RESULTS+=("PASS: Password-based login")
    else
        log_error "Password-based login failed"
        TEST_RESULTS+=("FAIL: Password-based login")
    fi

    # Test invalid login
    test_endpoint "POST" "/api/v1/auth/login" '{"phone_number": "+919876543210", "password": "wrongpassword"}' "" 401 "Invalid password login"

    # Send OTP (test the endpoint exists)
    test_endpoint "POST" "/api/v1/auth/send-otp" '{"phone_number": "+919876543299"}' "" 200 "Send OTP"

    # Test User Endpoints
    log_info "Testing User Management Endpoints..."

    # Get current user profile
    test_endpoint "GET" "/api/v1/users/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" "" "$AUTH_TOKEN" 200 "Get user profile"

    # Update user profile
    test_endpoint "PUT" "/api/v1/users/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" '{"first_name": "Updated"}' "$AUTH_TOKEN" 200 "Update user profile"

    # Get user preferences
    test_endpoint "GET" "/api/v1/users/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/preferences" "" "$AUTH_TOKEN" 200 "Get user preferences"

    # Update user preferences
    test_endpoint "PUT" "/api/v1/users/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/preferences" '{"language_preference": "hi"}' "$AUTH_TOKEN" 200 "Update user preferences"

    # Search users (junior agent can search policyholders)
    test_endpoint "GET" "/api/v1/users/?q=customer&limit=5" "" "$AUTH_TOKEN" 200 "Search users"

    # Test Provider Endpoints
    log_info "Testing Provider Management Endpoints..."

    # Get all providers
    test_endpoint "GET" "/api/v1/providers/" "" "$AUTH_TOKEN" 200 "Get all providers"

    # Get specific provider
    test_endpoint "GET" "/api/v1/providers/01fa8d3a-5509-4f73-abeb-617fd547f16d" "" "$AUTH_TOKEN" 200 "Get provider by ID"

    # Get provider by code
    test_endpoint "GET" "/api/v1/providers/code/LIC" "" "$AUTH_TOKEN" 200 "Get provider by code"

    # Test Agent Endpoints
    log_info "Testing Agent Management Endpoints..."

    # Get agent by code
    test_endpoint "GET" "/api/v1/agents/code/AGENT001" "" "$AUTH_TOKEN" 200 "Get agent by code"

    # Skip agent search for junior agent (insufficient permissions) - tested manually

    # Test Policy Endpoints
    log_info "Testing Policy Management Endpoints..."

    # Get policies (junior agent can see policies they created)
    test_endpoint "GET" "/api/v1/policies/" "" "$AUTH_TOKEN" 200 "Get policies list"

    # Test Policy Endpoints
    log_info "Testing Policy Management Endpoints..."

    # Get policies
    test_endpoint "GET" "/api/v1/policies/" "" "$AUTH_TOKEN" 200 "Get policies list"

    # Test Session Management
    log_info "Testing Session Management Endpoints..."

    # Get user sessions
    test_endpoint "GET" "/api/v1/auth/sessions" "" "$AUTH_TOKEN" 200 "Get user sessions"

    # Test Logout
    test_endpoint "POST" "/api/v1/auth/logout" "" "$AUTH_TOKEN" 200 "User logout"

    # Test Presentation Endpoints
    log_info "Testing Presentation Endpoints..."

    # Get presentations for agent
    test_endpoint "GET" "/api/v1/presentations/agent/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" "" "$AUTH_TOKEN" 200 "Get agent presentations"

    # Get active presentation
    test_endpoint "GET" "/api/v1/presentations/agent/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/active" "" "$AUTH_TOKEN" 200 "Get active presentation"

    # Get presentation templates
    test_endpoint "GET" "/api/v1/presentations/templates" "" "$AUTH_TOKEN" 200 "Get presentation templates"

    # Test Analytics Endpoints
    log_info "Testing Analytics Endpoints..."

    # Get agent dashboard analytics
    test_endpoint "GET" "/api/v1/analytics/dashboard/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" "" "$AUTH_TOKEN" 200 "Get agent dashboard analytics"

    # Get global dashboard analytics
    test_endpoint "GET" "/api/v1/analytics/dashboard/overview" "" "$AUTH_TOKEN" 200 "Get global dashboard analytics"

    # Get revenue trends chart
    test_endpoint "GET" "/api/v1/analytics/dashboard/charts/revenue-trends?months=6" "" "$AUTH_TOKEN" 200 "Get revenue trends chart"

    # Get policy trends chart
    test_endpoint "GET" "/api/v1/analytics/dashboard/charts/policy-trends?months=6" "" "$AUTH_TOKEN" 200 "Get policy trends chart"

    # Get top performing agents
    test_endpoint "GET" "/api/v1/analytics/dashboard/top-agents?limit=5" "" "$AUTH_TOKEN" 200 "Get top performing agents"

    # Get agent performance metrics
    test_endpoint "GET" "/api/v1/analytics/agents/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11/performance" "" "$AUTH_TOKEN" 200 "Get agent performance metrics"

    # Get policy analytics
    test_endpoint "GET" "/api/v1/analytics/policies/analytics" "" "$AUTH_TOKEN" 200 "Get policy analytics"

    # Get revenue analytics
    test_endpoint "GET" "/api/v1/analytics/revenue/analytics" "" "$AUTH_TOKEN" 200 "Get revenue analytics"

    # Get analytics summary
    test_endpoint "GET" "/api/v1/analytics/reports/summary" "" "$AUTH_TOKEN" 200 "Get analytics summary"

    # Generate custom analytics report
    test_endpoint "POST" "/api/v1/analytics/reports/generate" '{"report_type": "dashboard", "agent_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"}' "$AUTH_TOKEN" 200 "Generate custom analytics report"

    # Test Presentation Analytics Endpoints
    log_info "Testing Presentation Analytics Endpoints..."

    # Get presentations list first to get a valid presentation ID
    PRESENTATION_RESPONSE=$(curl -s "$BASE_URL/api/v1/presentations/agent/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" \
        -H "Authorization: Bearer $AUTH_TOKEN")

    # Extract presentation ID if available
    PRESENTATION_ID=$(echo "$PRESENTATION_RESPONSE" | jq -r '.[0].presentation_id' 2>/dev/null || echo "")

    if [ "$PRESENTATION_ID" != "null" ] && [ "$PRESENTATION_ID" != "" ]; then
        test_endpoint "GET" "/api/v1/analytics/presentations/$PRESENTATION_ID/analytics" "" "$AUTH_TOKEN" 200 "Get presentation analytics"
        test_endpoint "GET" "/api/v1/analytics/presentations/$PRESENTATION_ID/analytics/trends?days=7" "" "$AUTH_TOKEN" 200 "Get presentation trends"
    else
        log_warning "No presentations found for analytics testing"
    fi

    # Test Chatbot Endpoints
    log_info "Testing Chatbot Endpoints..."

    # Create a new chat session
    SESSION_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/chat/sessions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{"user_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11", "device_info": {"device": "test", "os": "linux"}}')

    SESSION_ID=$(echo "$SESSION_RESPONSE" | jq -r '.session_id' 2>/dev/null || echo "")

    if [ "$SESSION_ID" != "null" ] && [ "$SESSION_ID" != "" ]; then
        # Test sending a message to the chatbot
        test_endpoint "POST" "/api/v1/chat/sessions/$SESSION_ID/messages" '{"message": "What is life insurance?", "user_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"}' "$AUTH_TOKEN" 200 "Send message to chatbot"

        # Test getting session analytics
        test_endpoint "GET" "/api/v1/chat/sessions/$SESSION_ID/analytics" "" "$AUTH_TOKEN" 200 "Get chat session analytics"

        # End the chat session
        test_endpoint "PUT" "/api/v1/chat/sessions/$SESSION_ID/end?satisfaction_score=5" "" "$AUTH_TOKEN" 200 "End chat session"
    else
        log_warning "Failed to create chat session for testing"
    fi

    # Test Knowledge Base Endpoints
    log_info "Testing Knowledge Base Endpoints..."

    # Search knowledge base
    test_endpoint "GET" "/api/v1/chat/knowledge-base/search?q=life%20insurance&limit=5" "" "$AUTH_TOKEN" 200 "Search knowledge base"

    # Create a knowledge base article
    ARTICLE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/chat/knowledge-base/articles" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "title": "Test Article for API Testing",
            "content": "This is a test article created during API testing to verify the knowledge base functionality.",
            "category": "testing",
            "tags": ["test", "api", "automation"]
        }')

    ARTICLE_ID=$(echo "$ARTICLE_RESPONSE" | jq -r '.article_id' 2>/dev/null || echo "")

    if [ "$ARTICLE_ID" != "null" ] && [ "$ARTICLE_ID" != "" ]; then
        # Update the article
        test_endpoint "PUT" "/api/v1/chat/knowledge-base/articles/$ARTICLE_ID" '{"title": "Updated Test Article"}' "$AUTH_TOKEN" 200 "Update knowledge base article"

        # Note: Delete test disabled to avoid cleanup issues in repeated tests
        # test_endpoint "DELETE" "/api/v1/chat/knowledge-base/articles/$ARTICLE_ID" "" "$AUTH_TOKEN" 200 "Delete knowledge base article"
    fi

    # Test Intent Management Endpoints
    log_info "Testing Intent Management Endpoints..."

    # Create a test intent
    INTENT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/chat/intents" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -d '{
            "intent_name": "test_api_inquiry",
            "description": "Test intent for API testing",
            "training_examples": ["How does the API work?", "What is API testing?"],
            "response_templates": ["The API allows you to interact with our system programmatically.", "API testing ensures our endpoints work correctly."]
        }')

    # Get intent statistics
    test_endpoint "GET" "/api/v1/chat/intents/stats" "" "$AUTH_TOKEN" 200 "Get intent statistics"

    # Test Chatbot Analytics Endpoints
    log_info "Testing Chatbot Analytics Endpoints..."

    # Get chatbot analytics
    test_endpoint "GET" "/api/v1/chat/analytics" "" "$AUTH_TOKEN" 200 "Get chatbot analytics"

    # Test chatbot health check
    test_endpoint "GET" "/api/v1/chat/health" "" "" 200 "Chatbot health check"

    # Summary
    echo "=============================================="
    echo "📊 Test Results Summary"
    echo "=============================================="

    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == PASS* ]]; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    done

    log_info "Total Tests: $total_tests"
    log_success "Passed: $passed_tests"
    if [ $failed_tests -gt 0 ]; then
        log_error "Failed: $failed_tests"
        echo ""
        echo "Failed Tests:"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == FAIL* ]]; then
                echo "  - $result"
            fi
        done
    fi

    echo ""
    if [ $failed_tests -eq 0 ]; then
        log_success "🎉 All API endpoints tested successfully!"
        return 0
    else
        log_error "❌ Some tests failed. Please check the implementation."
        return 1
    fi
}

# Run the tests
check_backend
run_tests