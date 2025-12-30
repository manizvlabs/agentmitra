#!/bin/bash

# Agent Mitra Flyway Backup Database Test Script
# This script tests Flyway migrations on a backup database

set -e  # Exit on any error

echo "🔄 Agent Mitra Flyway Backup Database Test"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DB="agentmitra_dev_backup"
ORIGINAL_DB="agentmitra_dev"
CLOUD_SQL_INSTANCE="vaulted-scholar-480715-u4:europe-north1:agentmitra-postgres"

echo -e "${BLUE}Step 1: Checking current Flyway status${NC}"
flyway -configFiles=flyway.cloud.conf info

echo -e "\n${YELLOW}Step 2: Testing Flyway baseline on backup database${NC}"
echo "Note: Make sure $BACKUP_DB exists and has proper permissions"

# Test baseline
if flyway -configFiles=flyway.cloud.conf baseline; then
    echo -e "${GREEN}✅ Baseline successful${NC}"
else
    echo -e "${RED}❌ Baseline failed${NC}"
    exit 1
fi

# Test migrations
echo -e "\n${YELLOW}Step 3: Running Flyway migrations${NC}"
if flyway -configFiles=flyway.cloud.conf migrate; then
    echo -e "${GREEN}✅ All migrations successful${NC}"
    
    # Show final status
    echo -e "\n${BLUE}Step 4: Final Flyway status${NC}"
    flyway -configFiles=flyway.cloud.conf info
    
    echo -e "\n${GREEN}🎉 SUCCESS: Flyway is now properly synchronized!${NC}"
    echo -e "${GREEN}You can now safely switch the backend to use $BACKUP_DB${NC}"
    
else
    echo -e "${RED}❌ Migration failed${NC}"
    echo -e "${YELLOW}Check the error messages above and fix any issues${NC}"
    exit 1
fi

echo -e "\n${BLUE}Next Steps:${NC}"
echo "1. Test your backend application with the backup database"
echo "2. If successful, update production to use $BACKUP_DB"
echo "3. Keep $ORIGINAL_DB as backup until confident"
