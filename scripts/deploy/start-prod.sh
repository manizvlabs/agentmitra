#!/bin/bash
# Comprehensive setup and startup script for Agent Mitra production services
# Usage: ./scripts/start-prod.sh [service1] [service2] ... | all | minimal
# 
# This script:
# 1. Checks Docker daemon
# 2. Creates .env file if needed
# 3. Generates SSL certificates (if needed)
# 4. Builds Flutter web app (if needed for nginx)
# 5. Starts Docker Compose services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Agent Mitra Production Setup & Startup Script${NC}"
echo "======================================================"
echo ""

# Check if Docker is running
echo -e "${BLUE}[1/5]${NC} Checking Docker daemon..."
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
echo -e "${BLUE}[2/5]${NC} Checking .env file..."
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
CORS_ORIGINS=http://localhost:8080,http://localhost:3000,http://localhost:8012,http://localhost:3013
GRAFANA_PASSWORD=admin
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET_NAME=agentmitra-media
EOF
        echo -e "${GREEN}✓ Created minimal .env file${NC}"
    fi
else
    echo -e "${GREEN}✓ .env file exists${NC}"
fi
echo ""

# Determine which services to start
# Default: start essential services (minio + backend)
# Usage: ./scripts/start-prod.sh [service1] [service2] ... | all | minimal
if [ $# -eq 0 ]; then
    # No arguments - start essential services by default
    SERVICES="minio backend"
    START_ALL=false
    echo -e "${YELLOW}Note: Starting essential services only (minio + backend)${NC}"
    echo "To start all services: ./scripts/start-prod.sh all"
    echo "To start minimal: ./scripts/start-prod.sh minimal"
    echo ""
elif [ "$1" = "all" ]; then
    SERVICES="minio backend portal nginx prometheus grafana"
    START_ALL=true
    echo -e "${GREEN}Starting all services including portal and nginx${NC}"
    echo ""
elif [ "$1" = "minimal" ]; then
    SERVICES="minio backend"
    START_ALL=false
else
    # Specific services provided
    SERVICES="$@"
    START_ALL=false
    # Check if nginx or portal are in the list
    if echo "$SERVICES" | grep -qE "(nginx|portal)"; then
        START_ALL=true
    fi
fi

# Generate SSL certificates if needed
echo -e "${BLUE}[3/5]${NC} Checking SSL certificates..."
if [ ! -f "nginx/ssl/nginx-selfsigned.crt" ] || [ ! -f "nginx/ssl/nginx-selfsigned.key" ]; then
    echo -e "${YELLOW}⚠ SSL certificates not found. Generating self-signed certificates...${NC}"
    if [ -f "$SCRIPT_DIR/generate-ssl-certs.sh" ]; then
        bash "$SCRIPT_DIR/generate-ssl-certs.sh"
        echo -e "${GREEN}✓ SSL certificates generated${NC}"
    else
        echo -e "${YELLOW}⚠ generate-ssl-certs.sh not found. Skipping SSL setup.${NC}"
        echo "  HTTP will work, but HTTPS will not be available."
    fi
else
    echo -e "${GREEN}✓ SSL certificates exist${NC}"
fi
echo ""

# Build Flutter web app if nginx is needed
if [ "$START_ALL" = true ] || echo "$SERVICES" | grep -q "nginx"; then
    echo -e "${BLUE}[4/5]${NC} Checking Flutter web build..."
    if [ ! -d "build/web" ] || [ ! -f "build/web/index.html" ]; then
        echo -e "${YELLOW}⚠ Flutter web build not found. Building Flutter web app...${NC}"
        echo "This may take a few minutes..."
        
        # Check if Flutter is installed
        if ! command -v flutter &> /dev/null; then
            echo -e "${RED}✗ Flutter is not installed or not in PATH${NC}"
            echo ""
            echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
            echo "Or build manually: flutter build web"
            echo ""
            read -p "Press Enter to continue without Flutter build (nginx may not work), or Ctrl+C to exit..."
        else
            flutter build web
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Flutter web build completed${NC}"
            else
                echo -e "${RED}✗ Flutter build failed${NC}"
                echo "Continuing anyway, but nginx may not work correctly."
            fi
        fi
    else
        echo -e "${GREEN}✓ Flutter web build exists${NC}"
    fi
    echo ""
else
    echo -e "${BLUE}[4/5]${NC} Skipping Flutter build (not needed for selected services)"
    echo ""
fi

# Start Docker Compose services
echo -e "${BLUE}[5/5]${NC} Starting Docker Compose services..."
echo "Services to start: $SERVICES"
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
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup and startup completed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "Service URLs:"
echo "============="
if echo "$SERVICES" | grep -q "nginx"; then
    echo "  Flutter Web App: http://localhost:80"
fi
if echo "$SERVICES" | grep -q "portal"; then
    echo "  Portal:          http://localhost:3013"
fi
if echo "$SERVICES" | grep -q "backend"; then
    echo "  Backend API:     http://localhost:8012"
fi
if echo "$SERVICES" | grep -q "minio"; then
    echo "  MinIO Console:   http://localhost:9001 (minioadmin/minioadmin)"
    echo "  MinIO API:       http://localhost:9000"
fi
if echo "$SERVICES" | grep -q "grafana"; then
    echo "  Grafana:         http://localhost:3012 (admin/\$GRAFANA_PASSWORD)"
fi
if echo "$SERVICES" | grep -q "prometheus"; then
    echo "  Prometheus:      http://localhost:9012"
fi
echo ""
if echo "$SERVICES" | grep -q "backend"; then
    echo "CORS Configuration:"
    echo "  Backend allows requests from: http://localhost:8080, http://localhost:3000, http://localhost:8012, http://localhost:3013"
    echo ""
fi
echo "Useful Commands:"
echo "================"
echo "  View logs:        docker-compose -f docker-compose.prod.yml logs -f [service]"
echo "  Stop services:    docker-compose -f docker-compose.prod.yml down"
echo "  Restart service:  docker-compose -f docker-compose.prod.yml restart [service]"
echo "  Service status:   docker-compose -f docker-compose.prod.yml ps"
echo ""
echo -e "${GREEN}All set! Your services are running.${NC}"
echo ""

