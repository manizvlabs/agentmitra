#!/bin/bash

# Lightweight Docker cleanup script for frequent automated testing
# This removes containers, build cache, and temporary resources but keeps base images

set -e  # Exit on any error

echo "🧹 Starting lightweight Docker cleanup for automated testing..."

# Stop all running containers (except those with specific labels if needed)
echo "Stopping containers..."
docker stop $(docker ps -q) 2>/dev/null || true

# Remove stopped containers
echo "Removing stopped containers..."
docker container prune -f

# Remove build cache (this is usually the biggest space consumer in frequent builds)
echo "Removing build cache..."
docker builder prune -a -f

# Remove unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Remove unused networks
echo "Removing unused networks..."
docker network prune -f

# Remove dangling images only (not all unused images)
echo "Removing dangling images..."
docker image prune -f

echo "✅ Lightweight Docker cleanup completed!"
echo "💾 Current Docker disk usage:"
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}"
