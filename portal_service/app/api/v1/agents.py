"""
Portal Agents Management API
============================

Agent management endpoints for the portal service.
Handles agent onboarding, profile management, and configuration.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime

from app.core.database import get_db
from app.models.user import User
from app.api.v1.auth import get_current_user
from app.repositories.user_repository import UserRepository

router = APIRouter()


class AgentProfile(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    phone_number: str
    business_name: Optional[str] = None
    license_number: Optional[str] = None
    territory: Optional[str] = None
    experience_years: Optional[int] = None


class AgentUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    business_name: Optional[str] = None
    license_number: Optional[str] = None
    territory: Optional[str] = None
    experience_years: Optional[int] = None


@router.get("/")
async def list_agents(
    status_filter: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List agents with filtering"""
    # Check permissions (only admins can list all agents)
    if current_user.role not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions"
        )

    user_repo = UserRepository(db)
    agents = user_repo.get_agents(
        status=status_filter,
        limit=limit,
        offset=offset
    )

    return {
        "success": True,
        "data": agents,
        "pagination": {
            "limit": limit,
            "offset": offset,
            "total": len(agents)  # This should be improved with actual count
        }
    }


@router.get("/{agent_id}")
async def get_agent(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get agent details"""
    # Check permissions
    if current_user.role not in ["admin", "super_admin"] and str(current_user.id) != agent_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions"
        )

    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    return {
        "success": True,
        "data": {
            "id": str(agent.id),
            "email": agent.email,
            "username": agent.username,
            "first_name": agent.first_name,
            "last_name": agent.last_name,
            "phone_number": agent.phone_number,
            "business_name": getattr(agent, 'business_name', None),
            "license_number": getattr(agent, 'license_number', None),
            "territory": getattr(agent, 'territory', None),
            "experience_years": getattr(agent, 'experience_years', None),
            "role": agent.role,
            "status": agent.status,
            "created_at": agent.created_at.isoformat() if agent.created_at else None,
            "last_login_at": agent.last_login_at.isoformat() if agent.last_login_at else None
        }
    }


@router.put("/{agent_id}")
async def update_agent(
    agent_id: str,
    agent_update: AgentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update agent profile"""
    # Check permissions
    if current_user.role not in ["admin", "super_admin"] and str(current_user.id) != agent_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions"
        )

    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    # Update agent fields
    update_data = agent_update.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(agent, field, value)

    agent.updated_at = datetime.utcnow()

    try:
        db.commit()
        db.refresh(agent)

        return {
            "success": True,
            "data": {
                "id": str(agent.id),
                "message": "Agent profile updated successfully"
            }
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update agent: {str(e)}"
        )


@router.put("/{agent_id}/status")
async def update_agent_status(
    agent_id: str,
    status: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update agent status (admin only)"""
    # Check permissions
    if current_user.role not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin permissions required"
        )

    # Validate status
    valid_statuses = ["active", "inactive", "pending_approval", "suspended"]
    if status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}"
        )

    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    agent.status = status
    agent.updated_at = datetime.utcnow()

    try:
        db.commit()

        return {
            "success": True,
            "data": {
                "id": str(agent.id),
                "status": agent.status,
                "message": f"Agent status updated to {status}"
            }
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update agent status: {str(e)}"
        )


@router.delete("/{agent_id}")
async def deactivate_agent(
    agent_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Deactivate agent (admin only)"""
    # Check permissions
    if current_user.role not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin permissions required"
        )

    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    agent.status = "inactive"
    agent.updated_at = datetime.utcnow()

    try:
        db.commit()

        return {
            "success": True,
            "data": {
                "id": str(agent.id),
                "message": "Agent deactivated successfully"
            }
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to deactivate agent: {str(e)}"
        )


@router.get("/stats/overview")
async def get_agent_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get agent statistics overview"""
    # Check permissions
    if current_user.role not in ["admin", "super_admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin permissions required"
        )

    user_repo = UserRepository(db)

    # Get statistics
    total_agents = user_repo.count_agents()
    active_agents = user_repo.count_agents(status="active")
    pending_agents = user_repo.count_agents(status="pending_approval")
    inactive_agents = user_repo.count_agents(status="inactive")

    return {
        "success": True,
        "data": {
            "total_agents": total_agents,
            "active_agents": active_agents,
            "pending_agents": pending_agents,
            "inactive_agents": inactive_agents,
            "activation_rate": (active_agents / total_agents * 100) if total_agents > 0 else 0
        }
    }
