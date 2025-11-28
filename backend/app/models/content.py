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


class VideoTutorial(Base, TimestampMixin, AuditMixin):
    """Video tutorial model for educational content"""

    __tablename__ = "video_tutorials"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    video_id = Column(String(255), unique=True, index=True, nullable=False)

    # Content reference
    content_id = Column(UUID(as_uuid=True), ForeignKey("content.id"), nullable=False, index=True)

    # Video metadata
    youtube_video_id = Column(String(50), nullable=True, index=True)
    youtube_url = Column(String(500), nullable=True)
    title = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)
    duration_seconds = Column(Integer, nullable=True)
    language = Column(String(10), default="en")  # ISO language code

    # Categorization
    category = Column(String(100), nullable=False, index=True)
    sub_category = Column(String(100), nullable=True)
    difficulty_level = Column(String(20), default="beginner")  # beginner, intermediate, advanced
    target_audience = Column(JSON, nullable=True)  # List of audience types
    policy_types = Column(JSON, nullable=True)  # Related policy types

    # Agent information
    agent_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    agent_name = Column(String(255), nullable=False)

    # Processing and status
    processing_status = Column(String(50), default="pending")  # pending, processing, completed, failed
    youtube_upload_status = Column(String(50), nullable=True)  # uploaded, failed, pending
    transcription_status = Column(String(50), nullable=True)  # completed, processing, failed

    # Analytics
    view_count = Column(Integer, default=0)
    completion_rate = Column(Float, default=0.0)  # Percentage who watch to end
    average_watch_time = Column(Float, nullable=True)  # Average watch time in seconds
    engagement_score = Column(Float, default=0.0)  # Calculated engagement score
    rating = Column(Float, nullable=True)  # Average user rating
    rating_count = Column(Integer, default=0)

    # Learning path integration
    is_featured = Column(Boolean, default=False)
    learning_path_order = Column(Integer, nullable=True)
    prerequisites = Column(JSON, nullable=True)  # List of prerequisite video IDs

    # Multi-language support
    original_language = Column(String(10), default="en")
    available_languages = Column(JSON, nullable=True)  # List of available languages
    translation_status = Column(String(50), nullable=True)  # pending, processing, completed

    # Search and discovery
    search_tags = Column(JSON, nullable=True)  # Auto-generated search tags
    keywords = Column(JSON, nullable=True)  # Important keywords for search

    # Relationships (would be defined if we had related models)
    # agent = relationship("Agent", back_populates="video_tutorials")
    # content = relationship("Content", back_populates="video_tutorial")

    def __repr__(self):
        return f"<VideoTutorial(id={self.id}, video_id={self.video_id}, title={self.title[:30]}...)>"


class VideoCategory(Base, TimestampMixin):
    """Video category and taxonomy model"""

    __tablename__ = "video_categories"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    category_id = Column(String(100), unique=True, nullable=False, index=True)
    name = Column(String(200), nullable=False)
    description = Column(Text, nullable=True)
    parent_category_id = Column(UUID(as_uuid=True), ForeignKey("video_categories.id"), nullable=True)

    # Hierarchy and organization
    level = Column(Integer, default=1)  # 1 = top level, 2 = subcategory, etc.
    sort_order = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)

    # Statistics
    video_count = Column(Integer, default=0)
    total_views = Column(Integer, default=0)

    # Metadata
    icon_name = Column(String(100), nullable=True)  # Icon identifier for UI
    color_code = Column(String(7), nullable=True)  # Hex color code

    def __repr__(self):
        return f"<VideoCategory(id={self.id}, category_id={self.category_id}, name={self.name})>"


