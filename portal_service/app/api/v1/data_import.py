"""
Portal Data Import API
======================

Data import endpoints for the portal service.
Handles bulk data uploads and import job management.
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.models.user import User
from app.api.v1.auth import get_current_user

router = APIRouter()


@router.post("/upload")
async def upload_data_file(
    file: UploadFile = File(...),
    import_type: str = "customer_data",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Upload data file for import"""
    try:
        # Validate file type
        if not file.filename.endswith(('.xlsx', '.xls', '.csv')):
            raise HTTPException(
                status_code=400,
                detail="Unsupported file type. Only Excel (.xlsx, .xls) and CSV files are supported."
            )

        # Save file temporarily and queue import job
        # This would integrate with the data import service

        return {
            "success": True,
            "data": {
                "import_id": "import_123",
                "filename": file.filename,
                "import_type": import_type,
                "status": "queued",
                "message": "Import job queued successfully"
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.get("/jobs")
async def list_import_jobs(
    status: Optional[str] = None,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List import jobs"""
    # This would query import jobs from database
    return {
        "success": True,
        "data": {
            "jobs": [
                {
                    "id": "job_001",
                    "filename": "customers.xlsx",
                    "status": "completed",
                    "records_processed": 500,
                    "created_at": "2024-01-20T10:00:00Z"
                }
            ],
            "pagination": {
                "total": 1,
                "limit": limit,
                "offset": 0
            }
        }
    }


@router.get("/jobs/{job_id}")
async def get_import_job_status(
    job_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get import job status"""
    # This would query specific job status
    return {
        "success": True,
        "data": {
            "id": job_id,
            "status": "completed",
            "progress": 100,
            "records_processed": 500,
            "errors": []
        }
    }
