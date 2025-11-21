"""
Analytics repository for comprehensive business intelligence queries
"""
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_, desc, asc, text, case, cast, Date, Integer, Float
from sqlalchemy.sql import label
from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime, timedelta, date
import uuid
from app.models.analytics import (
    DashboardKPIs,
    AgentPerformanceMetrics,
    PolicyAnalytics,
    RevenueAnalytics,
    PresentationAnalytics,
    TrendData,
    TopPerformer
)


class AnalyticsRepository:
    """Repository for analytics and business intelligence queries"""

    def __init__(self, db: Session):
        self.db = db

    # =====================================================
    # DASHBOARD ANALYTICS
    # =====================================================

    def get_dashboard_kpis(self, agent_id: Optional[str] = None, date_range: Optional[Tuple[date, date]] = None) -> DashboardKPIs:
        """Get comprehensive dashboard KPIs"""

        # Base query components
        date_filter = ""
        agent_filter = ""

        if date_range:
            start_date, end_date = date_range
            date_filter = f"AND p.created_at BETWEEN '{start_date}' AND '{end_date}'"

        if agent_id:
            agent_filter = f"AND p.agent_id = '{agent_id}'"

        # Total policies query
        total_policies_query = f"""
            SELECT COUNT(*) as count
            FROM lic_schema.insurance_policies p
            WHERE p.status IN ('active', 'approved')
            {agent_filter}
            {date_filter}
        """

        # Active policies query
        active_policies_query = f"""
            SELECT COUNT(*) as count
            FROM lic_schema.insurance_policies p
            WHERE p.status = 'active'
            {agent_filter}
            {date_filter}
        """

        # Premium collected query
        premium_query = f"""
            SELECT
                COALESCE(SUM(p.premium_amount), 0) as total_premium,
                COALESCE(SUM(CASE WHEN pm.payment_date >= CURRENT_DATE - INTERVAL '30 days' THEN pm.amount ELSE 0 END), 0) as monthly_premium
            FROM lic_schema.insurance_policies p
            LEFT JOIN lic_schema.premium_payments pm ON p.policy_id = pm.policy_id AND pm.status = 'completed'
            WHERE p.status IN ('active', 'approved')
            {agent_filter}
        """

        # Customer metrics query
        customer_query = f"""
            SELECT
                COUNT(DISTINCT ph.policyholder_id) as total_customers,
                COUNT(DISTINCT CASE WHEN p.start_date >= CURRENT_DATE - INTERVAL '30 days' THEN ph.policyholder_id END) as new_customers_month
            FROM lic_schema.policyholders ph
            LEFT JOIN lic_schema.insurance_policies p ON ph.policyholder_id = p.policyholder_id
            WHERE p.status IN ('active', 'approved')
            {agent_filter}
        """

        # Execute queries
        total_policies = self.db.execute(text(total_policies_query)).scalar()
        active_policies = self.db.execute(text(active_policies_query)).scalar()
        premium_data = self.db.execute(text(premium_query)).first()
        customer_data = self.db.execute(text(customer_query)).first()

        # Calculate conversion rate (policies created vs converted to active)
        conversion_query = f"""
            SELECT
                COUNT(*) as total_applications,
                COUNT(CASE WHEN status = 'active' THEN 1 END) as active_policies
            FROM lic_schema.insurance_policies p
            WHERE 1=1
            {agent_filter}
            {date_filter}
        """
        conversion_data = self.db.execute(text(conversion_query)).first()
        conversion_rate = (conversion_data.active_policies / conversion_data.total_applications * 100) if conversion_data.total_applications > 0 else 0

        # Calculate average policy value
        avg_policy_value = (premium_data.total_premium / total_policies) if total_policies > 0 else 0

        return DashboardKPIs(
            total_policies=total_policies or 0,
            active_policies=active_policies or 0,
            total_premium_collected=premium_data.total_premium or 0,
            monthly_premium_collected=premium_data.monthly_premium or 0,
            total_customers=customer_data.total_customers or 0,
            active_customers=customer_data.total_customers or 0,  # Approximation
            new_customers_this_month=customer_data.new_customers_month or 0,
            conversion_rate=conversion_rate,
            average_policy_value=avg_policy_value
        )

    # =====================================================
    # AGENT PERFORMANCE ANALYTICS
    # =====================================================

    def get_agent_performance_metrics(self, agent_id: str, date_range: Optional[Tuple[date, date]] = None) -> AgentPerformanceMetrics:
        """Get comprehensive agent performance metrics"""

        agent_uuid = uuid.UUID(agent_id)

        # Date filter
        date_filter = ""
        if date_range:
            start_date, end_date = date_range
            date_filter = f"AND p.created_at BETWEEN '{start_date}' AND '{end_date}'"

        # Agent info query
        agent_info = self.db.execute(text(f"""
            SELECT u.first_name, u.last_name, u.display_name, a.agent_code
            FROM lic_schema.agents a
            JOIN lic_schema.users u ON a.user_id = u.user_id
            WHERE a.agent_id = '{agent_id}'
        """)).first()

        if not agent_info:
            return None

        # Performance metrics query
        metrics_query = f"""
            SELECT
                COUNT(p.policy_id) as total_policies_sold,
                COALESCE(SUM(p.premium_amount), 0) as total_premium_collected,
                COUNT(DISTINCT ph.policyholder_id) as active_policyholders,
                COUNT(CASE WHEN p.created_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as new_policies_month,
                COALESCE(AVG(p.premium_amount), 0) as average_policy_value,
                COUNT(CASE WHEN p.status = 'active' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) as conversion_rate
            FROM lic_schema.insurance_policies p
            LEFT JOIN lic_schema.policyholders ph ON p.policyholder_id = ph.policyholder_id
            WHERE p.agent_id = '{agent_id}'
            AND p.status IN ('active', 'approved', 'pending_approval')
            {date_filter}
        """

        metrics = self.db.execute(text(metrics_query)).first()

        return AgentPerformanceMetrics(
            agent_id=agent_id,
            agent_name=f"{agent_info.first_name} {agent_info.last_name}",
            total_policies_sold=metrics.total_policies_sold or 0,
            total_premium_collected=metrics.total_premium_collected or 0,
            active_policyholders=metrics.active_policyholders or 0,
            new_policies_this_month=metrics.new_policies_month or 0,
            average_policy_value=metrics.average_policy_value or 0,
            conversion_rate=metrics.conversion_rate or 0
        )

    def get_top_performing_agents(self, limit: int = 10, date_range: Optional[Tuple[date, date]] = None) -> List[TopPerformer]:
        """Get top performing agents by premium collected"""

        date_filter = ""
        if date_range:
            start_date, end_date = date_range
            date_filter = f"AND p.created_at BETWEEN '{start_date}' AND '{end_date}'"

        query = f"""
            SELECT
                a.agent_id::text,
                CONCAT(u.first_name, ' ', u.last_name) as agent_name,
                COALESCE(SUM(p.premium_amount), 0) as total_premium,
                COUNT(p.policy_id) as policies_count
            FROM lic_schema.agents a
            JOIN lic_schema.users u ON a.user_id = u.user_id
            LEFT JOIN lic_schema.insurance_policies p ON a.agent_id = p.agent_id
                AND p.status IN ('active', 'approved')
                {date_filter}
            WHERE a.status = 'active'
            GROUP BY a.agent_id, u.first_name, u.last_name
            ORDER BY total_premium DESC
            LIMIT {limit}
        """

        results = self.db.execute(text(query)).all()

        return [
            TopPerformer(
                id=row.agent_id,
                name=row.agent_name,
                value=row.total_premium,
                rank=idx + 1
            )
            for idx, row in enumerate(results)
        ]

    # =====================================================
    # POLICY ANALYTICS
    # =====================================================

    def get_policy_analytics(self, agent_id: Optional[str] = None, date_range: Optional[Tuple[date, date]] = None) -> PolicyAnalytics:
        """Get comprehensive policy analytics"""

        date_filter = ""
        agent_filter = ""

        if date_range:
            start_date, end_date = date_range
            date_filter = f"AND p.created_at BETWEEN '{start_date}' AND '{end_date}'"

        if agent_id:
            agent_filter = f"AND p.agent_id = '{agent_id}'"

        # Policy status distribution
        status_query = f"""
            SELECT
                status,
                COUNT(*) as count
            FROM lic_schema.insurance_policies p
            WHERE 1=1
            {agent_filter}
            {date_filter}
            GROUP BY status
        """

        # Policy type distribution
        type_query = f"""
            SELECT
                policy_type,
                COUNT(*) as count
            FROM lic_schema.insurance_policies p
            WHERE 1=1
            {agent_filter}
            {date_filter}
            GROUP BY policy_type
        """

        # Monthly trends (last 12 months)
        trends_query = f"""
            SELECT
                DATE_TRUNC('month', created_at) as month,
                COUNT(*) as policies_created,
                SUM(premium_amount) as total_premium
            FROM lic_schema.insurance_policies p
            WHERE created_at >= CURRENT_DATE - INTERVAL '12 months'
            {agent_filter}
            GROUP BY DATE_TRUNC('month', created_at)
            ORDER BY month DESC
        """

        # Execute queries
        status_data = self.db.execute(text(status_query)).all()
        type_data = self.db.execute(text(type_query)).all()
        trends_data = self.db.execute(text(trends_query)).all()

        # Process results
        policies_by_status = {row.status: row.count for row in status_data}
        policies_by_type = {row.policy_type: row.count for row in type_data}

        monthly_policy_trends = [
            {
                "month": row.month.strftime("%Y-%m"),
                "policies_created": row.policies_created,
                "total_premium": row.total_premium or 0
            }
            for row in trends_data
        ]

        total_policies = sum(policies_by_status.values())
        active_policies = policies_by_status.get('active', 0)

        return PolicyAnalytics(
            total_policies=total_policies,
            active_policies=active_policies,
            pending_policies=policies_by_status.get('pending_approval', 0),
            draft_policies=policies_by_status.get('draft', 0),
            cancelled_policies=policies_by_status.get('cancelled', 0),
            policies_by_status=policies_by_status,
            policies_by_type=policies_by_type,
            monthly_policy_trends=monthly_policy_trends
        )

    # =====================================================
    # REVENUE AND COMMISSION ANALYTICS
    # =====================================================

    def get_revenue_analytics(self, agent_id: Optional[str] = None, date_range: Optional[Tuple[date, date]] = None) -> RevenueAnalytics:
        """Get comprehensive revenue and commission analytics"""

        date_filter = ""
        agent_filter = ""

        if date_range:
            start_date, end_date = date_range
            date_filter = f"AND pm.payment_date BETWEEN '{start_date}' AND '{end_date}'"

        if agent_id:
            agent_filter = f"AND p.agent_id = '{agent_id}'"

        # Revenue metrics query
        revenue_query = f"""
            SELECT
                COALESCE(SUM(pm.amount), 0) as total_revenue,
                COALESCE(SUM(CASE WHEN pm.payment_date >= CURRENT_DATE - INTERVAL '30 days' THEN pm.amount ELSE 0 END), 0) as monthly_revenue,
                COALESCE(SUM(CASE WHEN pm.payment_date >= CURRENT_DATE - INTERVAL '90 days' THEN pm.amount ELSE 0 END), 0) as quarterly_revenue,
                COALESCE(SUM(CASE WHEN EXTRACT(YEAR FROM pm.payment_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN pm.amount ELSE 0 END), 0) as yearly_revenue
            FROM lic_schema.premium_payments pm
            JOIN lic_schema.insurance_policies p ON pm.policy_id = p.policy_id
            WHERE pm.status = 'completed'
            {agent_filter}
            {date_filter}
        """

        # Commission calculation (assuming commission is stored or can be calculated)
        commission_query = f"""
            SELECT
                COALESCE(SUM(p.premium_amount * COALESCE(a.commission_rate, 0) / 100), 0) as total_commission,
                COALESCE(AVG(a.commission_rate), 0) as average_commission_rate
            FROM lic_schema.insurance_policies p
            JOIN lic_schema.agents a ON p.agent_id = a.agent_id
            LEFT JOIN lic_schema.premium_payments pm ON p.policy_id = pm.policy_id AND pm.status = 'completed'
            WHERE p.status IN ('active', 'approved')
            {agent_filter}
            {date_filter}
        """

        # Revenue by provider
        provider_revenue_query = f"""
            SELECT
                pr.provider_name,
                COALESCE(SUM(pm.amount), 0) as revenue
            FROM lic_schema.premium_payments pm
            JOIN lic_schema.insurance_policies p ON pm.policy_id = p.policy_id
            JOIN shared.insurance_providers pr ON p.provider_id = pr.provider_id
            WHERE pm.status = 'completed'
            {agent_filter}
            {date_filter}
            GROUP BY pr.provider_name
            ORDER BY revenue DESC
        """

        # Monthly revenue trends
        trends_query = f"""
            SELECT
                DATE_TRUNC('month', pm.payment_date) as month,
                COALESCE(SUM(pm.amount), 0) as revenue
            FROM lic_schema.premium_payments pm
            JOIN lic_schema.insurance_policies p ON pm.policy_id = p.policy_id
            WHERE pm.status = 'completed'
            AND pm.payment_date >= CURRENT_DATE - INTERVAL '12 months'
            {agent_filter}
            GROUP BY DATE_TRUNC('month', pm.payment_date)
            ORDER BY month DESC
        """

        # Execute queries
        revenue_data = self.db.execute(text(revenue_query)).first()
        commission_data = self.db.execute(text(commission_query)).first()
        provider_data = self.db.execute(text(provider_revenue_query)).all()
        trends_data = self.db.execute(text(trends_query)).all()

        # Process results
        revenue_by_provider = {row.provider_name: row.revenue for row in provider_data}
        revenue_trends = [
            {
                "month": row.month.strftime("%Y-%m"),
                "revenue": row.revenue
            }
            for row in trends_data
        ]

        # Simple forecasting (linear trend)
        commission_forecast = self._calculate_simple_forecast([t["revenue"] for t in revenue_trends])

        return RevenueAnalytics(
            total_revenue=revenue_data.total_revenue or 0,
            monthly_revenue=revenue_data.monthly_revenue or 0,
            quarterly_revenue=revenue_data.quarterly_revenue or 0,
            yearly_revenue=revenue_data.yearly_revenue or 0,
            commission_earned=commission_data.total_commission or 0,
            monthly_commission=float(commission_data.total_commission or 0) * 0.1,  # Approximation
            average_commission_rate=commission_data.average_commission_rate or 0,
            revenue_by_provider=revenue_by_provider,
            revenue_trends=revenue_trends,
            commission_forecast=commission_forecast
        )

    def _calculate_simple_forecast(self, values: List[float], periods: int = 3) -> Optional[float]:
        """Simple linear forecasting"""
        if len(values) < 2:
            return None

        # Calculate trend
        n = len(values)
        x = list(range(n))
        y = values

        sum_x = sum(x)
        sum_y = sum(y)
        sum_xy = sum(xi * yi for xi, yi in zip(x, y))
        sum_x2 = sum(xi * xi for xi in x)

        slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
        intercept = (sum_y - slope * sum_x) / n

        # Forecast next periods
        return intercept + slope * (n + periods - 1)

    # =====================================================
    # PRESENTATION ANALYTICS
    # =====================================================

    def get_presentation_analytics(self, presentation_id: str) -> PresentationAnalytics:
        """Get comprehensive presentation analytics"""

        presentation_uuid = uuid.UUID(presentation_id)

        # Basic presentation info and view counts
        presentation_query = """
            SELECT
                p.name,
                p.total_views,
                p.total_shares,
                p.total_cta_clicks,
                pa.unique_viewers
            FROM lic_schema.presentations p
            LEFT JOIN (
                SELECT
                    presentation_id,
                    COUNT(DISTINCT viewer_id) as unique_viewers
                FROM lic_schema.presentation_analytics
                WHERE event_type = 'view'
                GROUP BY presentation_id
            ) pa ON p.presentation_id = pa.presentation_id
            WHERE p.presentation_id = :presentation_id
        """

        result = self.db.execute(text(presentation_query), {"presentation_id": presentation_uuid}).first()
        if not result:
            return None

        # View trends over time
        trends_query = """
            SELECT
                DATE(event_timestamp) as date,
                COUNT(*) as views
            FROM lic_schema.presentation_analytics
            WHERE presentation_id = :presentation_id
            AND event_type = 'view'
            AND event_timestamp >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY DATE(event_timestamp)
            ORDER BY date
        """

        trends_data = self.db.execute(text(trends_query), {"presentation_id": presentation_uuid}).all()

        view_trends = [
            {
                "date": row.date.strftime("%Y-%m-%d"),
                "views": row.views
            }
            for row in trends_data
        ]

        # Geographic distribution
        geo_query = """
            SELECT
                COALESCE(location_info->>'country', 'Unknown') as country,
                COUNT(*) as views
            FROM lic_schema.presentation_analytics
            WHERE presentation_id = :presentation_id
            AND event_type = 'view'
            AND location_info IS NOT NULL
            GROUP BY location_info->>'country'
            ORDER BY views DESC
            LIMIT 10
        """

        geo_data = self.db.execute(text(geo_query), {"presentation_id": presentation_uuid}).all()
        geographic_distribution = {row.country: row.views for row in geo_data}

        # Calculate conversion rate
        total_views = result.total_views or 0
        total_cta_clicks = result.total_cta_clicks or 0
        conversion_rate = (total_cta_clicks / total_views * 100) if total_views > 0 else 0

        return PresentationAnalytics(
            presentation_id=presentation_id,
            presentation_name=result.name,
            total_views=total_views,
            unique_views=result.unique_viewers or 0,
            total_shares=result.total_shares or 0,
            cta_clicks=total_cta_clicks,
            conversion_rate=conversion_rate,
            view_trends=view_trends,
            geographic_distribution=geographic_distribution
        )

    # =====================================================
    # TREND ANALYSIS
    # =====================================================

    def get_revenue_trends(self, agent_id: Optional[str] = None, months: int = 12) -> List[TrendData]:
        """Get revenue trends over time"""

        agent_filter = f"AND p.agent_id = '{agent_id}'" if agent_id else ""

        query = f"""
            SELECT
                DATE_TRUNC('month', pm.payment_date) as month,
                COALESCE(SUM(pm.amount), 0) as revenue
            FROM lic_schema.premium_payments pm
            JOIN lic_schema.insurance_policies p ON pm.policy_id = p.policy_id
            WHERE pm.status = 'completed'
            AND pm.payment_date >= CURRENT_DATE - INTERVAL '{months} months'
            {agent_filter}
            GROUP BY DATE_TRUNC('month', pm.payment_date)
            ORDER BY month
        """

        results = self.db.execute(text(query)).all()

        return [
            TrendData(
                date=row.month.strftime("%Y-%m"),
                value=row.revenue,
                label=f"{row.month.strftime('%B %Y')}"
            )
            for row in results
        ]

    def get_policy_trends(self, agent_id: Optional[str] = None, months: int = 12) -> List[TrendData]:
        """Get policy creation trends over time"""

        agent_filter = f"AND agent_id = '{agent_id}'" if agent_id else ""

        query = f"""
            SELECT
                DATE_TRUNC('month', created_at) as month,
                COUNT(*) as policies_created
            FROM lic_schema.insurance_policies
            WHERE created_at >= CURRENT_DATE - INTERVAL '{months} months'
            {agent_filter}
            GROUP BY DATE_TRUNC('month', created_at)
            ORDER BY month
        """

        results = self.db.execute(text(query)).all()

        return [
            TrendData(
                date=row.month.strftime("%Y-%m"),
                value=row.policies_created,
                label=f"{row.month.strftime('%B %Y')}"
            )
            for row in results
        ]
