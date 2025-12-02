#!/bin/bash

# Agent Mitra Notification API Newman Testing Script
# ====================================================
#
# This script runs comprehensive API tests for the Notification Management system
# using Newman (Postman CLI) and generates detailed HTML reports.
#
# Prerequisites:
# - Node.js and npm installed
# - Newman installed globally: npm install -g newman newman-reporter-html
# - Backend server running on localhost:8015
#
# Usage:
#   ./test-notifications-newman.sh [environment]
#
# Environments:
#   - local (default): Test against localhost:8015
#   - staging: Test against staging environment
#   - production: Test against production environment
#
# Output:
#   - HTML report: reports/notification-api-test-report.html
#   - JUnit XML: reports/notification-api-test-results.xml
#   - JSON results: reports/notification-api-test-results.json

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
REPORTS_DIR="$SCRIPT_DIR/reports"
COLLECTION_FILE="$SCRIPT_DIR/agent-mitra-notifications-collection.json"

# Default environment
ENVIRONMENT="${1:-local}"

# Environment file mapping
if [ "$ENVIRONMENT" = "local" ]; then
    ENV_FILE="$SCRIPT_DIR/agent-mitra-local.postman_environment.json"
elif [ "$ENVIRONMENT" = "staging" ]; then
    ENV_FILE="$SCRIPT_DIR/agent-mitra-staging.postman_environment.json"
elif [ "$ENVIRONMENT" = "production" ]; then
    ENV_FILE="$SCRIPT_DIR/agent-mitra-production.postman_environment.json"
else
    ENV_FILE="$SCRIPT_DIR/agent-mitra-local.postman_environment.json"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================================${NC}"
}

# Function to check if newman is installed
check_newman() {
    if ! command -v newman &> /dev/null; then
        log_error "Newman is not installed. Please install it with:"
        echo "npm install -g newman newman-reporter-html"
        exit 1
    fi
}

# Function to check if collection and environment files exist
check_files() {
    if [ ! -f "$COLLECTION_FILE" ]; then
        log_error "Collection file not found: $COLLECTION_FILE"
        exit 1
    fi

    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file not found: $ENV_FILE"
        exit 1
    fi
}

# Function to create reports directory
create_reports_dir() {
    mkdir -p "$REPORTS_DIR"
    log_info "Reports directory: $REPORTS_DIR"
}

# Function to test server connectivity
test_server_connectivity() {
    log_info "Testing server connectivity..."

    # Extract base URL from environment file
    BASE_URL=$(grep -o '"api_host":[^,]*' "$ENV_FILE" | cut -d'"' -f4)
    if [ -z "$BASE_URL" ]; then
        BASE_URL="http://localhost:8015"
    fi

    # Test health endpoint
    if curl -s --connect-timeout 5 --max-time 10 "$BASE_URL/health" > /dev/null 2>&1; then
        log_success "Server is responding at $BASE_URL"
    else
        log_error "Server is not responding at $BASE_URL"
        log_error "Please ensure the backend server is running on port 8015"
        exit 1
    fi
}

# Function to run newman tests
run_newman_tests() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_prefix="notification-api-test-${timestamp}"

    log_header "Running Newman Tests"

    log_info "Environment: $ENVIRONMENT"
    log_info "Collection: $COLLECTION_FILE"
    log_info "Environment: $ENV_FILE"
    log_info "Reports: $REPORTS_DIR"

    # Run Newman with comprehensive reporting
    newman run "$COLLECTION_FILE" \
        --environment "$ENV_FILE" \
        --reporters cli,json,html,junit \
        --reporter-json-export "$REPORTS_DIR/${report_prefix}-results.json" \
        --reporter-html-export "$REPORTS_DIR/${report_prefix}-report.html" \
        --reporter-junit-export "$REPORTS_DIR/${report_prefix}-results.xml" \
        --timeout 30000 \
        --delay-request 500 \
        --bail \
        --color on \
        --verbose

    local exit_code=$?

    # Create latest symlinks
    ln -sf "${report_prefix}-report.html" "$REPORTS_DIR/notification-api-test-report.html"
    ln -sf "${report_prefix}-results.json" "$REPORTS_DIR/notification-api-test-results.json"
    ln -sf "${report_prefix}-results.xml" "$REPORTS_DIR/notification-api-test-results.xml"

    return $exit_code
}

