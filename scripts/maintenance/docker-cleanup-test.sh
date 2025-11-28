#!/bin/bash

# Docker cleanup script optimized for automated testing environments
# Safely cleans up resources between test runs without stopping production services

set -e  # Exit on any error

echo "🧹 Starting Docker cleanup for automated testing..."

# Stop and remove containers that match test patterns (customize these patterns for your tests)
echo "Stopping test containers..."
docker stop $(docker ps -q --filter "name=test_*" --filter "name=*_test" --filter "name=*-test-*") 2>/dev/null || true

# Remove stopped test containers
echo "Removing stopped test containers..."
docker rm $(docker ps -aq --filter "status=exited" --filter "name=test_*" --filter "name=*_test" --filter "name=*-test-*") 2>/dev/null || true

# Clean up build cache (most important for frequent builds)
echo "Cleaning build cache..."
docker builder prune -a -f

# Remove dangling images (safe cleanup)
echo "Removing dangling images..."
docker image prune -f

# Remove unused volumes (be careful with this in production)
echo "Removing unused volumes..."
docker volume prune -f

# Clean up networks
echo "Removing unused networks..."
docker network prune -f

# Optional: Remove images older than 24 hours (customize as needed)
echo "Removing old unused images (24h+)..."
docker image prune -a --filter "until=24h" -f

echo "✅ Test cleanup completed!"
echo "💾 Docker disk usage after cleanup:"
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}"
