"""
WhatsApp Template Model
=======================

Database model for storing WhatsApp message templates.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, JSON, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.models.base import Base, TimestampMixin


class WhatsAppTemplate(Base, TimestampMixin):
    """WhatsApp template model"""

    __tablename__ = "whatsapp_templates"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    template_id = Column(String(255), unique=True, index=True, nullable=False)  # WhatsApp template ID
    name = Column(String(255), nullable=False, index=True)
    category = Column(String(100), nullable=False)  # marketing, transactional, otp, etc.
    language = Column(String(10), nullable=False, default="en")  # ISO language code
    content = Column(Text, nullable=False)  # Template content
    variables = Column(JSON, nullable=True)  # List of variable names
    status = Column(String(50), nullable=False, default="pending")  # pending, approved, rejected
    is_active = Column(Boolean, default=True)
    rejection_reason = Column(Text, nullable=True)

    def __repr__(self):
        return f"<WhatsAppTemplate(id={self.id}, name={self.name}, status={self.status})>"
