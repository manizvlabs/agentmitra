#!/bin/bash

# Agent Mitra API Testing Script using Newman
# This script runs the Postman collection and generates HTML reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COLLECTION_FILE="../postman/agent-mitra-api-collection.json"
ENVIRONMENT_FILE="../postman/agent-mitra-local.postman_environment.json"
REPORT_DIR="../reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/api-test-report-${TIMESTAMP}.html"
JSON_REPORT_FILE="${REPORT_DIR}/api-test-results-${TIMESTAMP}.json"

# Create reports directory if it doesn't exist
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}🚀 Starting Agent Mitra API Tests${NC}"
echo -e "${BLUE}=====================================${NC}"

# Check if newman is installed
if ! command -v newman &> /dev/null; then
    echo -e "${RED}❌ Newman is not installed. Installing...${NC}"
    npm install -g newman newman-reporter-html
fi

# Check if collection and environment files exist
if [ ! -f "$COLLECTION_FILE" ]; then
    echo -e "${RED}❌ Collection file not found: $COLLECTION_FILE${NC}"
    exit 1
fi

if [ ! -f "$ENVIRONMENT_FILE" ]; then
    echo -e "${RED}❌ Environment file not found: $ENVIRONMENT_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Collection: $(basename $COLLECTION_FILE)${NC}"
echo -e "${YELLOW}🌍 Environment: $(basename $ENVIRONMENT_FILE)${NC}"
echo -e "${YELLOW}📊 Report: $(basename $REPORT_FILE)${NC}"
echo -e "${BLUE}--------------------------------------${NC}"

# Run Newman tests
echo -e "${BLUE}🔬 Running API tests...${NC}"
newman run "$COLLECTION_FILE" \
    --environment "$ENVIRONMENT_FILE" \
    --reporters cli,json \
    --reporter-json-export "$JSON_REPORT_FILE" \
    --timeout 10000 \
    --delay-request 1000

# Check exit code
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo -e "${GREEN}📊 Report generated: $REPORT_FILE${NC}"

    # Open report in browser (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${BLUE}🌐 Opening report in browser...${NC}"
        open "$REPORT_FILE"
    fi

else
    echo -e "${RED}❌ Some tests failed!${NC}"
    echo -e "${YELLOW}📊 Check the report for details: $REPORT_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}=====================================${NC}"
echo -e "${GREEN}🎉 API Testing Complete!${NC}"
