#!/bin/bash

# Agent Mitra API Testing with Newman
# ===================================
# This script runs Postman collections against the Agent Mitra backend API

set -e

# Configuration - will be set based on environment parameter
COLLECTION_FILE="../postman/agent-mitra-api-collection.json"
ENVIRONMENT_FILE=""
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
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

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v newman &> /dev/null; then
        log_error "Newman is not installed. Please install it with: npm install -g newman"
        log_info "Or install Newman with Newman Reporter: npm install -g newman newman-reporter-html"
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi

    log_success "Dependencies check passed"
}

check_files() {
    log_info "Checking required files..."

    if [ ! -f "$COLLECTION_FILE" ]; then
        log_error "Collection file not found: $COLLECTION_FILE"
        exit 1
    fi

    if [ ! -f "$ENVIRONMENT_FILE" ]; then
        log_error "Environment file not found: $ENVIRONMENT_FILE"
        exit 1
    fi

    log_success "Required files found"
}

create_report_dir() {
    if [ ! -d "$REPORT_DIR" ]; then
        mkdir -p "$REPORT_DIR"
        log_info "Created reports directory: $REPORT_DIR"
    fi
}

set_environment() {
    local env=$1

    case "$env" in
        "local")
            ENVIRONMENT_FILE="../postman/agent-mitra-local.postman_environment.json"
            log_info "Using LOCAL environment: http://localhost:8015/api/v1"
            ;;
        "staging")
            ENVIRONMENT_FILE="../postman/agent-mitra-staging.postman_environment.json"
            log_info "Using STAGING environment: https://api-staging.agentmitra.com/api/v1"
            ;;
        "production")
            ENVIRONMENT_FILE="../postman/agent-mitra-production.postman_environment.json"
            log_info "Using PRODUCTION environment: https://api.agentmitra.com/api/v1"
            ;;
        *)
            log_error "Unknown environment: $env"
            log_info "Available environments: local, staging, production"
            exit 1
            ;;
    esac

    if [ ! -f "$ENVIRONMENT_FILE" ]; then
        log_error "Environment file not found: $ENVIRONMENT_FILE"
        exit 1
    fi
}

run_collection_tests() {
    local collection_name=$1
    local report_file="$REPORT_DIR/${collection_name}_report_$TIMESTAMP.html"

    log_info "Running $collection_name tests..."

    if newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        --reporters cli,html \
        --reporter-html-export "$report_file" \
        --reporter-html-title "Agent Mitra API Test Report - $collection_name" \
        --timeout 30000 \
        --delay-request 1000; then

        log_success "$collection_name tests completed successfully"
        log_info "HTML report saved to: $report_file"
        return 0
    else
        log_error "$collection_name tests failed"
        log_info "Check the HTML report for details: $report_file"
        return 1
    fi
}

run_specific_folder() {
    local folder_name=$1
    local report_file="$REPORT_DIR/${folder_name// /_}_report_$TIMESTAMP.html"

    log_info "Running tests for folder: $folder_name"

    if newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        --folder "$folder_name" \
        --reporters cli,html \
        --reporter-html-export "$report_file" \
        --reporter-html-title "Agent Mitra API Test Report - $folder_name" \
        --timeout 30000 \
        --delay-request 1000; then

        log_success "$folder_name tests completed successfully"
        log_info "HTML report saved to: $report_file"
        return 0
    else
        log_error "$folder_name tests failed"
        log_info "Check the HTML report for details: $report_file"
        return 1
    fi
}

run_all_tests() {
    log_info "Running all API tests (full collection)..."

    local report_file="$REPORT_DIR/full_test_suite_report_$TIMESTAMP.html"

    if newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        --reporters cli,html \
        --reporter-html-export "$report_file" \
        --reporter-html-title "Agent Mitra Full API Test Suite - $TIMESTAMP" \
        --timeout 30000 \
        --delay-request 500; then

        log_success "All tests completed successfully! ✅"
        log_info "Full HTML report saved to: $report_file"
        return 0
    else
        log_error "Some tests failed. Check the reports for details."
        log_info "Check the HTML report for details: $report_file"
        return 1
    fi
}

show_usage() {
    echo "Usage: $0 [OPTION] [ENVIRONMENT]"
    echo ""
    echo "Agent Mitra API Testing Script"
    echo ""
    echo "Options:"
    echo "  all           Run all tests (default)"
    echo "  core          Run only Core System tests (auth, users, health)"
    echo "  auth          Run only Authentication tests"
    echo "  users         Run only User Management tests"
    echo "  business      Run only Business Operations tests (agents, providers, policies)"
    echo "  content       Run only Content & Marketing tests"
    echo "  admin         Run only System Administration tests"
    echo "  external      Run only External Services & OTP tests"
    echo "  otp           Run only OTP & External Services tests (legacy)"
    echo "  health        Run only Health Check tests"
    echo "  features      Run only Feature Flags tests (legacy)"
    echo "  help          Show this help message"
    echo ""
    echo "Environments:"
    echo "  local         Use local development environment (default)"
    echo "  staging       Use staging environment"
    echo "  production    Use production environment"
    echo ""
    echo "Examples:"
    echo "  $0 all                    # Run all tests (local env)"
    echo "  $0 auth staging          # Run auth tests on staging"
    echo "  $0 otp production        # Run OTP tests on production"
    echo ""
    echo "Environment Variables:"
    echo "  Set base_url in environment files:"
    echo "  - local: http://localhost:8015/api/v1"
    echo "  - staging: https://api-staging.agentmitra.com/api/v1"
    echo "  - production: https://api.agentmitra.com/api/v1"
}

main() {
    echo "========================================"
    echo "🧪 Agent Mitra API Testing with Newman"
    echo "========================================"
    echo ""

    check_dependencies

    # Parse arguments
    local test_type="all"
    local environment="local"

    case "${1:-all}" in
        "help"|"-h"|"--help")
            show_usage
            exit 0
            ;;
        "all"|"auth"|"otp"|"health"|"features"|"users"|"core"|"business"|"content"|"admin"|"external")
            test_type="$1"
            environment="${2:-local}"
            ;;
        *)
            # Check if first arg is environment
            if [[ "$1" =~ ^(local|staging|production)$ ]]; then
                environment="$1"
                test_type="${2:-all}"
            else
                test_type="$1"
                environment="${2:-local}"
            fi
            ;;
    esac

    set_environment "$environment"
    check_files
    create_report_dir

    log_info "Test Type: $test_type"
    log_info "Environment: $environment"
    log_info "Environment File: $ENVIRONMENT_FILE"

    case "$test_type" in
        "all")
            run_all_tests
            ;;
        "auth")
            run_specific_folder "🔐 Authentication & Authorization"
            ;;
        "otp")
            run_specific_folder "📱 OTP & External Services"
            ;;
        "health")
            run_specific_folder "🏥 Health Check"
            ;;
        "features")
            run_specific_folder "🚩 Feature Flags & Configuration"
            ;;
        "core")
            run_specific_folder "📜 Core System"
            ;;
        "users")
            run_specific_folder "👥 User Management"
            ;;
        "business")
            run_specific_folder "📊 Business Operations"
            ;;
        "content")
            run_specific_folder "📝 Content & Marketing"
            ;;
        "admin")
            run_specific_folder "⚙️ System Administration"
            ;;
        "external")
            run_specific_folder "📱 OTP & External Services"
            ;;
        *)
            log_error "Unknown test type: $test_type"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
