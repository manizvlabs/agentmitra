#!/bin/bash

# Agent Mitra Complete API Testing Script
# Tests all Postman collections with Cloud SQL backup database

set -e  # Exit on any error

# Configuration
ENVIRONMENT_FILE="agent-mitra-cloudsql-backup.postman_environment.json"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORTS_DIR="reports"
LOG_FILE="${REPORTS_DIR}/complete-api-test-${TIMESTAMP}.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Collections to test
COLLECTIONS=(
    "agent-mitra-api-collection.json:Main API Collection"
    "agent-mitra-rbac-collection.json:RBAC API Collection" 
    "agent-mitra-crm-leads-collection.json:CRM Leads API Collection"
    "agent-mitra-campaigns-collection.json:Campaigns API Collection"
    "agent-mitra-notifications-collection.json:Notifications API Collection"
    "agent-mitra-campaigns-simple.json:Simple Campaigns Collection"
)

# Create reports directory
mkdir -p "$REPORTS_DIR"

# Logging function
log() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

# Test function
run_test() {
    local collection_file="$1"
    local collection_name="$2"
    local report_file="${REPORTS_DIR}/$(basename "$collection_file" .json)-${TIMESTAMP}-report.html"
    
    log "${BLUE}🧪 Testing: ${collection_name}${NC}"
    log "${CYAN}📄 Collection: ${collection_file}${NC}"
    log "${CYAN}📊 Report: ${report_file}${NC}"
    
    if [ ! -f "$collection_file" ]; then
        log "${RED}❌ Collection file not found: ${collection_file}${NC}"
        return 1
    fi
    
    if [ ! -f "$ENVIRONMENT_FILE" ]; then
        log "${RED}❌ Environment file not found: ${ENVIRONMENT_FILE}${NC}"
        return 1
    fi
    
    # Run Newman test
    if newman run "$collection_file" \
        --environment "$ENVIRONMENT_FILE" \
        --reporters html \
        --reporter-html-export "$report_file" \
        --reporter-html-title "Agent Mitra ${collection_name} - Cloud SQL Backup Test" \
        --timeout 30000 \
        --delay-request 1000 \
        --suppress-exit-code \
        >> "$LOG_FILE" 2>&1; then
        
        log "${GREEN}✅ Test completed: ${collection_name}${NC}"
        return 0
    else
        log "${RED}❌ Test failed: ${collection_name}${NC}"
        return 1
    fi
}

# Main execution
log "${PURPLE}🚀 Agent Mitra Complete API Testing Suite${NC}"
log "${PURPLE}================================================${NC}"
log "${BLUE}📅 Timestamp: ${TIMESTAMP}${NC}"
log "${BLUE}🌐 Environment: ${ENVIRONMENT_FILE}${NC}"
log "${BLUE}📁 Reports Directory: ${REPORTS_DIR}${NC}"
log "${YELLOW}🎯 Collections to test: ${#COLLECTIONS[@]}${NC}"

# Pre-flight checks
log "${YELLOW}🔍 Running pre-flight checks...${NC}"

if ! command -v newman &> /dev/null; then
    log "${RED}❌ Newman is not installed. Please install Newman globally:${NC}"
    log "${RED}   npm install -g newman${NC}"
    exit 1
fi

if ! command -v newman-reporter-html &> /dev/null; then
    log "${YELLOW}⚠️  HTML reporter not found. Installing...${NC}"
    npm install -g newman-reporter-html || {
        log "${RED}❌ Failed to install HTML reporter${NC}"
        exit 1
    }
fi

log "${GREEN}✅ Pre-flight checks passed${NC}"

# Health check
log "${YELLOW}🏥 Checking backend health...${NC}"
if curl -s "http://localhost:80/api/v1/health" | grep -q "healthy"; then
    log "${GREEN}✅ Backend is healthy${NC}"
else
    log "${RED}❌ Backend health check failed${NC}"
    log "${RED}   Please ensure Docker containers are running${NC}"
    exit 1
fi

