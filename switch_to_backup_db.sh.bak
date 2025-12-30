#!/bin/bash

# Script to switch backend from agentmitra_dev to agentmitra_dev_backup
# Only run this after thorough testing of the backup database

set -e

echo "🔄 Switching Backend to Backup Database"
echo "======================================="

BACKUP_DB="agentmitra_dev_backup"
ORIGINAL_DB="agentmitra_dev"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}⚠️  WARNING: This will switch the backend to use $BACKUP_DB${NC}"
echo -e "${YELLOW}   Make sure you have tested $BACKUP_DB thoroughly!${NC}"
echo ""

read -p "Are you sure you want to proceed? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo -e "\n${BLUE}Step 1: Updating docker-compose.prod.yml${NC}"

# Update docker-compose.prod.yml
sed -i.bak "s/agentmitra_dev/agentmitra_dev_backup/g" docker-compose.prod.yml

echo -e "${GREEN}✅ Updated docker-compose.prod.yml${NC}"

echo -e "\n${BLUE}Step 2: Restarting backend services${NC}"

# Restart services
docker-compose -f docker-compose.prod.yml down backend
docker-compose -f docker-compose.prod.yml up -d backend

echo -e "${GREEN}✅ Backend restarted with backup database${NC}"

echo -e "\n${BLUE}Step 3: Testing backend health${NC}"

# Wait for backend to start
sleep 10

# Test health endpoint
if curl -s "http://localhost/api/v1/health" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Backend is healthy with backup database${NC}"
    echo -e "\n${GREEN}🎉 SUCCESS: Backend successfully switched to $BACKUP_DB${NC}"
    echo -e "${YELLOW}📋 Next steps:${NC}"
    echo "  1. Test all application features thoroughly"
    echo "  2. Monitor for any issues"
    echo "  3. Keep $ORIGINAL_DB as backup for rollback if needed"
else
    echo -e "${RED}❌ Backend health check failed!${NC}"
    echo -e "${YELLOW}Rolling back to original database...${NC}"
    
    # Rollback
    sed -i.bak "s/agentmitra_dev_backup/agentmitra_dev/g" docker-compose.prod.yml
    docker-compose -f docker-compose.prod.yml down backend
    docker-compose -f docker-compose.prod.yml up -d backend
    
    echo -e "${RED}❌ Switch failed - rolled back to $ORIGINAL_DB${NC}"
    exit 1
fi
