# MinIO Media Upload Testing Guide

## Prerequisites

1. **Docker Desktop must be running**
2. **Start MinIO:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d minio
   ```

3. **Setup bucket (if not auto-created):**
   ```bash
   ./scripts/setup-minio-bucket.sh
   ```

4. **Start backend:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d backend
   ```

5. **Start Flutter web app:**
   ```bash
   cd build/web && python3 -m http.server 8080
   ```

## Testing Steps

### 1. Navigate to Presentation Editor
- Open browser: http://localhost:8080
- Navigate to: `/presentation-editor` or `/presentations` → Create New

### 2. Upload Media
- Click "Upload Media" or "Add Image/Video" button
- Select an image file (JPG, PNG) or video file (MP4)
- File should upload and show preview

### 3. Verify Upload
- Check backend logs: `docker logs agentmitra_backend --tail 50`
- Look for: "File uploaded successfully" message
- Check MinIO Console: http://localhost:9001
- Navigate to `agentmitra-media` bucket
- Verify file exists in: `presentations/{agent_id}/{year}/{month}/`

### 4. Verify Database Entry
- Check `presentation_media` table:
  ```sql
  SELECT * FROM lic_schema.presentation_media ORDER BY uploaded_at DESC LIMIT 5;
  ```
- Should show:
  - `media_id`, `agent_id`, `media_type`, `storage_key`, `media_url`
  - `file_hash`, `file_size_bytes`, `status='active'`

### 5. Test Media URL
- Copy `media_url` from database
- Access directly: `http://localhost:9000/agentmitra-media/{storage_key}`
- Should display/download the file

## Expected Behavior

✅ **Success:**
- File uploads without errors
- Media URL is returned in API response
- File appears in MinIO bucket
- Database entry created with correct metadata
- File is accessible via URL

❌ **Failure Indicators:**
- "Failed to upload file to storage" error
- "Failed to initialize MinIO client" error
- Connection refused errors
- Bucket not found errors

## Troubleshooting

### MinIO Connection Issues
```bash
# Check MinIO is running
docker ps | grep minio

# Check MinIO health
curl http://localhost:9000/minio/health/live

# Check backend can reach MinIO
docker exec agentmitra_backend ping -c 2 minio
```

### Bucket Issues
```bash
# List buckets
docker exec agentmitra_minio mc ls myminio

# Create bucket manually
docker exec agentmitra_minio mc mb myminio/agentmitra-media

# Set public access
docker exec agentmitra_minio mc anonymous set download myminio/agentmitra-media
```

### Backend Configuration
Verify environment variables in backend container:
```bash
docker exec agentmitra_backend env | grep MINIO
```

Should show:
- `MINIO_ENDPOINT=minio:9000`
- `MINIO_ACCESS_KEY=minioadmin`
- `MINIO_SECRET_KEY=minioadmin`
- `MINIO_BUCKET_NAME=agentmitra-media`

## API Testing (Direct)

```bash
# Upload file via curl
curl -X POST http://localhost:8012/api/v1/presentations/media/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/image.jpg"

# Expected response:
{
  "media_id": "uuid",
  "media_url": "http://minio:9000/agentmitra-media/presentations/...",
  "thumbnail_url": "...",
  "media_type": "image",
  "file_name": "image.jpg",
  "file_size": 12345,
  "mime_type": "image/jpeg",
  "storage_key": "presentations/.../file.jpg"
}
```

