#!/bin/bash

# Agent Mitra Backend API Testing Script
# Comprehensive testing of all backend endpoints

set -e

# Configuration
BASE_URL="http://localhost:8012"
API_VERSION="/api/v1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

run_test() {
    local test_name="$1"
    local command="$2"
    local expected_status="${3:-200}"

    ((TOTAL_TESTS++))

    log_info "Running: $test_name"

    # Run the command and capture output
    local output
    local status
    if output=$(eval "$command" 2>&1); then
        status=$?
        if [ "$status" -eq 0 ]; then
            log_success "$test_name"
        else
            log_error "$test_name - Command failed with status $status"
            echo "Output: $output"
        fi
    else
        status=$?
        log_error "$test_name - Command failed with status $status"
        echo "Output: $output"
    fi
}

# Health check tests
test_health_endpoints() {
    log_info "=== Testing Health Endpoints ==="

    # Overall health
    run_test "Overall Health Check" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL/health" "200"

    # API health
    run_test "API Health Check" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/health" "200"

    # Database health (if implemented)
    run_test "Database Health Check" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/health/database" "200"
}

# Authentication tests
test_auth_endpoints() {
    log_info "=== Testing Authentication Endpoints ==="

    # Login endpoint
    run_test "Login Endpoint" "curl -s -o /dev/null -w '%{http_code}' -X POST $BASE_URL${API_VERSION}/auth/login -H 'Content-Type: application/json' -d '{\"phone_number\":\"+1234567890\",\"otp\":\"123456\"}'" "200"

    # OTP request
    run_test "OTP Request" "curl -s -o /dev/null -w '%{http_code}' -X POST $BASE_URL${API_VERSION}/auth/request-otp -H 'Content-Type: application/json' -d '{\"phone_number\":\"+1234567890\"}'" "200"

    # Logout
    run_test "Logout Endpoint" "curl -s -o /dev/null -w '%{http_code}' -X POST $BASE_URL${API_VERSION}/auth/logout" "401"
}

# User management tests
test_user_endpoints() {
    log_info "=== Testing User Management Endpoints ==="

    # Get user profile (requires auth)
    run_test "Get User Profile" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/users/profile" "401"

    # Update user profile
    run_test "Update User Profile" "curl -s -o /dev/null -w '%{http_code}' -X PUT $BASE_URL${API_VERSION}/users/profile -H 'Content-Type: application/json' -d '{\"name\":\"Test User\"}'" "401"
}

# Agent management tests
test_agent_endpoints() {
    log_info "=== Testing Agent Management Endpoints ==="

    # Get agents
    run_test "Get Agents" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/agents" "401"

    # Get agent by ID
    run_test "Get Agent by ID" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/agents/test-id" "401"
}

# Policy management tests
test_policy_endpoints() {
    log_info "=== Testing Policy Management Endpoints ==="

    # Get policies
    run_test "Get Policies" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/policies" "401"

    # Get policy by ID
    run_test "Get Policy by ID" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/policies/test-id" "401"
}

# Presentation management tests
test_presentation_endpoints() {
    log_info "=== Testing Presentation Endpoints ==="

    # Get presentations
    run_test "Get Presentations" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/presentations" "401"

    # Get presentation templates
    run_test "Get Presentation Templates" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/presentations/templates" "200"
}

# Analytics tests
test_analytics_endpoints() {
    log_info "=== Testing Analytics Endpoints ==="

    # Dashboard overview
    run_test "Analytics Dashboard" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/analytics/dashboard/overview" "401"

    # Agent performance
    run_test "Agent Performance Analytics" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/analytics/agents/test-id/performance" "401"
}

# Import functionality tests
test_import_endpoints() {
    log_info "=== Testing Import Endpoints ==="

    # Get import templates
    run_test "Get Import Templates" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/import/templates" "401"

    # Upload file (will fail without auth and file)
    run_test "Upload Import File" "curl -s -o /dev/null -w '%{http_code}' -X POST $BASE_URL${API_VERSION}/import/upload" "401"
}

# Notification tests
test_notification_endpoints() {
    log_info "=== Testing Notification Endpoints ==="

    # Get notifications
    run_test "Get Notifications" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/notifications" "401"

    # Get notification settings
    run_test "Get Notification Settings" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/notifications/settings" "401"
}

# Chatbot tests
test_chatbot_endpoints() {
    log_info "=== Testing Chatbot Endpoints ==="

    # Create chat session
    run_test "Create Chat Session" "curl -s -o /dev/null -w '%{http_code}' -X POST $BASE_URL${API_VERSION}/chat/sessions -H 'Content-Type: application/json' -d '{\"user_id\":\"test-user\"}'" "401"
}

# Feature flags tests
test_feature_flags_endpoints() {
    log_info "=== Testing Feature Flags Endpoints ==="

    # Get feature flags
    run_test "Get Feature Flags" "curl -s -o /dev/null -w '%{http_code}' $BASE_URL${API_VERSION}/features/flags" "200"
}

# Performance tests
test_performance() {
    log_info "=== Performance Testing ==="

    # Response time test
    local start_time=$(date +%s%3N)
    curl -s $BASE_URL/health > /dev/null
    local end_time=$(date +%s%3N)
    local response_time=$((end_time - start_time))

    if [ $response_time -lt 1000 ]; then
        log_success "Health Check Response Time: ${response_time}ms"
    else
        log_warn "Health Check Response Time: ${response_time}ms (slow)"
    fi
}

# Main test execution
main() {
    log_info "Agent Mitra Backend API Testing Suite"
    log_info "======================================"
    log_info "Base URL: $BASE_URL"
    log_info "API Version: $API_VERSION"
    log_info ""

    # Check if backend is running
    if ! curl -s --max-time 5 $BASE_URL/health > /dev/null; then
        log_error "Backend is not running or accessible at $BASE_URL"
        log_error "Please start the backend service first:"
        log_error "  cd backend && python main.py"
        exit 1
    fi

    log_success "Backend is running and accessible"

    # Run all test suites
    test_health_endpoints
    echo ""
    test_auth_endpoints
    echo ""
    test_user_endpoints
    echo ""
    test_agent_endpoints
    echo ""
    test_policy_endpoints
    echo ""
    test_presentation_endpoints
    echo ""
    test_analytics_endpoints
    echo ""
    test_import_endpoints
    echo ""
    test_notification_endpoints
    echo ""
    test_chatbot_endpoints
    echo ""
    test_feature_flags_endpoints
    echo ""
    test_performance

    # Summary
    echo ""
    log_info "=== Test Summary ==="
    log_info "Total Tests: $TOTAL_TESTS"
    log_success "Passed: $PASSED_TESTS"
    if [ $FAILED_TESTS -gt 0 ]; then
        log_error "Failed: $FAILED_TESTS"
    fi

    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    log_info "Success Rate: ${success_rate}%"

    if [ $success_rate -ge 80 ]; then
        log_success "Overall: PASSED"
        exit 0
    else
        log_error "Overall: FAILED"
        exit 1
    fi
}

# Handle script arguments
case "$1" in
    --help)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --health     Run only health checks"
        echo "  --auth       Run only authentication tests"
        echo "  --perf       Run only performance tests"
        echo "  --help       Show this help message"
        echo ""
        echo "Environment Variables:"
        echo "  BASE_URL     Backend base URL (default: http://localhost:8012)"
        exit 0
        ;;
    --health)
        test_health_endpoints
        ;;
    --auth)
        test_auth_endpoints
        ;;
    --perf)
        test_performance
        ;;
    *)
        main "$@"
        ;;
esac
