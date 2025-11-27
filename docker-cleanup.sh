#!/bin/bash

# Comprehensive Docker cleanup script for automated testing
# This script aggressively cleans up Docker resources to prevent disk space issues

set -e  # Exit on any error

echo "🧹 Starting comprehensive Docker cleanup..."

# Stop all running containers
echo "Stopping all running containers..."
docker stop $(docker ps -q) 2>/dev/null || true

# Remove all containers (including stopped ones)
echo "Removing all containers..."
docker rm -f $(docker ps -aq) 2>/dev/null || true

# Remove all images (this is aggressive - use with caution)
echo "Removing all unused images..."
docker image prune -a -f

# Remove build cache
echo "Removing build cache..."
docker builder prune -a -f

# Remove unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Remove unused networks
echo "Removing unused networks..."
docker network prune -f

# Final system-wide cleanup
echo "Final system cleanup..."
docker system prune -a -f

echo "✅ Docker cleanup completed!"
echo "💾 Checking remaining disk usage..."
docker system df
