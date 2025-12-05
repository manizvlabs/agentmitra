#!/bin/bash
# Comprehensive setup and startup script for Agent Mitra production services
# Usage: ./scripts/start-prod.sh [service1] [service2] ... | all | minimal
# 
# This script:
# 1. Checks Docker daemon
# 2. Creates .env file if needed
# 3. Generates SSL certificates (if needed)
# 4. Builds Flutter web app (if needed for nginx)
# 5. Starts Docker Compose services (backend excluded - runs locally)
# 6. Starts backend locally with hot reload (if requested)
#
# Note: Backend runs locally (not in Docker) for fast hot reload development
# Docker services: minio, portal, nginx, pioneer services, prometheus, grafana
# Local service: backend (runs via scripts/run_backend.sh)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
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
# Note: Backend runs locally (not in Docker) for hot reload
START_BACKEND=false
DOCKER_SERVICES=""

if [ $# -eq 0 ]; then
    # No arguments - start essential services by default
    DOCKER_SERVICES="minio"
    START_BACKEND=true
    START_ALL=false
    echo -e "${YELLOW}Note: Starting essential services (minio + backend)${NC}"
    echo -e "${YELLOW}Backend will run locally with hot reload${NC}"
    echo "To start all services: ./scripts/start-prod.sh all"
    echo "To start minimal: ./scripts/start-prod.sh minimal"
    echo ""
elif [ "$1" = "all" ]; then
    DOCKER_SERVICES="pioneer-nats pioneer-compass-server pioneer-scout pioneer-compass-client minio portal nginx prometheus grafana"
    START_BACKEND=true
    START_ALL=true
    echo -e "${GREEN}Starting all services including Pioneer, portal and nginx${NC}"
    echo -e "${YELLOW}Backend will run locally with hot reload${NC}"
    echo ""
elif [ "$1" = "minimal" ]; then
    DOCKER_SERVICES="minio"
    START_BACKEND=true
    START_ALL=false
else
    # Specific services provided
    USER_SERVICES="$@"
    START_ALL=false
    
    # Separate backend from Docker services
    if echo "$USER_SERVICES" | grep -q "backend"; then
        START_BACKEND=true
        DOCKER_SERVICES=$(echo "$USER_SERVICES" | sed 's/backend//g' | xargs)
    else
        DOCKER_SERVICES="$USER_SERVICES"
    fi
    
    # Check if nginx or portal are in the list
    if echo "$DOCKER_SERVICES" | grep -qE "(nginx|portal)"; then
        START_ALL=true
    fi
fi

# Generate SSL certificates if needed
echo -e "${BLUE}[3/5]${NC} Checking SSL certificates..."
if [ ! -f "$PROJECT_DIR/nginx/ssl/nginx-selfsigned.crt" ] || [ ! -f "$PROJECT_DIR/nginx/ssl/nginx-selfsigned.key" ]; then
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
if [ "$START_ALL" = true ] || echo "$DOCKER_SERVICES" | grep -q "nginx"; then
    echo -e "${BLUE}[4/5]${NC} Checking Flutter web build..."
    if [ ! -d "$PROJECT_DIR/build/web" ] || [ ! -f "$PROJECT_DIR/build/web/index.html" ]; then
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
            cd "$PROJECT_DIR"
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
echo -e "${BLUE}[5/6]${NC} Starting Docker Compose services..."
if [ -n "$DOCKER_SERVICES" ]; then
    echo "Docker services to start: $DOCKER_SERVICES"
    docker compose -f docker-compose.prod.yml up -d $DOCKER_SERVICES
else
    echo "No Docker services to start"
fi
echo ""

# Start backend locally if requested
if [ "$START_BACKEND" = true ]; then
    echo -e "${BLUE}[6/6]${NC} Starting backend locally with hot reload..."
    echo ""
    
    # Check if backend is already running
    if lsof -Pi :8012 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}⚠ Backend is already running on port 8012${NC}"
        echo "  If you want to restart it, stop the existing process first:"
        echo "  lsof -ti:8012 | xargs kill"
        echo ""
        read -p "Press Enter to continue, or Ctrl+C to exit and stop the existing backend..."
    else
        # Start backend in background
        echo -e "${GREEN}Starting backend with hot reload...${NC}"
        echo "  Backend will run in background"
        echo "  Logs will be written to: $PROJECT_DIR/logs/app.log"
        echo "  To view logs: tail -f $PROJECT_DIR/logs/app.log"
        echo ""
        
        # Run backend script in background and save PID
        nohup bash "$PROJECT_DIR/scripts/run_backend.sh" > "$PROJECT_DIR/logs/backend-startup.log" 2>&1 &
        BACKEND_PID=$!
        echo $BACKEND_PID > "$PROJECT_DIR/.backend.pid"
        
        # Wait a moment for backend to start
        sleep 3
        
        # Check if backend started successfully
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Backend started successfully (PID: $BACKEND_PID)${NC}"
        else
            echo -e "${RED}✗ Backend failed to start${NC}"
            echo "  Check logs: cat $PROJECT_DIR/logs/backend-startup.log"
        fi
    fi
    echo ""
