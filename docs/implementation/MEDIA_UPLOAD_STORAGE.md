# Media Upload Storage Implementation

## Current Status

The media upload functionality is **partially implemented**:

### Frontend (Flutter)
- ✅ File picker implemented (web: HTML5 FileUploadInputElement)
- ✅ Multipart file upload to backend endpoint
- ✅ Error handling and user feedback
- ✅ Integration with Presentation Editor

### Backend (Python/FastAPI)
- ⚠️ **Endpoint exists but returns mock data**
- ❌ **No actual file storage implemented**
- ❌ **No S3/CDN integration**

## Backend Endpoint

**Location:** `backend/app/api/v1/presentations.py`

**Endpoint:** `POST /api/v1/presentations/media/upload`

**Current Implementation:**
```python
@router.post("/media/upload")
async def upload_media(file: bytes, type: str = "image"):
    """Upload media file (image/video)"""
    # TODO: Implement file upload to S3/CDN
    # For now, return mock response
    import uuid
    media_id = str(uuid.uuid4())[:8]
    
    return {
        "media_url": f"https://cdn.agentmitra.com/presentations/{media_id}.{type}",
        "thumbnail_url": f"https://cdn.agentmitra.com/presentations/thumb_{media_id}.{type}",
        "media_id": media_id
    }
```

## Database Schema

The database table `presentation_media` is already created and ready:

```sql
CREATE TABLE lic_schema.presentation_media (
    media_id UUID PRIMARY KEY,
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    media_type VARCHAR(50) NOT NULL, -- 'image', 'video'
    mime_type VARCHAR(100),
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    storage_provider VARCHAR(50) DEFAULT 's3', -- 's3', 'firebase', 'cdn'
    storage_key VARCHAR(500) NOT NULL, -- S3 key or storage path
    media_url VARCHAR(500) NOT NULL, -- Public CDN URL
    thumbnail_url VARCHAR(500),
    -- ... other fields
);
```

## Required Implementation Steps

### 1. Choose Storage Provider
- **Option A:** Amazon S3 (recommended for production)
- **Option B:** Firebase Storage
- **Option C:** Local file system (for development only)

### 2. Install Required Packages

For S3:
```bash
pip install boto3
```

For Firebase:
```bash
pip install firebase-admin
```

### 3. Configure Storage Credentials

Add to `backend/app/core/config/settings.py`:
```python
class Settings(BaseSettings):
    # S3 Configuration
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    S3_BUCKET_NAME: str = "agentmitra-media"
    CDN_BASE_URL: str = "https://cdn.agentmitra.com"
    
    # Or Firebase Configuration
    FIREBASE_CREDENTIALS_PATH: Optional[str] = None
    FIREBASE_STORAGE_BUCKET: Optional[str] = None
```

### 4. Implement Storage Service

Create `backend/app/services/storage_service.py`:

```python
from abc import ABC, abstractmethod
from typing import BinaryIO, Tuple
import boto3
from botocore.exceptions import ClientError

class StorageService(ABC):
    @abstractmethod
    async def upload_file(
        self, 
        file_data: bytes, 
        file_name: str, 
        content_type: str,
        folder: str = "presentations"
    ) -> Tuple[str, str]:  # Returns (storage_key, public_url)
        pass
    
    @abstractmethod
    async def delete_file(self, storage_key: str) -> bool:
        pass

class S3StorageService(StorageService):
    def __init__(self, bucket_name: str, cdn_base_url: str):
        self.s3_client = boto3.client('s3')
        self.bucket_name = bucket_name
        self.cdn_base_url = cdn_base_url
    
    async def upload_file(
        self, 
        file_data: bytes, 
        file_name: str, 
        content_type: str,
        folder: str = "presentations"
    ) -> Tuple[str, str]:
        import uuid
        file_extension = file_name.split('.')[-1]
        storage_key = f"{folder}/{uuid.uuid4()}.{file_extension}"
        
        try:
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=storage_key,
                Body=file_data,
                ContentType=content_type,
                ACL='public-read'  # Or use CloudFront signed URLs
            )
            
            public_url = f"{self.cdn_base_url}/{storage_key}"
            return storage_key, public_url
        except ClientError as e:
            raise Exception(f"Failed to upload to S3: {e}")
    
    async def delete_file(self, storage_key: str) -> bool:
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=storage_key
            )
            return True
        except ClientError:
            return False
```

### 5. Update Backend Endpoint

Update `backend/app/api/v1/presentations.py`:

```python
from app.services.storage_service import StorageService, S3StorageService
from app.core.config import get_settings

@router.post("/media/upload")
async def upload_media(
    file: UploadFile = File(...),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Upload media file (image/video) to S3/CDN"""
    settings = get_settings()
    
    # Initialize storage service
    storage_service = S3StorageService(
        bucket_name=settings.S3_BUCKET_NAME,
        cdn_base_url=settings.CDN_BASE_URL
    )
    
    # Read file data
    file_data = await file.read()
    file_size = len(file_data)
    
    # Determine media type
    media_type = "image" if file.content_type.startswith("image/") else "video"
    
    # Upload to storage
    storage_key, public_url = await storage_service.upload_file(
        file_data=file_data,
        file_name=file.filename,
        content_type=file.content_type,
        folder=f"presentations/{current_user.agent_id}"
    )
    
    # Save to database
    from app.models.presentation import PresentationMedia
    media = PresentationMedia(
        agent_id=current_user.agent_id,
        media_type=media_type,
        mime_type=file.content_type,
        file_name=file.filename,
        file_size_bytes=file_size,
        storage_provider="s3",
        storage_key=storage_key,
        media_url=public_url,
        status="active"
    )
    db.add(media)
    db.commit()
    
    return {
        "media_id": str(media.media_id),
        "media_url": public_url,
        "thumbnail_url": public_url,  # Generate thumbnail for videos
        "media_type": media_type,
        "file_size": file_size
    }
```

## Frontend Changes Required

**None** - The frontend is already implemented correctly and will work once the backend is updated.

## Testing

1. **Without Storage (Current):**
   - Upload returns mock URL
   - File is not actually stored
   - Works for UI testing only

2. **With Storage (After Implementation):**
   - File uploaded to S3/Firebase
   - Database record created
   - Real URL returned
   - File accessible via CDN

## Security Considerations

1. **File Type Validation:** Only allow image/video MIME types
2. **File Size Limits:** Enforce maximum file sizes (e.g., 10MB for images, 100MB for videos)
3. **Virus Scanning:** Consider adding virus scanning for uploaded files
4. **Access Control:** Ensure files are only accessible by the uploading agent
5. **Signed URLs:** Use CloudFront signed URLs instead of public-read ACL for better security

## Next Steps

1. ✅ Frontend implementation complete
2. ⏳ Configure S3 bucket and credentials
3. ⏳ Implement StorageService
4. ⏳ Update backend endpoint
5. ⏳ Test end-to-end upload flow
6. ⏳ Add thumbnail generation for videos
7. ⏳ Add file cleanup/archival logic

