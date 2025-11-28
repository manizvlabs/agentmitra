"""
Analytics API Endpoints for Business Intelligence and Reporting
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime, timedelta, date
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.services.analytics_service import AnalyticsService
from app.repositories.analytics_repository import AnalyticsRepository
from app.models.analytics import (
    DashboardKPIs,
    AgentPerformanceMetrics,
    PolicyAnalytics,
    RevenueAnalytics,
    PresentationAnalytics,
    TrendData,
    TopPerformer,
    DateRangeFilter,
    AnalyticsFilter
)

router = APIRouter()


# =====================================================
# ADVANCED ANALYTICS ENDPOINTS
# =====================================================

@router.get("/comprehensive/dashboard")
async def get_comprehensive_dashboard(
    db: Session = Depends(get_db)
):
    """Get comprehensive dashboard analytics with KPIs and trends"""
    try:
        analytics_service = AnalyticsService(db)
        dashboard_data = await analytics_service.get_dashboard_kpis()

        return {
            "success": True,
            "data": dashboard_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get comprehensive dashboard: {str(e)}")


@router.get("/agents/performance/{agent_id}")
async def get_agent_performance_analytics(
    agent_id: str,
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Get detailed performance analytics for a specific agent"""
    try:
        analytics_service = AnalyticsService(db)
        analytics_data = await analytics_service.get_agent_performance_analytics(
            agent_id=agent_id,
            start_date=start_date,
            end_date=end_date,
            period=period
        )

        return {
            "success": True,
            "data": analytics_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agent analytics: {str(e)}")


@router.get("/agents/performance")
async def get_all_agents_performance_analytics(
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Get performance analytics for all agents"""
    try:
        analytics_service = AnalyticsService(db)
        analytics_data = await analytics_service.get_agent_performance_analytics(
            agent_id=None,
            start_date=start_date,
            end_date=end_date,
            period=period
        )

        return {
            "success": True,
            "data": analytics_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get agents analytics: {str(e)}")


@router.get("/policies/analytics")
async def get_policy_analytics(
    agent_id: Optional[str] = None,
    policy_type: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Get comprehensive policy analytics"""
    try:
        analytics_service = AnalyticsService(db)
        analytics_data = await analytics_service.get_policy_analytics(
            start_date=start_date,
            end_date=end_date,
            agent_id=agent_id,
            policy_type=policy_type
        )

        return {
            "success": True,
            "data": analytics_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get policy analytics: {str(e)}")


@router.get("/payments/analytics")
async def get_payment_analytics(
    gateway: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Get comprehensive payment analytics"""
    try:
        analytics_service = AnalyticsService(db)
        analytics_data = await analytics_service.get_payment_analytics(
            start_date=start_date,
            end_date=end_date,
            gateway=gateway
        )

        return {
            "success": True,
            "data": analytics_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get payment analytics: {str(e)}")


@router.get("/users/engagement")
async def get_user_engagement_analytics(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """Get user engagement and behavior analytics"""
    try:
        analytics_service = AnalyticsService(db)
        analytics_data = await analytics_service.get_user_engagement_analytics(
            start_date=start_date,
            end_date=end_date
        )

        return {
            "success": True,
            "data": analytics_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get user engagement analytics: {str(e)}")


@router.post("/reports/custom")
async def generate_custom_report(
    report_config: dict,
    format: str = Query("json", regex="^(json|csv|pdf)$"),
    db: Session = Depends(get_db)
):
    """Generate custom analytics report"""
    try:
        analytics_service = AnalyticsService(db)
        report_data = await analytics_service.generate_custom_report(
            report_config=report_config,
            format=format
        )

        return {
            "success": True,
            "data": report_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate custom report: {str(e)}")


@router.get("/export/{data_type}")
async def export_analytics_data(
    data_type: str,
    format: str = Query("csv", regex="^(csv|json|excel)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    agent_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Export analytics data for external analysis"""
    try:
        filters = {}
        if start_date:
            filters["start_date"] = start_date
        if end_date:
            filters["end_date"] = end_date
        if agent_id:
            filters["agent_id"] = agent_id

        analytics_service = AnalyticsService(db)
        export_data = await analytics_service.export_analytics_data(
            data_type=data_type,
            format=format,
            filters=filters
        )

        return {
            "success": True,
            "data": export_data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to export analytics data: {str(e)}")


@router.get("/reports/performance-summary")
async def get_performance_summary_report(
    period: str = Query("monthly", regex="^(weekly|monthly|quarterly|yearly)$"),
    db: Session = Depends(get_db)
):
    """Get performance summary report"""
    try:
        # Calculate date range based on period
        end_date = datetime.utcnow()
        if period == "weekly":
            start_date = end_date - timedelta(days=7)
        elif period == "monthly":
            start_date = end_date - timedelta(days=30)
        elif period == "quarterly":
            start_date = end_date - timedelta(days=90)
        else:  # yearly
            start_date = end_date - timedelta(days=365)

        analytics_service = AnalyticsService(db)

        # Get all analytics data
        dashboard_kpis = await analytics_service.get_dashboard_kpis()
        agent_analytics = await analytics_service.get_agent_performance_analytics(
            start_date=start_date, end_date=end_date
        )
        policy_analytics = await analytics_service.get_policy_analytics(
            start_date=start_date, end_date=end_date
        )
        payment_analytics = await analytics_service.get_payment_analytics(
            start_date=start_date, end_date=end_date
        )

        summary_report = {
            "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
            "dashboard_kpis": dashboard_kpis,
            "agent_performance": agent_analytics,
            "policy_analytics": policy_analytics,
            "payment_analytics": payment_analytics,
            "generated_at": datetime.utcnow().isoformat()
        }

        return {
            "success": True,
            "data": summary_report
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate performance summary: {str(e)}")


@router.get("/insights/business-intelligence")
async def get_business_intelligence_insights(
    db: Session = Depends(get_db)
):
    """Get business intelligence insights and recommendations"""
    try:
        analytics_service = AnalyticsService(db)

        # Get current period data (last 30 days)
        end_date = datetime.utcnow()
        start_date = end_date - timedelta(days=30)

        # Gather insights from different analytics
        dashboard_data = await analytics_service.get_dashboard_kpis()
        agent_data = await analytics_service.get_agent_performance_analytics(
            start_date=start_date, end_date=end_date
        )
        policy_data = await analytics_service.get_policy_analytics(
            start_date=start_date, end_date=end_date
        )

        # Generate business insights
        insights = []

        # Agent performance insights
        if "top_agents" in dashboard_data:
            top_agent = dashboard_data["top_agents"][0] if dashboard_data["top_agents"] else None
            if top_agent:
                insights.append({
                    "type": "performance",
                    "title": "Top Performing Agent",
                    "description": f"{top_agent['name']} leads with {top_agent['policies_sold']} policies sold",
                    "recommendation": "Consider promoting successful strategies across the team"
                })

        # Growth insights
        if "monthly_growth" in dashboard_data:
            growth = dashboard_data["monthly_growth"]
            if growth.get("policies_growth", 0) > 15:
                insights.append({
                    "type": "growth",
                    "title": "Strong Policy Growth",
                    "description": f"Policy sales grew by {growth['policies_growth']:.1f}% this month",
                    "recommendation": "Capitalize on current market momentum"
                })

        # Policy type insights
        if "policy_distribution" in policy_data:
            distribution = policy_data["policy_distribution"]
            max_type = max(distribution.keys(), key=lambda k: distribution[k]["count"])
            insights.append({
                "type": "product",
                "title": "Popular Policy Type",
                "description": f"{max_type.title()} policies are most popular ({distribution[max_type]['percentage']:.1f}%)",
                "recommendation": "Focus marketing efforts on this policy type"
            })

        # Default insights if none generated
        if not insights:
            insights = [{
                "type": "general",
                "title": "Analytics Active",
                "description": "Business intelligence system is collecting and analyzing data",
                "recommendation": "Continue monitoring performance metrics"
            }]

        return {
            "success": True,
            "data": {
                "insights": insights,
                "data_quality": {
                    "agents_analyzed": dashboard_data.get("total_agents", 0),
                    "policies_analyzed": dashboard_data.get("total_policies", 0),
                    "date_range": f"{start_date.date()} to {end_date.date()}"
                },
                "generated_at": datetime.utcnow().isoformat()
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate business insights: {str(e)}")


# =====================================================
# DASHBOARD ANALYTICS
# =====================================================

@router.get("/dashboard/overview", response_model=DashboardKPIs)
async def get_global_dashboard(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get global dashboard KPIs (all agents)"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        kpis = repo.get_dashboard_kpis(agent_id=None, date_range=date_range)
        return kpis
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch global dashboard KPIs: {str(e)}")


@router.get("/dashboard/{agent_id}", response_model=DashboardKPIs)
async def get_agent_dashboard(
    agent_id: str,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get comprehensive agent dashboard KPIs"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        kpis = repo.get_dashboard_kpis(agent_id=agent_id, date_range=date_range)
        return kpis
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch dashboard KPIs: {str(e)}")


@router.get("/dashboard/charts/revenue-trends", response_model=List[TrendData])
async def get_revenue_trends_chart(
    agent_id: Optional[str] = None,
    months: int = Query(12, ge=1, le=24),
    db: Session = Depends(get_db)
):
    """Get revenue trends chart data"""
    try:
        repo = AnalyticsRepository(db)
        return repo.get_revenue_trends(agent_id=agent_id, months=months)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch revenue trends: {str(e)}")


@router.get("/dashboard/charts/policy-trends", response_model=List[TrendData])
async def get_policy_trends_chart(
    agent_id: Optional[str] = None,
    months: int = Query(12, ge=1, le=24),
    db: Session = Depends(get_db)
):
    """Get policy creation trends chart data"""
    try:
        repo = AnalyticsRepository(db)
        return repo.get_policy_trends(agent_id=agent_id, months=months)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch policy trends: {str(e)}")


@router.get("/dashboard/top-agents", response_model=List[TopPerformer])
async def get_top_performing_agents(
    limit: int = Query(10, ge=1, le=50),
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get top performing agents by premium collected"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        return repo.get_top_performing_agents(limit=limit, date_range=date_range)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch top performing agents: {str(e)}")


# =====================================================
# AGENT PERFORMANCE ANALYTICS
# =====================================================

@router.get("/agents/{agent_id}/performance", response_model=AgentPerformanceMetrics)
async def get_agent_performance(
    agent_id: str,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get detailed agent performance metrics"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        metrics = repo.get_agent_performance_metrics(agent_id=agent_id, date_range=date_range)
        if not metrics:
            raise HTTPException(status_code=404, detail="Agent not found")

        return metrics
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch agent performance metrics: {str(e)}")


@router.get("/agents/performance/comparison")
async def get_agents_performance_comparison(
    agent_ids: List[str] = Query(...),
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Compare performance metrics across multiple agents"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        comparison_data = []
        for agent_id in agent_ids:
            metrics = repo.get_agent_performance_metrics(agent_id=agent_id, date_range=date_range)
            if metrics:
                comparison_data.append(metrics)

        return {
            "agents": comparison_data,
            "period": {
                "start": start_date.isoformat() if start_date else None,
                "end": end_date.isoformat() if end_date else None
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch agent comparison: {str(e)}")


# =====================================================
# POLICY ANALYTICS
# =====================================================

@router.get("/policies/analytics", response_model=PolicyAnalytics)
async def get_policy_analytics(
    agent_id: Optional[str] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get comprehensive policy analytics"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        return repo.get_policy_analytics(agent_id=agent_id, date_range=date_range)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch policy analytics: {str(e)}")


# =====================================================
# REVENUE AND COMMISSION ANALYTICS
# =====================================================

@router.get("/revenue/analytics", response_model=RevenueAnalytics)
async def get_revenue_analytics(
    agent_id: Optional[str] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db)
):
    """Get comprehensive revenue and commission analytics"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if start_date and end_date:
            date_range = (start_date, end_date)

        return repo.get_revenue_analytics(agent_id=agent_id, date_range=date_range)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch revenue analytics: {str(e)}")


# =====================================================
# PRESENTATION ANALYTICS
# =====================================================

@router.get("/presentations/{presentation_id}/analytics", response_model=PresentationAnalytics)
async def get_presentation_analytics(
    presentation_id: str,
    db: Session = Depends(get_db)
):
    """Get comprehensive presentation analytics"""
    try:
        repo = AnalyticsRepository(db)
        analytics = repo.get_presentation_analytics(presentation_id=presentation_id)

        if not analytics:
            raise HTTPException(status_code=404, detail="Presentation not found")

        return analytics
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch presentation analytics: {str(e)}")


@router.get("/presentations/{presentation_id}/analytics/trends")
async def get_presentation_trends(
    presentation_id: str,
    days: int = Query(30, ge=1, le=90),
    db: Session = Depends(get_db)
):
    """Get presentation view trends over time"""
    try:
        repo = AnalyticsRepository(db)
        analytics = repo.get_presentation_analytics(presentation_id=presentation_id)

        if not analytics:
            raise HTTPException(status_code=404, detail="Presentation not found")

        # Filter trends for the specified days
        cutoff_date = datetime.now().date() - timedelta(days=days)
        filtered_trends = [
            trend for trend in analytics.view_trends
            if datetime.strptime(trend["date"], "%Y-%m-%d").date() >= cutoff_date
        ]

        return {
            "presentation_id": presentation_id,
            "trends": filtered_trends,
            "period_days": days
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch presentation trends: {str(e)}")


# =====================================================
# CUSTOM ANALYTICS REPORTS
# =====================================================

class AnalyticsReportRequest(BaseModel):
    """Request model for custom analytics reports"""
    report_type: str  # 'dashboard', 'agent_performance', 'policy', 'revenue'
    agent_id: Optional[str] = None
    date_range: Optional[DateRangeFilter] = None
    filters: Optional[AnalyticsFilter] = None


@router.post("/reports/generate")
async def generate_custom_report(
    request: AnalyticsReportRequest,
    db: Session = Depends(get_db)
):
    """Generate custom analytics reports"""
    try:
        repo = AnalyticsRepository(db)

        date_range = None
        if request.date_range and request.date_range.start_date and request.date_range.end_date:
            date_range = (request.date_range.start_date, request.date_range.end_date)

        if request.report_type == "dashboard":
            data = repo.get_dashboard_kpis(agent_id=request.agent_id, date_range=date_range)
        elif request.report_type == "agent_performance":
            if not request.agent_id:
                raise HTTPException(status_code=400, detail="agent_id required for agent performance report")
            data = repo.get_agent_performance_metrics(agent_id=request.agent_id, date_range=date_range)
        elif request.report_type == "policy":
            data = repo.get_policy_analytics(agent_id=request.agent_id, date_range=date_range)
        elif request.report_type == "revenue":
            data = repo.get_revenue_analytics(agent_id=request.agent_id, date_range=date_range)
        else:
            raise HTTPException(status_code=400, detail=f"Unsupported report type: {request.report_type}")

        return {
            "report_type": request.report_type,
            "generated_at": datetime.now().isoformat(),
            "data": data,
            "filters": {
                "agent_id": request.agent_id,
                "date_range": request.date_range.dict() if request.date_range else None
            }
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate report: {str(e)}")


@router.get("/reports/summary")
async def get_analytics_summary(
    db: Session = Depends(get_db)
):
    """Get a quick summary of all key analytics metrics"""
    try:
        repo = AnalyticsRepository(db)

        # Get current month data
        end_date = datetime.now().date()
        start_date = end_date.replace(day=1)

        dashboard_kpis = repo.get_dashboard_kpis(date_range=(start_date, end_date))
        top_agents = repo.get_top_performing_agents(limit=5, date_range=(start_date, end_date))

        return {
            "current_month": {
                "kpis": dashboard_kpis,
                "top_agents": top_agents
            },
            "generated_at": datetime.now().isoformat()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate analytics summary: {str(e)}")

