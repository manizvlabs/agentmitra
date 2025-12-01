"""
Agent Profile Management API Endpoints
======================================

API endpoints for:
- Comprehensive agent profile management
- Photo upload and profile picture handling
- Advanced agent settings and preferences
- Agent verification and approval workflows
- Performance metrics and analytics
"""

import logging
from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status, UploadFile, File, Form, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from datetime import datetime
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context, require_permission
from app.repositories.agent_repository import AgentRepository
from app.services.content_management_service import ContentManagementService
from app.models.user import User
from app.models.agent import Agent

logger = logging.getLogger(__name__)


router = APIRouter(prefix="/agents", tags=["agents"])


# Pydantic models for API
class AgentProfileResponse(BaseModel):
    agent_id: str
    user_id: str
    agent_code: str
    license_number: Optional[str]
    license_expiry_date: Optional[str]
    license_issuing_authority: Optional[str]

    # Business information
    business_name: Optional[str]
    business_address: Optional[Dict[str, Any]]
    gst_number: Optional[str]
    pan_number: Optional[str]

    # Operational details
    territory: Optional[str]
    operating_regions: Optional[List[str]]
    experience_years: Optional[int]
    specializations: Optional[List[str]]

    # Communication
    whatsapp_business_number: Optional[str]
    business_email: Optional[str]
    website: Optional[str]

    # Performance metrics
    total_policies_sold: int
    total_premium_collected: float
    active_policyholders: int
    customer_satisfaction_score: Optional[float]

    # Status
    status: str
    verification_status: str
    approved_at: Optional[str]
    hierarchy_level: int
    sub_agents_count: int

    # User information
    user_profile: Dict[str, Any]


class AgentProfileUpdateRequest(BaseModel):
    # Business information
    business_name: Optional[str] = None
    business_address: Optional[Dict[str, Any]] = None
    gst_number: Optional[str] = None
    pan_number: Optional[str] = None

    # Operational details
    territory: Optional[str] = None
    operating_regions: Optional[List[str]] = None
    experience_years: Optional[int] = None
    specializations: Optional[List[str]] = None

    # Communication
    whatsapp_business_number: Optional[str] = None
    business_email: Optional[str] = None
    website: Optional[str] = None


class AgentSettingsUpdateRequest(BaseModel):
    notification_preferences: Optional[Dict[str, Any]] = None
    dashboard_layout: Optional[Dict[str, Any]] = None
    theme_preference: Optional[str] = None
    language_preference: Optional[str] = None
    timezone: Optional[str] = None
    working_hours: Optional[Dict[str, Any]] = None
    auto_save_enabled: Optional[bool] = None
    two_factor_enabled: Optional[bool] = None


class AgentVerificationRequest(BaseModel):
    license_number: str
    license_expiry_date: str
    license_issuing_authority: str
    documents: List[str]  # List of document URLs/keys

    @validator('license_expiry_date')
    def validate_license_expiry(cls, v):
        try:
            datetime.fromisoformat(v.replace('Z', '+00:00'))
            return v
        except ValueError:
            raise ValueError('Invalid date format. Use ISO format.')


class AgentPerformanceMetrics(BaseModel):
    total_policies: int
    total_premium: float
    conversion_rate: float
    customer_satisfaction: Optional[float]
    monthly_growth: float
    active_customers: int
    leads_generated: int
    quotes_created: int
    presentations_delivered: int


