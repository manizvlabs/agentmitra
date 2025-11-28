#!/bin/bash
# Script to check what Docker containers are running
# Usage: ./scripts/check-running-containers.sh

set -e

echo "Checking running Docker containers..."
echo "======================================"
echo ""

if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker daemon is not running"
    exit 1
fi

echo "Running containers:"
echo "-------------------"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | head -20

echo ""
echo "Container details:"
echo "------------------"

# Check if containers match docker-compose services
CONTAINERS=$(docker ps --format "{{.Names}}")

for container in $CONTAINERS; do
    if echo "$container" | grep -q "agentmitra"; then
        echo ""
        echo "Container: $container"
        
        # Check if it's from docker-compose
        COMPOSE_PROJECT=$(docker inspect "$container" 2>/dev/null | grep -o '"com.docker.compose.project.working_dir":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        COMPOSE_SERVICE=$(docker inspect "$container" 2>/dev/null | grep -o '"com.docker.compose.service":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
        
        if [ "$COMPOSE_SERVICE" != "unknown" ]; then
            echo "  From docker-compose service: $COMPOSE_SERVICE"
            echo "  Project directory: $COMPOSE_PROJECT"
        else
            echo "  Not from docker-compose (may be manually started)"
        fi
        
        # Show ports
        PORTS=$(docker port "$container" 2>/dev/null | head -5 || echo "No ports mapped")
        echo "  Ports: $PORTS"
    fi
done

echo ""
echo "To stop all agentmitra containers:"
echo "  docker ps -q --filter 'name=agentmitra' | xargs docker stop"
echo ""
echo "To remove all agentmitra containers:"
echo "  docker ps -aq --filter 'name=agentmitra' | xargs docker rm"
echo ""

