"""
Portal Callbacks API
====================

Callback management endpoints for the portal service.
Handles customer inquiries and agent escalations.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from app.core.database import get_db
from app.models.user import User
from app.api.v1.auth import get_current_user

router = APIRouter()


@router.get("/")
async def list_callbacks(
    status: Optional[str] = None,
    priority: Optional[str] = None,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List callback requests"""
    # This would integrate with callback service
    return {
        "success": True,
        "data": {
            "callbacks": [
                {
                    "id": "cb_001",
                    "customer_name": "Rajesh Kumar",
                    "priority": "high",
                    "status": "pending",
                    "created_at": "2024-01-20T14:30:00Z"
                }
            ],
            "pagination": {
                "total": 1,
                "limit": limit,
                "offset": 0
            }
        }
    }


@router.post("/{callback_id}/assign")
async def assign_callback(
    callback_id: str,
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Assign callback to agent"""
    return {
        "success": True,
        "data": {
            "callback_id": callback_id,
            "agent_id": agent_id,
            "message": "Callback assigned successfully"
        }
    }


@router.post("/{callback_id}/complete")
async def complete_callback(
    callback_id: str,
    notes: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark callback as completed"""
    return {
        "success": True,
        "data": {
            "callback_id": callback_id,
            "status": "completed",
            "message": "Callback completed successfully"
        }
    }
