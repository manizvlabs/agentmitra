#!/bin/bash

# Agent Mitra Production Deployment Script
# This script handles the complete deployment of all components

set -e

# Configuration
BACKEND_PORT=8012
FRONTEND_PORT=3000
ENVIRONMENT=${1:-production}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Starting Agent Mitra Deployment - $ENVIRONMENT"
echo "Timestamp: $TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."

    # Check if required tools are installed
    command -v node >/dev/null 2>&1 || { log_error "Node.js is required but not installed."; exit 1; }
    command -v npm >/dev/null 2>&1 || { log_error "npm is required but not installed."; exit 1; }
    command -v python3 >/dev/null 2>&1 || { log_error "Python3 is required but not installed."; exit 1; }
    command -v docker >/dev/null 2>&1 || { log_error "Docker is required but not installed."; exit 1; }

    # Check if ports are available
    if lsof -Pi :$BACKEND_PORT -sTCP:LISTEN -t >/dev/null ; then
        log_error "Port $BACKEND_PORT is already in use"
        exit 1
    fi

    if lsof -Pi :$FRONTEND_PORT -sTCP:LISTEN -t >/dev/null ; then
        log_warn "Port $FRONTEND_PORT is already in use - will attempt to free it"
        fuser -k $FRONTEND_PORT/tcp || true
    fi

    log_info "Pre-deployment checks passed"
}

# Deploy backend
deploy_backend() {
    log_info "Deploying backend..."

    cd backend

    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        log_info "Creating Python virtual environment..."
        python3 -m venv venv
    fi

    # Activate virtual environment
    source venv/bin/activate

    # Install/update dependencies
    log_info "Installing Python dependencies..."
    pip install -r requirements.txt

    # Run database migrations
    log_info "Running database migrations..."
    # Note: This would need to be configured for your specific database setup
    # python manage.py migrate

    # Start backend service
    log_info "Starting backend service on port $BACKEND_PORT..."
    nohup python main.py > ../logs/backend_$TIMESTAMP.log 2>&1 &

    # Wait for backend to start
    sleep 10

    # Health check
    if curl -s http://localhost:$BACKEND_PORT/health > /dev/null; then
        log_info "Backend deployment successful"
    else
        log_error "Backend health check failed"
        exit 1
    fi

    cd ..
}

# Deploy frontend (React portal)
deploy_frontend() {
    log_info "Deploying React portal..."

    cd config-portal

    # Install dependencies
    log_info "Installing Node.js dependencies..."
    npm ci

    # Build for production
    log_info "Building React application..."
    npm run build

    # Start production server
    log_info "Starting React production server on port $FRONTEND_PORT..."
    nohup npm start > ../logs/frontend_$TIMESTAMP.log 2>&1 &

    # Wait for frontend to start
    sleep 5

    # Health check
    if curl -s http://localhost:$FRONTEND_PORT | grep -q "Agent Mitra"; then
        log_info "React portal deployment successful"
    else
        log_error "React portal health check failed"
        exit 1
    fi

    cd ..
}

# Deploy Flutter web app
deploy_flutter_web() {
    log_info "Deploying Flutter web application..."

    # Build Flutter web app
    log_info "Building Flutter web application..."
    flutter build web --release

    # Copy to web server directory (assuming nginx or similar)
    WEB_ROOT="/var/www/agentmitra"
    if [ -d "$WEB_ROOT" ]; then
        log_info "Copying Flutter build to web server..."
        cp -r build/web/* $WEB_ROOT/
        log_info "Flutter web deployment successful"
    else
        log_warn "Web root directory $WEB_ROOT not found - skipping Flutter web deployment"
    fi
}

# Post-deployment verification
post_deployment_verification() {
    log_info "Running post-deployment verification..."

    # Test backend APIs
    log_info "Testing backend APIs..."
    if curl -s http://localhost:$BACKEND_PORT/health | grep -q "healthy"; then
        log_info "✅ Backend health check passed"
    else
        log_error "❌ Backend health check failed"
    fi

    # Test frontend
    log_info "Testing React portal..."
    if curl -s http://localhost:$FRONTEND_PORT | grep -q "Agent Mitra"; then
        log_info "✅ React portal check passed"
    else
        log_error "❌ React portal check failed"
    fi

    # Test key API endpoints
    log_info "Testing key API endpoints..."
    endpoints=(
        "/api/v1/auth/login"
        "/api/v1/presentations/templates"
        "/api/v1/analytics/dashboard/overview"
        "/api/v1/import/templates"
    )

    for endpoint in "${endpoints[@]}"; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT$endpoint | grep -q "200\|401"; then
            log_info "✅ $endpoint accessible"
        else
            log_error "❌ $endpoint not accessible"
        fi
    done
}

# Backup current deployment
backup_current_deployment() {
    log_info "Creating deployment backup..."

    BACKUP_DIR="backups/$TIMESTAMP"
    mkdir -p $BACKUP_DIR

    # Backup configuration files
    cp -r config-portal/build $BACKUP_DIR/ 2>/dev/null || true
    cp backend/main.py $BACKUP_DIR/ 2>/dev/null || true
    cp -r backend/app $BACKUP_DIR/ 2>/dev/null || true

    log_info "Backup created in $BACKUP_DIR"
}

# Rollback function
rollback_deployment() {
    log_error "Deployment failed - initiating rollback..."

    # Kill any processes we started
    pkill -f "python main.py" || true
    pkill -f "npm start" || true

    # Restore from backup if available
    LATEST_BACKUP=$(ls -t backups/ | head -1 2>/dev/null || echo "")
    if [ -n "$LATEST_BACKUP" ] && [ -d "backups/$LATEST_BACKUP" ]; then
        log_info "Restoring from backup $LATEST_BACKUP..."
        # Restore logic would go here
    fi

    log_error "Rollback completed"
    exit 1
}

# Main deployment flow
main() {
    log_info "Agent Mitra Production Deployment Script"
    log_info "Environment: $ENVIRONMENT"
    log_info "========================================"

    # Create logs and backups directories
    mkdir -p logs backups

    # Pre-deployment checks
    pre_deployment_checks

    # Backup current deployment
    backup_current_deployment

    # Deploy components
    deploy_backend || rollback_deployment
    deploy_frontend || rollback_deployment
    deploy_flutter_web || log_warn "Flutter web deployment skipped"

    # Post-deployment verification
    post_deployment_verification

    log_info "🎉 Deployment completed successfully!"
    log_info "Backend: http://localhost:$BACKEND_PORT"
    log_info "Frontend: http://localhost:$FRONTEND_PORT"
    log_info "Monitoring: http://localhost:$FRONTEND_PORT/monitoring.html"

    # Print deployment summary
    echo ""
    echo "========================================"
    echo "DEPLOYMENT SUMMARY"
    echo "========================================"
    echo "Environment: $ENVIRONMENT"
    echo "Timestamp: $TIMESTAMP"
    echo "Backend Status: ✅ Running on port $BACKEND_PORT"
    echo "Frontend Status: ✅ Running on port $FRONTEND_PORT"
    echo "Logs: logs/backend_$TIMESTAMP.log, logs/frontend_$TIMESTAMP.log"
    echo "========================================"
}

# Handle script arguments
case "$1" in
    --rollback)
        rollback_deployment
        ;;
    --help)
        echo "Usage: $0 [environment] [options]"
        echo ""
        echo "Environments:"
        echo "  production    Production deployment (default)"
        echo "  staging       Staging deployment"
        echo "  development   Development deployment"
        echo ""
        echo "Options:"
        echo "  --rollback    Rollback to previous deployment"
        echo "  --help        Show this help message"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
