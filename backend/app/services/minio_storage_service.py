"""
MinIO Storage Service for media file uploads
Handles file uploads to MinIO object storage
"""
import os
import hashlib
import uuid
from typing import Optional, Tuple
from datetime import datetime, timedelta
from minio import Minio
from minio.error import S3Error
from fastapi import UploadFile
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class MinIOStorageService:
    """Service for handling file uploads to MinIO"""
    
    def __init__(self):
        """Initialize MinIO client"""
        self.endpoint = os.getenv("MINIO_ENDPOINT", "localhost:9000")
        self.access_key = os.getenv("MINIO_ACCESS_KEY", "minioadmin")
        self.secret_key = os.getenv("MINIO_SECRET_KEY", "minioadmin")
        self.bucket_name = os.getenv("MINIO_BUCKET_NAME", "agentmitra-media")
        self.use_ssl = os.getenv("MINIO_USE_SSL", "false").lower() == "true"
        self.cdn_base_url = os.getenv("MINIO_CDN_BASE_URL", f"http://{self.endpoint}/{self.bucket_name}")
        
        try:
            self.client = Minio(
                self.endpoint,
                access_key=self.access_key,
                secret_key=self.secret_key,
                secure=self.use_ssl
            )
            # Ensure bucket exists
            self._ensure_bucket_exists()
            logger.info(f"MinIO client initialized: endpoint={self.endpoint}, bucket={self.bucket_name}")
        except Exception as e:
            logger.error(f"Failed to initialize MinIO client: {e}")
            raise
    
    def _ensure_bucket_exists(self):
        """Ensure the bucket exists, create if it doesn't"""
        try:
            if not self.client.bucket_exists(self.bucket_name):
                self.client.make_bucket(self.bucket_name)
                logger.info(f"Created MinIO bucket: {self.bucket_name}")
        except S3Error as e:
            logger.error(f"Error ensuring bucket exists: {e}")
            raise
    
    def _generate_storage_key(self, agent_id: str, file_name: str, folder: str = "presentations") -> str:
        """Generate a unique storage key for the file"""
        # Extract file extension
        file_ext = os.path.splitext(file_name)[1] or ""
        # Generate unique filename
        unique_id = str(uuid.uuid4())
        # Create path: folder/agent_id/YYYY/MM/unique_id.ext
        now = datetime.utcnow()
        path = f"{folder}/{agent_id}/{now.year}/{now.month:02d}/{unique_id}{file_ext}"
        return path
    
    def _calculate_file_hash(self, file_data: bytes) -> str:
        """Calculate SHA-256 hash of file data"""
        return hashlib.sha256(file_data).hexdigest()
    
    async def upload_file(
        self,
        file: UploadFile,
        agent_id: str,
        folder: str = "presentations"
    ) -> Tuple[str, str, str]:
        """
        Upload a file to MinIO
        
        Returns:
            Tuple of (storage_key, media_url, file_hash)
        """
        try:
            # Read file data
            file_data = await file.read()
            file_size = len(file_data)
            
            # Generate storage key
            storage_key = self._generate_storage_key(agent_id, file.filename or "file", folder)
            
            # Calculate file hash
            file_hash = self._calculate_file_hash(file_data)
            
            # Upload to MinIO
            # Create BytesIO from file data for MinIO
            from io import BytesIO
            file_stream = BytesIO(file_data)
            self.client.put_object(
                bucket_name=self.bucket_name,
                object_name=storage_key,
                data=file_stream,
                length=file_size,
                content_type=file.content_type or "application/octet-stream"
            )
            
            # Generate public URL
            media_url = f"{self.cdn_base_url}/{storage_key}"
            
            logger.info(f"File uploaded successfully: {storage_key}, size={file_size} bytes")
            
            return storage_key, media_url, file_hash
            
        except S3Error as e:
            logger.error(f"MinIO S3Error during upload: {e}")
            raise Exception(f"Failed to upload file to storage: {str(e)}")
        except Exception as e:
            logger.error(f"Error uploading file: {e}")
            raise Exception(f"Failed to upload file: {str(e)}")
    
    async def delete_file(self, storage_key: str) -> bool:
        """Delete a file from MinIO"""
        try:
            self.client.remove_object(self.bucket_name, storage_key)
            logger.info(f"File deleted successfully: {storage_key}")
            return True
        except S3Error as e:
            logger.error(f"MinIO S3Error during delete: {e}")
            return False
        except Exception as e:
            logger.error(f"Error deleting file: {e}")
            return False
    
    def get_presigned_url(self, storage_key: str, expires_in_hours: int = 24) -> str:
        """Generate a presigned URL for temporary access"""
        try:
            expires = timedelta(hours=expires_in_hours)
            url = self.client.presigned_get_object(
                bucket_name=self.bucket_name,
                object_name=storage_key,
                expires=expires
            )
            return url
        except Exception as e:
            logger.error(f"Error generating presigned URL: {e}")
            raise


# Global instance
_minio_service: Optional[MinIOStorageService] = None


def get_minio_service() -> MinIOStorageService:
    """Get or create MinIO storage service instance"""
    global _minio_service
    if _minio_service is None:
        _minio_service = MinIOStorageService()
    return _minio_service

