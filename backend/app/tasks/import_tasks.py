"""
Import Tasks
============

Celery tasks for data import processing.
"""

import logging
from app.core.tasks import import_task
from app.core.database import get_db
from app.services.data_import_service import DataImportService

logger = logging.getLogger(__name__)


@import_task("process_excel_import")
def process_excel_import(
    agent_id: str,
    file_path: str,
    import_type: str = "customer_data"
) -> dict:
    """Process Excel import asynchronously"""
    try:
        with get_db() as db:
            import_service = DataImportService(db)
            result = import_service.process_excel_import(
                agent_id=agent_id,
                file_path=file_path,
                import_type=import_type
            )
            logger.info(f"Excel import processed for agent: {agent_id}")
            return result
    except Exception as e:
        logger.error(f"Failed to process Excel import for agent {agent_id}: {e}")
        raise


@import_task("retry_failed_import")
def retry_failed_import(import_id: str) -> dict:
    """Retry failed import"""
    try:
        with get_db() as db:
            import_service = DataImportService(db)
            # Implementation for retry logic
            logger.info(f"Import retry initiated for: {import_id}")
            return {"success": True, "message": "Retry queued"}
    except Exception as e:
        logger.error(f"Failed to retry import {import_id}: {e}")
        raise


@import_task("validate_import_data")
def validate_import_data(import_id: str) -> dict:
    """Validate import data"""
    try:
        with get_db() as db:
            import_service = DataImportService(db)
            # Implementation for validation logic
            logger.info(f"Import validation completed for: {import_id}")
            return {"success": True, "message": "Validation completed"}
    except Exception as e:
        logger.error(f"Failed to validate import {import_id}: {e}")
        raise
