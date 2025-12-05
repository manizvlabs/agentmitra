"""
Analytics API Endpoints for Business Intelligence and Reporting
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from datetime import datetime, timedelta, date
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.core.auth_middleware import (
    get_current_user_context,
    UserContext,
    require_any_role,
    require_permission
)
from app.core.monitoring import analytics_monitor
from app.services.analytics_service import AnalyticsService
from app.services.roi_calculation_service import ROICalculationService
from app.services.revenue_forecasting_service import RevenueForecastingService
from app.services.hot_leads_service import HotLeadsService
from app.services.at_risk_customers_service import AtRiskCustomersService
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
logger = logging.getLogger(__name__)


# =====================================================
# ROI CALCULATION ENDPOINTS
# =====================================================

@router.get("/roi/agent/{agent_id}")
async def get_agent_roi_analytics(
    agent_id: str,
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get comprehensive ROI analytics for a specific agent"""
    try:
        roi_data = ROICalculationService.calculate_agent_roi(agent_id=agent_id, timeframe=period)

        return {
            "success": True,
            "data": roi_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to calculate agent ROI: {str(e)}")


@router.get("/roi/dashboard/{agent_id}")
async def get_roi_dashboard_data(
    agent_id: str,
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get ROI dashboard data formatted for frontend consumption"""
    try:
        roi_data = ROICalculationService.calculate_agent_roi(agent_id=agent_id, timeframe=period)

        # Format data for dashboard widgets
        dashboard_data = {
            'overall_roi_score': {
                'score': roi_data['overall_roi'],
                'grade': roi_data['roi_grade'],
                'trend': roi_data['roi_trend'],
                'change': roi_data['roi_change']
            },
            'revenue_performance': {
                'total_revenue': roi_data['total_revenue'],
                'new_policies': roi_data['new_policies'],
                'revenue_growth': roi_data['revenue_growth'],
                'average_premium': roi_data['average_premium'],
                'collection_rate': roi_data['collection_rate']
            },
            'conversion_funnel': {
                'total_leads': roi_data['total_leads'],
                'contacted_leads': roi_data['contacted_leads'],
                'total_quotes': roi_data['total_quotes'],
                'total_policies': roi_data['total_policies'],
                'contact_rate': roi_data['contact_rate'],
                'quote_rate': roi_data['quote_rate'],
                'conversion_rate': roi_data['conversion_rate']
            },
            'action_items': roi_data['action_items'],
            'predictive_insights': roi_data['predictive_insights'],
            'efficiency_metrics': {
                'collection_rate': roi_data['collection_rate'],
                'retention_rate': roi_data['retention_rate'],
                'avg_response_time': roi_data['avg_response_time']
            }
        }

        return {
            "success": True,
            "data": dashboard_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get ROI dashboard data: {str(e)}")


# =====================================================
# REVENUE FORECASTING ENDPOINTS
# =====================================================

@router.get("/forecast/revenue/{agent_id}")
async def get_revenue_forecast(
    agent_id: str,
    forecast_period: str = Query("3m", regex="^(1m|3m|6m|1y)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get comprehensive revenue forecast with scenario analysis"""
    try:
        forecast_data = RevenueForecastingService.generate_revenue_forecast(
            agent_id=agent_id,
            forecast_period=forecast_period
        )

        return {
            "success": True,
            "data": forecast_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate revenue forecast: {str(e)}")


@router.get("/forecast/dashboard/{agent_id}")
async def get_forecast_dashboard_data(
    agent_id: str,
    forecast_period: str = Query("3m", regex="^(1m|3m|6m|1y)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get forecast dashboard data formatted for frontend consumption"""
    try:
        forecast_data = RevenueForecastingService.generate_revenue_forecast(
            agent_id=agent_id,
            forecast_period=forecast_period
        )

        # Format data for dashboard widgets
        dashboard_data = {
            'forecast_summary': {
                'projected_revenue': forecast_data['projected_revenue'],
                'revenue_growth': forecast_data['revenue_growth'],
                'confidence_level': forecast_data['confidence_level'],
                'forecast_period': forecast_data['forecast_period']
            },
            'scenario_analysis': {
                'best_case': forecast_data['best_case'],
                'base_case': forecast_data['base_case'],
                'worst_case': forecast_data['worst_case']
            },
            'forecast_chart': forecast_data['forecast_chart_data'],
            'risk_factors': forecast_data['risk_factors']
        }

        return {
            "success": True,
            "data": dashboard_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get forecast dashboard data: {str(e)}")


# =====================================================
# HOT LEADS ENDPOINTS
# =====================================================

@router.get("/leads/hot/{agent_id}")
async def get_hot_leads(
    agent_id: str,
    priority: str = Query("all", regex="^(all|high|medium|low)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get hot leads and opportunities for an agent"""
    try:
        leads_data = HotLeadsService.get_hot_leads(agent_id=agent_id, priority_filter=priority)

        return {
            "success": True,
            "data": leads_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get hot leads: {str(e)}")


@router.get("/leads/dashboard/{agent_id}")
@analytics_monitor("leads.dashboard")
async def get_leads_dashboard_data(
    agent_id: str,
    priority: str = Query("all", regex="^(all|high|medium|low)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get leads dashboard data formatted for frontend consumption"""
    try:
        leads_data = HotLeadsService.get_hot_leads(agent_id=agent_id, priority_filter=priority)

        # Format data for dashboard widgets
        dashboard_data = {
            'leads_summary': {
                'hot_leads_count': leads_data['hot_leads_count'],
                'total_potential_value': leads_data['total_potential_value'],
                'conversion_rate': leads_data['conversion_rate'],
                'total_leads_count': leads_data['total_leads_count']
            },
            'leads_list': leads_data['leads'],
            'priority_breakdown': leads_data['summary']['priority_breakdown']
        }

        return {
            "success": True,
            "data": dashboard_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get leads dashboard data: {str(e)}")


@router.get("/leads/{lead_id}/details")
async def get_lead_details(
    lead_id: str,
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get detailed information about a specific lead"""
    try:
        lead_details = HotLeadsService.get_lead_details(lead_id=lead_id)

        if not lead_details:
            raise HTTPException(status_code=404, detail="Lead not found")

        return {
            "success": True,
            "data": lead_details,
            "generated_at": datetime.utcnow().isoformat()
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get lead details: {str(e)}")


# =====================================================
# AT-RISK CUSTOMERS ENDPOINTS
# =====================================================

@router.get("/customers/at-risk/{agent_id}")
async def get_at_risk_customers(
    agent_id: str,
    risk_level: str = Query("all", regex="^(all|high|medium|low)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get at-risk customers for an agent with retention recommendations"""
    try:
        customers_data = AtRiskCustomersService.get_at_risk_customers(
            agent_id=agent_id,
            risk_level_filter=risk_level
        )

        return {
            "success": True,
            "data": customers_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get at-risk customers: {str(e)}")


@router.get("/customers/retention/dashboard/{agent_id}")
async def get_retention_dashboard_data(
    agent_id: str,
    risk_level: str = Query("all", regex="^(all|high|medium|low)$"),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get retention dashboard data formatted for frontend consumption"""
    try:
        customers_data = AtRiskCustomersService.get_at_risk_customers(
            agent_id=agent_id,
            risk_level_filter=risk_level
        )

        # Format data for dashboard widgets
        dashboard_data = {
            'retention_summary': {
                'at_risk_count': customers_data['at_risk_count'],
                'total_retention_value': customers_data['total_retention_value'],
                'retention_success_rate': customers_data['retention_success_rate'],
                'retention_opportunities': customers_data['summary']['retention_opportunities']
            },
            'risk_breakdown': {
                'high_risk': customers_data['summary']['high_risk_count'],
                'medium_risk': customers_data['summary']['medium_risk_count'],
                'low_risk': customers_data['summary']['low_risk_count']
            },
            'customers_list': customers_data['customers']
        }

        return {
            "success": True,
            "data": dashboard_data,
            "generated_at": datetime.utcnow().isoformat()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get retention dashboard data: {str(e)}")


@router.get("/customers/{customer_id}/retention-plan")
async def get_customer_retention_plan(
    customer_id: str,
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get detailed retention plan for a specific customer"""
    try:
        retention_plan = AtRiskCustomersService.get_customer_retention_plan(customer_id=customer_id)

        if not retention_plan:
            raise HTTPException(status_code=404, detail="Customer retention plan not found")

        return {
            "success": True,
            "data": retention_plan,
            "generated_at": datetime.utcnow().isoformat()
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get customer retention plan: {str(e)}")


# =====================================================
# ADVANCED ANALYTICS ENDPOINTS
# =====================================================

@router.get("/comprehensive/dashboard")
async def get_comprehensive_dashboard(
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
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
        logger.error(f"Comprehensive dashboard error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get comprehensive dashboard: {str(e)}")


@router.get("/agents/performance/{agent_id}")
async def get_agent_performance_analytics(
    agent_id: str,
    period: str = Query("30d", regex="^(7d|30d|90d|1y)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager"])),
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
        logger.error(f"Agent analytics error: {e}")
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
        logger.error(f"All agents analytics error: {e}")
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
        logger.error(f"Policy analytics error: {e}")
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
        logger.error(f"Payment analytics error: {e}")
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
        logger.error(f"User engagement analytics error: {e}")
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
        logger.error(f"Custom report generation error: {e}")
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
        logger.error(f"Analytics data export error: {e}")
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
        logger.error(f"Performance summary generation error: {e}")
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
        logger.error(f"Business insights generation error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate business insights: {str(e)}")


# =====================================================
# DASHBOARD ANALYTICS
# =====================================================

@router.get("/dashboard/overview", response_model=DashboardKPIs)
@analytics_monitor("dashboard.overview")
async def get_global_dashboard(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
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
        logger.error(f"Global dashboard KPIs error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch global dashboard KPIs: {str(e)}")


@router.get("/dashboard/top-agents", response_model=List[TopPerformer])
@analytics_monitor("dashboard.top_agents")
async def get_top_performing_agents(
    limit: int = Query(10, ge=1, le=50),
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
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
        logger.error(f"Top performing agents error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch top performing agents: {str(e)}")


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
        logger.error(f"Agent dashboard KPIs error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch dashboard KPIs: {str(e)}")


@router.get("/dashboard/charts/revenue-trends", response_model=List[TrendData])
async def get_revenue_trends_chart(
    agent_id: Optional[str] = None,
    months: int = Query(12, ge=1, le=24),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get revenue trends chart data"""
    try:
        repo = AnalyticsRepository(db)
        return repo.get_revenue_trends(agent_id=agent_id, months=months)
    except Exception as e:
        logger.error(f"Revenue trends error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch revenue trends: {str(e)}")


@router.get("/dashboard/charts/policy-trends", response_model=List[TrendData])
async def get_policy_trends_chart(
    agent_id: Optional[str] = None,
    months: int = Query(12, ge=1, le=24),
    current_user: UserContext = Depends(require_any_role(["super_admin", "provider_admin", "regional_manager", "senior_agent"])),
    db: Session = Depends(get_db)
):
    """Get policy creation trends chart data"""
    try:
        repo = AnalyticsRepository(db)
        return repo.get_policy_trends(agent_id=agent_id, months=months)
    except Exception as e:
        logger.error(f"Policy trends error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to fetch policy trends: {str(e)}")


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
        logger.error(f"Agent performance metrics error: {e}")
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
        logger.error(f"Agent comparison error: {e}")
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
        logger.error(f"Policy analytics error: {e}")
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
        logger.error(f"Revenue analytics error: {e}")
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
        logger.error(f"Presentation analytics error: {e}")
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
        logger.error(f"Presentation trends error: {e}")
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
        logger.error(f"Report generation error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate report: {str(e)}")


@router.get("/reports/generate")
async def generate_report(
    report_type: str = "policies",
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    user_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Generate reports based on type and date range - GET version for frontend compatibility"""
    try:
        repo = AnalyticsRepository(db)

        # Parse dates
        date_range = None
        if start_date and end_date:
            try:
                start = datetime.fromisoformat(start_date.replace('Z', '+00:00'))
                end = datetime.fromisoformat(end_date.replace('Z', '+00:00'))
                date_range = (start.date(), end.date())
            except:
                # If parsing fails, use current month
                end_date_obj = datetime.now().date()
                start_date_obj = end_date_obj.replace(day=1)
                date_range = (start_date_obj, end_date_obj)

        # Generate report based on type
        if report_type == "policies":
            policy_data = repo.get_policy_analytics(agent_id=user_id, date_range=date_range)
            return {
                "summary": {
                    "total_count": policy_data.get("total_policies", 0),
                    "total_amount": policy_data.get("total_premium", 0),
                    "success_rate": policy_data.get("active_policies_rate", 0)
                },
                "details": [
                    {"title": "Active Policies", "value": policy_data.get("active_policies", 0)},
                    {"title": "Total Premium", "value": f"₹{policy_data.get('total_premium', 0):,.2f}"},
                    {"title": "New Policies", "value": policy_data.get("new_policies", 0)}
                ]
            }
        elif report_type == "payments":
            payment_data = repo.get_revenue_analytics(agent_id=user_id, date_range=date_range)
            return {
                "summary": {
                    "total_count": payment_data.get("total_payments", 0),
                    "total_amount": payment_data.get("total_revenue", 0)
                },
                "details": [
                    {"title": "Total Revenue", "value": f"₹{payment_data.get('total_revenue', 0):,.2f}"},
                    {"title": "Pending Payments", "value": payment_data.get("pending_payments", 0)},
                    {"title": "Overdue Payments", "value": payment_data.get("overdue_payments", 0)}
                ]
            }
        elif report_type == "customers":
            # Use dashboard KPIs for customer data
            customer_data = repo.get_dashboard_kpis(agent_id=user_id, date_range=date_range)
            return {
                "summary": {
                    "total_count": customer_data.get("total_customers", 0),
                    "total_amount": customer_data.get("total_premium", 0)
                },
                "details": [
                    {"title": "Total Customers", "value": customer_data.get("total_customers", 0)},
                    {"title": "Active Customers", "value": customer_data.get("active_customers", 0)},
                    {"title": "New Customers", "value": customer_data.get("new_customers", 0)}
                ]
            }
        elif report_type == "performance":
            perf_data = repo.get_agent_performance_metrics(agent_id=user_id, date_range=date_range)
            return {
                "summary": {
                    "total_count": perf_data.get("total_policies_sold", 0),
                    "total_amount": perf_data.get("total_revenue", 0)
                },
                "details": [
                    {"title": "Policies Sold", "value": perf_data.get("total_policies_sold", 0)},
                    {"title": "Conversion Rate", "value": f"{perf_data.get('conversion_rate', 0):.1f}%"},
                    {"title": "Customer Satisfaction", "value": f"{perf_data.get('customer_satisfaction', 0):.1f}/5"}
                ]
            }
        else:
            # Default to policies
            policy_data = repo.get_policy_analytics(agent_id=user_id, date_range=date_range)
            return {
                "summary": {
                    "total_count": policy_data.get("total_policies", 0),
                    "total_amount": policy_data.get("total_premium", 0)
                },
                "details": []
            }

    except Exception as e:
        logger.error(f"Report generation error: {e}")
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
        logger.error(f"Analytics summary generation error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to generate analytics summary: {str(e)}")

