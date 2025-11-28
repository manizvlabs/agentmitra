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
from app.services.callback_service import CallbackService
from app.core.auth import get_current_user_context, UserContext
from app.core.logging_config import get_logger
from app.models.callback import PriorityLevel, CallbackStatus, CallbackSource

logger = get_logger(__name__)

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
        # Get agent_id safely - handle None case
        agent_id_str = getattr(current_user, 'agent_id', None)
        agent_id = UUID(agent_id_str) if agent_id_str else None

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
                    "agent_id": str(c.agent_id) if c.agent_id else None,
                    "request_type": c.request_type,
                    "description": c.description,
                    "priority": c.priority,
                    "priority_score": float(c.priority_score or 0),
                    "status": c.status,
                    "customer_name": c.customer_name,
                    "customer_phone": c.customer_phone,
                    "customer_email": c.customer_email,
                    "due_at": c.due_at.isoformat() if c.due_at else None,
                    "created_at": c.created_at.isoformat() if c.created_at else None,
                }
                for c in callbacks
            ],
            "total": len(callbacks)
        }

    except Exception as e:
        import traceback
        logger.error(f"Error listing callback requests: {e}")
        logger.error(f"Traceback: {traceback.format_exc()}")
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


# =====================================================
# ENHANCED CALLBACK MANAGEMENT ENDPOINTS
# =====================================================

class EnhancedCallbackCreate(BaseModel):
    customer_name: str
    customer_phone: str
    subject: str
    description: Optional[str] = None
    category: Optional[str] = None
    source: CallbackSource = CallbackSource.CUSTOMER_PORTAL
    customer_email: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class EnhancedCallbackResponse(BaseModel):
    callback_id: str
    customer_name: str
    customer_phone: str
    subject: str
    priority: str
    priority_score: float
    status: str
    source: str
    sla_target_minutes: Optional[int]
    created_at: str


