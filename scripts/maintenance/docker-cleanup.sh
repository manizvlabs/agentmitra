#!/bin/bash

# Docker build cache cleanup script
# This script only removes Docker build cache to reclaim storage space
# Preserves agentmitra and transva network images and containers

set -e  # Exit on any error

echo "🧹 Starting Docker build cache cleanup..."

# Remove build cache only
echo "Removing Docker build cache..."
docker builder prune -a -f

echo "✅ Docker build cache cleanup completed!"
echo "💾 Checking remaining disk usage..."
docker system df
