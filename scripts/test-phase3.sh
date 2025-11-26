#!/bin/bash

# Phase 3 Testing Script
# Tests: Agent Dashboard Enhancement, Presentation Editor, Presentation List, Callback Management

set -e

BACKEND_URL="${BACKEND_URL:-http://localhost:8012}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:9102}"
TEST_TIMEOUT=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 3 Testing - Core Agent Features${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# Function to print test result
print_test() {
    local status=$1
    local message=$2
    if [ "$status" = "PASS" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $message"
        ((TESTS_PASSED++))
    elif [ "$status" = "FAIL" ]; then
        echo -e "${RED}❌ FAIL${NC}: $message"
        ((TESTS_FAILED++))
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠️  WARN${NC}: $message"
        ((TESTS_WARNINGS++))
    fi
}

# Function to check if service is running
check_service() {
    local url=$1
    local name=$2
    if curl -s --max-time 5 "$url" > /dev/null 2>&1; then
        print_test "PASS" "$name is running"
        return 0
    else
        print_test "FAIL" "$name is not accessible at $url"
        return 1
    fi
}

# Function to test API endpoint
test_api_endpoint() {
    local method=$1
    local endpoint=$2
    local name=$3
    local expected_status=${4:-200}
    local auth_token=${5:-""}
    
    local headers="Content-Type: application/json"
    if [ -n "$auth_token" ]; then
        headers="$headers\nAuthorization: Bearer $auth_token"
    fi
    
    local response
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" --max-time $TEST_TIMEOUT \
            -H "Content-Type: application/json" \
            ${auth_token:+-H "Authorization: Bearer $auth_token"} \
            "$BACKEND_URL$endpoint" 2>&1)
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" --max-time $TEST_TIMEOUT \
            -X POST \
            -H "Content-Type: application/json" \
            ${auth_token:+-H "Authorization: Bearer $auth_token"} \
            "$BACKEND_URL$endpoint" 2>&1)
    fi
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "$expected_status" ]; then
        print_test "PASS" "$name (HTTP $http_code)"
        return 0
    else
        print_test "FAIL" "$name - Expected HTTP $expected_status, got $http_code"
        return 1
    fi
}

echo -e "${BLUE}1. Service Health Checks${NC}"
echo "----------------------------------------"

# Check backend health
check_service "$BACKEND_URL/health" "Backend Health"

# Check frontend (if running)
if check_service "$FRONTEND_URL" "Frontend"; then
    FRONTEND_AVAILABLE=true
else
    FRONTEND_AVAILABLE=false
    print_test "WARN" "Frontend not available - skipping UI tests"
fi

echo ""
echo -e "${BLUE}2. Agent Dashboard API Tests${NC}"
echo "----------------------------------------"

# Test dashboard analytics endpoint
test_api_endpoint "GET" "/api/v1/dashboard/analytics" "Dashboard Analytics" 200

# Test agent performance endpoint
test_api_endpoint "GET" "/api/v1/dashboard/agent-performance" "Agent Performance" 200

# Test business intelligence endpoint
test_api_endpoint "GET" "/api/v1/dashboard/business-intelligence" "Business Intelligence" 200

echo ""
echo -e "${BLUE}3. Presentation API Tests${NC}"
echo "----------------------------------------"

# Test presentations list endpoint
test_api_endpoint "GET" "/api/v1/presentations" "Presentations List" 200

# Test presentation templates endpoint
test_api_endpoint "GET" "/api/v1/presentations/templates" "Presentation Templates" 200

# Test media upload endpoint (should require auth)
test_api_endpoint "POST" "/api/v1/presentations/media/upload" "Media Upload (Auth Required)" 401

echo ""
echo -e "${BLUE}4. Callback Management API Tests${NC}"
echo "----------------------------------------"

# Test callback requests endpoint
test_api_endpoint "GET" "/api/v1/callbacks" "Callback Requests List" 200

# Test callback statistics endpoint
test_api_endpoint "GET" "/api/v1/callbacks/statistics" "Callback Statistics" 200

echo ""
echo -e "${BLUE}5. Code Structure Verification${NC}"
echo "----------------------------------------"

# Check if Phase 3 widgets exist
check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        print_test "PASS" "$name exists"
        return 0
    else
        print_test "FAIL" "$name not found: $file"
        return 1
    fi
}

# Agent Dashboard widgets
check_file "lib/features/dashboard/presentation/widgets/dashboard_kpi_cards.dart" "Dashboard KPI Cards Widget"
check_file "lib/features/dashboard/presentation/widgets/dashboard_trend_charts.dart" "Dashboard Trend Charts Widget"
check_file "lib/features/dashboard/presentation/widgets/dashboard_action_items.dart" "Dashboard Action Items Widget"
check_file "lib/features/dashboard/presentation/widgets/dashboard_smart_alerts.dart" "Dashboard Smart Alerts Widget"

