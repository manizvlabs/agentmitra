#!/bin/bash
# Script to start MinIO for development/testing
# Usage: ./scripts/start-minio.sh

set -e

echo "Starting MinIO server..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker daemon is not running. Please start Docker Desktop first."
    exit 1
fi

# Start MinIO using Docker Compose
if [ -f "docker-compose.dev.yml" ]; then
    echo "Starting MinIO from docker-compose.dev.yml..."
    docker-compose -f docker-compose.dev.yml up -d minio
    echo "Waiting for MinIO to be ready..."
    sleep 5
    
    # Check if MinIO is running
    if docker ps | grep -q agentmitra_minio_dev; then
        echo "✓ MinIO is running!"
        echo ""
        echo "MinIO Console: http://localhost:9001"
        echo "MinIO API: http://localhost:9000"
        echo "Default credentials: minioadmin / minioadmin"
        echo ""
        echo "To create the bucket 'agentmitra-media', visit the console or use:"
        echo "  docker exec agentmitra_minio_dev mc alias set myminio http://localhost:9000 minioadmin minioadmin"
        echo "  docker exec agentmitra_minio_dev mc mb myminio/agentmitra-media"
        echo "  docker exec agentmitra_minio_dev mc anonymous set download myminio/agentmitra-media"
    else
        echo "✗ Failed to start MinIO. Check logs with: docker logs agentmitra_minio_dev"
        exit 1
    fi
else
    echo "Error: docker-compose.dev.yml not found"
    exit 1
fi

