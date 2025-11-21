#!/bin/bash

# Agent Mitra - Local Services Verification Script

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Agent Mitra - Service Verification                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check PostgreSQL
log_info "Checking PostgreSQL..."
if command_exists psql; then
    if psql -U agentmitra -d agentmitra_dev -c "SELECT version();" >/dev/null 2>&1; then
        VERSION=$(psql -U agentmitra -d agentmitra_dev -t -c "SELECT version();" | head -n 1 | xargs)
        log_success "PostgreSQL: Running ($VERSION)"
    else
        log_error "PostgreSQL: Not connected"
    fi
else
    log_error "PostgreSQL: Not installed"
fi

# Check Redis
log_info "Checking Redis..."
if command_exists redis-cli; then
    if redis-cli ping >/dev/null 2>&1; then
        VERSION=$(redis-cli --version | awk '{print $2}')
        log_success "Redis: Running ($VERSION)"
    else
        log_error "Redis: Not connected"
    fi
else
    log_error "Redis: Not installed"
fi

# Check Docker
log_info "Checking Docker..."
if command_exists docker; then
    if docker ps >/dev/null 2>&1; then
        VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
        log_success "Docker: Running ($VERSION)"
    else
        log_warning "Docker: Installed but not running"
    fi
else
    log_warning "Docker: Not installed (optional)"
fi

# Check Python
log_info "Checking Python..."
if command_exists python3; then
    VERSION=$(python3 --version | awk '{print $2}')
    log_success "Python: Installed ($VERSION)"
else
    log_error "Python: Not installed"
fi

# Check Node.js
log_info "Checking Node.js..."
if command_exists node; then
    VERSION=$(node --version)
    log_success "Node.js: Installed ($VERSION)"
else
    log_error "Node.js: Not installed"
fi

# Check Flutter
log_info "Checking Flutter..."
if command_exists flutter; then
    VERSION=$(flutter --version | head -n 1 | awk '{print $2}')
    log_success "Flutter: Installed ($VERSION)"
else
    log_error "Flutter: Not installed"
fi

# Check Flyway
log_info "Checking Flyway..."
if command_exists flyway; then
    VERSION=$(flyway -v | head -n 1 | awk '{print $2}')
    log_success "Flyway: Installed ($VERSION)"
else
    log_error "Flyway: Not installed"
fi

echo ""
echo -e "${GREEN}Verification complete!${NC}"

