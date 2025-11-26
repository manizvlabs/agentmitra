"""
Presentation models - matching lic_schema database structure
"""
from datetime import datetime
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Text, DateTime, DECIMAL
from sqlalchemy.dialects.postgresql import UUID, JSONB, ARRAY
from sqlalchemy.orm import relationship
from .base import Base, TimestampMixin


class Presentation(Base, TimestampMixin):
    """Presentation model matching lic_schema.presentations"""
    __tablename__ = "presentations"
    __table_args__ = {'schema': 'lic_schema'}

    presentation_id = Column(UUID(as_uuid=True), primary_key=True)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(50), nullable=False, default="draft")  # 'draft', 'published', 'archived'
    is_active = Column(Boolean, default=False, nullable=False, index=True)
    
    # Template reference
    template_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.presentation_templates.template_id"), nullable=True)
    template_category = Column(String(100), nullable=True)
    
    # Version control
    version = Column(Integer, default=1, nullable=True)
    parent_presentation_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.presentations.presentation_id"), nullable=True)
    
    # Lifecycle timestamps
    published_at = Column(DateTime, nullable=True)
    archived_at = Column(DateTime, nullable=True)
    
    # Metadata
    tags = Column(ARRAY(Text), nullable=True)
    target_audience = Column(ARRAY(Text), nullable=True)
    language = Column(String(10), default='en', nullable=True)
    
    # Analytics summary
    total_views = Column(Integer, default=0, nullable=True)
    total_shares = Column(Integer, default=0, nullable=True)
    total_cta_clicks = Column(Integer, default=0, nullable=True)
    
    # Audit fields
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)
    published_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)
    
    # Relationships
    slides = relationship("Slide", back_populates="presentation", cascade="all, delete-orphan", order_by="Slide.slide_order")
    template = relationship("PresentationTemplate", back_populates="presentations")
    agent = relationship("Agent", back_populates="presentations")

    def __repr__(self):
        return f"<Presentation(presentation_id={self.presentation_id}, name={self.name}, status={self.status})>"


class Slide(Base, TimestampMixin):
    """Slide model matching lic_schema.presentation_slides"""
    __tablename__ = "presentation_slides"
    __table_args__ = {'schema': 'lic_schema'}

    slide_id = Column(UUID(as_uuid=True), primary_key=True)
    presentation_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.presentations.presentation_id", ondelete="CASCADE"), nullable=False, index=True)
    slide_order = Column(Integer, nullable=False)
    slide_type = Column(String(50), nullable=False)  # 'image', 'video', 'text'
    
    # Media content
    media_url = Column(String(500), nullable=True)
    media_type = Column(String(50), nullable=True)
    thumbnail_url = Column(String(500), nullable=True)
    media_storage_key = Column(String(500), nullable=True)
    
    # Text content
    title = Column(Text, nullable=True)
    subtitle = Column(Text, nullable=True)
    description = Column(Text, nullable=True)
    
    # Styling
    text_color = Column(String(7), default="#FFFFFF", nullable=False)
    background_color = Column(String(7), default="#000000", nullable=False)
    overlay_opacity = Column(DECIMAL(3, 2), default=0.5, nullable=True)
    layout = Column(String(50), default="centered", nullable=False)
    
    # Display settings
    duration = Column(Integer, default=4, nullable=False)  # seconds
    transition_effect = Column(String(50), default='fade', nullable=True)
    
    # CTA and branding
    cta_button = Column(JSONB, nullable=True)
    agent_branding = Column(JSONB, nullable=True)
    
    # Relationships
    presentation = relationship("Presentation", back_populates="slides")

    def __repr__(self):
        return f"<Slide(slide_id={self.slide_id}, slide_order={self.slide_order}, slide_type={self.slide_type})>"


class PresentationTemplate(Base, TimestampMixin):
    """Presentation template model matching lic_schema.presentation_templates"""
    __tablename__ = "presentation_templates"
    __table_args__ = {'schema': 'lic_schema'}

    template_id = Column(UUID(as_uuid=True), primary_key=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(100), nullable=False)
    
    # Template content
    slides = Column(JSONB, nullable=False)  # Array of slide objects
    
    # Template metadata
    is_default = Column(Boolean, default=False, nullable=True)
    is_public = Column(Boolean, default=False, nullable=False)
    is_system_template = Column(Boolean, default=False, nullable=True)
    
    # Usage tracking
    usage_count = Column(Integer, default=0, nullable=True)
    average_rating = Column(DECIMAL(3, 2), nullable=True)
    total_ratings = Column(Integer, default=0, nullable=True)
    
    # Preview
    preview_image_url = Column(String(500), nullable=True)
    preview_video_url = Column(String(500), nullable=True)
    
    # Availability
    status = Column(String(50), default='active', nullable=True)
    available_from = Column(DateTime, nullable=True)
    available_until = Column(DateTime, nullable=True)
    
    # Audit fields
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)
    
    # Relationships
    presentations = relationship("Presentation", back_populates="template")

    @property
    def thumbnail_url(self):
        """Get thumbnail URL (alias for preview_image_url)"""
        return self.preview_image_url

    def __repr__(self):
        return f"<PresentationTemplate(template_id={self.template_id}, name={self.name})>"


class PresentationMedia(Base, TimestampMixin):
    """Presentation media model matching lic_schema.presentation_media"""
    __tablename__ = "presentation_media"
    __table_args__ = {'schema': 'lic_schema'}

    media_id = Column(UUID(as_uuid=True), primary_key=True)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("lic_schema.agents.agent_id"), nullable=False, index=True)
    
    # Media details
    media_type = Column(String(50), nullable=False)  # 'image', 'video'
    mime_type = Column(String(100), nullable=True)
    file_name = Column(String(255), nullable=True)
    file_size_bytes = Column(Integer, nullable=True)
    
    # Storage locations
    storage_provider = Column(String(50), default='minio', nullable=False)
    storage_key = Column(String(500), nullable=False)
    media_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500), nullable=True)
    
    # Media metadata
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    duration_seconds = Column(Integer, nullable=True)
    file_hash = Column(String(64), nullable=True)
    
    # Usage tracking
    usage_count = Column(Integer, default=0, nullable=False)
    last_used_at = Column(DateTime, nullable=True)
    
    # Status
    status = Column(String(50), default='active', nullable=False)
    is_optimized = Column(Boolean, default=False, nullable=False)
    
    uploaded_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    agent = relationship("Agent", back_populates="presentation_media")

    def __repr__(self):
        return f"<PresentationMedia(media_id={self.media_id}, media_type={self.media_type}, storage_key={self.storage_key})>"
