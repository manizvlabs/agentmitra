#!/bin/bash
# Script to test MinIO upload via API
# Usage: ./scripts/test-minio-upload.sh [image_path]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

IMAGE_PATH="${1:-discovery/screenshots/Buy-Online-Page1.jpeg}"
BACKEND_URL="http://localhost:8012"

echo "Testing MinIO Upload Integration"
echo "================================"
echo ""
echo "Image file: $IMAGE_PATH"
echo "Backend URL: $BACKEND_URL"
echo ""

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: File not found: $IMAGE_PATH"
    exit 1
fi

# Check if backend is running
if ! curl -s "$BACKEND_URL/health" > /dev/null; then
    echo "Error: Backend is not running at $BACKEND_URL"
    echo "Please start the backend: ./scripts/start-prod.sh backend"
    exit 1
fi

echo "Step 1: Attempting login to get auth token..."
echo "----------------------------------------------"

# Try to login (this may fail if user doesn't exist, that's okay for testing)
LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123"}' 2>&1)

echo "Login response: $LOGIN_RESPONSE"
echo ""

# Extract token if login successful
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4 || echo "")

if [ -z "$TOKEN" ]; then
    echo "⚠️  Login failed (expected if test user doesn't exist)"
    echo "Attempting upload without auth token (will likely fail with 401)..."
    echo ""
    TOKEN_HEADER=""
else
    echo "✓ Login successful, token obtained"
    TOKEN_HEADER="-H \"Authorization: Bearer $TOKEN\""
fi

echo "Step 2: Uploading image to MinIO via API..."
echo "--------------------------------------------"

# Upload file
UPLOAD_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/presentations/media/upload" \
    -H "Authorization: Bearer ${TOKEN:-none}" \
    -F "file=@$IMAGE_PATH" 2>&1)

echo "Upload response:"
echo "$UPLOAD_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$UPLOAD_RESPONSE"
echo ""

# Check if upload was successful
if echo "$UPLOAD_RESPONSE" | grep -q "media_id"; then
    MEDIA_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"media_url":"[^"]*' | cut -d'"' -f4 || echo "")
    echo "✓ Upload successful!"
    echo ""
    echo "Media URL: $MEDIA_URL"
    echo ""
    echo "Step 3: Verifying file in MinIO..."
    echo "-----------------------------------"
    
    # Try to access the media URL
    if [ ! -z "$MEDIA_URL" ]; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$MEDIA_URL" || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            echo "✓ File is accessible at: $MEDIA_URL"
        else
            echo "⚠️  File URL returned HTTP $HTTP_CODE (may need public access policy)"
        fi
    fi
else
    echo "✗ Upload failed"
    echo ""
    echo "Common issues:"
    echo "  1. Authentication required - need valid JWT token"
    echo "  2. Agent ID required - user must have agent_id"
    echo "  3. MinIO connection issue - check MinIO is running"
    echo ""
    echo "To test with authentication:"
    echo "  1. Create a test user with agent_id"
    echo "  2. Login to get access token"
    echo "  3. Use token in Authorization header"
fi

echo ""
echo "Test complete!"

