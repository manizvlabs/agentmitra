#!/bin/bash
# Script to start Agent Mitra production services
# Usage: ./scripts/start-prod.sh [service1] [service2] ...

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Agent Mitra Production Startup Script${NC}"
echo "=========================================="
echo ""

# Check if Docker is running
echo "Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗ Docker daemon is not running!${NC}"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo "On macOS: Open Docker Desktop application"
    echo "On Linux: sudo systemctl start docker"
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon is running${NC}"
echo ""

# Check for .env file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠ .env file not found${NC}"
    if [ -f ".env.example" ]; then
        echo "Creating .env from .env.example..."
        cp .env.example .env
        echo -e "${YELLOW}⚠ Please edit .env file and set required values before starting services${NC}"
        echo "Required variables:"
        echo "  - JWT_SECRET_KEY (generate with: openssl rand -hex 32)"
        echo "  - CORS_ORIGINS"
        echo "  - GRAFANA_PASSWORD"
        echo ""
        read -p "Press Enter to continue anyway, or Ctrl+C to exit and edit .env first..."
    else
        echo -e "${YELLOW}⚠ No .env.example found. Some services may not work correctly.${NC}"
        echo "Creating minimal .env file..."
        cat > .env << EOF
# Minimal .env file - please configure properly
JWT_SECRET_KEY=$(openssl rand -hex 32)
CORS_ORIGINS=http://localhost:8080,http://localhost:3000
GRAFANA_PASSWORD=admin
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET_NAME=agentmitra-media
EOF
        echo -e "${GREEN}✓ Created minimal .env file${NC}"
    fi
    echo ""
fi

# Determine which services to start
SERVICES="${@:-minio backend}"

if [ "$SERVICES" = "all" ]; then
    SERVICES="minio backend portal nginx prometheus grafana"
fi

echo "Starting services: $SERVICES"
echo ""

# Start services
docker-compose -f docker-compose.prod.yml up -d $SERVICES

# Wait for services to be ready
echo ""
echo "Waiting for services to be ready..."
sleep 5

# Check service status
echo ""
echo "Service Status:"
echo "==============="
docker-compose -f docker-compose.prod.yml ps

# Setup MinIO bucket if MinIO is running
if echo "$SERVICES" | grep -q "minio" || [ "$SERVICES" = "all" ]; then
    echo ""
    echo "Setting up MinIO bucket..."
    if docker ps | grep -q agentmitra_minio; then
        sleep 3
        if docker exec agentmitra_minio mc --version > /dev/null 2>&1; then
            docker exec agentmitra_minio mc alias set myminio http://localhost:9000 minioadmin minioadmin 2>/dev/null || true
            if ! docker exec agentmitra_minio mc ls myminio 2>/dev/null | grep -q agentmitra-media; then
                docker exec agentmitra_minio mc mb myminio/agentmitra-media 2>/dev/null || true
                docker exec agentmitra_minio mc anonymous set download myminio/agentmitra-media 2>/dev/null || true
                echo -e "${GREEN}✓ MinIO bucket 'agentmitra-media' created${NC}"
            else
                echo -e "${GREEN}✓ MinIO bucket 'agentmitra-media' already exists${NC}"
            fi
        else
            echo -e "${YELLOW}⚠ MinIO client not available, bucket will be auto-created on first use${NC}"
        fi
    fi
fi

echo ""
echo -e "${GREEN}✓ Services started successfully!${NC}"
echo ""
echo "Service URLs:"
echo "============="
echo "  Backend API:    http://localhost:8012"
echo "  MinIO Console:  http://localhost:9001 (minioadmin/minioadmin)"
echo "  MinIO API:      http://localhost:9000"
echo "  Portal:         http://localhost:3013"
echo "  Grafana:        http://localhost:3012 (admin/\$GRAFANA_PASSWORD)"
echo "  Prometheus:     http://localhost:9012"
echo ""
echo "To view logs:"
echo "  docker-compose -f docker-compose.prod.yml logs -f [service]"
echo ""
echo "To stop services:"
echo "  docker-compose -f docker-compose.prod.yml down"
echo ""

