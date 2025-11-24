"""
Callback Request Management API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from uuid import UUID

from app.core.database import get_db
from app.services.callback_service import CallbackService, CallbackPriorityManager
from app.core.auth import get_current_user_context, UserContext

router = APIRouter()


# Request/Response Models
class CallbackRequestCreate(BaseModel):
    policyholder_id: str
    request_type: str
    description: str
    urgency_level: str = "medium"
    customer_value: str = "bronze"
    source: str = "mobile"
    tags: Optional[List[str]] = []
    category: Optional[str] = None


class CallbackRequestUpdate(BaseModel):
    status: Optional[str] = None
    resolution: Optional[str] = None
    resolution_category: Optional[str] = None
    satisfaction_rating: Optional[int] = Field(None, ge=1, le=5)


class CallbackRequestResponse(BaseModel):
    callback_request_id: str
    policyholder_id: str
    agent_id: Optional[str]
    request_type: str
    description: str
    priority: str
    priority_score: float
    status: str
    customer_name: str
    customer_phone: str
    customer_email: Optional[str]
    due_at: Optional[str]
    created_at: str

    class Config:
        from_attributes = True


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_callback_request(
    callback_data: CallbackRequestCreate,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Create a new callback request"""
    try:
        callback = CallbackService.create_callback_request(
            db=db,
            policyholder_id=UUID(callback_data.policyholder_id),
            request_data=callback_data.dict(),
            created_by=UUID(current_user.user_id)
        )

        return {
            "success": True,
            "data": {
                "callback_request_id": str(callback.callback_request_id),
                "priority": callback.priority,
                "status": callback.status,
                "due_at": callback.due_at.isoformat() if callback.due_at else None,
            },
            "message": "Callback request created successfully"
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create callback request: {str(e)}"
        )


@router.get("")
async def list_callback_requests(
    status_filter: Optional[str] = Query(None, alias="status"),
    priority: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """List callback requests"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None

        callbacks = CallbackService.get_callback_requests(
            db=db,
            agent_id=agent_id,
            status=status_filter,
            priority=priority,
            limit=limit,
            offset=offset
        )

        return {
            "success": True,
            "data": [
                {
                    "callback_request_id": str(c.callback_request_id),
                    "policyholder_id": str(c.policyholder_id),
                    "request_type": c.request_type,
                    "description": c.description,
                    "priority": c.priority,
                    "priority_score": float(c.priority_score or 0),
                    "status": c.status,
                    "customer_name": c.customer_name,
                    "customer_phone": c.customer_phone,
                    "due_at": c.due_at.isoformat() if c.due_at else None,
                    "created_at": c.created_at.isoformat() if c.created_at else None,
                }
                for c in callbacks
            ],
            "total": len(callbacks)
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list callback requests: {str(e)}"
        )


@router.get("/{callback_id}")
async def get_callback_request(
    callback_id: str,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Get callback request details"""
    try:
        from app.models.callback import CallbackRequest
        
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        
        query = db.query(CallbackRequest).filter(
            CallbackRequest.callback_request_id == UUID(callback_id)
        )
        
        if agent_id:
            query = query.filter(CallbackRequest.agent_id == agent_id)
        
        callback = query.first()

        if not callback:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Callback request not found"
            )

        # Get activities
        activities = [
            {
                "activity_type": a.activity_type,
                "description": a.description,
                "created_at": a.created_at.isoformat() if a.created_at else None,
            }
            for a in callback.activities
        ]

        return {
            "success": True,
            "data": {
                "callback_request_id": str(callback.callback_request_id),
                "policyholder_id": str(callback.policyholder_id),
                "request_type": callback.request_type,
                "description": callback.description,
                "priority": callback.priority,
                "priority_score": float(callback.priority_score or 0),
                "status": callback.status,
                "customer_name": callback.customer_name,
                "customer_phone": callback.customer_phone,
                "customer_email": callback.customer_email,
                "due_at": callback.due_at.isoformat() if callback.due_at else None,
                "created_at": callback.created_at.isoformat() if callback.created_at else None,
                "activities": activities,
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get callback request: {str(e)}"
        )


@router.put("/{callback_id}/status")
async def update_callback_status(
    callback_id: str,
    status_update: str = Query(..., description="New status"),
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Update callback request status"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None

        callback = CallbackService.update_callback_status(
            db=db,
            callback_id=UUID(callback_id),
            status=status_update,
            agent_id=agent_id,
            updated_by=UUID(current_user.user_id)
        )

        if not callback:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Callback request not found"
            )

        return {
            "success": True,
            "data": {
                "callback_request_id": str(callback.callback_request_id),
                "status": callback.status,
            },
            "message": "Callback status updated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update callback status: {str(e)}"
        )


@router.post("/{callback_id}/assign")
async def assign_callback(
    callback_id: str,
    agent_id: Optional[str] = Query(None, description="Agent ID to assign to (defaults to current user)"),
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Assign callback request to an agent"""
    try:
        assign_agent_id = UUID(agent_id) if agent_id else UUID(current_user.agent_id) if current_user.agent_id else None
        
        if not assign_agent_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Agent ID is required"
            )

        callback = CallbackService.assign_callback(
            db=db,
            callback_id=UUID(callback_id),
            agent_id=assign_agent_id,
            assigned_by=UUID(current_user.user_id)
        )

        if not callback:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Callback request not found"
            )

        return {
            "success": True,
            "data": {
                "callback_request_id": str(callback.callback_request_id),
                "agent_id": str(callback.agent_id),
                "status": callback.status,
            },
            "message": "Callback assigned successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to assign callback: {str(e)}"
        )


@router.post("/{callback_id}/complete")
async def complete_callback(
    callback_id: str,
    completion_data: CallbackRequestUpdate,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Complete a callback request"""
    try:
        callback = CallbackService.complete_callback(
            db=db,
            callback_id=UUID(callback_id),
            resolution=completion_data.resolution or "",
            resolution_category=completion_data.resolution_category or "resolved",
            satisfaction_rating=completion_data.satisfaction_rating,
            completed_by=UUID(current_user.user_id)
        )

        if not callback:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Callback request not found"
            )

        return {
            "success": True,
            "data": {
                "callback_request_id": str(callback.callback_request_id),
                "status": callback.status,
                "completed_at": callback.completed_at.isoformat() if callback.completed_at else None,
            },
            "message": "Callback completed successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to complete callback: {str(e)}"
        )

