"""
Content Management API Endpoints
=================================

API endpoints for content management including:
- File upload and download
- Content organization and tagging
- Access control and sharing
- Content analytics and reporting
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, Query, BackgroundTasks
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
import logging

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.services.content_management_service import ContentManagementService
from app.services.video_tutorial_service import VideoTutorialService
from app.models.user import User

router = APIRouter(prefix="/content", tags=["content"])
logger = logging.getLogger(__name__)


@router.post("/upload")
async def upload_content(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    content_type: str = Form("general"),
    category: str = Form("misc"),
    tags: Optional[str] = Form(None),  # JSON string of tags
    description: Optional[str] = Form(None),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Upload content file with metadata

    - **file**: The file to upload
    - **content_type**: Type of content (video, document, image)
    - **category**: Content category
    - **tags**: JSON array of tags (optional)
    - **description**: Content description (optional)
    """
    try:
        # Parse tags
        parsed_tags = []
        if tags:
            try:
                import json
                parsed_tags = json.loads(tags)
            except json.JSONDecodeError:
                raise HTTPException(status_code=400, detail="Invalid tags format")

        # Prepare metadata
        metadata = {}
        if description:
            metadata["description"] = description

        # Upload content
        content_service = ContentManagementService(db)
        result = await content_service.upload_content(
            file=file,
            uploader_id=str(current_user.id),
            content_type=content_type,
            category=category,
            tags=parsed_tags,
            metadata=metadata
        )

        return {
            "success": True,
            "data": result,
            "message": "Content uploaded successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Content upload error: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.get("/")
async def list_content(
    content_type: Optional[str] = None,
    category: Optional[str] = None,
    tags: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    List content with filtering and pagination

    - **content_type**: Filter by content type (video, document, image)
    - **category**: Filter by category
    - **tags**: Filter by tags (comma-separated)
    - **page**: Page number
    - **limit**: Items per page
    """
    try:
        # Parse tags
        parsed_tags = None
        if tags:
            parsed_tags = [tag.strip() for tag in tags.split(",")]

        content_service = ContentManagementService(db)
        result = await content_service.list_content(
            content_type=content_type,
            category=category,
            uploader_id=str(current_user.id),
            tags=parsed_tags,
            page=page,
            limit=limit
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"List content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list content: {str(e)}")


@router.get("/{content_id}")
async def get_content(
    content_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get content details by ID

    - **content_id**: Content identifier
    """
    try:
        content_service = ContentManagementService(db)
        content = await content_service.get_content(
            content_id=content_id,
            user_id=str(current_user.id)
        )

        return {
            "success": True,
            "data": content
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Get content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get content: {str(e)}")


@router.get("/{content_id}/download")
async def download_content(
    content_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Download content file

    - **content_id**: Content identifier
    """
    try:
        content_service = ContentManagementService(db)

        # Get content info
        content = await content_service.get_content(
            content_id=content_id,
            user_id=str(current_user.id)
        )

        # Generate presigned URL for download
        presigned_url = await content_service.generate_presigned_url(content_id)

        # Log download access
        # await content_service.log_access(content_id, str(current_user.id), "download")

        return {
            "success": True,
            "data": {
                "content_id": content_id,
                "filename": content.get("filename"),
                "download_url": presigned_url,
                "expires_in": "24 hours"
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Download content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to download content: {str(e)}")


@router.delete("/{content_id}")
async def delete_content(
    content_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Delete content

    - **content_id**: Content identifier
    """
    try:
        content_service = ContentManagementService(db)
        success = await content_service.delete_content(
            content_id=content_id,
            user_id=str(current_user.id)
        )

        if success:
            return {
                "success": True,
                "message": "Content deleted successfully"
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to delete content")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Delete content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to delete content: {str(e)}")


@router.post("/{content_id}/share")
async def share_content(
    content_id: str,
    permissions: Dict[str, Any],
    expires_in_hours: Optional[int] = 24,
    max_access_count: Optional[int] = None,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Share content with others

    - **content_id**: Content identifier
    - **permissions**: Access permissions
    - **expires_in_hours**: Link expiration time
    - **max_access_count**: Maximum access count
    """
    try:
        # Implementation for content sharing
        # This would generate a share token and return a shareable link

        return {
            "success": True,
            "data": {
                "content_id": content_id,
                "share_token": "generated-token",
                "share_url": f"/content/shared/generated-token",
                "expires_at": "timestamp",
                "permissions": permissions
            },
            "message": "Content shared successfully"
        }

    except Exception as e:
        logger.error(f"Share content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to share content: {str(e)}")


@router.get("/shared/{share_token}")
async def access_shared_content(
    share_token: str,
    db: Session = Depends(get_db)
):
    """
    Access shared content via token

    - **share_token**: Share token
    """
    try:
        # Implementation for accessing shared content
        # This would validate the token and provide access

        return {
            "success": True,
            "data": {
                "content_id": "content-id",
                "filename": "shared-file.pdf",
                "download_url": "presigned-url",
                "expires_in": "24 hours"
            }
        }

    except Exception as e:
        logger.error(f"Access shared content error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to access shared content: {str(e)}")


@router.put("/{content_id}/tags")
async def update_content_tags(
    content_id: str,
    tags: List[str],
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update content tags

    - **content_id**: Content identifier
    - **tags**: List of tags
    """
    try:
        # Implementation for updating content tags

        return {
            "success": True,
            "data": {
                "content_id": content_id,
                "tags": tags
            },
            "message": "Tags updated successfully"
        }

    except Exception as e:
        logger.error(f"Update content tags error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update tags: {str(e)}")


@router.get("/analytics/overview")
async def get_content_analytics(
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get content analytics overview

    - **period**: Time period (7d, 30d, 90d, 1y)
    """
    try:
        content_service = ContentManagementService(db)
        analytics = await content_service.get_content_analytics()

        return {
            "success": True,
            "data": analytics or {
                "total_content": 0,
                "total_size_gb": 0,
                "content_by_type": {},
                "uploads_over_time": [],
                "top_categories": [],
                "storage_utilization": 0
            }
        }

    except Exception as e:
        logger.error(f"Get content analytics error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get analytics: {str(e)}")


@router.get("/categories")
async def get_content_categories():
    """
    Get available content categories
    """
    categories = [
        {"id": "presentations", "name": "Presentations", "description": "Sales presentations and demos"},
        {"id": "training", "name": "Training", "description": "Training materials and videos"},
        {"id": "marketing", "name": "Marketing", "description": "Marketing collateral and campaigns"},
        {"id": "policies", "name": "Policies", "description": "Insurance policy documents"},
        {"id": "reports", "name": "Reports", "description": "Business reports and analytics"},
        {"id": "misc", "name": "Miscellaneous", "description": "Other content types"}
    ]

    return {
        "success": True,
        "data": categories
    }


@router.get("/types")
async def get_content_types():
    """
    Get supported content types
    """
    content_types = [
        {
            "id": "video",
            "name": "Video",
            "description": "Video files (MP4, AVI, MOV, etc.)",
            "max_size_mb": 100,
            "supported_formats": ["mp4", "avi", "mov", "mkv", "webm"]
        },
        {
            "id": "document",
            "name": "Document",
            "description": "Documents (PDF, Word, Excel, etc.)",
            "max_size_mb": 10,
            "supported_formats": ["pdf", "doc", "docx", "xls", "xlsx", "txt", "csv"]
        },
        {
            "id": "image",
            "name": "Image",
            "description": "Image files (JPEG, PNG, GIF, etc.)",
            "max_size_mb": 5,
            "supported_formats": ["jpg", "jpeg", "png", "gif", "webp", "bmp"]
        }
    ]

    return {
        "success": True,
        "data": content_types
    }


# Video Tutorial Endpoints
@router.post("/videos/upload")
async def upload_video_tutorial(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    title: str = Form(..., description="Video tutorial title"),
    description: Optional[str] = Form(None, description="Video description"),
    category: str = Form("general", description="Video category"),
    tags: Optional[str] = Form(None, description="JSON array of tags"),
    target_audience: Optional[str] = Form(None, description="JSON array of target audiences"),
    policy_types: Optional[str] = Form(None, description="JSON array of policy types"),
    difficulty_level: str = Form("beginner", description="Difficulty level"),
    language: str = Form("en", description="Video language"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Upload a video tutorial with comprehensive metadata

    - **file**: Video file to upload (MP4, AVI, MOV, MKV, WebM)
    - **title**: Video tutorial title (required)
    - **description**: Detailed video description
    - **category**: Content category (insurance_fundamentals, policy_management, etc.)
    - **tags**: JSON array of searchable tags
    - **target_audience**: JSON array of target audience types
    - **policy_types**: JSON array of related policy types
    - **difficulty_level**: beginner, intermediate, advanced
    - **language**: Video language code (en, hi, te)
    """
    try:
        # Parse JSON fields
        parsed_tags = []
        if tags:
            try:
                import json
                parsed_tags = json.loads(tags)
            except json.JSONDecodeError:
                raise HTTPException(status_code=400, detail="Invalid tags format")

        parsed_target_audience = []
        if target_audience:
            try:
                parsed_target_audience = json.loads(target_audience)
            except json.JSONDecodeError:
                raise HTTPException(status_code=400, detail="Invalid target_audience format")

        parsed_policy_types = []
        if policy_types:
            try:
                parsed_policy_types = json.loads(policy_types)
            except json.JSONDecodeError:
                raise HTTPException(status_code=400, detail="Invalid policy_types format")

        # Upload video tutorial
        video_service = VideoTutorialService(db)
        result = await video_service.upload_video_tutorial(
            file=file,
            uploader=current_user,
            title=title,
            description=description,
            category=category,
            tags=parsed_tags,
            target_audience=parsed_target_audience,
            policy_types=parsed_policy_types,
            difficulty_level=difficulty_level,
            language=language
        )

        return {
            "success": True,
            "data": result,
            "message": "Video tutorial uploaded successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Video tutorial upload error: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")


@router.get("/videos")
async def list_video_tutorials(
    category: Optional[str] = None,
    agent_id: Optional[str] = None,
    language: Optional[str] = None,
    difficulty_level: Optional[str] = None,
    target_audience: Optional[str] = None,
    policy_types: Optional[str] = None,
    search_query: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    List video tutorials with advanced filtering and search

    - **category**: Filter by category
    - **agent_id**: Filter by agent who uploaded
    - **language**: Filter by language
    - **difficulty_level**: Filter by difficulty
    - **target_audience**: Filter by target audience (comma-separated)
    - **policy_types**: Filter by policy types (comma-separated)
    - **search_query**: Search in title and description
    - **page**: Page number
    - **limit**: Items per page
    """
    try:
        # Parse comma-separated fields
        parsed_target_audience = target_audience.split(",") if target_audience else None
        parsed_policy_types = policy_types.split(",") if policy_types else None

        video_service = VideoTutorialService(db)
        result = await video_service.list_video_tutorials(
            category=category,
            agent_id=agent_id,
            language=language,
            difficulty_level=difficulty_level,
            target_audience=parsed_target_audience,
            policy_types=parsed_policy_types,
            search_query=search_query,
            page=page,
            limit=limit
        )

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        logger.error(f"List video tutorials error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to list videos: {str(e)}")


@router.get("/videos/{video_id}")
async def get_video_tutorial(
    video_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get video tutorial details by ID

    - **video_id**: Video tutorial identifier
    """
    try:
        video_service = VideoTutorialService(db)
        video = await video_service.get_video_tutorial(
            video_id=video_id,
            user_id=str(current_user.id)
        )

        return {
            "success": True,
            "data": video
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Get video tutorial error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get video: {str(e)}")


@router.post("/videos/{video_id}/progress")
async def update_video_progress(
    video_id: str,
    watch_time_seconds: float = Form(..., ge=0),
    completion_percentage: float = Form(..., ge=0, le=100),
    is_completed: bool = Form(False),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update user progress for a video tutorial

    - **video_id**: Video tutorial identifier
    - **watch_time_seconds**: Time watched in seconds
    - **completion_percentage**: Completion percentage (0-100)
    - **is_completed**: Whether video is completed
    """
    try:
        video_service = VideoTutorialService(db)
        result = await video_service.update_video_progress(
            video_id=video_id,
            user_id=str(current_user.id),
            watch_time_seconds=watch_time_seconds,
            completion_percentage=completion_percentage,
            is_completed=is_completed
        )

        return {
            "success": True,
            "data": result,
            "message": "Progress updated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Update video progress error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update progress: {str(e)}")


@router.get("/videos/recommendations")
async def get_video_recommendations(
    intent_query: Optional[str] = None,
    context: Optional[str] = None,
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get personalized video recommendations

    - **intent_query**: User intent or search query
    - **context**: Additional context (JSON string)
    - **limit**: Number of recommendations to return
    """
    try:
        # Parse context if provided
        parsed_context = None
        if context:
            try:
                import json
                parsed_context = json.loads(context)
            except json.JSONDecodeError:
                logger.warning(f"Invalid context format: {context}")

        video_service = VideoTutorialService(db)
        recommendations = await video_service.get_recommended_videos(
            user_id=str(current_user.id),
            intent_query=intent_query,
            context=parsed_context,
            limit=limit
        )

        return {
            "success": True,
            "data": recommendations,
            "count": len(recommendations)
        }

    except Exception as e:
        logger.error(f"Get video recommendations error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get recommendations: {str(e)}")


@router.get("/videos/categories")
async def get_video_categories():
    """
    Get available video tutorial categories
    """
    categories = [
        {
            "id": "insurance_fundamentals",
            "name": "Insurance Fundamentals",
            "description": "Core concepts and basics of insurance",
            "icon": "book-open",
            "color": "#3B82F6"
        },
        {
            "id": "policy_management",
            "name": "Policy Management",
            "description": "Managing and maintaining insurance policies",
            "icon": "clipboard-list",
            "color": "#10B981"
        },
        {
            "id": "financial_planning",
            "name": "Financial Planning",
            "description": "Investment strategies and financial planning",
            "icon": "trending-up",
            "color": "#F59E0B"
        },
        {
            "id": "technical_support",
            "name": "Technical Support",
            "description": "App usage and technical assistance",
            "icon": "support",
            "color": "#EF4444"
        },
        {
            "id": "agent_content",
            "name": "Agent Content",
            "description": "Custom content created by insurance agents",
            "icon": "user-circle",
            "color": "#8B5CF6"
        }
    ]

    return {
        "success": True,
        "data": categories
    }