class VideoProgress(Base, TimestampMixin):
    """User video watching progress model"""

    __tablename__ = "video_progress"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    video_id = Column(UUID(as_uuid=True), ForeignKey("video_tutorials.id"), nullable=False, index=True)

    # Progress tracking
    watch_time_seconds = Column(Float, default=0.0)  # Total time watched
    completion_percentage = Column(Float, default=0.0)  # 0-100
    is_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    # Engagement metrics
    play_count = Column(Integer, default=0)  # How many times started
    last_watched_at = Column(DateTime(timezone=True), nullable=True)
    watch_sessions = Column(JSON, nullable=True)  # List of watch sessions with timestamps

    # Learning path context
    learning_path_id = Column(String(255), nullable=True)
    next_recommended_video_id = Column(UUID(as_uuid=True), nullable=True)

    # User feedback
    user_rating = Column(Integer, nullable=True)  # 1-5 stars
    is_bookmarked = Column(Boolean, default=False)
    notes = Column(Text, nullable=True)  # User notes about the video

    def __repr__(self):
        return f"<VideoProgress(user_id={self.user_id}, video_id={self.video_id}, completion={self.completion_percentage}%)>"


class VideoRecommendation(Base, TimestampMixin):
    """Video recommendation model for personalized suggestions"""

    __tablename__ = "video_recommendations"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    user_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    video_id = Column(UUID(as_uuid=True), ForeignKey("video_tutorials.id"), nullable=False, index=True)

    # Recommendation context
    recommendation_type = Column(String(50), nullable=False)  # intent_based, learning_path, similar_content, etc.
    trigger_source = Column(String(50), nullable=True)  # chatbot, dashboard, search, etc.
    trigger_query = Column(String(500), nullable=True)  # Original query that triggered recommendation

    # Scoring and ranking
    relevance_score = Column(Float, default=0.0)  # 0-1 relevance score
    confidence_score = Column(Float, default=0.0)  # 0-1 confidence in recommendation
    ranking_position = Column(Integer, nullable=True)  # Position in recommendation list

    # Contextual factors
    intent_match_score = Column(Float, default=0.0)
    learning_history_score = Column(Float, default=0.0)
    policy_context_score = Column(Float, default=0.0)
    agent_expertise_score = Column(Float, default=0.0)
    content_freshness_score = Column(Float, default=0.0)

    # User interaction
    was_viewed = Column(Boolean, default=False)
    viewed_at = Column(DateTime(timezone=True), nullable=True)
    was_completed = Column(Boolean, default=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    user_feedback = Column(String(20), nullable=True)  # positive, negative, neutral

    # Metadata
    recommendation_context = Column(JSON, nullable=True)  # Additional context data
    expires_at = Column(DateTime(timezone=True), nullable=True)  # When recommendation expires

    def __repr__(self):
        return f"<VideoRecommendation(user_id={self.user_id}, video_id={self.video_id}, score={self.relevance_score})>"


class LearningPath(Base, TimestampMixin):
    """Learning path model for structured video sequences"""

    __tablename__ = "learning_paths"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    path_id = Column(String(255), unique=True, nullable=False, index=True)
    title = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)

    # Path configuration
    target_audience = Column(JSON, nullable=True)  # List of audience types
    policy_types = Column(JSON, nullable=True)  # Related policy types
    difficulty_level = Column(String(20), default="beginner")
    estimated_duration_hours = Column(Float, nullable=True)

    # Path structure
    video_sequence = Column(JSON, nullable=True)  # Ordered list of video IDs with metadata
    prerequisites = Column(JSON, nullable=True)  # Required knowledge or videos

    # Status and analytics
    is_active = Column(Boolean, default=True)
    total_enrollments = Column(Integer, default=0)
    completion_rate = Column(Float, default=0.0)
    average_completion_days = Column(Float, nullable=True)

    # Agent/creator information
    created_by_agent_id = Column(UUID(as_uuid=True), nullable=False)
    last_updated_by = Column(UUID(as_uuid=True), nullable=False)

    def __repr__(self):
        return f"<LearningPath(id={self.id}, path_id={self.path_id}, title={self.title[:30]}...)>"
