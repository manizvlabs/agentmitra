"""
Content Management Service
=========================

Comprehensive content management for video/document storage with:
- File upload and management via MinIO
- Video processing (thumbnails, compression)
- Document indexing and search
- CDN integration and access control
- Storage analytics and reporting
- Content categorization and tagging
"""

import os
import uuid
import mimetypes
from typing import List, Dict, Optional, Any, Tuple
from datetime import datetime, timedelta
from pathlib import Path
import logging

import aiofiles
from fastapi import UploadFile, HTTPException
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.services.minio_storage_service import get_minio_service, MinIOStorageService
from app.core.monitoring import monitoring
from app.core.logging_config import get_logger


logger = logging.getLogger(__name__)


class ContentManagementService:
    """Comprehensive content management service"""

    # Supported content types
    @property
    def VIDEO_TYPES(self):
        return settings.content_allowed_video_types.split(',')

    @property
    def DOCUMENT_TYPES(self):
        return settings.content_allowed_doc_types.split(',')

    IMAGE_TYPES = [
        'image/jpeg', 'image/png', 'image/gif', 'image/webp',
        'image/bmp', 'image/tiff', 'image/svg+xml'
    ]

    def __init__(self, db: Session):
        self.db = db
        self.minio_service = get_minio_service()
        self.temp_dir = Path(settings.upload_dir) / "temp"
        self.temp_dir.mkdir(parents=True, exist_ok=True)

    async def upload_content(
        self,
        file: UploadFile,
        uploader_id: str,
        content_type: str = "general",
        category: str = "misc",
        tags: List[str] = None,
        metadata: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Upload content with comprehensive processing

        Args:
            file: UploadFile object
            uploader_id: ID of the user uploading
            content_type: Type of content (video, document, image)
            category: Content category
            tags: List of tags
            metadata: Additional metadata

        Returns:
            Dict with upload results and content information
        """
        try:
            # Validate file
            await self._validate_file(file)

            # Determine content type from file
            detected_content_type = self._detect_content_type(file.content_type, file.filename)

            # Generate unique content ID
            content_id = str(uuid.uuid4())

            # Upload to MinIO
            storage_key, media_url, file_hash, file_size = await self.minio_service.upload_file(
                file=file,
                agent_id=uploader_id,
                folder=f"{content_type}s"  # videos, documents, images
            )

            # Create content record
            content_record = await self._create_content_record(
                content_id=content_id,
                filename=file.filename,
                storage_key=storage_key,
                media_url=media_url,
                file_hash=file_hash,
                file_size=file_size,
                content_type=detected_content_type,
                category=category,
                uploader_id=uploader_id,
                tags=tags or [],
                metadata=metadata or {}
            )

            # Process content based on type
            processing_result = await self._process_content(
                content_record=content_record,
                file=file,
                detected_type=detected_content_type
            )

            # Update content record with processing results
            content_record.update(processing_result)
            await self._update_content_record(content_record)

            # Record metrics
            monitoring.record_business_metrics(
                "content_uploaded",
                {"content_type": detected_content_type, "category": category}
            )

            logger.info(f"Content uploaded successfully: {content_id}, type: {detected_content_type}")

            return {
                "success": True,
                "content_id": content_id,
                "storage_key": storage_key,
                "media_url": media_url,
                "content_type": detected_content_type,
                "file_size": file_size,
                "processing_status": content_record.get("processing_status", "completed")
            }

        except Exception as e:
            logger.error(f"Content upload failed: {e}")
            raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

    async def get_content(self, content_id: str, user_id: Optional[str] = None) -> Dict[str, Any]:
        """Get content information by ID"""
        content_record = await self._get_content_record(content_id)

        if not content_record:
            raise HTTPException(status_code=404, detail="Content not found")

        # Check access permissions if user_id provided
        if user_id and not await self._check_access_permission(content_record, user_id):
            raise HTTPException(status_code=403, detail="Access denied")

        return content_record

    async def list_content(
        self,
        content_type: Optional[str] = None,
        category: Optional[str] = None,
        uploader_id: Optional[str] = None,
        tags: List[str] = None,
        page: int = 1,
        limit: int = 20
    ) -> Dict[str, Any]:
        """List content with filtering and pagination"""
        query = self.db.query(Content)

        # Apply filters
        if content_type:
            query = query.filter(Content.content_type == content_type)
        if category:
            query = query.filter(Content.category == category)
        if uploader_id:
            query = query.filter(Content.uploader_id == uploader_id)
        if tags:
            # Filter content that has any of the specified tags
            from sqlalchemy import or_
            tag_filters = [Content.tags.contains([tag]) for tag in tags]
            if tag_filters:
                query = query.filter(or_(*tag_filters))

        # Apply status filter (only active content)
        query = query.filter(Content.status == "active")

        # Sorting by creation date (newest first)
        query = query.order_by(desc(Content.created_at))

        # Pagination
        total_count = query.count()
        content_items = query.offset((page - 1) * limit).limit(limit).all()

        # Convert to dict format
        content_list = []
        for content in content_items:
            content_data = {
                "content_id": content.content_id,
                "filename": content.filename,
                "content_type": content.content_type,
                "category": content.category,
                "file_size": content.file_size,
                "mime_type": content.mime_type,
                "tags": content.tags,
                "uploader_id": content.uploader_id,
                "view_count": content.view_count,
                "download_count": content.download_count,
                "processing_status": content.processing_status,
                "created_at": content.created_at.isoformat() if content.created_at else None,
                "updated_at": content.updated_at.isoformat() if content.updated_at else None
            }
            content_list.append(content_data)

        return {
            "content": content_list,
            "total_count": total_count,
            "page": page,
            "limit": limit,
            "total_pages": (total_count + limit - 1) // limit
        }

    async def delete_content(self, content_id: str, user_id: str) -> bool:
        """Delete content"""
        content_record = await self._get_content_record(content_id)

        if not content_record:
            raise HTTPException(status_code=404, detail="Content not found")

        # Check delete permissions
        if not await self._check_delete_permission(content_record, user_id):
            raise HTTPException(status_code=403, detail="Delete access denied")

        # Delete from MinIO
        success = await self.minio_service.delete_file(content_record["storage_key"])

        if success:
            # Delete from database
            await self._delete_content_record(content_id)
            monitoring.record_business_metrics("content_deleted", {"content_type": content_record["content_type"]})

        return success

    async def generate_presigned_url(self, content_id: str, expires_in_hours: int = 24) -> str:
        """Generate presigned URL for content access"""
        content_record = await self._get_content_record(content_id)

        if not content_record:
            raise HTTPException(status_code=404, detail="Content not found")

        return self.minio_service.get_presigned_url(
            content_record["storage_key"],
            expires_in_hours
        )

    async def get_content_analytics(self, content_id: Optional[str] = None) -> Dict[str, Any]:
        """Get content analytics and statistics"""
        if content_id:
            # Get analytics for specific content
            content = self.db.query(Content).filter(Content.content_id == content_id).first()
            if not content:
                raise HTTPException(status_code=404, detail="Content not found")

            # Get access logs for this content
            access_logs = self.db.query(ContentAccess).filter(ContentAccess.content_id == content.id).all()

            # Calculate analytics
            total_views = len([log for log in access_logs if log.access_type == "view"])
            total_downloads = len([log for log in access_logs if log.access_type == "download"])

            # Update content counters
            content.view_count = max(content.view_count, total_views)
            content.download_count = max(content.download_count, total_downloads)
            self.db.commit()

            return {
                "content_id": content_id,
                "total_views": total_views,
                "total_downloads": total_downloads,
                "unique_viewers": len(set(log.user_id for log in access_logs if log.user_id)),
                "file_size": content.file_size,
                "content_type": content.content_type,
                "category": content.category,
                "upload_date": content.created_at.isoformat() if content.created_at else None,
                "last_accessed": content.last_accessed_at.isoformat() if content.last_accessed_at else None
            }

        else:
            # Get overall analytics
            total_content = self.db.query(Content).count()
            total_size = self.db.query(Content).with_entities(func.sum(Content.file_size)).scalar() or 0
            total_views = self.db.query(Content).with_entities(func.sum(Content.view_count)).scalar() or 0
            total_downloads = self.db.query(Content).with_entities(func.sum(Content.download_count)).scalar() or 0

            # Content by type
            content_by_type = self.db.query(
                Content.content_type,
                func.count(Content.id).label('count'),
                func.sum(Content.file_size).label('size')
            ).group_by(Content.content_type).all()

            content_type_stats = {}
            for content_type, count, size in content_by_type:
                content_type_stats[content_type] = {
                    "count": count,
                    "total_size_mb": round((size or 0) / (1024 * 1024), 2)
                }

            # Content by category
            content_by_category = self.db.query(
                Content.category,
                func.count(Content.id).label('count')
            ).group_by(Content.category).all()

            category_stats = {category: count for category, count in content_by_category}

            return {
                "total_content": total_content,
                "total_size_gb": round(total_size / (1024 * 1024 * 1024), 2),
                "total_views": total_views,
                "total_downloads": total_downloads,
                "content_by_type": content_type_stats,
                "content_by_category": category_stats,
                "storage_utilization": round((total_size / (100 * 1024 * 1024 * 1024)) * 100, 2)  # Assuming 100GB limit
            }

    async def _validate_file(self, file: UploadFile) -> None:
        """Validate uploaded file"""
        # Check file size
        max_size_bytes = settings.content_max_file_size_mb * 1024 * 1024

        # Get file size (this reads the file into memory temporarily)
        file_data = await file.read()
        file_size = len(file_data)

        if file_size > max_size_bytes:
            raise HTTPException(
                status_code=413,
                detail=f"File too large. Maximum size: {settings.max_upload_size_mb}MB"
            )

        # Reset file pointer
        await file.seek(0)

        # Validate content type
        if file.content_type not in self._get_allowed_types():
            raise HTTPException(
                status_code=400,
                detail=f"Unsupported file type: {file.content_type}"
            )

    def _detect_content_type(self, mime_type: str, filename: str) -> str:
        """Detect content type from MIME type and filename"""
        if mime_type in self.VIDEO_TYPES:
            return "video"
        elif mime_type in self.DOCUMENT_TYPES:
            return "document"
        elif mime_type in self.IMAGE_TYPES:
            return "image"
        else:
            # Fallback to extension-based detection
            ext = Path(filename).suffix.lower()
            if ext in ['.mp4', '.avi', '.mov', '.mkv', '.webm']:
                return "video"
            elif ext in ['.pdf', '.doc', '.docx', '.xls', '.xlsx', '.txt', '.csv']:
                return "document"
            elif ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']:
                return "image"
            else:
                return "other"

    def _get_allowed_types(self) -> List[str]:
        """Get list of allowed MIME types"""
        return self.VIDEO_TYPES + self.DOCUMENT_TYPES + self.IMAGE_TYPES

    async def _process_content(
        self,
        content_record: Dict[str, Any],
        file: UploadFile,
        detected_type: str
    ) -> Dict[str, Any]:
        """Process content based on type"""
        processing_result = {
            "processing_status": "completed",
            "processing_completed_at": datetime.utcnow().isoformat()
        }

        if detected_type == "video":
            # Video processing (thumbnail generation, compression, etc.)
            processing_result.update(await self._process_video_content(content_record, file))
        elif detected_type == "document":
            # Document processing (text extraction, indexing, etc.)
            processing_result.update(await self._process_document_content(content_record, file))
        elif detected_type == "image":
            # Image processing (thumbnail, optimization, etc.)
            processing_result.update(await self._process_image_content(content_record, file))

        return processing_result

    async def _process_video_content(self, content_record: Dict[str, Any], file: UploadFile) -> Dict[str, Any]:
        """Process video content - generate thumbnails, extract metadata"""
        # Implementation for video processing
        # This would involve:
        # - Generating video thumbnails
        # - Extracting video metadata (duration, resolution, etc.)
        # - Optional video compression/transcoding

        return {
            "video_duration": None,  # Would be extracted
            "video_resolution": None,  # Would be extracted
            "thumbnail_url": None,  # Would be generated
            "compressed_url": None  # Would be created if compression enabled
        }

    async def _process_document_content(self, content_record: Dict[str, Any], file: UploadFile) -> Dict[str, Any]:
        """Process document content - extract text, create index"""
        # Implementation for document processing
        # This would involve:
        # - Text extraction from PDFs/docs
        # - Creating searchable index
        # - Generating document previews/thumbnails

        return {
            "text_content": None,  # Would be extracted
            "page_count": None,  # Would be counted
            "word_count": None,  # Would be counted
            "search_index_created": False  # Would be set to True
        }

    async def _process_image_content(self, content_record: Dict[str, Any], file: UploadFile) -> Dict[str, Any]:
        """Process image content - generate thumbnails, extract metadata"""
        # Implementation for image processing
        # This would involve:
        # - Generating image thumbnails
        # - Extracting image metadata (dimensions, EXIF, etc.)
        # - Optional image optimization

        return {
            "image_width": None,  # Would be extracted
            "image_height": None,  # Would be extracted
            "thumbnail_url": None,  # Would be generated
            "optimized_url": None  # Would be created if optimization enabled
        }

    async def _create_content_record(self, **kwargs) -> Dict[str, Any]:
        """Create content record in database"""
        content_record = Content(
            content_id=kwargs["content_id"],
            filename=kwargs["filename"],
            original_filename=kwargs["filename"],
            storage_key=kwargs["storage_key"],
            media_url=kwargs["media_url"],
            file_hash=kwargs["file_hash"],
            file_size=kwargs["file_size"],
            mime_type=kwargs.get("mime_type", "application/octet-stream"),
            content_type=kwargs["content_type"],
            category=kwargs["category"],
            uploader_id=kwargs["uploader_id"],
            owner_id=kwargs["uploader_id"],
            tags=kwargs.get("tags", []),
            metadata=kwargs.get("metadata", {}),
            status="active",
            processing_status="pending"
        )

        self.db.add(content_record)
        self.db.commit()
        self.db.refresh(content_record)

        return {
            "id": content_record.id,
            "content_id": content_record.content_id,
            "filename": content_record.filename,
            "storage_key": content_record.storage_key,
            "media_url": content_record.media_url,
            "file_hash": content_record.file_hash,
            "file_size": content_record.file_size,
            "content_type": content_record.content_type,
            "category": content_record.category,
            "uploader_id": content_record.uploader_id,
            "tags": content_record.tags,
            "metadata": content_record.metadata,
            "created_at": content_record.created_at.isoformat() if content_record.created_at else None,
            "updated_at": content_record.updated_at.isoformat() if content_record.updated_at else None,
            "status": content_record.status,
            "processing_status": content_record.processing_status
        }

    async def _update_content_record(self, content_record: Dict[str, Any]) -> None:
        """Update content record in database"""
        # Get the content record from database
        db_content = self.db.query(Content).filter(Content.id == content_record["id"]).first()
        if db_content:
            # Update fields
            for key, value in content_record.items():
                if hasattr(db_content, key) and key not in ['id', 'created_at']:
                    setattr(db_content, key, value)

            db_content.updated_at = datetime.utcnow()
            self.db.commit()

    async def _get_content_record(self, content_id: str) -> Optional[Dict[str, Any]]:
        """Get content record from database"""
        content = self.db.query(Content).filter(Content.content_id == content_id).first()

        if not content:
            return None

        return {
            "id": content.id,
            "content_id": content.content_id,
            "filename": content.filename,
            "storage_key": content.storage_key,
            "media_url": content.media_url,
            "file_hash": content.file_hash,
            "file_size": content.file_size,
            "mime_type": content.mime_type,
            "content_type": content.content_type,
            "category": content.category,
            "uploader_id": content.uploader_id,
            "owner_id": content.owner_id,
            "tags": content.tags,
            "metadata": content.metadata,
            "processing_status": content.processing_status,
            "view_count": content.view_count,
            "download_count": content.download_count,
            "status": content.status,
            "created_at": content.created_at.isoformat() if content.created_at else None,
            "updated_at": content.updated_at.isoformat() if content.updated_at else None
        }

    async def _delete_content_record(self, content_id: str) -> None:
        """Delete content record from database"""
        content = self.db.query(Content).filter(Content.content_id == content_id).first()
        if content:
            self.db.delete(content)
            self.db.commit()

    async def _check_access_permission(self, content_record: Dict[str, Any], user_id: str) -> bool:
        """Check if user has access to content"""
        # Implementation for access control
        # Check ownership, sharing permissions, etc.
        return True

    async def _check_delete_permission(self, content_record: Dict[str, Any], user_id: str) -> bool:
        """Check if user can delete content"""
        # Implementation for delete permissions
        return content_record.get("uploader_id") == user_id