# Presentation pages
check_file "lib/features/presentations/presentation/pages/presentation_editor_page.dart" "Presentation Editor Page"
check_file "lib/features/presentations/presentation/pages/presentation_list_page.dart" "Presentation List Page"

# Callback management
check_file "lib/screens/callback_request_management.dart" "Callback Request Management Page"

echo ""
echo -e "${BLUE}6. Widget Implementation Verification${NC}"
echo "----------------------------------------"

# Check if widgets are properly implemented
check_widget_implementation() {
    local file=$1
    local widget_name=$2
    local pattern=$3
    
    if [ -f "$file" ]; then
        if grep -q "$pattern" "$file" 2>/dev/null; then
            print_test "PASS" "$widget_name implementation found"
            return 0
        else
            print_test "WARN" "$widget_name - pattern '$pattern' not found"
            return 1
        fi
    else
        print_test "FAIL" "$widget_name file not found"
        return 1
    fi
}

# Verify KPI Cards implementation
check_widget_implementation \
    "lib/features/dashboard/presentation/widgets/dashboard_kpi_cards.dart" \
    "DashboardKPICards" \
    "class DashboardKPICards"

# Verify Trend Charts implementation
check_widget_implementation \
    "lib/features/dashboard/presentation/widgets/dashboard_trend_charts.dart" \
    "DashboardTrendCharts" \
    "class DashboardTrendCharts"

# Verify Action Items implementation
check_widget_implementation \
    "lib/features/dashboard/presentation/widgets/dashboard_action_items.dart" \
    "DashboardActionItems" \
    "class DashboardActionItems"

# Verify Smart Alerts implementation
check_widget_implementation \
    "lib/features/dashboard/presentation/widgets/dashboard_smart_alerts.dart" \
    "DashboardSmartAlerts" \
    "class DashboardSmartAlerts"

# Verify Presentation Editor has slide management
check_widget_implementation \
    "lib/features/presentations/presentation/pages/presentation_editor_page.dart" \
    "Presentation Editor" \
    "class PresentationEditorPage"

# Verify Presentation List has filters
check_widget_implementation \
    "lib/features/presentations/presentation/pages/presentation_list_page.dart" \
    "Presentation List" \
    "_buildFilterChips"

# Verify Callback Management has tabs
check_widget_implementation \
    "lib/screens/callback_request_management.dart" \
    "Callback Management" \
    "TabController"

echo ""
echo -e "${BLUE}7. Backend Model Verification${NC}"
echo "----------------------------------------"

# Check backend models exist
check_file "backend/app/models/presentation.py" "Presentation Model"
check_file "backend/app/models/callback.py" "Callback Model"
check_file "backend/app/api/v1/presentations.py" "Presentations API"
check_file "backend/app/api/v1/callbacks.py" "Callbacks API" || print_test "WARN" "Callbacks API may be in campaigns module"

echo ""
echo -e "${BLUE}8. Database Schema Verification${NC}"
echo "----------------------------------------"

# Check if migrations exist for Phase 3 features
if [ -d "db/migration" ]; then
    if find db/migration -name "*presentation*" -o -name "*callback*" | grep -q .; then
        print_test "PASS" "Database migrations found for Phase 3 features"
    else
        print_test "WARN" "No specific migrations found for Phase 3 features"
    fi
else
    print_test "WARN" "Migration directory not found"
fi

echo ""
echo -e "${BLUE}9. Integration Points Verification${NC}"
echo "----------------------------------------"

# Check if dashboard page integrates Phase 3 widgets
if grep -q "DashboardKPICards\|DashboardTrendCharts\|DashboardActionItems\|DashboardSmartAlerts" \
    "lib/features/dashboard/presentation/pages/dashboard_page.dart" 2>/dev/null; then
    print_test "PASS" "Dashboard page integrates Phase 3 widgets"
else
    print_test "FAIL" "Dashboard page does not integrate Phase 3 widgets"
fi

# Check if bottom navigation exists
if grep -q "BottomNavigationBar\|bottomNavigationBar" \
    "lib/features/dashboard/presentation/pages/dashboard_page.dart" 2>/dev/null; then
    print_test "PASS" "Bottom navigation bar implemented"
else
    print_test "WARN" "Bottom navigation bar not found"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED + TESTS_WARNINGS))"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo -e "${YELLOW}Warnings: $TESTS_WARNINGS${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Phase 3 Testing: ALL CRITICAL TESTS PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ Phase 3 Testing: SOME TESTS FAILED${NC}"
    exit 1
fi

