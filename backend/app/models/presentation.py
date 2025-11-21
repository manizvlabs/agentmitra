"""
Presentation models
"""
from sqlalchemy import Column, String, Boolean, Integer, ForeignKey, Text, JSON, DateTime
from sqlalchemy.orm import relationship
from .base import Base, TimestampMixin


class Presentation(Base, TimestampMixin):
    """Presentation model"""
    __tablename__ = "presentations"

    presentation_id = Column(String, primary_key=True)
    agent_id = Column(String, ForeignKey("users.user_id"), nullable=False, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String, nullable=False, default="draft")  # 'draft', 'published', 'archived'
    is_active = Column(Boolean, default=False, nullable=False, index=True)
    template_id = Column(String, ForeignKey("presentation_templates.template_id"), nullable=True)
    tags = Column(JSON, nullable=True)  # Array of strings
    
    # Relationships
    slides = relationship("Slide", back_populates="presentation", cascade="all, delete-orphan", order_by="Slide.slide_order")
    template = relationship("PresentationTemplate", back_populates="presentations")

    def __repr__(self):
        return f"<Presentation(presentation_id={self.presentation_id}, name={self.name}, status={self.status})>"


class Slide(Base, TimestampMixin):
    """Slide model"""
    __tablename__ = "slides"

    slide_id = Column(String, primary_key=True)
    presentation_id = Column(String, ForeignKey("presentations.presentation_id"), nullable=False, index=True)
    slide_order = Column(Integer, nullable=False)
    slide_type = Column(String, nullable=False)  # 'image', 'video', 'text'
    media_url = Column(String, nullable=True)
    thumbnail_url = Column(String, nullable=True)
    title = Column(String, nullable=True)
    subtitle = Column(String, nullable=True)
    text_color = Column(String, default="#FFFFFF", nullable=False)
    background_color = Column(String, default="#000000", nullable=False)
    layout = Column(String, default="centered", nullable=False)  # 'centered', 'top', 'bottom', 'left', 'right'
    duration = Column(Integer, default=4, nullable=False)  # seconds
    cta_button = Column(JSON, nullable=True)  # CTA button configuration
    agent_branding = Column(JSON, nullable=True)  # Agent branding configuration
    
    # Relationships
    presentation = relationship("Presentation", back_populates="slides")

    def __repr__(self):
        return f"<Slide(slide_id={self.slide_id}, slide_order={self.slide_order}, slide_type={self.slide_type})>"


class PresentationTemplate(Base, TimestampMixin):
    """Presentation template model"""
    __tablename__ = "presentation_templates"

    template_id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String, nullable=True)  # 'promotional', 'educational', 'product'
    is_public = Column(Boolean, default=True, nullable=False)
    thumbnail_url = Column(String, nullable=True)
    template_data = Column(JSON, nullable=True)  # Template structure
    
    # Relationships
    presentations = relationship("Presentation", back_populates="template")

    def __repr__(self):
        return f"<PresentationTemplate(template_id={self.template_id}, name={self.name})>"

