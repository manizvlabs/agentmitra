"""
Presentation Carousel API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.repositories.presentation_repository import PresentationRepository
from app.repositories.user_repository import UserRepository

router = APIRouter()


class SlideModel(BaseModel):
    slide_id: Optional[str] = None
    slide_order: int
    slide_type: str  # 'image', 'video', 'text'
    media_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    title: Optional[str] = None
    subtitle: Optional[str] = None
    text_color: str = "#FFFFFF"
    background_color: str = "#000000"
    layout: str = "centered"
    duration: int = 4
    cta_button: Optional[dict] = None
    agent_branding: Optional[dict] = None


class PresentationModel(BaseModel):
    presentation_id: Optional[str] = None
    agent_id: str
    name: str
    description: Optional[str] = None
    status: str = "draft"  # 'draft', 'published', 'archived'
    is_active: bool = False
    slides: List[SlideModel] = []
    template_id: Optional[str] = None
    tags: List[str] = []


def _presentation_to_dict(presentation):
    """Convert Presentation model to dict"""
    return {
        "presentation_id": presentation.presentation_id,
        "agent_id": presentation.agent_id,
        "name": presentation.name,
        "description": presentation.description,
        "status": presentation.status,
        "is_active": presentation.is_active,
        "slides": [
            {
                "slide_id": slide.slide_id,
                "slide_order": slide.slide_order,
                "slide_type": slide.slide_type,
                "media_url": slide.media_url,
                "thumbnail_url": slide.thumbnail_url,
                "title": slide.title,
                "subtitle": slide.subtitle,
                "text_color": slide.text_color,
                "background_color": slide.background_color,
                "layout": slide.layout,
                "duration": slide.duration,
                "cta_button": slide.cta_button,
                "agent_branding": slide.agent_branding,
            }
            for slide in presentation.slides
        ],
        "template_id": presentation.template_id,
        "tags": presentation.tags or [],
        "created_at": presentation.created_at.isoformat() if presentation.created_at else None,
        "updated_at": presentation.updated_at.isoformat() if presentation.updated_at else None,
        "last_updated": presentation.updated_at.isoformat() if presentation.updated_at else None,
    }


@router.get("/agent/{agent_id}/active")
async def get_active_presentation(agent_id: str, db: Session = Depends(get_db)):
    """Get active presentation for an agent"""
    # Verify agent exists
    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)
    
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )
    
    presentation_repo = PresentationRepository(db)
    presentation = presentation_repo.get_active_by_agent(agent_id)
    
    if not presentation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active presentation found"
        )
    
    return _presentation_to_dict(presentation)


@router.get("/agent/{agent_id}")
async def get_agent_presentations(
    agent_id: str,
    status: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get all presentations for an agent"""
    # Verify agent exists
    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)
    
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )
    
    presentation_repo = PresentationRepository(db)
    presentations, total = presentation_repo.get_by_agent(
        agent_id, status=status, limit=limit, offset=offset
    )
    
    return {
        "presentations": [_presentation_to_dict(p) for p in presentations],
        "total": total,
        "limit": limit,
        "offset": offset
    }


@router.post("/agent/{agent_id}")
async def create_presentation(
    agent_id: str,
    presentation: PresentationModel,
    db: Session = Depends(get_db)
):
    """Create a new presentation"""
    # Verify agent exists
    user_repo = UserRepository(db)
    agent = user_repo.get_by_id(agent_id)
    
    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )
    
    presentation_repo = PresentationRepository(db)
    
    # Convert slides to dict format
    slides_data = [
        {
            "slide_order": slide.slide_order,
            "slide_type": slide.slide_type,
            "media_url": slide.media_url,
            "thumbnail_url": slide.thumbnail_url,
            "title": slide.title,
            "subtitle": slide.subtitle,
            "text_color": slide.text_color,
            "background_color": slide.background_color,
            "layout": slide.layout,
            "duration": slide.duration,
            "cta_button": slide.cta_button,
            "agent_branding": slide.agent_branding,
        }
        for slide in presentation.slides
    ]
    
    created = presentation_repo.create({
        "agent_id": agent_id,
        "name": presentation.name,
        "description": presentation.description,
        "status": presentation.status,
        "is_active": presentation.is_active,
        "template_id": presentation.template_id,
        "tags": presentation.tags,
        "slides": slides_data,
    })
    
    return {
        "presentation_id": created.presentation_id,
        "status": created.status,
        "created_at": created.created_at.isoformat() if created.created_at else None
    }


@router.put("/agent/{agent_id}/{presentation_id}")
async def update_presentation(
    agent_id: str,
    presentation_id: str,
    presentation: PresentationModel,
    db: Session = Depends(get_db)
):
    """Update an existing presentation"""
    presentation_repo = PresentationRepository(db)
    
    # Verify presentation exists and belongs to agent
    existing = presentation_repo.get_by_id(presentation_id)
    if not existing or existing.agent_id != agent_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Presentation not found"
        )
    
    # Convert slides to dict format
    slides_data = [
        {
            "slide_order": slide.slide_order,
            "slide_type": slide.slide_type,
            "media_url": slide.media_url,
            "thumbnail_url": slide.thumbnail_url,
            "title": slide.title,
            "subtitle": slide.subtitle,
            "text_color": slide.text_color,
            "background_color": slide.background_color,
            "layout": slide.layout,
            "duration": slide.duration,
            "cta_button": slide.cta_button,
            "agent_branding": slide.agent_branding,
        }
        for slide in presentation.slides
    ]
    
    updated = presentation_repo.update(presentation_id, {
        "name": presentation.name,
        "description": presentation.description,
        "status": presentation.status,
        "is_active": presentation.is_active,
        "template_id": presentation.template_id,
        "tags": presentation.tags,
        "slides": slides_data,
    })
    
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update presentation"
        )
    
    return {
        "presentation_id": presentation_id,
        "status": updated.status,
        "updated_at": updated.updated_at.isoformat() if updated.updated_at else None
    }


@router.get("/templates")
async def get_templates(
    category: Optional[str] = None,
    is_public: bool = True,
    db: Session = Depends(get_db)
):
    """Get presentation templates"""
    presentation_repo = PresentationRepository(db)
    templates = presentation_repo.get_templates(category=category, is_public=is_public)
    
    return {
        "templates": [
            {
                "template_id": t.template_id,
                "name": t.name,
                "description": t.description,
                "category": t.category,
                "is_public": t.is_public,
                "thumbnail_url": t.thumbnail_url,
                "template_data": t.template_data,
            }
            for t in templates
        ]
    }


@router.post("/media/upload")
async def upload_media(file: bytes, type: str = "image"):
    """Upload media file (image/video)"""
    # TODO: Implement file upload to S3/CDN
    # For now, return mock response
    import uuid
    media_id = str(uuid.uuid4())[:8]
    
    return {
        "media_url": f"https://cdn.agentmitra.com/presentations/{media_id}.{type}",
        "thumbnail_url": f"https://cdn.agentmitra.com/presentations/thumb_{media_id}.{type}",
        "media_id": media_id
    }
