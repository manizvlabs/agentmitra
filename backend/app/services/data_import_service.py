"""
Data Import Service
===================

This service handles Excel file processing from agent configuration portal including:
- Excel file validation and parsing
- Customer and policy data mapping
- Background job processing and queuing
- Data validation and transformation
- Import status tracking and notifications
- Error handling and retry logic
"""

import asyncio
import uuid
from typing import Dict, List, Optional, Any
from pathlib import Path
import pandas as pd
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
import logging

from app.core.config.settings import settings
from app.models import DataImport, ImportJob, CustomerDataMapping, DataSyncStatus
from app.repositories import DataImportRepository
from app.utils.excel_parser import ExcelParser
from app.utils.data_validator import DataValidator
from app.services.notification_service import NotificationService

logger = logging.getLogger(__name__)


class DataImportService:
    """Service for handling Excel data imports from agent configuration portal"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.import_repo = DataImportRepository(db)
        self.excel_parser = ExcelParser()
        self.data_validator = DataValidator()
        self.notification_service = NotificationService()

    async def process_excel_import(
        self,
        agent_id: str,
        file_path: str,
        import_type: str = "customer_data"
    ) -> Dict[str, Any]:
        """Main entry point for Excel file processing"""

        # 1. Create import record
        import_record = await self._create_import_record(
            agent_id=agent_id,
            file_path=file_path,
            import_type=import_type
        )

        # 2. Validate file
        validation_result = await self._validate_excel_file(file_path)
        if not validation_result["valid"]:
            await self._update_import_status(
                import_record.id,
                "failed",
                error_details={"validation_errors": validation_result["errors"]}
            )
            return {"success": False, "errors": validation_result["errors"]}

        # 3. Parse Excel data
        try:
            parsed_data = await self.excel_parser.parse_excel(file_path)
        except Exception as e:
            logger.error(f"Excel parsing failed: {e}")
            await self._update_import_status(
                import_record.id,
                "failed",
                error_details={"parsing_error": str(e)}
            )
            return {"success": False, "error": f"Failed to parse Excel file: {str(e)}"}

        # 4. Create background job for processing
        job_result = await self._create_background_job(
            import_id=import_record.id,
            job_type="process_data",
            job_data={
                "parsed_data": parsed_data,
                "agent_id": agent_id,
                "import_type": import_type
            }
        )

        # 5. Update import record with job info
        await self._update_import_record(
            import_record.id,
            total_records=len(parsed_data),
            processing_job_id=job_result["job_id"]
        )

        return {
            "success": True,
            "import_id": import_record.id,
            "job_id": job_result["job_id"],
            "total_records": len(parsed_data),
            "message": "Import job queued for processing"
        }

    async def _create_import_record(
        self,
        agent_id: str,
        file_path: str,
        import_type: str
    ) -> DataImport:
        """Create import record in database"""
        file_path_obj = Path(file_path)

        import_record = DataImport(
            id=str(uuid.uuid4()),
            agent_id=agent_id,
            file_name=file_path_obj.name,
            file_path=file_path,
            file_size_bytes=file_path_obj.stat().st_size,
            import_type=import_type,
            status="pending"
        )

        self.db.add(import_record)
        await self.db.commit()
        await self.db.refresh(import_record)

        return import_record

    async def _validate_excel_file(self, file_path: str) -> Dict[str, Any]:
        """Validate Excel file structure and content"""
        try:
            # Check file exists and is readable
            if not Path(file_path).exists():
                return {"valid": False, "errors": ["File does not exist"]}

            # Validate Excel structure
            validation_result = await self.excel_parser.validate_structure(file_path)

            return validation_result

        except Exception as e:
            logger.error(f"File validation failed: {e}")
            return {"valid": False, "errors": [f"Validation failed: {str(e)}"]}

    async def _create_background_job(
        self,
        import_id: str,
        job_type: str,
        job_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Create background job for data processing"""

        # Create job record
        job = ImportJob(
            id=str(uuid.uuid4()),
            import_id=import_id,
            job_type=job_type,
            priority=1,
            status="queued",
            job_data=job_data
        )

        self.db.add(job)
        await self.db.commit()

        # Queue job for processing (this would integrate with Celery/RQ)
        await self._queue_job_for_processing(job.id)

        return {"job_id": job.id, "status": "queued"}

    async def _queue_job_for_processing(self, job_id: str):
        """Queue job for background processing using Celery"""
        # This would integrate with Celery or similar job queue
        # For now, we'll simulate by calling the processing function directly

        # In production, this would be:
        # from ..tasks import process_data_import
        # process_data_import.delay(job_id)

        # For demo purposes, we'll process synchronously
        asyncio.create_task(self._process_job_async(job_id))

    async def _process_job_async(self, job_id: str):
        """Process job asynchronously"""
        try:
            await self._process_data_import_job(job_id)
        except Exception as e:
            logger.error(f"Job processing failed for job {job_id}: {e}")
            await self._update_job_status(job_id, "failed", str(e))

    async def _process_data_import_job(self, job_id: str):
        """Main data processing logic"""

        # Get job details
        job = await self.import_repo.get_job_by_id(job_id)
        if not job:
            raise ValueError(f"Job {job_id} not found")

        # Update job status to processing
        await self._update_job_status(job_id, "processing")

        try:
            # Extract job data
            job_data = job.job_data
            parsed_data = job_data["parsed_data"]
            agent_id = job_data["agent_id"]
            import_type = job_data["import_type"]

            # Process each row
            processed_count = 0
            error_count = 0

            for row_idx, row_data in enumerate(parsed_data):
                try:
                    # Validate row data
                    validation_result = await self.data_validator.validate_row(
                        row_data, import_type
                    )

                    if not validation_result["valid"]:
                        # Create mapping record with errors
                        await self._create_data_mapping_record(
                            import_id=job.import_id,
                            excel_row_number=row_idx + 1,
                            raw_excel_data=row_data,
                            mapping_status="error",
                            validation_errors=validation_result["errors"]
                        )
                        error_count += 1
                        continue

                    # Process valid data
                    await self._process_valid_row(
                        row_data=row_data,
                        agent_id=agent_id,
                        import_type=import_type,
                        import_id=job.import_id,
                        row_number=row_idx + 1
                    )
                    processed_count += 1

                except Exception as e:
                    logger.error(f"Error processing row {row_idx + 1}: {e}")
                    await self._create_data_mapping_record(
                        import_id=job.import_id,
                        excel_row_number=row_idx + 1,
                        raw_excel_data=row_data,
                        mapping_status="error",
                        validation_errors=[str(e)]
                    )
                    error_count += 1

            # Update import record with results
            await self._update_import_record(
                job.import_id,
                processed_records=processed_count,
                error_records=error_count,
                status="completed" if error_count == 0 else "completed_with_errors"
            )

            # Update job status
            await self._update_job_status(job_id, "completed")

            # Send notifications
            await self._send_import_completion_notification(
                agent_id=agent_id,
                import_id=job.import_id,
                processed_count=processed_count,
                error_count=error_count
            )

        except Exception as e:
            logger.error(f"Job processing failed: {e}")
            await self._update_job_status(job_id, "failed", str(e))
            await self._update_import_record(job.import_id, status="failed")
            raise

    async def _process_valid_row(
        self,
        row_data: Dict[str, Any],
        agent_id: str,
        import_type: str,
        import_id: str,
        row_number: int
    ):
        """Process a valid row of data"""

        if import_type == "customer_data":
            # Create or update customer record
            customer_result = await self._create_or_update_customer(
                row_data=row_data,
                agent_id=agent_id
            )

            # Create data mapping record
            await self._create_data_mapping_record(
                import_id=import_id,
                excel_row_number=row_number,
                customer_name=row_data.get("customer_name"),
                phone_number=row_data.get("phone_number"),
                email=row_data.get("email"),
                policy_number=row_data.get("policy_number"),
                raw_excel_data=row_data,
                mapping_status="mapped",
                created_customer_id=customer_result.get("customer_id")
            )

        # Additional processing for other import types can be added here

    async def _create_or_update_customer(
        self,
        row_data: Dict[str, Any],
        agent_id: str
    ) -> Dict[str, Any]:
        """Create or update customer record"""
        # Implementation for customer creation/update
        # This would involve checking existing customers and updating/creating records
        pass

    async def _create_data_mapping_record(
        self,
        import_id: str,
        excel_row_number: int,
        customer_name: Optional[str] = None,
        phone_number: Optional[str] = None,
        email: Optional[str] = None,
        policy_number: Optional[str] = None,
        raw_excel_data: Dict[str, Any] = None,
        mapping_status: str = "pending",
        validation_errors: List[str] = None,
        created_customer_id: Optional[str] = None
    ):
        """Create data mapping record"""
        mapping = CustomerDataMapping(
            id=str(uuid.uuid4()),
            import_id=import_id,
            excel_row_number=excel_row_number,
            customer_name=customer_name,
            phone_number=phone_number,
            email=email,
            policy_number=policy_number,
            raw_excel_data=raw_excel_data or {},
            mapping_status=mapping_status,
            validation_errors=validation_errors or [],
            created_customer_id=created_customer_id
        )

        self.db.add(mapping)
        await self.db.commit()

    async def _update_import_record(
        self,
        import_id: str,
        processed_records: Optional[int] = None,
        error_records: Optional[int] = None,
        status: Optional[str] = None,
        processing_job_id: Optional[str] = None
    ):
        """Update import record"""
        import_record = await self.import_repo.get_import_by_id(import_id)
        if not import_record:
            return

        if processed_records is not None:
            import_record.processed_records = processed_records
        if error_records is not None:
            import_record.error_records = error_records
        if status is not None:
            import_record.status = status
        if processing_job_id is not None:
            # This would be a foreign key reference in a real implementation
            pass

        import_record.processing_completed_at = text("NOW()")

        await self.db.commit()

    async def _update_job_status(
        self,
        job_id: str,
        status: str,
        error_message: Optional[str] = None
    ):
        """Update job status"""
        job = await self.import_repo.get_job_by_id(job_id)
        if not job:
            return

        job.status = status
        if error_message:
            job.error_message = error_message

        if status in ["completed", "failed"]:
            job.completed_at = text("NOW()")

        await self.db.commit()

    async def _send_import_completion_notification(
        self,
        agent_id: str,
        import_id: str,
        processed_count: int,
        error_count: int
    ):
        """Send completion notification to agent"""
        # Implementation for sending notifications
        pass

    async def get_import_status(self, import_id: str) -> Dict[str, Any]:
        """Get import status and details"""
        import_record = await self.import_repo.get_import_by_id(import_id)
        if not import_record:
            return {"error": "Import not found"}

        return {
            "import_id": import_record.id,
            "status": import_record.status,
            "total_records": import_record.total_records,
            "processed_records": import_record.processed_records,
            "error_records": import_record.error_records,
            "created_at": import_record.created_at.isoformat(),
            "processing_started_at": import_record.processing_started_at.isoformat() if import_record.processing_started_at else None,
            "processing_completed_at": import_record.processing_completed_at.isoformat() if import_record.processing_completed_at else None
        }
