#!/bin/bash

# Script to update Cloud Run URLs after deployment
# Usage: ./update_cloudrun_urls.sh <CLOUD_RUN_URL>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <CLOUD_RUN_URL>"
    echo "Example: $0 https://agentmitra-backend-abc123.a.run.app"
    exit 1
fi

CLOUD_RUN_URL=$1

echo "🔄 Updating Cloud Run URLs to: $CLOUD_RUN_URL"
echo "==============================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Update docker-compose.prod.yml
echo -e "${YELLOW}Updating docker-compose.prod.yml...${NC}"
sed -i.bak "s|PORTAL_API_URL=.*|PORTAL_API_URL=$CLOUD_RUN_URL|" docker-compose.prod.yml

# Update nginx.conf
echo -e "${YELLOW}Updating config-portal/nginx.conf...${NC}"
sed -i.bak "s|https://agentmitra-backend-xxxxxxxxxx.a.run.app|$CLOUD_RUN_URL|" config-portal/nginx.conf

echo -e "${GREEN}✅ URLs updated successfully!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Restart your services: docker-compose -f docker-compose.prod.yml down && docker-compose -f docker-compose.prod.yml up -d"
echo "2. Test the API: curl http://localhost/api/v1/health"
echo "3. Access the portal: http://localhost:3013"
echo ""
echo -e "${GREEN}🎉 Ready to test the Cloud Run + Local setup!${NC}"
