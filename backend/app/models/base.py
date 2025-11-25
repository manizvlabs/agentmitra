"""
Base model class for all database models
"""
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, DateTime, func, MetaData

# Configure metadata to not check foreign keys at import time
# Foreign keys are managed by Flyway migrations, not SQLAlchemy
metadata = MetaData()
Base = declarative_base(metadata=metadata)


class TimestampMixin:
    """Mixin for created_at and updated_at timestamps"""
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)

