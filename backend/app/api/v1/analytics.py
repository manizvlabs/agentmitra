"""
Analytics API Endpoints for Business Intelligence and Reporting
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime, timedelta, date
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
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

