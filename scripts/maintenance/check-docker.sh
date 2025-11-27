#!/bin/bash
# Script to check Docker daemon status
# Usage: ./scripts/check-docker.sh

set -e

echo "Checking Docker daemon status..."

if docker info > /dev/null 2>&1; then
    echo "✓ Docker daemon is running"
    echo ""
    echo "Docker version:"
    docker --version
    echo ""
    echo "Docker Compose version:"
    docker-compose --version
    echo ""
    echo "Running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    exit 0
else
    echo "✗ Docker daemon is not running"
    echo ""
    echo "Please start Docker Desktop:"
    echo "  macOS: Open Docker Desktop application"
    echo "  Linux: sudo systemctl start docker"
    exit 1
fi

