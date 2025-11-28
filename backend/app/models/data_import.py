"""
Data Import Models
==================

Database models for data import functionality including Excel imports,
background jobs, and data mapping.
"""

from sqlalchemy import Column, String, Integer, DateTime, Text, ForeignKey, JSON, BigInteger
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from app.db.base import Base, TimestampMixin, AuditMixin


class DataImport(Base, TimestampMixin, AuditMixin):
    """Data import record model"""

    __tablename__ = "data_imports"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    agent_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    file_name = Column(String(255), nullable=False)
    file_path = Column(Text, nullable=False)
    file_size_bytes = Column(BigInteger, nullable=False)
    import_type = Column(String(100), nullable=False)  # customer_data, policy_data, etc.
    status = Column(String(50), nullable=False, default="pending")  # pending, processing, completed, failed

    total_records = Column(Integer, nullable=True)
    processed_records = Column(Integer, nullable=False, default=0)
    error_records = Column(Integer, nullable=False, default=0)

    processing_started_at = Column(DateTime(timezone=True), nullable=True)
    processing_completed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    jobs = relationship("ImportJob", back_populates="data_import")
    mappings = relationship("CustomerDataMapping", back_populates="data_import")

    def __repr__(self):
        return f"<DataImport(id={self.id}, agent_id={self.agent_id}, status={self.status})>"


class ImportJob(Base, TimestampMixin):
    """Background job for data import processing"""

    __tablename__ = "import_jobs"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    import_id = Column(UUID(as_uuid=True), ForeignKey("data_imports.id"), nullable=False, index=True)
    job_type = Column(String(100), nullable=False)  # process_data, validate_data, etc.
    priority = Column(Integer, nullable=False, default=1)
    status = Column(String(50), nullable=False, default="queued")  # queued, processing, completed, failed

    job_data = Column(JSON, nullable=False)  # Job parameters and data
    error_message = Column(Text, nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    data_import = relationship("DataImport", back_populates="jobs")

    def __repr__(self):
        return f"<ImportJob(id={self.id}, import_id={self.import_id}, status={self.status})>"


class CustomerDataMapping(Base, TimestampMixin):
    """Customer data mapping from Excel to database"""

    __tablename__ = "customer_data_mappings"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    import_id = Column(UUID(as_uuid=True), ForeignKey("data_imports.id"), nullable=False, index=True)

    excel_row_number = Column(Integer, nullable=False)
    customer_name = Column(String(255), nullable=True)
    phone_number = Column(String(20), nullable=True, index=True)
    email = Column(String(255), nullable=True, index=True)
    policy_number = Column(String(100), nullable=True, index=True)

    raw_excel_data = Column(JSON, nullable=False)  # Original Excel row data
    mapping_status = Column(String(50), nullable=False, default="pending")  # pending, mapped, error
    validation_errors = Column(JSON, nullable=True)  # List of validation errors
    created_customer_id = Column(UUID(as_uuid=True), nullable=True)  # ID of created customer

    # Relationships
    data_import = relationship("DataImport", back_populates="mappings")

    def __repr__(self):
        return f"<CustomerDataMapping(id={self.id}, row={self.excel_row_number}, status={self.mapping_status})>"


class DataSyncStatus(Base, TimestampMixin):
    """Data synchronization status tracking"""

    __tablename__ = "data_sync_status"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    agent_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    sync_type = Column(String(100), nullable=False)  # excel_import, api_sync, manual_update
    status = Column(String(50), nullable=False, default="running")  # running, completed, failed

    records_processed = Column(Integer, nullable=False, default=0)
    records_updated = Column(Integer, nullable=False, default=0)
    records_created = Column(Integer, nullable=False, default=0)
    records_failed = Column(Integer, nullable=False, default=0)

    error_message = Column(Text, nullable=True)
    sync_metadata = Column(JSON, nullable=True)  # Additional sync information

    started_at = Column(DateTime(timezone=True), nullable=False, default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)

    def __repr__(self):
        return f"<DataSyncStatus(id={self.id}, agent_id={self.agent_id}, status={self.status})>"
