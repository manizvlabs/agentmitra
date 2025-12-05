#!/bin/bash

# Agent Mitra Backend - Local Development Runner with Hot Reload
# This script runs the FastAPI backend locally with uvicorn for fast development
# No Docker builds required - instant hot reload on code changes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
BACKEND_DIR="$PROJECT_ROOT/backend"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Agent Mitra Backend - Local Development${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "$BACKEND_DIR/main.py" ]; then
    echo -e "${RED}Error: backend/main.py not found!${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Change to backend directory
cd "$BACKEND_DIR"

# Check if virtual environment exists
if [ ! -d "venv" ] && [ ! -d ".venv" ]; then
    echo -e "${YELLOW}Warning: No virtual environment found.${NC}"
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
if [ -d "venv" ]; then
    source venv/bin/activate
elif [ -d ".venv" ]; then
    source .venv/bin/activate
fi

# Install/upgrade dependencies if needed
echo -e "${GREEN}Checking dependencies...${NC}"
if [ -f "requirements.txt" ]; then
    pip install -q --upgrade pip
    pip install -q -r requirements.txt
fi

# Set environment variables for local development
export ENVIRONMENT=development
export API_PORT=8012
export API_HOST=0.0.0.0

# Database configuration - using localhost (not Docker internal)
export DATABASE_URL="${DATABASE_URL:-postgresql://manish:agentmitra_dev@localhost:5432/agentmitra_dev?sslmode=disable}"
export REDIS_URL="${REDIS_URL:-redis://localhost:6379}"

# MinIO configuration - using localhost (Docker container accessible via localhost:9000)
export MINIO_ENDPOINT="${MINIO_ENDPOINT:-localhost:9000}"
export MINIO_ACCESS_KEY="${MINIO_ACCESS_KEY:-minioadmin}"
export MINIO_SECRET_KEY="${MINIO_SECRET_KEY:-minioadmin}"
export MINIO_BUCKET_NAME="${MINIO_BUCKET_NAME:-agentmitra-media}"
export MINIO_USE_SSL="${MINIO_USE_SSL:-false}"
export MINIO_CDN_BASE_URL="${MINIO_CDN_BASE_URL:-http://localhost:9000/agentmitra-media}"

# Pioneer configuration - using localhost (Docker container accessible via localhost:4001)
export PIONEER_URL="${PIONEER_URL:-http://localhost:4001}"

# CORS configuration
export CORS_ORIGINS="${CORS_ORIGINS:-http://localhost:8080,http://localhost:3000,http://localhost:8012,http://localhost:3013}"

# JWT Secret
export JWT_SECRET_KEY="${JWT_SECRET_KEY:-dev-secret-key-change-in-production-minimum-32-chars}"

# SSL disabled for local development
export USE_SSL=false

# Load .env file if it exists (will override above defaults)
if [ -f ".env" ]; then
    echo -e "${GREEN}Loading .env file...${NC}"
    export $(cat .env | grep -v '^#' | xargs)
elif [ -f "env.development" ]; then
    echo -e "${YELLOW}No .env file found, using env.development as template...${NC}"
    echo "Consider copying env.development to .env and customizing it."
fi

# Create logs directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/logs"

echo ""
echo -e "${GREEN}Starting FastAPI backend with hot reload...${NC}"
echo -e "${GREEN}Server will be available at: http://localhost:8012${NC}"
echo -e "${GREEN}API docs available at: http://localhost:8012/docs${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Run uvicorn with hot reload
python main.py

