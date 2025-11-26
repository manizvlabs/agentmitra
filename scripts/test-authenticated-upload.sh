#!/bin/bash
# Script to test MinIO upload with authentication
# Usage: ./scripts/test-authenticated-upload.sh [image_path] [phone] [password]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

IMAGE_PATH="${1:-discovery/screenshots/Buy-Online-Page1.jpeg}"
PHONE="${2:-+919876543203}"
PASSWORD="${3:-testpassword}"
BACKEND_URL="http://localhost:8012"

echo "Testing Authenticated MinIO Upload"
echo "==================================="
echo ""
echo "Image file: $IMAGE_PATH"
echo "Backend URL: $BACKEND_URL"
echo "Phone: $PHONE"
echo ""

# Check if file exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: File not found: $IMAGE_PATH"
    exit 1
fi

# Check if backend is running
if ! curl -s "$BACKEND_URL/health" > /dev/null; then
    echo "Error: Backend is not running at $BACKEND_URL"
    exit 1
fi

echo "Step 1: Logging in..."
echo "---------------------"

LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"phone_number\":\"$PHONE\",\"password\":\"$PASSWORD\"}")

# Check if login was successful
if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])" 2>/dev/null)
    USER_INFO=$(echo "$LOGIN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"User: {data.get('user', {}).get('name', 'Unknown')}, Agent ID: {data.get('user', {}).get('agent_id', 'None')}\")" 2>/dev/null)
    echo "✓ Login successful"
    echo "$USER_INFO"
    echo ""
else
    echo "✗ Login failed"
    echo "Response: $LOGIN_RESPONSE"
    exit 1
fi

echo "Step 2: Uploading image to MinIO..."
echo "------------------------------------"

UPLOAD_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/presentations/media/upload" \
    -H "Authorization: Bearer $TOKEN" \
    -F "file=@$IMAGE_PATH")

# Check if upload was successful
if echo "$UPLOAD_RESPONSE" | grep -q "media_id"; then
    echo "✓ Upload successful!"
    echo ""
    echo "Upload Response:"
    echo "$UPLOAD_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$UPLOAD_RESPONSE"
    echo ""
    
    # Extract media URL
    MEDIA_URL=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['media_url'])" 2>/dev/null || echo "")
    MEDIA_ID=$(echo "$UPLOAD_RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['media_id'])" 2>/dev/null || echo "")
    
    if [ ! -z "$MEDIA_URL" ]; then
        echo "Step 3: Verifying file accessibility..."
        echo "----------------------------------------"
        echo "Media URL: $MEDIA_URL"
        echo "Media ID: $MEDIA_ID"
        echo ""
        
        # Try to access the media URL
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$MEDIA_URL" || echo "000")
        if [ "$HTTP_CODE" = "200" ]; then
            echo "✓ File is accessible via URL (HTTP $HTTP_CODE)"
        else
            echo "⚠️  File URL returned HTTP $HTTP_CODE"
            echo "   This may be normal if MinIO bucket doesn't have public read access"
        fi
        
        # Check MinIO bucket
        echo ""
        echo "Step 4: Checking MinIO bucket..."
        echo "---------------------------------"
        docker exec agentmitra_minio mc ls myminio/agentmitra-media/presentations/ 2>&1 | tail -5 || echo "Could not list bucket contents"
    fi
else
    echo "✗ Upload failed"
    echo "Response: $UPLOAD_RESPONSE"
    exit 1
fi

echo ""
echo "✓ Test complete!"