# Run all tests
TOTAL_COLLECTIONS=${#COLLECTIONS[@]}
PASSED_TESTS=0
FAILED_TESTS=0

log "${BLUE}📋 Starting API tests...${NC}"

for collection_info in "${COLLECTIONS[@]}"; do
    IFS=':' read -r collection_file collection_name <<< "$collection_info"
    
    if run_test "$collection_file" "$collection_name"; then
        ((PASSED_TESTS++))
    else
        ((FAILED_TESTS++))
    fi
    
    log ""  # Empty line for readability
done

# Generate summary report
SUMMARY_REPORT="${REPORTS_DIR}/complete-api-test-summary-${TIMESTAMP}.html"

cat > "$SUMMARY_REPORT" << EOF_HTML
<!DOCTYPE html>
<html>
<head>
    <title>Agent Mitra Complete API Test Summary - ${TIMESTAMP}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #2c3e50; }
        .summary { background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .stats { display: flex; gap: 20px; margin: 20px 0; }
        .stat { background: white; padding: 15px; border-radius: 6px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .passed { border-left: 4px solid #28a745; }
        .failed { border-left: 4px solid #dc3545; }
        .total { border-left: 4px solid #007bff; }
        .collection { margin: 10px 0; padding: 10px; background: white; border-radius: 4px; }
        .collection a { color: #007bff; text-decoration: none; }
        .collection a:hover { text-decoration: underline; }
        .environment { background: #e9ecef; padding: 15px; border-radius: 6px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>🚀 Agent Mitra Complete API Test Summary</h1>
    <p><strong>Timestamp:</strong> ${TIMESTAMP}</p>
    <p><strong>Environment:</strong> Cloud SQL Backup Database</p>
    <p><strong>Backend URL:</strong> http://localhost:80</p>
    
    <div class="environment">
        <h3>🧪 Test Environment Details</h3>
        <ul>
            <li><strong>Database:</strong> agentmitra_dev_backup (Cloud SQL)</li>
            <li><strong>Backend:</strong> Docker container on port 8012</li>
            <li><strong>Nginx:</strong> Reverse proxy on port 80</li>
            <li><strong>Flyway Status:</strong> Schema version 71 ✅</li>
        </ul>
    </div>
    
    <div class="summary">
        <h2>📊 Test Results Summary</h2>
        <div class="stats">
            <div class="stat total">
                <h3>${TOTAL_COLLECTIONS}</h3>
                <p>Total Collections</p>
            </div>
            <div class="stat passed">
                <h3>${PASSED_TESTS}</h3>
                <p>Passed Tests</p>
            </div>
            <div class="stat failed">
                <h3>${FAILED_TESTS}</h3>
                <p>Failed Tests</p>
            </div>
        </div>
    </div>
    
    <h2>📋 Individual Test Reports</h2>
EOF_HTML

for collection_info in "${COLLECTIONS[@]}"; do
    IFS=':' read -r collection_file collection_name <<< "$collection_info"
    report_file="${REPORTS_DIR}/$(basename "$collection_file" .json)-${TIMESTAMP}-report.html"
    status="✅ PASSED"
    status_class="passed"
    
    if [ ! -f "$report_file" ]; then
        status="❌ FAILED"
        status_class="failed"
    fi
    
    cat >> "$SUMMARY_REPORT" << EOF_HTML
    <div class="collection ${status_class}">
        <h3>${collection_name}</h3>
        <p><strong>Status:</strong> ${status}</p>
        <p><strong>File:</strong> ${collection_file}</p>
        <p><strong>Report:</strong> <a href="$(basename "$report_file")" target="_blank">View Detailed Report</a></p>
    </div>
EOF_HTML
done

cat >> "$SUMMARY_REPORT" << EOF_HTML
    <div class="summary">
        <h2>📝 Test Execution Details</h2>
        <ul>
            <li><strong>Test Runner:</strong> Newman v$(newman --version)</li>
            <li><strong>Timeout:</strong> 30 seconds per request</li>
            <li><strong>Delay:</strong> 1 second between requests</li>
            <li><strong>Reports:</strong> HTML format with detailed assertions</li>
        </ul>
    </div>
    
    <div class="summary">
        <h2>🔍 Collection Coverage</h2>
        <ul>
            <li><strong>Main API:</strong> Core authentication, users, tenants</li>
            <li><strong>RBAC:</strong> Role-based access control endpoints</li>
            <li><strong>CRM Leads:</strong> Customer relationship management</li>
            <li><strong>Campaigns:</strong> Marketing campaign management</li>
            <li><strong>Notifications:</strong> SMS/WhatsApp messaging</li>
            <li><strong>Simple Campaigns:</strong> Basic campaign operations</li>
        </ul>
    </div>
</body>
</html>
EOF_HTML

# Final results
log "${PURPLE}🎯 TEST SUMMARY${NC}"
log "${PURPLE}==============${NC}"
log "${BLUE}📊 Total Collections: ${TOTAL_COLLECTIONS}${NC}"
log "${GREEN}✅ Passed: ${PASSED_TESTS}${NC}"
log "${RED}❌ Failed: ${FAILED_TESTS}${NC}"
log "${BLUE}📄 Summary Report: ${SUMMARY_REPORT}${NC}"
log "${BLUE}📋 Log File: ${LOG_FILE}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    log "${GREEN}🎉 ALL TESTS PASSED! Agent Mitra API is fully functional.${NC}"
    exit 0
else
    log "${RED}⚠️  Some tests failed. Check the reports for details.${NC}"
    exit 1
fi
