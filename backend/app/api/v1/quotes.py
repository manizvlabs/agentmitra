"""
Daily Motivational Quotes API Endpoints
=======================================

API endpoints for:
- CRUD operations on daily motivational quotes
- Quote branding and customization
- Sharing analytics and performance tracking
- Agent quote management
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from datetime import date
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.services.quotes_service import QuotesService
from app.models.user import User
from app.models.quotes import DailyQuote

router = APIRouter(prefix="/quotes", tags=["quotes"])


# Pydantic models for API
class QuoteCreateRequest(BaseModel):
    quote_text: str
    author: Optional[str] = None
    category: str = "motivation"
    tags: List[str] = []
    branding_settings: Dict[str, Any] = {}
    scheduled_date: Optional[date] = None
    is_active: bool = True

    @validator('quote_text')
    def validate_quote_text(cls, v):
        if not v.strip():
            raise ValueError('Quote text cannot be empty')
        if len(v) > 2000:
            raise ValueError('Quote text must be less than 2000 characters')
        return v

    @validator('category')
    def validate_category(cls, v):
        valid_categories = [
            'motivation', 'success', 'leadership', 'sales', 'insurance',
            'work', 'life', 'inspiration', 'growth', 'resilience'
        ]
        if v not in valid_categories:
            raise ValueError(f'Category must be one of: {", ".join(valid_categories)}')
        return v


class QuoteUpdateRequest(BaseModel):
    quote_text: Optional[str] = None
    author: Optional[str] = None
    category: Optional[str] = None
    tags: Optional[List[str]] = None
    branding_settings: Optional[Dict[str, Any]] = None
    scheduled_date: Optional[date] = None
    is_active: Optional[bool] = None

    @validator('quote_text')
    def validate_quote_text(cls, v):
        if v is not None and not v.strip():
            raise ValueError('Quote text cannot be empty')
        if v is not None and len(v) > 2000:
            raise ValueError('Quote text must be less than 2000 characters')
        return v

    @validator('category')
    def validate_category(cls, v):
        if v is not None:
            valid_categories = [
                'motivation', 'success', 'leadership', 'sales', 'insurance',
                'work', 'life', 'inspiration', 'growth', 'resilience'
            ]
            if v not in valid_categories:
                raise ValueError(f'Category must be one of: {", ".join(valid_categories)}')
        return v


class QuoteResponse(BaseModel):
    quote_id: str
    agent_id: str
    quote_text: str
    author: Optional[str]
    category: str
    tags: List[str]
    branding_settings: Dict[str, Any]
    is_active: bool
    scheduled_date: Optional[date]
    published_at: Optional[str]
    created_at: str
    updated_at: str


class ShareAnalyticsRequest(BaseModel):
    platform: str
    recipient_count: int = 1
    engagement_metrics: Dict[str, Any] = {}

    @validator('platform')
    def validate_platform(cls, v):
        valid_platforms = ['whatsapp', 'sms', 'email', 'facebook', 'twitter', 'linkedin']
        if v not in valid_platforms:
            raise ValueError(f'Platform must be one of: {", ".join(valid_platforms)}')
        return v


class PerformanceMetricsRequest(BaseModel):
    metric_date: date
    views: int = 0
    shares: int = 0
    likes: int = 0
    responses: int = 0
    conversions: int = 0


@router.post("/", response_model=QuoteResponse)
async def create_quote(
    quote_data: QuoteCreateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Create a new motivational quote

    - **quote_text**: The quote text (required, max 2000 chars)
    - **author**: Quote author (optional)
    - **category**: Quote category (motivation, success, etc.)
    - **tags**: List of searchable tags
    - **branding_settings**: Branding configuration (fonts, colors, etc.)
    - **scheduled_date**: Date to schedule the quote (optional)
    - **is_active**: Whether the quote is active (default: true)
    """
    try:
        quotes_service = QuotesService(db)
        quote = quotes_service.create_quote(
            agent_id=str(current_user.user_id),
            quote_data=quote_data.dict()
        )

        return QuoteResponse(
            quote_id=str(quote.quote_id),
            agent_id=str(quote.agent_id),
            quote_text=quote.quote_text,
            author=quote.author,
            category=quote.category,
            tags=quote.tags or [],
            branding_settings=quote.branding_settings or {},
            is_active=quote.is_active,
            scheduled_date=quote.scheduled_date,
            published_at=quote.published_at.isoformat() if quote.published_at else None,
            created_at=quote.created_at.isoformat(),
            updated_at=quote.updated_at.isoformat()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create quote: {str(e)}")


@router.get("/", response_model=List[QuoteResponse])
async def list_agent_quotes(
    active_only: bool = Query(False, description="Return only active quotes"),
    category: Optional[str] = Query(None, description="Filter by category"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    List all quotes for the current agent

    - **active_only**: Return only active quotes (default: false)
    - **category**: Filter quotes by category
    """
    try:
        quotes_service = QuotesService(db)
        quotes = quotes_service.get_agent_quotes(
            agent_id=str(current_user.user_id),
            active_only=active_only
        )

        # Filter by category if specified
        if category:
            quotes = [q for q in quotes if q.category == category]

        return [
            QuoteResponse(
                quote_id=str(quote.quote_id),
                agent_id=str(quote.agent_id),
                quote_text=quote.quote_text,
                author=quote.author,
                category=quote.category,
                tags=quote.tags or [],
                branding_settings=quote.branding_settings or {},
                is_active=quote.is_active,
                scheduled_date=quote.scheduled_date,
                published_at=quote.published_at.isoformat() if quote.published_at else None,
                created_at=quote.created_at.isoformat(),
                updated_at=quote.updated_at.isoformat()
            )
            for quote in quotes
        ]

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list quotes: {str(e)}")


@router.get("/{quote_id}", response_model=QuoteResponse)
async def get_quote(
    quote_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get a specific quote by ID

    - **quote_id**: Quote identifier
    """
    try:
        quotes_service = QuotesService(db)
        quote = quotes_service.get_quote_by_id(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )

        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        return QuoteResponse(
            quote_id=str(quote.quote_id),
            agent_id=str(quote.agent_id),
            quote_text=quote.quote_text,
            author=quote.author,
            category=quote.category,
            tags=quote.tags or [],
            branding_settings=quote.branding_settings or {},
            is_active=quote.is_active,
            scheduled_date=quote.scheduled_date,
            published_at=quote.published_at.isoformat() if quote.published_at else None,
            created_at=quote.created_at.isoformat(),
            updated_at=quote.updated_at.isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get quote: {str(e)}")


@router.put("/{quote_id}", response_model=QuoteResponse)
async def update_quote(
    quote_id: str,
    update_data: QuoteUpdateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update an existing quote

    - **quote_id**: Quote identifier
    - **update_data**: Fields to update (all optional)
    """
    try:
        quotes_service = QuotesService(db)
        quote = quotes_service.update_quote(
            quote_id=quote_id,
            agent_id=str(current_user.user_id),
            update_data=update_data.dict(exclude_unset=True)
        )

        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        return QuoteResponse(
            quote_id=str(quote.quote_id),
            agent_id=str(quote.agent_id),
            quote_text=quote.quote_text,
            author=quote.author,
            category=quote.category,
            tags=quote.tags or [],
            branding_settings=quote.branding_settings or {},
            is_active=quote.is_active,
            scheduled_date=quote.scheduled_date,
            published_at=quote.published_at.isoformat() if quote.published_at else None,
            created_at=quote.created_at.isoformat(),
            updated_at=quote.updated_at.isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update quote: {str(e)}")


@router.delete("/{quote_id}")
async def delete_quote(
    quote_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Delete a quote

    - **quote_id**: Quote identifier
    """
    try:
        quotes_service = QuotesService(db)
        success = quotes_service.delete_quote(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )

        if not success:
            raise HTTPException(status_code=404, detail="Quote not found")

        return {"success": True, "message": "Quote deleted successfully"}

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete quote: {str(e)}")


@router.post("/{quote_id}/publish")
async def publish_quote(
    quote_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Publish a quote (set published timestamp)

    - **quote_id**: Quote identifier
    """
    try:
        quotes_service = QuotesService(db)
        quote = quotes_service.publish_quote(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )

        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        return {
            "success": True,
            "message": "Quote published successfully",
            "published_at": quote.published_at.isoformat()
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to publish quote: {str(e)}")


@router.post("/{quote_id}/share")
async def record_quote_share(
    quote_id: str,
    share_data: ShareAnalyticsRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Record quote sharing analytics

    - **quote_id**: Quote identifier
    - **platform**: Sharing platform (whatsapp, sms, email, etc.)
    - **recipient_count**: Number of recipients (default: 1)
    - **engagement_metrics**: Additional engagement data
    """
    try:
        quotes_service = QuotesService(db)

        # Verify quote exists and belongs to user
        quote = quotes_service.get_quote_by_id(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )
        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        analytics = quotes_service.record_sharing_analytics(
            quote_id=quote_id,
            agent_id=str(current_user.user_id),
            platform=share_data.platform,
            recipient_count=share_data.recipient_count,
            engagement_metrics=share_data.engagement_metrics
        )

        return {
            "success": True,
            "message": "Share analytics recorded successfully",
            "share_id": str(analytics.share_id)
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to record share analytics: {str(e)}")


@router.post("/{quote_id}/performance")
async def update_quote_performance(
    quote_id: str,
    metrics: PerformanceMetricsRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Update performance metrics for a quote

    - **quote_id**: Quote identifier
    - **metric_date**: Date for the metrics
    - **views**: Number of views
    - **shares**: Number of shares
    - **likes**: Number of likes
    - **responses**: Number of responses
    - **conversions**: Number of conversions (leads generated)
    """
    try:
        quotes_service = QuotesService(db)

        # Verify quote exists and belongs to user
        quote = quotes_service.get_quote_by_id(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )
        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        performance = quotes_service.update_performance_metrics(
            quote_id=quote_id,
            agent_id=str(current_user.user_id),
            metric_date=metrics.metric_date,
            metrics={
                "views": metrics.views,
                "shares": metrics.shares,
                "likes": metrics.likes,
                "responses": metrics.responses,
                "conversions": metrics.conversions
            }
        )

        return {
            "success": True,
            "message": "Performance metrics updated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update performance metrics: {str(e)}")


@router.get("/{quote_id}/analytics")
async def get_quote_analytics(
    quote_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get comprehensive analytics for a specific quote

    - **quote_id**: Quote identifier
    """
    try:
        quotes_service = QuotesService(db)

        # Verify quote exists and belongs to user
        quote = quotes_service.get_quote_by_id(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )
        if not quote:
            raise HTTPException(status_code=404, detail="Quote not found")

        analytics = quotes_service.get_quote_analytics(
            quote_id=quote_id,
            agent_id=str(current_user.user_id)
        )

        return {
            "success": True,
            "data": analytics
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get quote analytics: {str(e)}")


@router.get("/analytics/summary")
async def get_quotes_analytics_summary(
    period_days: int = Query(30, ge=1, le=365, description="Analysis period in days"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get analytics summary for all agent's quotes

    - **period_days**: Number of days to analyze (1-365, default: 30)
    """
    try:
        quotes_service = QuotesService(db)
        analytics = quotes_service.get_agent_quotes_analytics(
            agent_id=str(current_user.user_id),
            period_days=period_days
        )

        return {
            "success": True,
            "data": analytics
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get analytics summary: {str(e)}")


@router.get("/categories/list")
async def get_quote_categories():
    """
    Get available quote categories
    """
    categories = [
        {"id": "motivation", "name": "Motivation", "description": "Inspirational and motivational quotes"},
        {"id": "success", "name": "Success", "description": "Quotes about achieving success"},
        {"id": "leadership", "name": "Leadership", "description": "Leadership and management quotes"},
        {"id": "sales", "name": "Sales", "description": "Sales and business quotes"},
        {"id": "insurance", "name": "Insurance", "description": "Insurance-specific quotes"},
        {"id": "work", "name": "Work", "description": "Work ethic and professionalism"},
        {"id": "life", "name": "Life", "description": "Life lessons and wisdom"},
        {"id": "inspiration", "name": "Inspiration", "description": "Inspirational quotes"},
        {"id": "growth", "name": "Growth", "description": "Personal and professional growth"},
        {"id": "resilience", "name": "Resilience", "description": "Overcoming challenges and resilience"}
    ]

    return {
        "success": True,
        "data": categories
    }
