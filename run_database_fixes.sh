#!/bin/bash

# Agent Mitra Database Fixes & API Testing Deployment Script
# This script applies all database fixes and runs comprehensive API testing

set -e  # Exit on any error

echo "🚀 Agent Mitra Database Fix & API Testing Script"
echo "=================================================="

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
DB_MIGRATION_DIR="$PROJECT_ROOT/db/migration"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flyway is installed
check_flyway() {
    if ! command -v flyway &> /dev/null; then
        error "Flyway is not installed. Please install Flyway first."
        echo "Visit: https://flywaydb.org/download"
        exit 1
    fi
    success "Flyway is installed"
}

# Check if PostgreSQL is running
check_postgres() {
    if ! pg_isready -h localhost -p 5432 &> /dev/null; then
        error "PostgreSQL is not running on localhost:5432"
        echo "Please start PostgreSQL service"
        exit 1
    fi
    success "PostgreSQL is running"
}

# Apply database migrations
apply_migrations() {
    log "Applying database migrations..."

    cd "$PROJECT_ROOT"

    # Set Flyway configuration (adjust these for your environment)
    export FLYWAY_URL="jdbc:postgresql://localhost:5432/agentmitra_db"
    export FLYWAY_USER="agentmitra"
    export FLYWAY_PASSWORD="your_password_here"
    export FLYWAY_LOCATIONS="filesystem:$DB_MIGRATION_DIR"

    # Run migrations
    flyway migrate

    if [ $? -eq 0 ]; then
        success "Database migrations applied successfully"
    else
        error "Database migration failed"
        exit 1
    fi
}

# Start backend server
start_backend() {
    log "Starting backend server..."

    # Kill any existing backend processes
    pkill -f "uvicorn main:app" || true
    sleep 2

    # Start backend in background
    cd "$BACKEND_DIR"
    PYTHONPATH="$BACKEND_DIR" ./venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload &
    BACKEND_PID=$!

    # Wait for backend to start
    log "Waiting for backend to start..."
    for i in {1..30}; do
        if curl -s http://127.0.0.1:8015/health > /dev/null 2>&1; then
            success "Backend server started successfully (PID: $BACKEND_PID)"
            return 0
        fi
        sleep 2
    done

    error "Backend server failed to start"
    exit 1
}

# Run comprehensive API tests
run_api_tests() {
    log "Running comprehensive API tests..."

    cd "$BACKEND_DIR"
    PYTHONPATH="$BACKEND_DIR" python comprehensive_api_test.py

    if [ $? -eq 0 ]; then
        success "API tests completed successfully"
    else
        warning "API tests completed with some failures (check results above)"
    fi
}

# Run specific authentication tests
test_authentication() {
    log "Testing user authentication..."

    cd "$BACKEND_DIR"

    # Test each user role
    declare -a users=(
        "+919876543200:Super Admin"
        "+919876543201:Provider Admin"
        "+919876543202:Regional Manager"
        "+919876543203:Senior Agent"
        "+919876543204:Junior Agent"
        "+919876543205:Policyholder"
        "+919876543206:Support Staff"
    )

    for user_info in "${users[@]}"; do
        phone="${user_info%%:*}"
        role="${user_info##*:}"

        # Test login
        response=$(curl -s -X POST http://127.0.0.1:8015/api/v1/auth/login \
            -H "Content-Type: application/json" \
            -d "{\"phone_number\": \"$phone\", \"password\": \"testpassword\"}")

        if echo "$response" | grep -q "access_token"; then
            success "$role authentication: SUCCESS"
        else
            error "$role authentication: FAILED - $response"
        fi
    done
}

# Show database statistics
show_db_stats() {
    log "Database seeding statistics..."

    # Query database for seeded data counts
    psql -h localhost -U agentmitra -d agentmitra_db -c "
        SELECT
            (SELECT COUNT(*) FROM lic_schema.users WHERE phone_number LIKE '+91987654320%') as test_users,
            (SELECT COUNT(*) FROM lic_schema.insurance_products) as products,
            (SELECT COUNT(*) FROM lic_schema.insurance_policies) as policies,
            (SELECT COUNT(*) FROM lic_schema.premium_payments) as payments,
            (SELECT COUNT(*) FROM lic_schema.leads) as leads,
            (SELECT COUNT(*) FROM lic_schema.quotes) as quotes,
            (SELECT COUNT(*) FROM public.daily_quotes) as daily_quotes;
    "
}

# Main execution
main() {
    echo "Step 1: Pre-flight checks"
    check_flyway
    check_postgres

    echo -e "\nStep 2: Apply database migrations"
    apply_migrations

    echo -e "\nStep 3: Start backend server"
    start_backend

    echo -e "\nStep 4: Test authentication"
    test_authentication

    echo -e "\nStep 5: Run comprehensive API tests"
    run_api_tests

    echo -e "\nStep 6: Database statistics"
    show_db_stats

    echo -e "\n${GREEN}🎉 Database fixes and API testing completed!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review API test results in backend/comprehensive_api_test_results.json"
    echo "2. Check database statistics above"
    echo "3. Fix any remaining issues based on test results"
    echo "4. Deploy to staging environment for further testing"
}

# Run main function
main "$@"
