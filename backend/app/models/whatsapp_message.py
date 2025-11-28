"""
WhatsApp Message Model
======================

Database model for storing WhatsApp messages and interactions.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.models.base import Base, TimestampMixin


class WhatsAppMessage(Base, TimestampMixin):
    """WhatsApp message model"""

    __tablename__ = "whatsapp_messages"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    message_id = Column(String(255), unique=True, index=True, nullable=False)  # WhatsApp message ID
    to_phone = Column(String(20), nullable=False, index=True)
    from_phone = Column(String(20), nullable=False, index=True)
    message_type = Column(String(50), nullable=False)  # text, template, interactive, etc.
    content = Column(JSON, nullable=False)  # Message content (JSON)
    status = Column(String(50), nullable=False, default="sent")  # sent, delivered, read, failed
    direction = Column(String(20), nullable=False)  # inbound, outbound
    template_name = Column(String(255), nullable=True)
    timestamp = Column(DateTime(timezone=True), nullable=True)
    metadata = Column(JSON, nullable=True)  # Additional metadata

    def __repr__(self):
        return f"<WhatsAppMessage(id={self.id}, message_id={self.message_id}, status={self.status})>"
