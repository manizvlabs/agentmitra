#!/bin/bash

# Agent Mitra - Local Development Environment Setup Script
# MacBook Compatible | One-Command Setup

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check macOS version
check_macos() {
    log_info "Checking macOS version..."
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS. Please use manual setup."
        exit 1
    fi
    
    MACOS_VERSION=$(sw_vers -productVersion)
    log_success "macOS version: $MACOS_VERSION"
}

# Check and install Homebrew
check_homebrew() {
    log_info "Checking Homebrew installation..."
    if ! command_exists brew; then
        log_warning "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed"
    else
        log_success "Homebrew already installed"
        brew update
    fi
}

# Install software via Homebrew
install_software() {
    log_info "Installing required software..."
    
    # Core tools
    install_if_missing "git" "git"
    install_if_missing "python3" "python@3.11"
    install_if_missing "node" "node@20"
    install_if_missing "flyway" "flyway"
    
    # Database services
    install_if_missing "psql" "postgresql@16"
    install_if_missing "redis-cli" "redis"
    
    # Flutter
    if ! command_exists flutter; then
        log_info "Installing Flutter..."
        brew install --cask flutter
        log_success "Flutter installed"
    else
        log_success "Flutter already installed"
    fi
    
    log_success "All software installed"
}

# Install if missing
install_if_missing() {
    local cmd=$1
    local package=$2
    
    if ! command_exists "$cmd"; then
        log_info "Installing $package..."
        brew install "$package"
        log_success "$package installed"
    else
        log_success "$package already installed"
    fi
}

# Start PostgreSQL service
setup_postgresql() {
    log_info "Setting up PostgreSQL..."
    
    # Start PostgreSQL service
    if brew services list | grep -q "postgresql@16.*started"; then
        log_success "PostgreSQL already running"
    else
        brew services start postgresql@16
        sleep 2
        log_success "PostgreSQL started"
    fi
    
    # Create database user (if not exists)
    if ! psql -U "$USER" -d postgres -c "\du" | grep -q "agentmitra"; then
        log_info "Creating database user..."
        createuser -s agentmitra 2>/dev/null || log_warning "User may already exist"
    fi
    
    # Create development database
    if ! psql -U agentmitra -d postgres -c "\l" | grep -q "agentmitra_dev"; then
        log_info "Creating development database..."
        createdb -U agentmitra agentmitra_dev || log_warning "Database may already exist"
        log_success "Database created"
    else
        log_success "Database already exists"
    fi
}

# Start Redis service
setup_redis() {
    log_info "Setting up Redis..."
    
    if brew services list | grep -q "redis.*started"; then
        log_success "Redis already running"
    else
        brew services start redis
        sleep 2
        log_success "Redis started"
    fi
    
    # Verify Redis connection
    if redis-cli ping >/dev/null 2>&1; then
        log_success "Redis connection verified"
    else
        log_error "Redis connection failed"
        exit 1
    fi
}

# Setup Python virtual environment
setup_python_env() {
    log_info "Setting up Python environment..."
    
    if [ ! -d "backend/venv" ]; then
        log_info "Creating Python virtual environment..."
        cd backend
        python3.11 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        log_success "Python virtual environment created"
        cd ..
    else
        log_success "Python virtual environment already exists"
    fi
}

# Setup Flutter dependencies
setup_flutter() {
    log_info "Setting up Flutter dependencies..."
    
    if [ -f "pubspec.yaml" ]; then
        flutter pub get
        log_success "Flutter dependencies installed"
    else
        log_warning "pubspec.yaml not found. Skipping Flutter setup."
    fi
}

# Create .env.local file
setup_env_file() {
    log_info "Setting up environment variables..."
    
    if [ ! -f ".env.local" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env.local
            log_success ".env.local created from .env.example"
        else
            log_warning ".env.example not found. Creating basic .env.local..."
            cat > .env.local << EOF
# Database
DATABASE_URL=postgresql://agentmitra@localhost:5432/agentmitra_dev
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=agentmitra
POSTGRES_PASSWORD=
POSTGRES_DB=agentmitra_dev

# Redis
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379

# Backend API
API_HOST=localhost
API_PORT=8000
API_URL=http://localhost:8000

# Flutter
FLUTTER_API_URL=http://localhost:8000
FLUTTER_USE_MOCK_DATA=true

# Feature Flags
ENABLE_MOCK_DATA=true
ENABLE_ANALYTICS=false
ENABLE_PAYMENT_PROCESSING=false
EOF
            log_success ".env.local created"
        fi
    else
        log_success ".env.local already exists"
    fi
}

# Verify all services
verify_services() {
    log_info "Verifying all services..."
    
    # PostgreSQL
    if psql -U agentmitra -d agentmitra_dev -c "SELECT version();" >/dev/null 2>&1; then
        log_success "PostgreSQL: Connected"
    else
        log_error "PostgreSQL: Connection failed"
    fi
    
    # Redis
    if redis-cli ping >/dev/null 2>&1; then
        log_success "Redis: Connected"
    else
        log_error "Redis: Connection failed"
    fi
    
    # Python
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version)
        log_success "Python: $PYTHON_VERSION"
    else
        log_error "Python: Not found"
    fi
    
    # Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version)
        log_success "Node.js: $NODE_VERSION"
    else
        log_error "Node.js: Not found"
    fi
    
    # Flutter
    if command_exists flutter; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        log_success "Flutter: $FLUTTER_VERSION"
    else
        log_error "Flutter: Not found"
    fi
    
    # Flyway
    if command_exists flyway; then
        FLYWAY_VERSION=$(flyway -v | head -n 1)
        log_success "Flyway: $FLYWAY_VERSION"
    else
        log_error "Flyway: Not found"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║  Agent Mitra - Local Development Setup                ║"
    echo "║  MacBook Compatible | One-Command Setup              ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_macos
    check_homebrew
    install_software
    setup_postgresql
    setup_redis
    setup_python_env
    setup_flutter
    setup_env_file
    verify_services
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ Setup Complete!                                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review .env.local and update if needed"
    echo "  2. Run Flyway migrations: flyway -configFiles=flyway.conf migrate"
    echo "  3. Start backend: cd backend && source venv/bin/activate && uvicorn main:app --reload"
    echo "  4. Start Flutter: flutter run"
    echo ""
    echo "For detailed documentation, see: docs/development/LOCAL_DEVELOPMENT_SETUP.md"
}

# Run main function
main

