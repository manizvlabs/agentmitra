# MinIO Access Guide

## Accessing MinIO Console UI

### 1. Open MinIO Console in Browser

**URL:** `http://localhost:9001`

### 2. Login Credentials

- **Username:** `minioadmin`
- **Password:** `minioadmin`

> **Note:** These are default credentials. For production, change them using `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` environment variables.

### 3. Locating Uploaded Files

#### File Location Structure

Files are organized in the following structure:
```
Bucket: agentmitra-media
  └── presentations/
      └── {agent_id}/
          └── {year}/
              └── {month}/
                  └── {unique_id}.{extension}
```

#### Example Uploaded File

From the test upload, the file is located at:

**Bucket:** `agentmitra-media`

**Path:** `presentations/7b501e0e-4393-4b5a-8de7-25fe384e91da/2025/11/b600120f-0ccb-4197-b288-2c876e05c0a0.jpeg`

**Full Storage Key:** 
```
presentations/7b501e0e-4393-4b5a-8de7-25fe384e91da/2025/11/b600120f-0ccb-4197-b288-2c876e05c0a0.jpeg
```

### 4. Steps to View File in MinIO Console

1. **Login** to `http://localhost:9001` with credentials above
2. **Navigate** to the `agentmitra-media` bucket
3. **Browse** to the path: `presentations/7b501e0e-4393-4b5a-8de7-25fe384e91da/2025/11/`
4. **Click** on the file `b600120f-0ccb-4197-b288-2c876e05c0a0.jpeg` to view/download

### 5. File Details

- **File Name:** `Buy-Online-Page1.jpeg`
- **File Size:** 41,450 bytes (~40.5 KB)
- **MIME Type:** `image/jpeg`
- **Media Type:** `image`
- **Storage Provider:** `minio`
- **Upload Date:** 2025-11-26

### 6. Direct File URL

The file can also be accessed directly via:
```
http://localhost:9000/agentmitra-media/presentations/7b501e0e-4393-4b5a-8de7-25fe384e91da/2025/11/b600120f-0ccb-4197-b288-2c876e05c0a0.jpeg
```

> **Note:** This requires the bucket to have public read access configured.

### 7. MinIO API Endpoints

- **API Endpoint:** `http://localhost:9000` (for programmatic access)
- **Console UI:** `http://localhost:9001` (for web interface)

### 8. Security Note

⚠️ **Important:** The default credentials (`minioadmin:minioadmin`) should be changed in production. Update the environment variables in `docker-compose.prod.yml`:

```yaml
environment:
  MINIO_ROOT_USER: your-secure-username
  MINIO_ROOT_PASSWORD: your-secure-password
```