# Function to analyze test results
analyze_results() {
    local json_file="$REPORTS_DIR/notification-api-test-results.json"

    if [ ! -f "$json_file" ]; then
        log_error "Results file not found: $json_file"
        return 1
    fi

    log_header "Test Results Analysis"

    # Extract key metrics using jq if available, otherwise use grep
    if command -v jq &> /dev/null; then
        local total_requests=$(jq '.run.stats.requests.total' "$json_file")
        local failed_requests=$(jq '.run.stats.requests.failed' "$json_file")
        local total_assertions=$(jq '.run.stats.assertions.total' "$json_file")
        local failed_assertions=$(jq '.run.stats.assertions.failed' "$json_file")
        local total_tests=$(jq '.run.stats.tests.total' "$json_file")
        local failed_tests=$(jq '.run.stats.tests.failed' "$json_file")

        echo "📊 Test Statistics:"
        echo "   Total Requests: $total_requests"
        echo "   Failed Requests: $failed_requests"
        echo "   Total Assertions: $total_assertions"
        echo "   Failed Assertions: $failed_assertions"
        echo "   Total Tests: $total_tests"
        echo "   Failed Tests: $failed_tests"

        # Calculate success rates
        if [ "$total_requests" -gt 0 ]; then
            local request_success_rate=$(( (total_requests - failed_requests) * 100 / total_requests ))
            echo "   Request Success Rate: ${request_success_rate}%"
        fi

        if [ "$total_assertions" -gt 0 ]; then
            local assertion_success_rate=$(( (total_assertions - failed_assertions) * 100 / total_assertions ))
            echo "   Assertion Success Rate: ${assertion_success_rate}%"
        fi

        if [ "$total_tests" -gt 0 ]; then
            local test_success_rate=$(( (total_tests - failed_tests) * 100 / total_tests ))
            echo "   Test Success Rate: ${test_success_rate}%"
        fi

        # Check for 100% success
        if [ "$failed_requests" -eq 0 ] && [ "$failed_assertions" -eq 0 ] && [ "$failed_tests" -eq 0 ]; then
            log_success "🎉 ALL TESTS PASSED! 100% Success Rate!"
        else
            log_error "❌ Some tests failed. Check the detailed report for issues."
        fi

    else
        log_warning "jq not found. Install jq for detailed analysis: brew install jq"
        log_info "Basic results available in: $REPORTS_DIR/notification-api-test-results.json"
    fi
}

# Function to display report locations
display_reports() {
    log_header "Generated Reports"

    echo "📁 Reports Directory: $REPORTS_DIR"
    echo ""
    echo "📄 HTML Report (Open in browser):"
    echo "   file://$REPORTS_DIR/notification-api-test-report.html"
    echo ""
    echo "📋 JSON Results:"
    echo "   $REPORTS_DIR/notification-api-test-results.json"
    echo ""
    echo "📊 JUnit XML:"
    echo "   $REPORTS_DIR/notification-api-test-results.xml"
    echo ""
    echo "💡 Tip: Open the HTML report in your browser for detailed test results"
}

# Function to cleanup old reports (keep last 10)
cleanup_old_reports() {
    log_info "Cleaning up old reports (keeping last 10)..."

    # Count total report files
    local total_reports=$(find "$REPORTS_DIR" -name "notification-api-test-*-results.json" | wc -l)

    if [ "$total_reports" -gt 10 ]; then
        local to_delete=$((total_reports - 10))

        # Delete oldest reports
        find "$REPORTS_DIR" -name "notification-api-test-*-results.json" -print0 |
        xargs -0 ls -t | tail -n "$to_delete" | xargs rm -f 2>/dev/null || true

        find "$REPORTS_DIR" -name "notification-api-test-*-report.html" -print0 |
        xargs -0 ls -t | tail -n "$to_delete" | xargs rm -f 2>/dev/null || true

        find "$REPORTS_DIR" -name "notification-api-test-*-results.xml" -print0 |
        xargs -0 ls -t | tail -n "$to_delete" | xargs rm -f 2>/dev/null || true

        log_info "Cleaned up $to_delete old report sets"
    fi
}

# Main execution
main() {
    log_header "Agent Mitra Notification API Testing Suite"
    echo "Environment: $ENVIRONMENT"
    echo "Timestamp: $(date)"
    echo ""

    # Pre-flight checks
    check_newman
    check_files
    create_reports_dir
    test_server_connectivity

    # Run tests
    if run_newman_tests; then
        log_success "✅ Newman tests completed successfully!"

        # Analyze results
        analyze_results

        # Display report locations
        display_reports

        # Cleanup
        cleanup_old_reports

        log_success "🎯 Notification API testing completed successfully!"
        exit 0
    else
        local exit_code=$?
        log_error "❌ Newman tests failed with exit code: $exit_code"

        # Still show reports if they exist
        if [ -f "$REPORTS_DIR/notification-api-test-report.html" ]; then
            display_reports
        fi

        exit $exit_code
    fi
}

# Run main function
main "$@"
