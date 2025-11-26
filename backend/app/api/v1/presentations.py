"""
Presentation Carousel API Endpoints
"""
from fastapi import APIRouter, HTTPException, Depends, status, File, UploadFile
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context, UserContext
from app.repositories.presentation_repository import PresentationRepository
from app.repositories.agent_repository import AgentRepository
from app.services.minio_storage_service import get_minio_service
from app.models.presentation import PresentationMedia

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
        "presentation_id": str(presentation.presentation_id),
        "agent_id": str(presentation.agent_id),
        "name": presentation.name,
        "description": presentation.description,
        "status": presentation.status,
        "is_active": presentation.is_active,
        "slides": [
            {
                "slide_id": str(slide.slide_id),
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
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_id(agent_id)
    
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
    presentation_status: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get all presentations for an agent (accepts both agent_id and user_id)"""
    agent_repo = AgentRepository(db)

    # First try to get agent by ID
    agent = agent_repo.get_by_id(agent_id)

    # If not found by ID, try to get by user_id
    if not agent:
        agent = agent_repo.get_by_user_id(agent_id)

    if not agent:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Agent not found"
        )

    presentation_repo = PresentationRepository(db)
    presentations, total = presentation_repo.get_by_agent(
        str(agent.agent_id), status=presentation_status, limit=limit, offset=offset
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
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Create a new presentation"""
    # Verify agent exists
    agent_repo = AgentRepository(db)
    agent = agent_repo.get_by_id(agent_id)
    
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
        "presentation_id": str(created.presentation_id),
        "status": created.status,
        "created_at": created.created_at.isoformat() if created.created_at else None
    }


@router.put("/agent/{agent_id}/{presentation_id}")
async def update_presentation(
    agent_id: str,
    presentation_id: str,
    presentation: PresentationModel,
    current_user: UserContext = Depends(get_current_user_context),
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
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get presentation templates"""
    presentation_repo = PresentationRepository(db)
    templates = presentation_repo.get_templates(category=category, is_public=is_public)
    
    return {
        "templates": [
            {
                "template_id": str(t.template_id),
                "name": t.name,
                "description": t.description,
                "category": t.category,
                "is_public": t.is_public,
                "thumbnail_url": t.thumbnail_url,
                "slides": t.slides,  # Changed from template_data to slides
            }
            for t in templates
        ]
    }


@router.post("/media/upload")
async def upload_media(
    file: UploadFile = File(...),
    current_user: UserContext = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Upload media file (image/video) for presentations
    
    Files are stored in MinIO object storage and metadata is saved to database.
    """
    if not current_user.agent_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Agent ID required for media upload"
        )
    
    try:
        # Get MinIO storage service
        storage_service = get_minio_service()
        
        # Determine media type from content type
        media_type = "image" if file.content_type and file.content_type.startswith("image/") else "video"
        
        # Read file content once to get size
        file_content = await file.read()
        file_size = len(file_content)
        
        # Create a new UploadFile from the content for the storage service
        from io import BytesIO
        from fastapi import UploadFile as FastAPIUploadFile
        file_stream = BytesIO(file_content)
        # Create new UploadFile - but we need to pass it properly
        # Since UploadFile reads from the stream, we need to reset it
        file_stream.seek(0)
        file_for_upload = FastAPIUploadFile(file=file_stream, filename=file.filename)
        file_for_upload.content_type = file.content_type
        
        # Upload file to MinIO
        storage_key, media_url, file_hash = await storage_service.upload_file(
            file=file_for_upload,
            agent_id=str(current_user.agent_id),
            folder="presentations"
        )
        
        # Save metadata to database
        import uuid
        media = PresentationMedia(
            media_id=uuid.uuid4(),
            agent_id=current_user.agent_id,
            media_type=media_type,
            mime_type=file.content_type,
            file_name=file.filename,
            file_size_bytes=file_size,
            storage_provider="minio",
            storage_key=storage_key,
            media_url=media_url,
            thumbnail_url=media_url if media_type == "image" else None,  # TODO: Generate thumbnail for videos
            file_hash=file_hash,
            status="active",
            uploaded_at=datetime.utcnow()
        )
        
        db.add(media)
        db.commit()
        db.refresh(media)
        
        return {
            "media_id": str(media.media_id),
            "media_url": media.media_url,
            "thumbnail_url": media.thumbnail_url,
            "media_type": media_type,
            "file_name": file.filename,
            "file_size": file_size,
            "mime_type": file.content_type,
            "storage_key": storage_key
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload media: {str(e)}"
        )
