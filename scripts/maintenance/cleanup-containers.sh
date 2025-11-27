#!/bin/bash
# Script to stop and remove all agentmitra containers
# Usage: ./scripts/cleanup-containers.sh

set -e

echo "Cleaning up Agent Mitra containers..."
echo "======================================"
echo ""

if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker daemon is not running"
    exit 1
fi

# Stop all agentmitra containers
echo "Stopping containers..."
docker ps -q --filter 'name=agentmitra' | xargs -r docker stop 2>/dev/null || echo "No running containers to stop"

# Remove all agentmitra containers
echo "Removing containers..."
docker ps -aq --filter 'name=agentmitra' | xargs -r docker rm 2>/dev/null || echo "No containers to remove"

echo ""
echo "✓ Cleanup complete!"
echo ""
echo "To start fresh:"
echo "  ./scripts/start-prod.sh minio backend"
echo ""

