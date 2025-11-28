"""
Content Model
=============

Database models for content management including videos, documents, and media files.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, JSON, BigInteger, Boolean, Float
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.db.base import Base, TimestampMixin, AuditMixin


class Content(Base, TimestampMixin, AuditMixin):
    """Content/media file model"""

    __tablename__ = "content"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    content_id = Column(String(255), unique=True, index=True, nullable=False)

    # File information
    filename = Column(String(255), nullable=False)
    original_filename = Column(String(255), nullable=False)
    storage_key = Column(String(500), nullable=False)
    media_url = Column(String(1000), nullable=False)
    file_hash = Column(String(64), nullable=False, index=True)  # SHA-256 hash
    file_size = Column(BigInteger, nullable=False)  # File size in bytes
    mime_type = Column(String(100), nullable=False)

    # Content classification
    content_type = Column(String(50), nullable=False, index=True)  # video, document, image, other
    category = Column(String(100), nullable=False, index=True)  # presentations, training, marketing, etc.
    sub_category = Column(String(100), nullable=True)

    # Metadata
    tags = Column(JSON, nullable=True)  # List of tags
    metadata = Column(JSON, nullable=True)  # Additional metadata
    description = Column(Text, nullable=True)

    # Processing information
    processing_status = Column(String(50), nullable=False, default="pending")  # pending, processing, completed, failed
    processing_started_at = Column(DateTime(timezone=True), nullable=True)
    processing_completed_at = Column(DateTime(timezone=True), nullable=True)
    processing_error = Column(Text, nullable=True)

    # Video-specific metadata
    video_duration = Column(Float, nullable=True)  # Duration in seconds
    video_resolution = Column(String(20), nullable=True)  # e.g., "1920x1080"
    video_bitrate = Column(Integer, nullable=True)  # Bitrate in kbps
    video_codec = Column(String(50), nullable=True)

    # Document-specific metadata
    page_count = Column(Integer, nullable=True)
    word_count = Column(Integer, nullable=True)
    text_content = Column(Text, nullable=True)  # Extracted text for search
    document_language = Column(String(10), nullable=True)

    # Image-specific metadata
    image_width = Column(Integer, nullable=True)
    image_height = Column(Integer, nullable=True)
    image_color_depth = Column(Integer, nullable=True)
    image_format = Column(String(20), nullable=True)

    # Access control
    uploader_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    owner_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    is_public = Column(Boolean, default=False)
    allowed_users = Column(JSON, nullable=True)  # List of user IDs with access
    share_token = Column(String(255), nullable=True)  # For public sharing

    # Usage statistics
    view_count = Column(Integer, nullable=False, default=0)
    download_count = Column(Integer, nullable=False, default=0)
    last_accessed_at = Column(DateTime(timezone=True), nullable=True)

    # Status and lifecycle
    status = Column(String(50), nullable=False, default="active")  # active, archived, deleted
    retention_policy = Column(String(50), nullable=True)  # e.g., "90_days", "permanent"
    deletion_date = Column(DateTime(timezone=True), nullable=True)

    # Relationships (would be defined if we had related models)
    # uploader = relationship("User", back_populates="uploaded_content")
    # owner = relationship("User", back_populates="owned_content")

    def __repr__(self):
        return f"<Content(id={self.id}, content_id={self.content_id}, type={self.content_type})>"


class ContentAccess(Base, TimestampMixin):
    """Content access log model"""

    __tablename__ = "content_access"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    content_id = Column(UUID(as_uuid=True), ForeignKey("content.id"), nullable=False, index=True)
    user_id = Column(UUID(as_uuid=True), nullable=True, index=True)
    access_type = Column(String(50), nullable=False)  # view, download, share, etc.
    ip_address = Column(String(45), nullable=True)  # IPv4/IPv6
    user_agent = Column(Text, nullable=True)
    session_id = Column(String(255), nullable=True)
    access_token = Column(String(255), nullable=True)  # For shared links

    def __repr__(self):
        return f"<ContentAccess(id={self.id}, content_id={self.content_id}, access_type={self.access_type})>"


class ContentTag(Base, TimestampMixin):
    """Content tagging model"""

    __tablename__ = "content_tags"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    content_id = Column(UUID(as_uuid=True), ForeignKey("content.id"), nullable=False, index=True)
    tag = Column(String(100), nullable=False, index=True)
    tagged_by = Column(UUID(as_uuid=True), nullable=False)
    confidence_score = Column(Float, nullable=True)  # For AI-generated tags

    def __repr__(self):
        return f"<ContentTag(id={self.id}, content_id={self.content_id}, tag={self.tag})>"


class ContentShare(Base, TimestampMixin):
    """Content sharing model"""

    __tablename__ = "content_shares"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    content_id = Column(UUID(as_uuid=True), ForeignKey("content.id"), nullable=False, index=True)
    share_token = Column(String(255), unique=True, nullable=False, index=True)
    shared_by = Column(UUID(as_uuid=True), nullable=False)
    shared_with = Column(JSON, nullable=True)  # List of user IDs or email addresses
    permissions = Column(JSON, nullable=True)  # view, download, edit, etc.
    expires_at = Column(DateTime(timezone=True), nullable=True)
    max_access_count = Column(Integer, nullable=True)
    access_count = Column(Integer, nullable=False, default=0)
    is_active = Column(Boolean, default=True)

    def __repr__(self):
        return f"<ContentShare(id={self.id}, content_id={self.content_id}, token={self.share_token[:8]}...)>"