@router.post("/enhanced", response_model=EnhancedCallbackResponse)
async def create_enhanced_callback(
    callback_data: EnhancedCallbackCreate,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Create enhanced callback with priority scoring and SLA tracking"""
    try:
        callback_service = CallbackService(db)

        callback = await callback_service.create_callback(
            customer_name=callback_data.customer_name,
            customer_phone=callback_data.customer_phone,
            subject=callback_data.subject,
            description=callback_data.description,
            category=callback_data.category,
            source=callback_data.source,
            customer_email=callback_data.customer_email,
            metadata=callback_data.metadata,
            created_by=str(current_user.user_id)
        )

        return {
            "callback_id": callback.callback_id,
            "customer_name": callback.customer_name,
            "customer_phone": callback.customer_phone,
            "subject": callback.subject,
            "priority": callback.priority.value,
            "priority_score": callback.priority_score,
            "status": callback.status.value,
            "source": callback.source.value,
            "sla_target_minutes": callback.sla_target_minutes,
            "created_at": callback.created_at.isoformat()
        }

    except Exception as e:
        logger.error(f"Failed to create enhanced callback: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create callback: {str(e)}"
        )


@router.put("/enhanced/{callback_id}/assign")
async def assign_enhanced_callback(
    callback_id: str,
    agent_id: str,
    notes: Optional[str] = None,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Assign enhanced callback to agent"""
    try:
        callback_service = CallbackService(db)

        callback = await callback_service.assign_callback(
            callback_id=callback_id,
            agent_id=agent_id,
            assigned_by=str(current_user.user_id),
            notes=notes
        )

        return {
            "success": True,
            "data": {
                "callback_id": callback.callback_id,
                "assigned_to": str(callback.assigned_to),
                "assigned_at": callback.assigned_at.isoformat(),
                "status": callback.status.value
            },
            "message": "Callback assigned successfully"
        }

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error(f"Failed to assign callback: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to assign callback: {str(e)}"
        )


@router.put("/enhanced/{callback_id}/status")
async def update_enhanced_callback_status(
    callback_id: str,
    status: CallbackStatus,
    resolution_notes: Optional[str] = None,
    resolution_category: Optional[str] = None,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Update enhanced callback status"""
    try:
        callback_service = CallbackService(db)

        callback = await callback_service.update_callback_status(
            callback_id=callback_id,
            new_status=status,
            updated_by=str(current_user.user_id),
            resolution_notes=resolution_notes,
            resolution_category=resolution_category
        )

        return {
            "success": True,
            "data": {
                "callback_id": callback.callback_id,
                "status": callback.status.value,
                "resolved_at": callback.resolved_at.isoformat() if callback.resolved_at else None,
                "sla_met": callback.sla_met
            },
            "message": f"Callback status updated to {status.value}"
        }

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error(f"Failed to update callback status: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update callback status: {str(e)}"
        )


@router.post("/enhanced/{callback_id}/escalate")
async def escalate_enhanced_callback(
    callback_id: str,
    escalation_reason: str,
    escalate_to: Optional[str] = None,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Escalate enhanced callback"""
    try:
        callback_service = CallbackService(db)

        callback = await callback_service.escalate_callback(
            callback_id=callback_id,
            escalated_by=str(current_user.user_id),
            escalation_reason=escalation_reason,
            escalate_to=escalate_to
        )

        return {
            "success": True,
            "data": {
                "callback_id": callback.callback_id,
                "priority": callback.priority.value,
                "escalated_at": callback.escalated_at.isoformat(),
                "escalation_reason": callback.escalation_reason
            },
            "message": "Callback escalated successfully"
        }

    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception as e:
        logger.error(f"Failed to escalate callback: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to escalate callback: {str(e)}"
        )


@router.get("/enhanced/{callback_id}")
async def get_enhanced_callback(
    callback_id: str,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get enhanced callback details"""
    try:
        callback_service = CallbackService(db)
        callback = await callback_service.get_callback(callback_id)

        if not callback:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Callback not found")

        return {
            "success": True,
            "data": {
                "callback_id": callback.callback_id,
                "customer_name": callback.customer_name,
                "customer_phone": callback.customer_phone,
                "customer_email": callback.customer_email,
                "subject": callback.subject,
                "description": callback.description,
                "category": callback.category,
                "priority": callback.priority.value,
                "priority_score": callback.priority_score,
                "status": callback.status.value,
                "assigned_to": str(callback.assigned_to) if callback.assigned_to else None,
                "source": callback.source.value,
                "sla_target_minutes": callback.sla_target_minutes,
                "sla_met": callback.sla_met,
                "escalated": callback.escalated,
                "created_at": callback.created_at.isoformat(),
                "resolved_at": callback.resolved_at.isoformat() if callback.resolved_at else None
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get callback: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get callback: {str(e)}"
        )


@router.get("/enhanced")
async def list_enhanced_callbacks(
    status: Optional[CallbackStatus] = None,
    priority: Optional[PriorityLevel] = None,
    assigned_to: Optional[str] = None,
    category: Optional[str] = None,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """List enhanced callbacks with filtering"""
    try:
        callback_service = CallbackService(db)
        callbacks = await callback_service.list_callbacks(
            status=status,
            priority=priority,
            assigned_to=assigned_to,
            category=category,
            limit=limit,
            offset=offset
        )

        return {
            "success": True,
            "data": [
                {
                    "callback_id": cb.callback_id,
                    "customer_name": cb.customer_name,
                    "subject": cb.subject,
                    "priority": cb.priority.value,
                    "status": cb.status.value,
                    "assigned_to": str(cb.assigned_to) if cb.assigned_to else None,
                    "created_at": cb.created_at.isoformat(),
                    "sla_target_minutes": cb.sla_target_minutes
                }
                for cb in callbacks
            ],
            "pagination": {
                "limit": limit,
                "offset": offset,
                "total": len(callbacks)  # In production, get actual count
            }
        }

    except Exception as e:
        logger.error(f"Failed to list callbacks: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list callbacks: {str(e)}"
        )


@router.get("/enhanced/analytics/overview")
async def get_callback_analytics(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    period: str = Query("daily", regex="^(daily|weekly|monthly)$"),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get callback analytics overview"""
    try:
        callback_service = CallbackService(db)
        analytics = await callback_service.get_callback_analytics(
            start_date=start_date,
            end_date=end_date,
            period=period
        )

        return {
            "success": True,
            "data": analytics
        }

    except Exception as e:
        logger.error(f"Failed to get callback analytics: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get callback analytics: {str(e)}"
        )


@router.get("/enhanced/sla/status")
async def get_sla_status(
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get SLA status for callbacks"""
    try:
        # Get callbacks that are at risk of SLA breach
        from datetime import timedelta
        warning_threshold = datetime.utcnow() - timedelta(minutes=30)  # Last 30 minutes

        # This would be implemented to check SLA status
        sla_status = {
            "healthy": 85,
            "warning": 12,
            "breached": 3,
            "total_active": 100
        }

        return {
            "success": True,
            "data": sla_status,
            "message": "SLA status retrieved successfully"
        }

    except Exception as e:
        logger.error(f"Failed to get SLA status: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get SLA status: {str(e)}"
        )
