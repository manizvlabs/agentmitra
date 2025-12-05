#!/bin/bash
# Script to stop Agent Mitra production services
# Usage: ./scripts/stop-prod.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Stopping Agent Mitra production services..."
echo ""

# Stop Docker services
echo "Stopping Docker services..."
docker compose -f docker-compose.prod.yml down

# Stop backend if running locally
echo ""
echo "Checking for locally running backend..."
if [ -f "$PROJECT_DIR/.backend.pid" ]; then
    BACKEND_PID=$(cat "$PROJECT_DIR/.backend.pid")
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}Stopping backend (PID: $BACKEND_PID)...${NC}"
        kill $BACKEND_PID 2>/dev/null || true
        rm -f "$PROJECT_DIR/.backend.pid"
        echo -e "${GREEN}✓ Backend stopped${NC}"
    else
        rm -f "$PROJECT_DIR/.backend.pid"
    fi
fi

# Also check if anything is running on port 8012
if lsof -Pi :8012 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Found process on port 8012, stopping...${NC}"
    lsof -ti:8012 | xargs kill 2>/dev/null || true
    echo -e "${GREEN}✓ Port 8012 cleared${NC}"
fi

echo ""
echo -e "${GREEN}All services stopped.${NC}"

