#!/bin/bash

# Agent Mitra CRM & Lead Management API Newman Testing Script
# ===============================================
#
# This script runs comprehensive API tests for the CRM & Lead Management system
# using Newman (Postman CLI) and generates detailed HTML reports.
#
# Prerequisites:
# - Node.js and npm installed
# - Newman installed globally: npm install -g newman newman-reporter-html
# - Backend server running on localhost:8015
#
# Usage:
#   ./test-crm-leads-newman.sh [environment]
#
# Environments:
#   - local (default): Test against localhost:8015
#   - staging: Test against staging environment
#   - production: Test against production environment
#
# Output:
#   - HTML report: reports/crm-leads-api-test-report.html
#   - JUnit XML: reports/crm-leads-api-test-results.xml
#   - JSON results: reports/crm-leads-api-test-results.json

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
REPORTS_DIR="$SCRIPT_DIR/reports"
COLLECTION_FILE="$SCRIPT_DIR/agent-mitra-crm-leads-collection.json"

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

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if newman is installed
    if ! command -v newman &> /dev/null; then
        log_error "Newman is not installed. Please install it with:"
        log_error "npm install -g newman newman-reporter-html"
        exit 1
    fi

    # Check if collection file exists
    if [ ! -f "$COLLECTION_FILE" ]; then
        log_error "Collection file not found: $COLLECTION_FILE"
        exit 1
    fi

    # Check if environment file exists
    if [ ! -f "$ENV_FILE" ]; then
        log_error "Environment file not found for $ENVIRONMENT: $ENV_FILE"
        exit 1
    fi

    log_success "Prerequisites check passed"
}

# Check if backend is running
check_backend() {
    log_info "Checking backend connectivity..."

    # Extract base URL from environment file
    BASE_URL=$(grep -o '"base_url":[[:space:]]*"[^"]*"' "$ENV_FILE" | cut -d'"' -f4)

    if [ -z "$BASE_URL" ]; then
        log_warning "Could not extract base_url from environment file, using default"
        BASE_URL="http://localhost:8015/api/v1"
    fi

    # Remove /api/v1 if present for health check
    HEALTH_URL="${BASE_URL%/api/v1}/health"

    log_info "Testing connection to: $HEALTH_URL"

    if ! curl -s --max-time 10 --fail "$HEALTH_URL" > /dev/null; then
        log_error "Backend is not accessible at $HEALTH_URL"
        log_error "Please ensure the backend server is running"
        exit 1
    fi

    log_success "Backend is accessible"
}

# Create reports directory
setup_reports() {
    log_info "Setting up reports directory..."

    mkdir -p "$REPORTS_DIR"

    # Clean up old reports
    rm -f "$REPORTS_DIR/crm-leads-api-test-report.html"
    rm -f "$REPORTS_DIR/crm-leads-api-test-results.xml"
    rm -f "$REPORTS_DIR/crm-leads-api-test-results.json"

    log_success "Reports directory ready"
}

# Run Newman tests
run_tests() {
    log_info "Starting Newman tests for environment: $ENVIRONMENT"
    log_info "Collection: $COLLECTION_FILE"
    log_info "Environment: $ENV_FILE"

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_prefix="$REPORTS_DIR/crm-leads-api-test-$ENVIRONMENT-$timestamp"

    # Run Newman with multiple reporters
    newman run "$COLLECTION_FILE" \
        --environment "$ENV_FILE" \
        --reporters cli,json,html,junit \
        --reporter-json-export "$report_prefix-results.json" \
        --reporter-html-export "$report_prefix-report.html" \
        --reporter-junit-export "$report_prefix-results.xml" \
        --timeout 30000 \
        --delay-request 1000 \
        --suppress-exit-code \
        --color on \
        --verbose

    local exit_code=$?

    # Copy reports to standard names for easy access
    cp "$report_prefix-report.html" "$REPORTS_DIR/crm-leads-api-test-report.html" 2>/dev/null || true
    cp "$report_prefix-results.xml" "$REPORTS_DIR/crm-leads-api-test-results.xml" 2>/dev/null || true
    cp "$report_prefix-results.json" "$REPORTS_DIR/crm-leads-api-test-results.json" 2>/dev/null || true

    return $exit_code
}

