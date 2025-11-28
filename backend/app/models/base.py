"""
Base model class for all database models
"""
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, DateTime, func, MetaData, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

# Configure metadata with default schema
# All models will use lic_schema unless explicitly overridden
metadata = MetaData(schema="lic_schema")

# Create Base with configure=False to prevent automatic mapper configuration
# Mappers will be configured explicitly after all models are imported
Base = declarative_base(metadata=metadata)


class TimestampMixin:
    """Mixin for created_at and updated_at timestamps"""
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)


class AuditMixin:
    """Mixin for audit fields like created_by, updated_by"""
    created_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)
    updated_by = Column(UUID(as_uuid=True), ForeignKey("lic_schema.users.user_id"), nullable=True)

