"""
Portal Dashboard API
====================

Dashboard endpoints for the Agent Configuration Portal.
Provides overview of agents, imports, callbacks, and system status.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any, List
from datetime import datetime, timedelta

from app.core.database import get_db
from app.models.user import User
from app.api.v1.auth import get_current_user

router = APIRouter()


@router.get("/overview")
async def get_portal_overview(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get portal overview dashboard"""
    try:
        # Get basic stats
        stats = await get_portal_stats(db)

        # Get recent activities
        activities = await get_recent_activities(db, limit=10)

        # Get system status
        system_status = await get_system_status()

        return {
            "success": True,
            "data": {
                "stats": stats,
                "recent_activities": activities,
                "system_status": system_status,
                "generated_at": datetime.utcnow().isoformat()
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get dashboard overview: {str(e)}")


@router.get("/agents/summary")
async def get_agents_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get agents summary for dashboard"""
    try:
        # Total agents
        total_agents = db.query(User).filter(User.role.in_(["agent", "senior_agent"])).count()

        # Active agents (logged in within last 30 days)
        thirty_days_ago = datetime.utcnow() - timedelta(days=30)
        active_agents = db.query(User).filter(
            User.role.in_(["agent", "senior_agent"]),
            User.last_login_at >= thirty_days_ago
        ).count()

        # Agents by status
        pending_agents = db.query(User).filter(
            User.role.in_(["agent", "senior_agent"]),
            User.status == "pending_approval"
        ).count()

        return {
            "success": True,
            "data": {
                "total_agents": total_agents,
                "active_agents": active_agents,
                "pending_approval": pending_agents,
                "inactive_agents": total_agents - active_agents
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agents summary: {str(e)}")


@router.get("/imports/summary")
async def get_imports_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get data imports summary"""
    try:
        # This would integrate with the data import service
        # For now, return placeholder data
        return {
            "success": True,
            "data": {
                "total_imports": 45,
                "successful_imports": 42,
                "failed_imports": 3,
                "pending_imports": 2,
                "total_records_processed": 12500,
                "recent_imports": [
                    {
                        "id": "import_001",
                        "filename": "customers_jan2024.xlsx",
                        "status": "completed",
                        "records_processed": 500,
                        "completed_at": "2024-01-15T10:30:00Z"
                    },
                    {
                        "id": "import_002",
                        "filename": "policies_feb2024.xlsx",
                        "status": "processing",
                        "records_processed": 250,
                        "started_at": "2024-02-01T08:00:00Z"
                    }
                ]
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get imports summary: {str(e)}")


@router.get("/callbacks/summary")
async def get_callbacks_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get callback requests summary"""
    try:
        # This would integrate with the callback service
        # For now, return placeholder data
        return {
            "success": True,
            "data": {
                "total_callbacks": 156,
                "pending_callbacks": 23,
                "completed_callbacks": 89,
                "overdue_callbacks": 8,
                "avg_resolution_time_hours": 4.5,
                "recent_callbacks": [
                    {
                        "id": "cb_001",
                        "customer_name": "Rajesh Kumar",
                        "priority": "high",
                        "status": "pending",
                        "created_at": "2024-01-20T14:30:00Z"
                    },
                    {
                        "id": "cb_002",
                        "customer_name": "Priya Sharma",
                        "priority": "medium",
                        "status": "in_progress",
                        "created_at": "2024-01-20T13:15:00Z"
                    }
                ]
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get callbacks summary: {str(e)}")


async def get_portal_stats(db: Session) -> Dict[str, Any]:
    """Get overall portal statistics"""
    return {
        "total_agents": 150,
        "active_agents": 120,
        "total_imports": 45,
        "successful_imports": 42,
        "total_callbacks": 156,
        "pending_callbacks": 23,
        "completed_callbacks": 89,
        "system_health": "healthy"
    }


async def get_recent_activities(db: Session, limit: int = 10) -> List[Dict[str, Any]]:
    """Get recent portal activities"""
    # This would aggregate activities from various services
    # For now, return sample data
    return [
        {
            "id": "act_001",
            "type": "agent_registered",
            "description": "New agent 'Amit Singh' registered",
            "timestamp": "2024-01-20T15:30:00Z",
            "actor": "system"
        },
        {
            "id": "act_002",
            "type": "import_completed",
            "description": "Data import 'customers_jan2024.xlsx' completed successfully",
            "timestamp": "2024-01-20T14:45:00Z",
            "actor": "agent_portal"
        },
        {
            "id": "act_003",
            "type": "callback_created",
            "description": "New callback request from customer 'Rajesh Kumar'",
            "timestamp": "2024-01-20T14:30:00Z",
            "actor": "customer"
        },
        {
            "id": "act_004",
            "type": "agent_login",
            "description": "Agent 'Priya Sharma' logged into portal",
            "timestamp": "2024-01-20T14:15:00Z",
            "actor": "priya.sharma"
        }
    ]


async def get_system_status() -> Dict[str, Any]:
    """Get system status information"""
    return {
        "database": "healthy",
        "redis": "healthy",
        "api_services": "healthy",
        "storage": "healthy",
        "last_backup": "2024-01-20T02:00:00Z",
        "uptime_hours": 168
    }
