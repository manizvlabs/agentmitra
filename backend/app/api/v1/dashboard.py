"""
Dashboard API Endpoints
========================

API endpoints for:
- Agent home dashboard with presentation carousel
- Feature tiles and quick actions
- Dashboard analytics and KPIs
- Personalized content recommendations
- System overview and admin dashboards
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, text

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.services.analytics_service import AnalyticsService
from app.services.presentation_service import PresentationService
from app.services.quotes_service import QuotesService
from app.services.video_tutorial_service import VideoTutorialService
from app.models.user import User

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


# Pydantic models for API
class PresentationCarouselItem(BaseModel):
    presentation_id: str
    title: str
    description: Optional[str]
    thumbnail_url: Optional[str]
    category: str
    last_modified: str
    view_count: int
    is_featured: bool
    tags: List[str]


class FeatureTile(BaseModel):
    tile_id: str
    title: str
    subtitle: Optional[str]
    icon: str
    color: str
    action_type: str  # 'navigate', 'modal', 'external'
    action_target: str
    is_enabled: bool
    priority: int
    required_permissions: List[str]


class QuickAction(BaseModel):
    action_id: str
    title: str
    icon: str
    action_type: str
    action_target: str
    color: str
    is_primary: bool


class DashboardKPIs(BaseModel):
    total_policies: int
    total_premium: float
    active_customers: int
    conversion_rate: float
    monthly_growth: float
    pending_tasks: int
    recent_activity: int


class MotivationalQuote(BaseModel):
    quote_id: str
    quote_text: str
    author: Optional[str]
    category: str
    is_daily_quote: bool


class VideoRecommendation(BaseModel):
    video_id: str
    title: str
    thumbnail_url: Optional[str]
    duration: str
    difficulty_level: str
    relevance_score: float


class AgentHomeDashboardResponse(BaseModel):
    kpis: DashboardKPIs
    presentation_carousel: List[PresentationCarouselItem]
    feature_tiles: List[FeatureTile]
    quick_actions: List[QuickAction]
    daily_quote: Optional[MotivationalQuote]
    video_recommendations: List[VideoRecommendation]
    recent_activity: List[Dict[str, Any]]
    notifications: List[Dict[str, Any]]
    subscription_status: Dict[str, Any]


@router.get("/home", response_model=AgentHomeDashboardResponse)
async def get_agent_home_dashboard(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get comprehensive agent home dashboard data

    Includes KPIs, presentation carousel, feature tiles, and personalized content
    """
    try:
        # Get dashboard KPIs
        kpis = await _get_dashboard_kpis(str(current_user.user_id), db)

        # Get presentation carousel items
        presentation_carousel = await _get_presentation_carousel(str(current_user.user_id), db)

        # Get feature tiles based on user role and permissions
        feature_tiles = await _get_feature_tiles(current_user, db)

        # Get quick actions
        quick_actions = await _get_quick_actions(current_user, db)

        # Get daily motivational quote
        daily_quote = await _get_daily_quote(str(current_user.user_id), db)

        # Get personalized video recommendations
        video_recommendations = await _get_video_recommendations(str(current_user.user_id), db)

        # Get recent activity
        recent_activity = await _get_recent_activity(str(current_user.user_id), db)

        # Get notifications
        notifications = await _get_dashboard_notifications(str(current_user.user_id), db)

        # Get subscription status
        subscription_status = await _get_subscription_status(str(current_user.user_id), db)

        return AgentHomeDashboardResponse(
            kpis=kpis,
            presentation_carousel=presentation_carousel,
            feature_tiles=feature_tiles,
            quick_actions=quick_actions,
            daily_quote=daily_quote,
            video_recommendations=video_recommendations,
            recent_activity=recent_activity,
            notifications=notifications,
            subscription_status=subscription_status
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get dashboard data: {str(e)}")


@router.get("/presentations/carousel")
async def get_presentation_carousel(
    limit: int = Query(10, ge=1, le=50),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get presentation carousel items for dashboard

    - **limit**: Maximum number of presentations to return
    """
    try:
        carousel_items = await _get_presentation_carousel(str(current_user.user_id), db, limit)
        return {
            "success": True,
            "data": carousel_items
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get presentation carousel: {str(e)}")


@router.get("/feature-tiles")
async def get_feature_tiles(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get available feature tiles for the current user
    """
    try:
        tiles = await _get_feature_tiles(current_user, db)
        return {
            "success": True,
            "data": tiles
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get feature tiles: {str(e)}")


@router.get("/analytics/summary")
async def get_dashboard_analytics_summary(
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get dashboard analytics summary

    - **period**: Time period (7d, 30d, 90d, 1y)
    """
    try:
        analytics_service = AnalyticsService(db)
        summary = await analytics_service.get_agent_dashboard_summary(
            agent_id=str(current_user.user_id),
            period=period
        )

        return {
            "success": True,
            "data": summary
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get analytics summary: {str(e)}")


@router.post("/activity/log")
async def log_dashboard_activity(
    activity_type: str,
    activity_data: Dict[str, Any],
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Log user activity on dashboard

    - **activity_type**: Type of activity (click, view, interaction, etc.)
    - **activity_data**: Additional activity data
    """
    try:
        # Here you would implement activity logging
        # For now, just return success
        return {
            "success": True,
            "message": "Activity logged successfully"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to log activity: {str(e)}")


# Helper functions
async def _get_dashboard_kpis(user_id: str, db: Session) -> DashboardKPIs:
    """Get dashboard KPIs for user"""
    try:
        analytics_service = AnalyticsService(db)

        # Get KPIs from analytics service
        kpis_data = await analytics_service.get_dashboard_kpis(user_id)

        return DashboardKPIs(
            total_policies=kpis_data.get("total_policies", 0),
            total_premium=kpis_data.get("total_premium", 0.0),
            active_customers=kpis_data.get("active_customers", 0),
            conversion_rate=kpis_data.get("conversion_rate", 0.0),
            monthly_growth=kpis_data.get("monthly_growth", 0.0),
            pending_tasks=kpis_data.get("pending_tasks", 0),
            recent_activity=kpis_data.get("recent_activity", 0)
        )

    except Exception:
        # Return default KPIs if service fails
        return DashboardKPIs(
            total_policies=0,
            total_premium=0.0,
            active_customers=0,
            conversion_rate=0.0,
            monthly_growth=0.0,
            pending_tasks=0,
            recent_activity=0
        )


async def _get_presentation_carousel(user_id: str, db: Session, limit: int = 10) -> List[PresentationCarouselItem]:
    """Get presentation carousel items"""
    try:
        presentation_service = PresentationService(db)

        # Get recent presentations for user
        presentations = await presentation_service.get_user_presentations(
            user_id=user_id,
            limit=limit,
            include_featured=True
        )

        carousel_items = []
        for presentation in presentations:
            carousel_items.append(PresentationCarouselItem(
                presentation_id=str(presentation.get("presentation_id", "")),
                title=presentation.get("title", ""),
                description=presentation.get("description"),
                thumbnail_url=presentation.get("thumbnail_url"),
                category=presentation.get("category", "general"),
                last_modified=presentation.get("updated_at", datetime.utcnow().isoformat()),
                view_count=presentation.get("view_count", 0),
                is_featured=presentation.get("is_featured", False),
                tags=presentation.get("tags", [])
            ))

        return carousel_items

    except Exception:
        return []


async def _get_feature_tiles(user: User, db: Session) -> List[FeatureTile]:
    """Get feature tiles based on user role and permissions"""
    # Define available feature tiles based on user role
    all_tiles = [
        {
            "tile_id": "policies",
            "title": "My Policies",
            "subtitle": "Manage customer policies",
            "icon": "document-text",
            "color": "#3B82F6",
            "action_type": "navigate",
            "action_target": "/policies",
            "is_enabled": True,
            "priority": 1,
            "required_permissions": ["policies:read"]
        },
        {
            "tile_id": "customers",
            "title": "Customers",
            "subtitle": "Customer relationship management",
            "icon": "users",
            "color": "#10B981",
            "action_type": "navigate",
            "action_target": "/customers",
            "is_enabled": True,
            "priority": 2,
            "required_permissions": ["customers:read"]
        },
        {
            "tile_id": "analytics",
            "title": "Analytics",
            "subtitle": "Performance insights",
            "icon": "chart-bar",
            "color": "#F59E0B",
            "action_type": "navigate",
            "action_target": "/analytics",
            "is_enabled": True,
            "priority": 3,
            "required_permissions": ["analytics:read"]
        },
        {
            "tile_id": "presentations",
            "title": "Presentations",
            "subtitle": "Sales presentations",
            "icon": "presentation-chart-line",
            "color": "#8B5CF6",
            "action_type": "navigate",
            "action_target": "/presentations",
            "is_enabled": True,
            "priority": 4,
            "required_permissions": ["presentations:read"]
        },
        {
            "tile_id": "quotes",
            "title": "Motivational Quotes",
            "subtitle": "Daily inspiration",
            "icon": "chat-bubble-left-right",
            "color": "#EF4444",
            "action_type": "navigate",
            "action_target": "/quotes",
            "is_enabled": True,
            "priority": 5,
            "required_permissions": []
        },
        {
            "tile_id": "videos",
            "title": "Video Tutorials",
            "subtitle": "Learning center",
            "icon": "video-camera",
            "color": "#06B6D4",
            "action_type": "navigate",
            "action_target": "/videos",
            "is_enabled": True,
            "priority": 6,
            "required_permissions": []
        },
        {
            "tile_id": "campaigns",
            "title": "Campaigns",
            "subtitle": "Marketing campaigns",
            "icon": "megaphone",
            "color": "#EC4899",
            "action_type": "navigate",
            "action_target": "/campaigns",
            "is_enabled": user.role in ['super_admin', 'provider_admin', 'regional_manager', 'senior_agent'],
            "priority": 7,
            "required_permissions": ["campaigns:read"]
        }
    ]

    # Filter tiles based on user permissions and role
    filtered_tiles = []
    for tile in all_tiles:
        if tile["is_enabled"]:
            # Check if user has required permissions
            has_permissions = not tile["required_permissions"] or any(
                perm in getattr(user, 'permissions', []) for perm in tile["required_permissions"]
            )
            if has_permissions:
                filtered_tiles.append(FeatureTile(**tile))

    # Sort by priority
    filtered_tiles.sort(key=lambda x: x.priority)

    return filtered_tiles


async def _get_quick_actions(user: User, db: Session) -> List[QuickAction]:
    """Get quick actions for dashboard"""
    actions = [
        {
            "action_id": "new_policy",
            "title": "New Policy",
            "icon": "plus",
            "action_type": "navigate",
            "action_target": "/policies/new",
            "color": "#3B82F6",
            "is_primary": True
        },
        {
            "action_id": "new_customer",
            "title": "Add Customer",
            "icon": "user-plus",
            "action_type": "navigate",
            "action_target": "/customers/new",
            "color": "#10B981",
            "is_primary": True
        },
        {
            "action_id": "create_quote",
            "title": "Create Quote",
            "icon": "document-plus",
            "action_type": "navigate",
            "action_target": "/quotes/create",
            "color": "#F59E0B",
            "is_primary": False
        },
        {
            "action_id": "record_call",
            "title": "Log Call",
            "icon": "phone",
            "action_type": "modal",
            "action_target": "call_log_modal",
            "color": "#8B5CF6",
            "is_primary": False
        }
    ]

    return [QuickAction(**action) for action in actions]


async def _get_daily_quote(user_id: str, db: Session) -> Optional[MotivationalQuote]:
    """Get daily motivational quote"""
    try:
        quotes_service = QuotesService(db)

        # Get a random active quote for today
        # In a real implementation, you'd have a daily rotation
        quotes = quotes_service.get_agent_quotes(user_id, active_only=True)
        if quotes:
            quote = quotes[0]  # Get first quote for now
            return MotivationalQuote(
                quote_id=str(quote.quote_id),
                quote_text=quote.quote_text,
                author=quote.author,
                category=quote.category,
                is_daily_quote=True
            )

    except Exception:
        pass

    return None


async def _get_video_recommendations(user_id: str, db: Session) -> List[VideoRecommendation]:
    """Get personalized video recommendations"""
    try:
        video_service = VideoTutorialService(db)

        # Get recommended videos for user
        recommendations = await video_service.get_recommended_videos(
            user_id=user_id,
            limit=3
        )

        video_recs = []
        for rec in recommendations:
            video_recs.append(VideoRecommendation(
                video_id=rec.get("video_id", ""),
                title=rec.get("title", ""),
                thumbnail_url=rec.get("thumbnail_url"),
                duration=rec.get("duration", "00:00"),
                difficulty_level=rec.get("difficulty_level", "beginner"),
                relevance_score=rec.get("relevance_score", 0.0)
            ))

        return video_recs

    except Exception:
        return []


async def _get_recent_activity(user_id: str, db: Session) -> List[Dict[str, Any]]:
    """Get recent user activity"""
    try:
        # This would query recent user activities from an activity log table
        # For now, return sample data
        return [
            {
                "activity_id": "1",
                "type": "policy_created",
                "description": "Created new policy for customer",
                "timestamp": datetime.utcnow().isoformat(),
                "metadata": {"customer_name": "John Doe"}
            },
            {
                "activity_id": "2",
                "type": "presentation_viewed",
                "description": "Viewed sales presentation",
                "timestamp": (datetime.utcnow() - timedelta(hours=2)).isoformat(),
                "metadata": {"presentation_title": "Term Life Insurance"}
            }
        ]

    except Exception:
        return []


async def _get_dashboard_notifications(user_id: str, db: Session) -> List[Dict[str, Any]]:
    """Get dashboard notifications"""
    try:
        # This would query user notifications
        # For now, return sample notifications
        return [
            {
                "notification_id": "1",
                "title": "Trial expires soon",
                "message": "Your trial period expires in 3 days",
                "type": "warning",
                "is_read": False,
                "created_at": datetime.utcnow().isoformat()
            }
        ]

    except Exception:
        return []


async def _get_subscription_status(user_id: str, db: Session) -> Dict[str, Any]:
    """Get user subscription status"""
    try:
        from app.services.subscription_service import SubscriptionService
        subscription_service = SubscriptionService(db)
        subscription_details = subscription_service.get_subscription_details(user_id)

        if subscription_details:
            return subscription_details
        else:
            # Return trial status
            from app.core.trial_subscription import TrialSubscriptionService
            trial_service = TrialSubscriptionService()
            user = db.query(User).filter(User.user_id == user_id).first()
            if user:
                return trial_service.check_trial_status(user)
            else:
                return {"status": "none"}

    except Exception:
        return {"status": "unknown"}


# =====================================================
# SYSTEM OVERVIEW ENDPOINTS (Super Admin)
# =====================================================

class SystemOverviewResponse(BaseModel):
    totalUsers: int
    activeUsers: int
    totalAgents: int
    activeAgents: int
    totalPolicies: int
    activePolicies: int
    totalPremium: float
    monthlyRevenue: float
    activeSessions: int
    systemHealth: float
    apiCalls24h: int
    pendingApprovals: int


@router.get("/system-overview", response_model=SystemOverviewResponse)
async def get_system_overview(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get comprehensive system overview statistics for Super Admin dashboard"""
    try:
        # Check permissions - only super admin can access
        if current_user.role != 'super_admin':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. Super admin role required."
            )

        # Get total users count
        total_users = db.query(func.count(User.user_id)).scalar() or 0

        # Get active users (users who logged in within last 30 days)
        thirty_days_ago = datetime.utcnow() - timedelta(days=30)
        active_users = db.query(func.count(User.user_id)).filter(
            User.last_login_at >= thirty_days_ago
        ).scalar() or 0

        # Get agent statistics
        total_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents WHERE status = 'active'
        """)).scalar() or 0

        active_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents a
            JOIN users u ON a.user_id = u.user_id
            WHERE a.status = 'active' AND u.last_login_at >= :thirty_days_ago
        """), {"thirty_days_ago": thirty_days_ago}).scalar() or 0

        # Get policy statistics
        total_policies = db.execute(text("""
            SELECT COUNT(*) FROM policies
        """)).scalar() or 0

        active_policies = db.execute(text("""
            SELECT COUNT(*) FROM policies
            WHERE status = 'active'
        """)).scalar() or 0

        # Get premium statistics
        total_premium_result = db.execute(text("""
            SELECT COALESCE(SUM(premium_amount), 0) FROM policies
            WHERE status = 'active'
        """)).scalar()
        total_premium = float(total_premium_result) if total_premium_result else 0.0

        # Get monthly revenue (current month)
        current_month = datetime.utcnow().replace(day=1)
        monthly_revenue_result = db.execute(text("""
            SELECT COALESCE(SUM(premium_amount), 0) FROM policies
            WHERE status = 'active' AND created_at >= :current_month
        """), {"current_month": current_month}).scalar()
        monthly_revenue = float(monthly_revenue_result) if monthly_revenue_result else 0.0

        # Get active sessions (simplified - could be enhanced with session tracking)
        active_sessions = db.execute(text("""
            SELECT COUNT(*) FROM user_sessions
            WHERE last_activity >= :one_hour_ago AND is_active = true
        """), {"one_hour_ago": datetime.utcnow() - timedelta(hours=1)}).scalar() or 0

        # System health score (0-100, based on various metrics)
        system_health = 95.5  # Could be calculated based on uptime, error rates, etc.

        # API calls in last 24 hours (simplified - would need API logging)
        api_calls_24h = db.execute(text("""
            SELECT COUNT(*) FROM api_logs
            WHERE created_at >= :one_day_ago
        """), {"one_day_ago": datetime.utcnow() - timedelta(days=1)}).scalar() or 0

        # Pending approvals
        pending_approvals = db.execute(text("""
            SELECT COUNT(*) FROM agents WHERE verification_status = 'pending'
        """)).scalar() or 0

        return SystemOverviewResponse(
            totalUsers=total_users,
            activeUsers=active_users,
            totalAgents=total_agents,
            activeAgents=active_agents,
            totalPolicies=total_policies,
            activePolicies=active_policies,
            totalPremium=total_premium,
            monthlyRevenue=monthly_revenue,
            activeSessions=active_sessions,
            systemHealth=system_health,
            apiCalls24h=api_calls_24h,
            pendingApprovals=pending_approvals
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch system overview: {str(e)}"
        )


# =====================================================
# PROVIDER ADMIN DASHBOARD ENDPOINTS
# =====================================================

class ProviderOverviewResponse(BaseModel):
    totalAgents: int
    activeAgents: int
    totalPolicies: int
    monthlyRevenue: float
    pendingVerifications: int
    topPerformingAgents: List[Dict[str, Any]]
    recentPolicies: List[Dict[str, Any]]


@router.get("/provider-overview", response_model=ProviderOverviewResponse)
async def get_provider_overview(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get provider admin dashboard overview"""
    try:
        # Check permissions - only provider admin can access
        if current_user.role != 'insurance_provider_admin':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. Provider admin role required."
            )

        # Get agents under this provider
        total_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents WHERE provider_id = :provider_id
        """), {"provider_id": current_user.user_id}).scalar() or 0

        active_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents a
            JOIN users u ON a.user_id = u.user_id
            WHERE a.provider_id = :provider_id AND a.status = 'active'
            AND u.last_login_at >= :thirty_days_ago
        """), {
            "provider_id": current_user.user_id,
            "thirty_days_ago": datetime.utcnow() - timedelta(days=30)
        }).scalar() or 0

        # Get policies sold by agents under this provider
        total_policies = db.execute(text("""
            SELECT COUNT(*) FROM policies p
            JOIN agents a ON p.agent_id = a.agent_id
            WHERE a.provider_id = :provider_id
        """), {"provider_id": current_user.user_id}).scalar() or 0

        # Monthly revenue
        current_month = datetime.utcnow().replace(day=1)
        monthly_revenue_result = db.execute(text("""
            SELECT COALESCE(SUM(p.premium_amount), 0) FROM policies p
            JOIN agents a ON p.agent_id = a.agent_id
            WHERE a.provider_id = :provider_id AND p.created_at >= :current_month
        """), {
            "provider_id": current_user.user_id,
            "current_month": current_month
        }).scalar()
        monthly_revenue = float(monthly_revenue_result) if monthly_revenue_result else 0.0

        # Pending verifications
        pending_verifications = db.execute(text("""
            SELECT COUNT(*) FROM agents
            WHERE provider_id = :provider_id AND verification_status = 'pending'
        """), {"provider_id": current_user.user_id}).scalar() or 0

        # Top performing agents
        top_agents = db.execute(text("""
            SELECT a.agent_id, u.full_name, a.total_policies_sold,
                   COALESCE(a.total_premium_collected, 0) as total_premium
            FROM agents a
            JOIN users u ON a.user_id = u.user_id
            WHERE a.provider_id = :provider_id AND a.status = 'active'
            ORDER BY a.total_premium_collected DESC
            LIMIT 5
        """), {"provider_id": current_user.user_id}).fetchall()

        top_performing_agents = [
            {
                "agentId": row[0],
                "name": row[1],
                "policiesSold": row[2] or 0,
                "totalPremium": float(row[3]) if row[3] else 0.0
            }
            for row in top_agents
        ]

        # Recent policies
        recent_policies_result = db.execute(text("""
            SELECT p.policy_id, p.policy_number, u.full_name as customer_name,
                   p.premium_amount, p.created_at
            FROM policies p
            JOIN customers c ON p.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            JOIN agents a ON p.agent_id = a.agent_id
            WHERE a.provider_id = :provider_id
            ORDER BY p.created_at DESC
            LIMIT 10
        """), {"provider_id": current_user.user_id}).fetchall()

        recent_policies = [
            {
                "policyId": row[0],
                "policyNumber": row[1],
                "customerName": row[2],
                "premiumAmount": float(row[3]) if row[3] else 0.0,
                "createdAt": row[4].isoformat() if row[4] else None
            }
            for row in recent_policies_result
        ]

        return ProviderOverviewResponse(
            totalAgents=total_agents,
            activeAgents=active_agents,
            totalPolicies=total_policies,
            monthlyRevenue=monthly_revenue,
            pendingVerifications=pending_verifications,
            topPerformingAgents=top_performing_agents,
            recentPolicies=recent_policies
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch provider overview: {str(e)}"
        )


# =====================================================
# REGIONAL MANAGER DASHBOARD ENDPOINTS
# =====================================================

class RegionalOverviewResponse(BaseModel):
    totalAgents: int
    activeAgents: int
    regionalRevenue: float
    monthlyGrowth: float
    topPerformers: List[Dict[str, Any]]
    regionalStats: Dict[str, Any]


@router.get("/regional-overview", response_model=RegionalOverviewResponse)
async def get_regional_overview(
    region: str = Query(..., description="Region identifier"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get regional manager dashboard overview"""
    try:
        # Check permissions - only regional manager can access
        if current_user.role != 'regional_manager':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. Regional manager role required."
            )

        # Get agents in this region
        total_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents
            WHERE region = :region AND status = 'active'
        """), {"region": region}).scalar() or 0

        active_agents = db.execute(text("""
            SELECT COUNT(*) FROM agents a
            JOIN users u ON a.user_id = u.user_id
            WHERE a.region = :region AND a.status = 'active'
            AND u.last_login_at >= :thirty_days_ago
        """), {
            "region": region,
            "thirty_days_ago": datetime.utcnow() - timedelta(days=30)
        }).scalar() or 0

        # Regional revenue (current month)
        current_month = datetime.utcnow().replace(day=1)
        regional_revenue_result = db.execute(text("""
            SELECT COALESCE(SUM(p.premium_amount), 0) FROM policies p
            JOIN agents a ON p.agent_id = a.agent_id
            WHERE a.region = :region AND p.created_at >= :current_month
        """), {
            "region": region,
            "current_month": current_month
        }).scalar()
        regional_revenue = float(regional_revenue_result) if regional_revenue_result else 0.0

        # Monthly growth (compared to previous month)
        last_month = (current_month - timedelta(days=1)).replace(day=1)
        last_month_revenue_result = db.execute(text("""
            SELECT COALESCE(SUM(p.premium_amount), 0) FROM policies p
            JOIN agents a ON p.agent_id = a.agent_id
            WHERE a.region = :region AND p.created_at >= :last_month
            AND p.created_at < :current_month
        """), {
            "region": region,
            "last_month": last_month,
            "current_month": current_month
        }).scalar()
        last_month_revenue = float(last_month_revenue_result) if last_month_revenue_result else 0.0

        monthly_growth = 0.0
        if last_month_revenue > 0:
            monthly_growth = ((regional_revenue - last_month_revenue) / last_month_revenue) * 100

        # Top performers in region
        top_performers_result = db.execute(text("""
            SELECT a.agent_id, u.full_name, a.total_policies_sold,
                   COALESCE(a.total_premium_collected, 0) as total_premium
            FROM agents a
            JOIN users u ON a.user_id = u.user_id
            WHERE a.region = :region AND a.status = 'active'
            ORDER BY a.total_premium_collected DESC
            LIMIT 10
        """), {"region": region}).fetchall()

        top_performers = [
            {
                "agentId": row[0],
                "name": row[1],
                "policiesSold": row[2] or 0,
                "totalPremium": float(row[3]) if row[3] else 0.0
            }
            for row in top_performers_result
        ]

        # Regional statistics
        regional_stats = {
            "totalPolicies": db.execute(text("""
                SELECT COUNT(*) FROM policies p
                JOIN agents a ON p.agent_id = a.agent_id
                WHERE a.region = :region
            """), {"region": region}).scalar() or 0,
            "activePolicies": db.execute(text("""
                SELECT COUNT(*) FROM policies p
                JOIN agents a ON p.agent_id = a.agent_id
                WHERE a.region = :region AND p.status = 'active'
            """), {"region": region}).scalar() or 0,
            "totalCustomers": db.execute(text("""
                SELECT COUNT(DISTINCT c.customer_id) FROM customers c
                JOIN policies p ON c.customer_id = p.customer_id
                JOIN agents a ON p.agent_id = a.agent_id
                WHERE a.region = :region
            """), {"region": region}).scalar() or 0,
        }

        return RegionalOverviewResponse(
            totalAgents=total_agents,
            activeAgents=active_agents,
            regionalRevenue=regional_revenue,
            monthlyGrowth=monthly_growth,
            topPerformers=top_performers,
            regionalStats=regional_stats
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch regional overview: {str(e)}"
        )


# =====================================================
# SENIOR AGENT DASHBOARD ENDPOINTS
# =====================================================

class SeniorAgentOverviewResponse(BaseModel):
    personalStats: Dict[str, Any]
    teamStats: Dict[str, Any]
    monthlyRevenue: float
    pendingTasks: int
    topCustomers: List[Dict[str, Any]]
    recentActivities: List[Dict[str, Any]]


@router.get("/senior-agent-overview", response_model=SeniorAgentOverviewResponse)
async def get_senior_agent_overview(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """Get senior agent dashboard overview"""
    try:
        # Check permissions - only senior agent can access
        if current_user.role != 'senior_agent':
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied. Senior agent role required."
            )

        # Get agent record
        agent_result = db.execute(text("""
            SELECT * FROM agents WHERE user_id = :user_id
        """), {"user_id": current_user.user_id}).first()

        if not agent_result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Agent profile not found"
            )

        agent_id = agent_result[0]  # Assuming agent_id is first column

        # Personal statistics
        personal_stats = {
            "totalPoliciesSold": agent_result[4] or 0,  # total_policies_sold
            "totalPremiumCollected": float(agent_result[5]) if agent_result[5] else 0.0,  # total_premium_collected
            "activePolicyholders": agent_result[6] or 0,  # active_policyholders
            "conversionRate": 0.0,  # Could be calculated
        }

        # Team statistics (for senior agents who manage junior agents)
        team_stats = {
            "teamSize": db.execute(text("""
                SELECT COUNT(*) FROM agent_hierarchy
                WHERE senior_agent_id = :agent_id
            """), {"agent_id": agent_id}).scalar() or 0,
            "teamPolicies": db.execute(text("""
                SELECT COUNT(*) FROM policies p
                JOIN agent_hierarchy ah ON p.agent_id = ah.junior_agent_id
                WHERE ah.senior_agent_id = :agent_id
            """), {"agent_id": agent_id}).scalar() or 0,
            "teamRevenue": float(db.execute(text("""
                SELECT COALESCE(SUM(p.premium_amount), 0) FROM policies p
                JOIN agent_hierarchy ah ON p.agent_id = ah.junior_agent_id
                WHERE ah.senior_agent_id = :agent_id
            """), {"agent_id": agent_id}).scalar() or 0.0),
        }

        # Monthly revenue
        current_month = datetime.utcnow().replace(day=1)
        monthly_revenue_result = db.execute(text("""
            SELECT COALESCE(SUM(p.premium_amount), 0) FROM policies p
            WHERE p.agent_id = :agent_id AND p.created_at >= :current_month
        """), {
            "agent_id": agent_id,
            "current_month": current_month
        }).scalar()
        monthly_revenue = float(monthly_revenue_result) if monthly_revenue_result else 0.0

        # Pending tasks (simplified - could be enhanced)
        pending_tasks = db.execute(text("""
            SELECT COUNT(*) FROM agent_tasks
            WHERE agent_id = :agent_id AND status = 'pending'
        """), {"agent_id": agent_id}).scalar() or 0

        # Top customers
        top_customers_result = db.execute(text("""
            SELECT c.customer_id, u.full_name, COUNT(p.policy_id) as policy_count,
                   COALESCE(SUM(p.premium_amount), 0) as total_premium
            FROM customers c
            JOIN users u ON c.user_id = u.user_id
            LEFT JOIN policies p ON c.customer_id = p.customer_id AND p.agent_id = :agent_id
            GROUP BY c.customer_id, u.full_name
            HAVING COUNT(p.policy_id) > 0
            ORDER BY total_premium DESC
            LIMIT 5
        """), {"agent_id": agent_id}).fetchall()

        top_customers = [
            {
                "customerId": row[0],
                "name": row[1],
                "policyCount": row[2] or 0,
                "totalPremium": float(row[3]) if row[3] else 0.0
            }
            for row in top_customers_result
        ]

        # Recent activities
        recent_activities_result = db.execute(text("""
            SELECT 'policy_sold' as activity_type, p.policy_number, u.full_name,
                   p.created_at, p.premium_amount
            FROM policies p
            JOIN customers c ON p.customer_id = c.customer_id
            JOIN users u ON c.user_id = u.user_id
            WHERE p.agent_id = :agent_id
            ORDER BY p.created_at DESC
            LIMIT 10
        """), {"agent_id": agent_id}).fetchall()

        recent_activities = [
            {
                "type": row[0],
                "description": f"Policy {row[1]} sold to {row[2]}",
                "timestamp": row[3].isoformat() if row[3] else None,
                "amount": float(row[4]) if row[4] else 0.0
            }
            for row in recent_activities_result
        ]

        return SeniorAgentOverviewResponse(
            personalStats=personal_stats,
            teamStats=team_stats,
            monthlyRevenue=monthly_revenue,
            pendingTasks=pending_tasks,
            topCustomers=top_customers,
            recentActivities=recent_activities
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch senior agent overview: {str(e)}"
        )