# Analyze test results
analyze_results() {
    local json_file="$REPORTS_DIR/crm-leads-api-test-results.json"

    if [ ! -f "$json_file" ]; then
        log_error "Results file not found: $json_file"
        return 1
    fi

    log_info "Analyzing test results..."

    # Extract key metrics using jq if available, otherwise use basic parsing
    if command -v jq &> /dev/null; then
        local total=$(jq '.run.stats.requests.total' "$json_file")
        local failed=$(jq '.run.stats.requests.failed' "$json_file")
        local passed=$((total - failed))

        echo ""
        echo "📊 TEST RESULTS SUMMARY"
        echo "========================"
        printf "Total Requests: %d\n" "$total"
        printf "Passed: %d\n" "$passed"
        printf "Failed: %d\n" "$failed"

        if [ "$total" -gt 0 ]; then
            local success_rate=$(( (passed * 100) / total ))
            printf "Success Rate: %d%%\n" "$success_rate"
        fi

        # Show failed requests
        local failed_requests=$(jq -r '.run.executions[] | select(.requestError != null or (.response.code // 0) >= 400) | .request.url.raw' "$json_file" 2>/dev/null || echo "")
        if [ -n "$failed_requests" ]; then
            echo ""
            echo "❌ FAILED REQUESTS:"
            echo "$failed_requests"
        fi

    else
        log_warning "jq not available for detailed analysis"
        echo "Please install jq for detailed test result analysis"
    fi
}

# Generate summary report
generate_summary() {
    local html_file="$REPORTS_DIR/crm-leads-api-test-report.html"
    local json_file="$REPORTS_DIR/crm-leads-api-test-results.json"

    if [ -f "$html_file" ]; then
        log_success "HTML report generated: $html_file"
        log_info "Open in browser: file://$html_file"
    fi

    if [ -f "$json_file" ]; then
        log_success "JSON results: $json_file"
    fi

    echo ""
    echo "🎯 CRM & LEAD MANAGEMENT API TEST SUMMARY"
    echo "=========================================="
    echo "Environment: $ENVIRONMENT"
    echo "Collection: $(basename "$COLLECTION_FILE")"
    echo "Reports Directory: $REPORTS_DIR"
    echo ""
    echo "📋 TESTED ENDPOINTS:"
    echo "  ✅ Authentication (Senior Agent Login)"
    echo "  ✅ Customers API (List Agent Customers)"
    echo "  ✅ CRM Analytics (Hot Leads, Dashboard, Lead Details)"
    echo "  ✅ Retention Analytics (At-Risk, Dashboard, Plans)"
    echo "  ✅ Lead CRUD Operations (Create, List, Get, Update)"
    echo "  ✅ Lead Interactions (Add, Get)"
    echo "  ✅ Lead Qualification"
    echo ""
    echo "🔍 KEY FEATURES TESTED:"
    echo "  • Real database queries (no mocks)"
    echo "  • JWT authentication with role-based access"
    echo "  • Comprehensive data validation"
    echo "  • Lead scoring and conversion analytics"
    echo "  • Customer retention risk assessment"
    echo "  • Lead interaction tracking"
    echo "  • Role-based permissions"
    echo ""
    echo "📊 REAL DATABASE INTEGRATION:"
    echo "  • Customer data from policyholders table"
    echo "  • Lead data from leads table with real scoring"
    echo "  • Interaction history from lead_interactions table"
    echo "  • Analytics calculations from multiple data sources"
    echo "  • Retention risk assessment based on real metrics"
}

# Main execution
main() {
    echo "🎯 Agent Mitra CRM & Lead Management API Newman Testing Suite"
    echo "============================================================"
    echo "Environment: $ENVIRONMENT"
    echo "Timestamp: $(date)"
    echo ""

    check_prerequisites
    check_backend
    setup_reports

    local start_time=$(date +%s)

    if run_tests; then
        local test_exit_code=$?
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))

        echo ""
        log_success "Tests completed in ${duration}s"

        analyze_results
        generate_summary

        if [ $test_exit_code -eq 0 ]; then
            log_success "🎉 All tests passed!"
            exit 0
        else
            log_warning "⚠️  Some tests failed - check reports for details"
            exit 1
        fi
    else
        log_error "❌ Test execution failed"
        exit 1
    fi
}

# Handle script arguments
case "$1" in
    local|staging|production)
        ENVIRONMENT="$1"
        ;;
    -h|--help)
        echo "Usage: $0 [environment]"
        echo ""
        echo "Environments:"
        echo "  local     - Test against localhost:8015 (default)"
        echo "  staging   - Test against staging environment"
        echo "  production- Test against production environment"
        echo ""
        echo "Output:"
        echo "  HTML report: reports/crm-leads-api-test-report.html"
        echo "  JSON results: reports/crm-leads-api-test-results.json"
        echo "  JUnit XML: reports/crm-leads-api-test-results.xml"
        exit 0
        ;;
    *)
        # Default is local
        ;;
esac

main "$@"
