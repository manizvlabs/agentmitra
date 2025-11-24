"""
Campaign Management API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from sqlalchemy.orm import Session
from uuid import UUID

from app.core.database import get_db
from app.services.campaign_service import CampaignService
from app.services.campaign_analytics_service import CampaignAnalyticsService
from app.services.campaign_automation_service import CampaignAutomationService
from app.core.auth import get_current_user_context, UserContext

router = APIRouter()


# Request/Response Models
class CampaignCreate(BaseModel):
    campaign_name: str
    campaign_type: str  # 'acquisition', 'retention', 'upselling', 'behavioral'
    campaign_goal: Optional[str] = None
    description: Optional[str] = None
    subject: Optional[str] = None
    message: str
    message_template_id: Optional[str] = None
    personalization_tags: Optional[List[str]] = []
    attachments: Optional[Dict[str, Any]] = None
    primary_channel: str = "whatsapp"
    channels: Optional[List[str]] = []
    target_audience: str = "all"
    selected_segments: Optional[List[str]] = []
    targeting_rules: Optional[Dict[str, Any]] = None
    estimated_reach: int = 0
    schedule_type: str = "immediate"
    scheduled_at: Optional[datetime] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    is_automated: bool = False
    automation_triggers: Optional[Dict[str, Any]] = None
    budget: float = 0.0
    estimated_cost: float = 0.0
    ab_testing_enabled: bool = False
    ab_test_variants: Optional[Dict[str, Any]] = None
    triggers: Optional[List[Dict[str, Any]]] = None


class CampaignUpdate(BaseModel):
    campaign_name: Optional[str] = None
    description: Optional[str] = None
    subject: Optional[str] = None
    message: Optional[str] = None
    status: Optional[str] = None
    scheduled_at: Optional[datetime] = None
    budget: Optional[float] = None


class CampaignResponse(BaseModel):
    campaign_id: str
    agent_id: str
    campaign_name: str
    campaign_type: str
    campaign_goal: Optional[str]
    description: Optional[str]
    status: str
    total_sent: int
    total_delivered: int
    total_opened: int
    total_clicked: int
    total_converted: int
    total_revenue: float
    roi_percentage: float
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_campaign(
    campaign_data: CampaignCreate,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Create a new marketing campaign"""
    try:
        # Get agent_id from user context
        agent_id = current_user.agent_id
        if not agent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User is not associated with an agent"
            )

        campaign_dict = campaign_data.dict()
        campaign = CampaignService.create_campaign(
            db=db,
            agent_id=UUID(agent_id),
            campaign_data=campaign_dict,
            created_by=UUID(current_user.user_id)
        )

        return {
            "success": True,
            "data": {
                "campaign_id": str(campaign.campaign_id),
                "campaign_name": campaign.campaign_name,
                "status": campaign.status,
            },
            "message": "Campaign created successfully"
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create campaign: {str(e)}"
        )