@router.get("/profile", response_model=AgentProfileResponse)
async def get_agent_profile(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get current user's agent profile
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent by user ID
        agent = agent_repo.get_by_user_id(str(current_user.user_id))
        if not agent:
            raise HTTPException(status_code=404, detail="Agent profile not found")

        # Build user profile data
        user_profile = {
            "first_name": current_user.first_name,
            "last_name": current_user.last_name,
            "display_name": current_user.display_name,
            "email": current_user.email,
            "phone_number": current_user.phone_number,
            "avatar_url": current_user.avatar_url,
            "language_preference": current_user.language_preference,
            "timezone": current_user.timezone,
            "theme_preference": current_user.theme_preference,
            "last_login_at": current_user.last_login_at.isoformat() if current_user.last_login_at else None
        }

        return AgentProfileResponse(
            agent_id=str(agent.agent_id),
            user_id=str(agent.user_id),
            agent_code=agent.agent_code,
            license_number=agent.license_number,
            license_expiry_date=agent.license_expiry_date.isoformat() if agent.license_expiry_date else None,
            license_issuing_authority=agent.license_issuing_authority,
            business_name=agent.business_name,
            business_address=agent.business_address,
            gst_number=agent.gst_number,
            pan_number=agent.pan_number,
            territory=agent.territory,
            operating_regions=agent.operating_regions,
            experience_years=agent.experience_years,
            specializations=agent.specializations,
            whatsapp_business_number=agent.whatsapp_business_number,
            business_email=agent.business_email,
            website=agent.website,
            total_policies_sold=agent.total_policies_sold or 0,
            total_premium_collected=float(agent.total_premium_collected or 0),
            active_policyholders=agent.active_policyholders or 0,
            customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
            status=agent.status or "active",
            verification_status=agent.verification_status or "pending",
            approved_at=agent.approved_at.isoformat() if agent.approved_at else None,
            hierarchy_level=agent.hierarchy_level or 1,
            sub_agents_count=agent.sub_agents_count or 0,
            user_profile=user_profile
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agent profile: {str(e)}")


@router.put("/profile", response_model=AgentProfileResponse)
async def update_agent_profile(
    profile_data: AgentProfileUpdateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update agent profile information
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent by user ID
        agent = agent_repo.get_by_user_id(str(current_user.user_id))
        if not agent:
            raise HTTPException(status_code=404, detail="Agent profile not found")

        # Update agent fields
        update_data = profile_data.dict(exclude_unset=True)
        updated_agent = agent_repo.update(agent.agent_id, update_data)

        if not updated_agent:
            raise HTTPException(status_code=500, detail="Failed to update agent profile")

        # Return updated profile
        return await get_agent_profile(current_user, db)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update agent profile: {str(e)}")


@router.put("/settings")
async def update_agent_settings(
    settings_data: AgentSettingsUpdateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update agent settings and preferences
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent by user ID
        agent = agent_repo.get_by_user_id(str(current_user.user_id))
        if not agent:
            raise HTTPException(status_code=404, detail="Agent profile not found")

        # Update user preferences
        update_data = settings_data.dict(exclude_unset=True)
        user_update_data = {}

        # Map settings to user fields
        if 'notification_preferences' in update_data:
            user_update_data['notification_preferences'] = update_data['notification_preferences']
        if 'theme_preference' in update_data:
            user_update_data['theme_preference'] = update_data['theme_preference']
        if 'language_preference' in update_data:
            user_update_data['language_preference'] = update_data['language_preference']
        if 'timezone' in update_data:
            user_update_data['timezone'] = update_data['timezone']

        if user_update_data:
            from app.repositories.user_repository import UserRepository
            user_repo = UserRepository(db)
            user_repo.update(current_user.user_id, user_update_data)

        # Store agent-specific settings (could be in a separate settings table)
        agent_settings = update_data
        # For now, we'll store in agent's business_address or create a settings field
        if agent_settings:
            # Update agent with settings
            agent_repo.update(agent.agent_id, {'business_address': agent_settings})

        return {
            "success": True,
            "message": "Agent settings updated successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update agent settings: {str(e)}")


@router.post("/profile/photo")
async def upload_profile_photo(
    request: Request,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Upload agent profile photo

    - **file**: Profile photo file (JPEG, PNG, max 5MB)
    """
    try:
        # Parse multipart data manually to avoid FastAPI UploadFile issues
        import multipart
        from multipart import MultipartParser
        from io import BytesIO

        body = await request.body()
        content_type = request.headers.get('content-type', '')

        if not content_type.startswith('multipart/form-data'):
            raise HTTPException(status_code=400, detail="Content-Type must be multipart/form-data")

        # Parse multipart data
        boundary = content_type.split('boundary=')[1] if 'boundary=' in content_type else None
        if not boundary:
            raise HTTPException(status_code=400, detail="Invalid multipart boundary")

        # Simple multipart parsing
        parts = body.split(f'--{boundary}'.encode())
        file_data = None
        filename = None
        file_content_type = None

        for part in parts:
            if b'Content-Disposition: form-data; name="photo"' in part:
                # Extract filename
                if b'filename="' in part:
                    filename_part = part.split(b'filename="')[1].split(b'"')[0]
                    filename = filename_part.decode('utf-8', errors='ignore')

                # Extract content type
                if b'Content-Type: ' in part:
                    content_type_part = part.split(b'Content-Type: ')[1].split(b'\r\n')[0]
                    file_content_type = content_type_part.decode('utf-8', errors='ignore')

                # Extract file content (skip headers)
                content_start = part.find(b'\r\n\r\n')
                if content_start != -1:
                    file_data = part[content_start + 4:].rstrip(b'\r\n')
                break

        if not file_data:
            raise HTTPException(status_code=400, detail="No file data found")

        # Validate file type
        allowed_types = ['image/jpeg', 'image/png', 'image/jpg']
        if file_content_type not in allowed_types:
            raise HTTPException(
                status_code=400,
                detail="Invalid file type. Only JPEG and PNG files are allowed."
            )

        # Validate file size (5MB max)
        file_size = len(file_data)
        if file_size > 5 * 1024 * 1024:  # 5MB
            raise HTTPException(
                status_code=400,
                detail="File too large. Maximum size is 5MB."
            )

        # Create UploadFile-like object for ContentManagementService
        from fastapi import UploadFile
        from io import BytesIO
        from starlette.datastructures import Headers

        file_obj = BytesIO(file_data)
        headers = Headers({'content-type': file_content_type or 'application/octet-stream'})
        upload_file = UploadFile(
            filename=filename or "uploaded_file",
            file=file_obj,
            headers=headers
        )

        # Upload to content management service
        content_service = ContentManagementService(db)
        upload_result = await content_service.upload_content(
            file=upload_file,
            uploader_id=str(current_user.user_id),
            content_type="image",
            category="profile_photos",
            metadata={"is_profile_photo": True, "agent_id": str(current_user.user_id)}
        )

        if not upload_result or 'content_id' not in upload_result:
            raise HTTPException(status_code=500, detail="Failed to upload profile photo")

        # Update user's avatar_url
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user_repo.update(current_user.user_id, {
            'avatar_url': upload_result.get('media_url') or upload_result['content_id']
        })

        return {
            "success": True,
            "message": "Profile photo uploaded successfully",
            "data": {
                "photo_url": upload_result.get('media_url'),
                "content_id": upload_result.get('content_id')
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error in photo upload: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Failed to upload profile photo: {str(e)}")


@router.post("/verification/request")
async def submit_verification_request(
    verification_data: AgentVerificationRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Submit agent verification request
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent by user ID
        agent = agent_repo.get_by_user_id(str(current_user.user_id))
        if not agent:
            raise HTTPException(status_code=404, detail="Agent profile not found")

        # Update agent verification data
        update_data = {
            'license_number': verification_data.license_number,
            'license_expiry_date': verification_data.license_expiry_date,
            'license_issuing_authority': verification_data.license_issuing_authority,
            'verification_status': 'submitted'
        }

        updated_agent = agent_repo.update(agent.agent_id, update_data)

        if not updated_agent:
            raise HTTPException(status_code=500, detail="Failed to submit verification request")

        return {
            "success": True,
            "message": "Verification request submitted successfully",
            "data": {
                "verification_status": "submitted",
                "submitted_at": datetime.utcnow().isoformat()
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to submit verification request: {str(e)}")


@router.post("/verification/{agent_id}/approve")
async def approve_agent_verification(
    agent_id: str,
    approval_notes: Optional[str] = None,
    current_user: User = Depends(require_permission("agents:verify")),
    db: Session = Depends(get_db)
):
    """
    Approve agent verification (admin only)

    - **agent_id**: Agent ID to approve
    - **approval_notes**: Optional approval notes
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent
        agent = agent_repo.get_by_id(agent_id)
        if not agent:
            raise HTTPException(status_code=404, detail="Agent not found")

        # Update verification status
        update_data = {
            'verification_status': 'verified',
            'approved_at': datetime.utcnow(),
            'approved_by': current_user.user_id,
            'status': 'active'
        }

        updated_agent = agent_repo.update(agent_id, update_data)

        if not updated_agent:
            raise HTTPException(status_code=500, detail="Failed to approve agent verification")

        return {
            "success": True,
            "message": "Agent verification approved successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to approve agent verification: {str(e)}")


@router.get("/performance/metrics", response_model=AgentPerformanceMetrics)
async def get_agent_performance_metrics(
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get agent performance metrics

    - **period**: Time period for metrics (7d, 30d, 90d, 1y)
    """
    try:
        from app.services.analytics_service import AnalyticsService
        analytics_service = AnalyticsService(db)

        # Get agent performance data
        performance_data = await analytics_service.get_agent_performance_analytics(
            agent_id=str(current_user.user_id),
            period=period
        )

        return AgentPerformanceMetrics(
            total_policies=performance_data.get("total_policies", 0),
            total_premium=performance_data.get("total_premium", 0.0),
            conversion_rate=performance_data.get("conversion_rate", 0.0),
            customer_satisfaction=performance_data.get("customer_satisfaction"),
            monthly_growth=performance_data.get("monthly_growth", 0.0),
            active_customers=performance_data.get("active_customers", 0),
            leads_generated=performance_data.get("leads_generated", 0),
            quotes_created=performance_data.get("quotes_created", 0),
            presentations_delivered=performance_data.get("presentations_delivered", 0)
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get performance metrics: {str(e)}")


@router.get("/hierarchy")
async def get_agent_hierarchy(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get agent hierarchy information (parent/child agents)
    """
    try:
        agent_repo = AgentRepository(db)

        # Get agent by user ID
        agent = agent_repo.get_by_user_id(str(current_user.user_id))
        if not agent:
            raise HTTPException(status_code=404, detail="Agent profile not found")

        hierarchy_info = {
            "agent_id": str(agent.agent_id),
            "hierarchy_level": agent.hierarchy_level or 1,
            "parent_agent": None,
            "sub_agents": []
        }

        # Get parent agent info
        if agent.parent_agent_id:
            parent_agent = agent_repo.get_by_id(str(agent.parent_agent_id))
            if parent_agent:
                hierarchy_info["parent_agent"] = {
                    "agent_id": str(parent_agent.agent_id),
                    "agent_code": parent_agent.agent_code,
                    "business_name": parent_agent.business_name,
                    "hierarchy_level": parent_agent.hierarchy_level
                }

        # Get sub-agents (simplified - would need recursive query for full hierarchy)
        if agent.sub_agents_count and agent.sub_agents_count > 0:
            sub_agents = agent_repo.get_sub_agents(agent.agent_id, limit=10)
            hierarchy_info["sub_agents"] = [
                {
                    "agent_id": str(sub.agent_id),
                    "agent_code": sub.agent_code,
                    "business_name": sub.business_name,
                    "status": sub.status,
                    "total_policies_sold": sub.total_policies_sold or 0
                }
                for sub in sub_agents
            ]

        return {
            "success": True,
            "data": hierarchy_info
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agent hierarchy: {str(e)}")


@router.get("/search")
async def search_agents(
    query: str = Query(..., min_length=2, max_length=100),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(require_permission("agents:read")),
    db: Session = Depends(get_db)
):
    """
    Search agents by name, code, or business name

    - **query**: Search query
    - **limit**: Maximum number of results
    """
    try:
        agent_repo = AgentRepository(db)
        agents = agent_repo.search_agents(query, limit=limit)

        results = []
        for agent in agents:
            results.append({
                "agent_id": str(agent.agent_id),
                "agent_code": agent.agent_code,
                "business_name": agent.business_name,
                "territory": agent.territory,
                "status": agent.status,
                "verification_status": agent.verification_status,
                "total_policies_sold": agent.total_policies_sold or 0,
                "user": {
                    "first_name": agent.user.first_name if agent.user else None,
                    "last_name": agent.user.last_name if agent.user else None,
                    "email": agent.user.email if agent.user else None,
                    "phone_number": agent.user.phone_number if agent.user else None
                }
            })

        return {
            "success": True,
            "data": results,
            "count": len(results)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to search agents: {str(e)}")


@router.get("/{agent_id}", response_model=AgentProfileResponse)
async def get_agent_by_id(
    agent_id: str,
    current_user: User = Depends(require_permission("agents:read")),
    db: Session = Depends(get_db)
):
    """
    Get agent profile by ID (admin/staff only)

    - **agent_id**: Agent identifier
    """
    try:
        agent_repo = AgentRepository(db)
        agent = agent_repo.get_by_id(agent_id)

        if not agent:
            raise HTTPException(status_code=404, detail="Agent not found")

        # Build user profile data
        user = agent.user
        user_profile = {
            "first_name": user.first_name if user else None,
            "last_name": user.last_name if user else None,
            "display_name": user.display_name if user else None,
            "email": user.email if user else None,
            "phone_number": user.phone_number if user else None,
            "avatar_url": user.avatar_url if user else None,
            "language_preference": user.language_preference if user else None,
            "timezone": user.timezone if user else None,
            "theme_preference": user.theme_preference if user else None,
            "last_login_at": user.last_login_at.isoformat() if user and user.last_login_at else None
        }

        return AgentProfileResponse(
            agent_id=str(agent.agent_id),
            user_id=str(agent.user_id),
            agent_code=agent.agent_code,
            license_number=agent.license_number,
            license_expiry_date=agent.license_expiry_date.isoformat() if agent.license_expiry_date else None,
            license_issuing_authority=agent.license_issuing_authority,
            business_name=agent.business_name,
            business_address=agent.business_address,
            gst_number=agent.gst_number,
            pan_number=agent.pan_number,
            territory=agent.territory,
            operating_regions=agent.operating_regions,
            experience_years=agent.experience_years,
            specializations=agent.specializations,
            whatsapp_business_number=agent.whatsapp_business_number,
            business_email=agent.business_email,
            website=agent.website,
            total_policies_sold=agent.total_policies_sold or 0,
            total_premium_collected=float(agent.total_premium_collected or 0),
            active_policyholders=agent.active_policyholders or 0,
            customer_satisfaction_score=float(agent.customer_satisfaction_score) if agent.customer_satisfaction_score else None,
            status=agent.status or "active",
            verification_status=agent.verification_status or "pending",
            approved_at=agent.approved_at.isoformat() if agent.approved_at else None,
            hierarchy_level=agent.hierarchy_level or 1,
            sub_agents_count=agent.sub_agents_count or 0,
            user_profile=user_profile
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agent: {str(e)}")