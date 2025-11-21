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

    # Get agent dashboard analytics (may return empty data)
    test_endpoint "GET" "/api/v1/analytics/dashboard/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11" "" "$AUTH_TOKEN" 200 "Get agent dashboard analytics"

    # Test Chat Endpoints (may not be fully implemented)
    log_info "Testing Chat Endpoints..."

    # Get chat sessions (may return empty array)
    test_endpoint "GET" "/api/v1/chat/sessions" "" "$AUTH_TOKEN" 200 "Get chat sessions"

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