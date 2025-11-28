"""
Data Import Repository
======================

Repository for data import related database operations.
"""

from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, desc

from app.models.data_import import DataImport, ImportJob, CustomerDataMapping


class DataImportRepository:
    """Repository for data import operations"""

    def __init__(self, db: Session):
        self.db = db

    async def get_import_by_id(self, import_id: str) -> Optional[DataImport]:
        """Get import record by ID"""
        return self.db.query(DataImport).filter(
            DataImport.id == import_id
        ).first()

    async def get_imports_by_agent(self, agent_id: str, limit: int = 20, offset: int = 0) -> List[DataImport]:
        """Get import records for an agent"""
        return self.db.query(DataImport).filter(
            DataImport.agent_id == agent_id
        ).order_by(desc(DataImport.created_at)).offset(offset).limit(limit).all()

    async def get_job_by_id(self, job_id: str) -> Optional[ImportJob]:
        """Get import job by ID"""
        return self.db.query(ImportJob).filter(
            ImportJob.id == job_id
        ).first()

    async def get_jobs_by_import(self, import_id: str) -> List[ImportJob]:
        """Get all jobs for an import"""
        return self.db.query(ImportJob).filter(
            ImportJob.import_id == import_id
        ).order_by(desc(ImportJob.created_at)).all()

    async def get_mappings_by_import(self, import_id: str, limit: int = 100, offset: int = 0) -> List[CustomerDataMapping]:
        """Get data mappings for an import"""
        return self.db.query(CustomerDataMapping).filter(
            CustomerDataMapping.import_id == import_id
        ).order_by(CustomerDataMapping.excel_row_number).offset(offset).limit(limit).all()

    async def get_failed_mappings(self, import_id: str) -> List[CustomerDataMapping]:
        """Get failed data mappings for an import"""
        return self.db.query(CustomerDataMapping).filter(
            and_(
                CustomerDataMapping.import_id == import_id,
                CustomerDataMapping.mapping_status == "error"
            )
        ).order_by(CustomerDataMapping.excel_row_number).all()

    async def get_successful_mappings(self, import_id: str) -> List[CustomerDataMapping]:
        """Get successful data mappings for an import"""
        return self.db.query(CustomerDataMapping).filter(
            and_(
                CustomerDataMapping.import_id == import_id,
                CustomerDataMapping.mapping_status == "mapped"
            )
        ).order_by(CustomerDataMapping.excel_row_number).all()

    async def search_imports(
        self,
        agent_id: str,
        status: Optional[str] = None,
        import_type: Optional[str] = None,
        date_from: Optional[str] = None,
        date_to: Optional[str] = None,
        limit: int = 20,
        offset: int = 0
    ) -> List[DataImport]:
        """Search imports with filters"""
        query = self.db.query(DataImport).filter(DataImport.agent_id == agent_id)

        if status:
            query = query.filter(DataImport.status == status)

        if import_type:
            query = query.filter(DataImport.import_type == import_type)

        if date_from:
            query = query.filter(DataImport.created_at >= date_from)

        if date_to:
            query = query.filter(DataImport.created_at <= date_to)

        return query.order_by(desc(DataImport.created_at)).offset(offset).limit(limit).all()

    async def get_import_stats(self, agent_id: str) -> Dict[str, Any]:
        """Get import statistics for an agent"""
        # This would typically use SQL aggregation queries
        # For now, returning basic structure
        imports = self.db.query(DataImport).filter(DataImport.agent_id == agent_id).all()

        total_imports = len(imports)
        completed_imports = len([i for i in imports if i.status == "completed"])
        failed_imports = len([i for i in imports if i.status == "failed"])

        total_records = sum(i.total_records or 0 for i in imports)
        processed_records = sum(i.processed_records or 0 for i in imports)

        return {
            "total_imports": total_imports,
            "completed_imports": completed_imports,
            "failed_imports": failed_imports,
            "pending_imports": total_imports - completed_imports - failed_imports,
            "total_records": total_records,
            "processed_records": processed_records,
            "success_rate": (processed_records / total_records * 100) if total_records > 0 else 0
        }
