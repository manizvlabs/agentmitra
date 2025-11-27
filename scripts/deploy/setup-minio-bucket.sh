#!/bin/bash
# Script to setup MinIO bucket for agentmitra-media
# Usage: ./scripts/setup-minio-bucket.sh

set -e

BUCKET_NAME="agentmitra-media"
CONTAINER_NAME="agentmitra_minio_dev"

echo "Setting up MinIO bucket: $BUCKET_NAME"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Error: MinIO container '$CONTAINER_NAME' is not running."
    echo "Start it with: docker-compose -f docker-compose.dev.yml up -d minio"
    exit 1
fi

# Setup MinIO client alias
echo "Configuring MinIO client..."
docker exec "$CONTAINER_NAME" mc alias set myminio http://localhost:9000 minioadmin minioadmin

# Create bucket if it doesn't exist
echo "Creating bucket '$BUCKET_NAME'..."
if docker exec "$CONTAINER_NAME" mc ls myminio | grep -q "$BUCKET_NAME"; then
    echo "Bucket '$BUCKET_NAME' already exists"
else
    docker exec "$CONTAINER_NAME" mc mb "myminio/$BUCKET_NAME"
    echo "✓ Bucket '$BUCKET_NAME' created"
fi

# Set bucket policy to allow public read (for CDN URLs)
echo "Setting bucket policy..."
docker exec "$CONTAINER_NAME" mc anonymous set download "myminio/$BUCKET_NAME"

echo ""
echo "✓ MinIO bucket setup complete!"
echo "Bucket: $BUCKET_NAME"
echo "Public URL: http://localhost:9000/$BUCKET_NAME"