fi

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 5

# Check service status
echo ""
echo "Service Status:"
echo "==============="
if [ -n "$DOCKER_SERVICES" ]; then
    docker compose -f docker-compose.prod.yml ps
fi
if [ "$START_BACKEND" = true ]; then
    if [ -f "$PROJECT_DIR/.backend.pid" ]; then
        BACKEND_PID=$(cat "$PROJECT_DIR/.backend.pid")
        if ps -p $BACKEND_PID > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Backend (local): Running (PID: $BACKEND_PID)${NC}"
        else
            echo -e "${RED}✗ Backend (local): Not running${NC}"
        fi
    fi
fi

# Setup MinIO bucket if MinIO is running
if echo "$DOCKER_SERVICES" | grep -q "minio" || [ "$START_ALL" = true ]; then
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
if echo "$DOCKER_SERVICES" | grep -q "nginx"; then
    echo "  Flutter Web App: http://localhost:80"
fi
if echo "$DOCKER_SERVICES" | grep -q "portal"; then
    echo "  Portal:          http://localhost:3013"
fi
if [ "$START_BACKEND" = true ]; then
    echo "  Backend API:     http://localhost:8012 (running locally with hot reload)"
    echo "  Backend Docs:    http://localhost:8012/docs"
fi
if echo "$DOCKER_SERVICES" | grep -q "pioneer-compass-server"; then
    echo "  Pioneer API:     http://localhost:4001"
    echo "  Pioneer Admin:   http://localhost:4000"
fi
if echo "$DOCKER_SERVICES" | grep -q "minio"; then
    echo "  MinIO Console:   http://localhost:9001 (minioadmin/minioadmin)"
    echo "  MinIO API:       http://localhost:9000"
fi
if echo "$DOCKER_SERVICES" | grep -q "grafana"; then
    echo "  Grafana:         http://localhost:3012 (admin/\$GRAFANA_PASSWORD)"
fi
if echo "$DOCKER_SERVICES" | grep -q "prometheus"; then
    echo "  Prometheus:      http://localhost:9012"
fi
echo ""
if [ "$START_BACKEND" = true ]; then
    echo "CORS Configuration:"
    echo "  Backend allows requests from: http://localhost:8080, http://localhost:3000, http://localhost:8012, http://localhost:3013"
    echo ""
fi
echo "Useful Commands:"
echo "================"
if [ -n "$DOCKER_SERVICES" ]; then
    echo "  View Docker logs: docker compose -f $PROJECT_DIR/docker-compose.prod.yml logs -f [service]"
    echo "  Stop Docker:      docker compose -f $PROJECT_DIR/docker-compose.prod.yml down"
    echo "  Restart service:  docker compose -f $PROJECT_DIR/docker-compose.prod.yml restart [service]"
    echo "  Docker status:    docker compose -f $PROJECT_DIR/docker-compose.prod.yml ps"
fi
if [ "$START_BACKEND" = true ]; then
    echo "  Backend logs:     tail -f $PROJECT_DIR/logs/app.log"
    echo "  Stop backend:     kill \$(cat $PROJECT_DIR/.backend.pid) 2>/dev/null || lsof -ti:8012 | xargs kill"
    echo "  Restart backend:  kill \$(cat $PROJECT_DIR/.backend.pid) 2>/dev/null; sleep 2; $PROJECT_DIR/scripts/run_backend.sh &"
fi
echo ""
echo -e "${GREEN}All set! Your services are running.${NC}"
if [ "$START_BACKEND" = true ]; then
    echo -e "${YELLOW}Note: Backend is running locally with hot reload - code changes will auto-reload${NC}"
fi
echo ""

# Copy .env file to web build directory for Flutter web builds
cp .env build/web/ || true
