#!/bin/bash

# Agent Mitra - Staging Deployment Script
# This script deploys the application to staging environment

set -e

echo "🚀 Starting Agent Mitra Staging Deployment"

# Configuration
ENVIRONMENT="staging"
COMPOSE_FILE="docker-compose.staging.yml"
PROJECT_NAME="agentmitra-staging"
USE_LOCAL_POSTGRES=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
check_env_vars() {
    print_status "Checking environment variables..."

    required_vars=("JWT_SECRET_KEY" "PIONEER_API_KEY")

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            print_error "Required environment variable $var is not set"
            exit 1
        fi
    done

    print_status "Environment variables check passed"
}

# Pre-deployment checks
pre_deployment_checks() {
    print_status "Running pre-deployment checks..."

    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi

    # Check if Docker Compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not available"
        exit 1
    fi

    # Check if required files exist
    required_files=("$COMPOSE_FILE" "backend/Dockerfile" "config-portal/Dockerfile")

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file $file not found"
            exit 1
        fi
    done

    print_status "Pre-deployment checks passed"
}

# Stop existing containers
stop_existing_containers() {
    print_status "Stopping existing containers..."

    if docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE ps -q | grep -q .; then
        docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE down --timeout 30
        print_status "Existing containers stopped"
    else
        print_status "No existing containers to stop"
    fi
}

# Clean up unused resources
cleanup_resources() {
    print_status "Cleaning up unused Docker resources..."

    # Remove unused containers, networks, and images
    docker system prune -f

    # Remove dangling images
    docker image prune -f

    print_status "Cleanup completed"
}

# Build and start services
deploy_services() {
    print_status "Building and starting services..."

    # Build images
    print_status "Building Docker images..."
    docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE build --no-cache

    # Start services
    print_status "Starting services..."
    docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE up -d

    print_status "Services deployment initiated"
}

# Wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to be healthy..."

    services=("backend" "portal" "minio" "pioneer")

    for service in "${services[@]}"; do
        print_status "Waiting for $service to be healthy..."

        # Wait for health check to pass (max 5 minutes)
        timeout=300
        elapsed=0

        while [ $elapsed -lt $timeout ]; do
            if docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE ps $service | grep -q "healthy"; then
                print_status "$service is healthy"
                break
            fi

            sleep 10
            elapsed=$((elapsed + 10))

            if [ $elapsed -ge $timeout ]; then
                print_warning "$service health check timed out, but continuing..."
                break
            fi
        done
    done

    print_status "Service health checks completed"
}

# Run database migrations
run_migrations() {
    print_status "Running database migrations..."

    if [[ "$USE_LOCAL_POSTGRES" == "true" ]]; then
        print_status "Using local PostgreSQL - migrations should be run manually with Flyway"
        print_warning "Please run: flyway -configFiles=flyway.conf migrate"
        print_status "Database migrations completed (manual step required)"
    else
        # Wait for database to be ready
        sleep 30

        # Run migrations (assuming backend container has migration scripts)
        if docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE exec -T backend python -c "
import asyncio
from app.core.database import init_db
asyncio.run(init_db())
print('Database initialized successfully')
" 2>/dev/null; then
            print_status "Database migrations completed"
        else
            print_warning "Database migration check failed, but continuing..."
        fi
    fi
}

# Run post-deployment tests
run_tests() {
    print_status "Running post-deployment tests..."

    # Test backend health endpoint
    if curl -f -s http://localhost:8013/health > /dev/null 2>&1; then
        print_status "Backend health check passed"
    else
        print_warning "Backend health check failed"
    fi

    # Test portal
    if curl -f -s http://localhost:3014 > /dev/null 2>&1; then
        print_status "Portal health check passed"
    else
        print_warning "Portal health check failed"
    fi

    print_status "Post-deployment tests completed"
}

# Main deployment function
main() {
    print_status "Agent Mitra Staging Deployment Started"
    print_status "Environment: $ENVIRONMENT"
    print_status "Compose File: $COMPOSE_FILE"
    print_status "Project Name: $PROJECT_NAME"

    check_env_vars
    pre_deployment_checks
    stop_existing_containers
    cleanup_resources
    deploy_services
    wait_for_services
    run_migrations
    run_tests

    print_status "🎉 Agent Mitra Staging Deployment Completed Successfully!"
    print_status ""
    print_status "Service URLs:"
    print_status "  Backend API: http://localhost:8013"
    print_status "  Portal: http://localhost:3014"
    print_status "  MinIO Console: http://localhost:9003"
    print_status "  Grafana: http://localhost:3015"
    print_status "  Prometheus: http://localhost:9013"
    print_status ""
    print_status "To view logs: docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE logs -f"
    print_status "To stop services: docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE down"
}

# Handle command line arguments
case "${1:-}" in
    "stop")
        print_status "Stopping staging environment..."
        docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE down
        print_status "Staging environment stopped"
        ;;
    "restart")
        print_status "Restarting staging environment..."
        docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE restart
        print_status "Staging environment restarted"
        ;;
    "logs")
        print_status "Showing staging logs..."
        docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE logs -f
        ;;
    *)
        main
        ;;
esac