@router.get("")
async def list_campaigns(
    status_filter: Optional[str] = Query(None, alias="status"),
    campaign_type: Optional[str] = Query(None, alias="type"),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """List campaigns for the current agent"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        
        campaigns = CampaignService.list_campaigns(
            db=db,
            agent_id=agent_id,
            status=status_filter,
            campaign_type=campaign_type,
            limit=limit,
            offset=offset
        )

        return {
            "success": True,
            "data": [
                {
                    "campaign_id": str(c.campaign_id),
                    "campaign_name": c.campaign_name,
                    "campaign_type": c.campaign_type,
                    "status": c.status,
                    "total_sent": c.total_sent or 0,
                    "total_converted": c.total_converted or 0,
                    "roi_percentage": float(c.roi_percentage or 0),
                    "created_at": c.created_at.isoformat() if c.created_at else None,
                }
                for c in campaigns
            ],
            "total": len(campaigns)
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list campaigns: {str(e)}"
        )


@router.get("/{campaign_id}")
async def get_campaign(
    campaign_id: str,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Get campaign details"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        
        campaign = CampaignService.get_campaign(
            db=db,
            campaign_id=UUID(campaign_id),
            agent_id=agent_id
        )

        if not campaign:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Campaign not found"
            )

        return {
            "success": True,
            "data": {
                "campaign_id": str(campaign.campaign_id),
                "campaign_name": campaign.campaign_name,
                "campaign_type": campaign.campaign_type,
                "campaign_goal": campaign.campaign_goal,
                "description": campaign.description,
                "subject": campaign.subject,
                "message": campaign.message,
                "status": campaign.status,
                "total_sent": campaign.total_sent or 0,
                "total_delivered": campaign.total_delivered or 0,
                "total_opened": campaign.total_opened or 0,
                "total_clicked": campaign.total_clicked or 0,
                "total_converted": campaign.total_converted or 0,
                "total_revenue": float(campaign.total_revenue or 0),
                "roi_percentage": float(campaign.roi_percentage or 0),
                "created_at": campaign.created_at.isoformat() if campaign.created_at else None,
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get campaign: {str(e)}"
        )


@router.put("/{campaign_id}")
async def update_campaign(
    campaign_id: str,
    campaign_data: CampaignUpdate,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Update a campaign"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        if not agent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User is not associated with an agent"
            )

        update_dict = {k: v for k, v in campaign_data.dict().items() if v is not None}
        
        campaign = CampaignService.update_campaign(
            db=db,
            campaign_id=UUID(campaign_id),
            agent_id=agent_id,
            update_data=update_dict,
            updated_by=UUID(current_user.user_id)
        )

        if not campaign:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Campaign not found"
            )

        return {
            "success": True,
            "data": {
                "campaign_id": str(campaign.campaign_id),
                "status": campaign.status,
            },
            "message": "Campaign updated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update campaign: {str(e)}"
        )


@router.post("/{campaign_id}/launch")
async def launch_campaign(
    campaign_id: str,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Launch a campaign"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        if not agent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User is not associated with an agent"
            )

        campaign = CampaignService.launch_campaign(
            db=db,
            campaign_id=UUID(campaign_id),
            agent_id=agent_id
        )

        if not campaign:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Campaign not found"
            )

        return {
            "success": True,
            "data": {
                "campaign_id": str(campaign.campaign_id),
                "status": campaign.status,
                "launched_at": campaign.launched_at.isoformat() if campaign.launched_at else None,
            },
            "message": "Campaign launched successfully"
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to launch campaign: {str(e)}"
        )


@router.get("/{campaign_id}/analytics")
async def get_campaign_analytics(
    campaign_id: str,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Get campaign analytics"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None

        analytics = CampaignAnalyticsService.get_campaign_analytics(
            db=db,
            campaign_id=UUID(campaign_id),
            agent_id=agent_id
        )

        return {
            "success": True,
            "data": analytics
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get campaign analytics: {str(e)}"
        )


@router.get("/templates")
async def get_campaign_templates(
    category: Optional[str] = Query(None),
    is_public: bool = Query(True),
    limit: int = Query(50, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get campaign templates"""
    try:
        templates = CampaignService.get_campaign_templates(
            db=db,
            category=category,
            is_public=is_public,
            limit=limit
        )

        return {
            "success": True,
            "data": [
                {
                    "template_id": str(t.template_id),
                    "template_name": t.template_name,
                    "description": t.description,
                    "category": t.category,
                    "subject_template": t.subject_template,
                    "message_template": t.message_template,
                    "personalization_tags": t.personalization_tags or [],
                    "usage_count": t.usage_count or 0,
                    "average_roi": float(t.average_roi or 0),
                }
                for t in templates
            ]
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get templates: {str(e)}"
        )


@router.post("/templates/{template_id}/create")
async def create_campaign_from_template(
    template_id: str,
    campaign_data: CampaignCreate,
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Create a campaign from a template"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        if not agent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User is not associated with an agent"
            )

        campaign_dict = campaign_data.dict()
        campaign = CampaignService.create_campaign_from_template(
            db=db,
            agent_id=agent_id,
            template_id=UUID(template_id),
            campaign_data=campaign_dict,
            created_by=UUID(current_user.user_id)
        )

        return {
            "success": True,
            "data": {
                "campaign_id": str(campaign.campaign_id),
                "campaign_name": campaign.campaign_name,
            },
            "message": "Campaign created from template successfully"
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create campaign from template: {str(e)}"
        )


@router.get("/recommendations")
async def get_campaign_recommendations(
    db: Session = Depends(get_db),
    current_user: UserContext = Depends(get_current_user_context)
):
    """Get campaign recommendations for the agent"""
    try:
        agent_id = UUID(current_user.agent_id) if current_user.agent_id else None
        if not agent_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User is not associated with an agent"
            )

        recommendations = CampaignAutomationService.get_campaign_recommendations(
            db=db,
            agent_id=agent_id
        )

        return {
            "success": True,
            "data": recommendations
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get recommendations: {str(e)}"
        )

