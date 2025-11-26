# MinIO Setup Guide

## Overview
MinIO is used for object storage of media files (images/videos) uploaded in the Presentation Editor.

## Docker Compose Setup

MinIO has been added to both `docker-compose.dev.yml` and `docker-compose.prod.yml`.

### Development Setup

1. **Start MinIO:**
   ```bash
   docker-compose -f docker-compose.dev.yml up -d minio
   ```

2. **Setup bucket:**
   ```bash
   ./scripts/setup-minio-bucket.sh
   ```

   Or manually:
   ```bash
   docker exec agentmitra_minio_dev mc alias set myminio http://localhost:9000 minioadmin minioadmin
   docker exec agentmitra_minio_dev mc mb myminio/agentmitra-media
   docker exec agentmitra_minio_dev mc anonymous set download myminio/agentmitra-media
   ```

3. **Access MinIO Console:**
   - URL: http://localhost:9001
   - Username: `minioadmin`
   - Password: `minioadmin`

### Production Setup

1. **Start MinIO:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d minio
   ```

2. **Environment Variables:**
   Set these in your `.env` file or environment:
   ```bash
   MINIO_ROOT_USER=your-secure-username
   MINIO_ROOT_PASSWORD=your-secure-password
   MINIO_BUCKET_NAME=agentmitra-media
   ```

3. **Backend Configuration:**
   The backend automatically connects to MinIO using these environment variables:
   - `MINIO_ENDPOINT` (default: `minio:9000` in Docker, `localhost:9000` locally)
   - `MINIO_ACCESS_KEY` (default: `minioadmin`)
   - `MINIO_SECRET_KEY` (default: `minioadmin`)
   - `MINIO_BUCKET_NAME` (default: `agentmitra-media`)
   - `MINIO_USE_SSL` (default: `false`)
   - `MINIO_CDN_BASE_URL` (for public URLs)

## Testing Media Upload

1. **Start all services:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

2. **Verify MinIO is running:**
   ```bash
   docker ps | grep minio
   curl http://localhost:9000/minio/health/live
   ```

3. **Test upload via Presentation Editor:**
   - Navigate to Presentation Editor
   - Click "Upload Media" button
   - Select an image or video file
   - File should be uploaded to MinIO and URL returned

4. **Check uploaded files:**
   - Visit MinIO Console: http://localhost:9001
   - Navigate to `agentmitra-media` bucket
   - Files are organized by: `presentations/{agent_id}/{year}/{month}/{uuid}.ext`

## Troubleshooting

### Docker daemon not running
```bash
# Start Docker Desktop, then:
docker info
```

### Bucket doesn't exist
The backend service automatically creates the bucket on first use. If you see errors:
```bash
docker exec agentmitra_minio mc mb myminio/agentmitra-media
```

### Connection refused
- Check MinIO is running: `docker ps | grep minio`
- Check endpoint matches: `MINIO_ENDPOINT=minio:9000` (in Docker) or `localhost:9000` (local)
- Check network: Ensure backend and MinIO are on same Docker network

### Permission denied
- Ensure bucket policy allows uploads:
  ```bash
  docker exec agentmitra_minio mc anonymous set download myminio/agentmitra-media
  ```

## File Storage Structure

```
agentmitra-media/
  └── presentations/
      └── {agent_id}/
          └── {year}/
              └── {month}/
                  └── {uuid}.{ext}
```

Example:
```
agentmitra-media/presentations/550e8400-e29b-41d4-a716-446655440000/2024/11/a1b2c3d4-e5f6-7890-abcd-ef1234567890.jpg
```

## API Endpoint

**POST** `/api/v1/presentations/media/upload`

**Request:**
- `file`: Multipart file upload (image or video)
- Headers: `Authorization: Bearer {token}`

**Response:**
```json
{
  "media_id": "uuid",
  "media_url": "http://minio:9000/agentmitra-media/presentations/...",
  "thumbnail_url": "http://minio:9000/agentmitra-media/presentations/...",
  "media_type": "image",
  "file_name": "example.jpg",
  "file_size": 12345,
  "mime_type": "image/jpeg",
  "storage_key": "presentations/.../file.jpg"
}
```

