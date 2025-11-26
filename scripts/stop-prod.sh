#!/bin/bash
# Script to stop Agent Mitra production services
# Usage: ./scripts/stop-prod.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

echo "Stopping Agent Mitra production services..."
docker-compose -f docker-compose.prod.yml down

echo ""
echo "Services stopped."

