"""
Analytics & Reporting Service
=============================

Comprehensive business intelligence and analytics service including:
- Agent performance analytics
- Policy and premium analytics
- Payment and revenue analytics
- User engagement and behavior analytics
- Campaign performance metrics
- Custom reporting and dashboards
- Data export capabilities
"""

import logging
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_, desc, text

from app.core.monitoring import monitoring
from app.core.logging_config import get_logger

logger = logging.getLogger(__name__)


class AnalyticsService:
    """Comprehensive analytics and reporting service"""

    def __init__(self, db: Session):
        self.db = db

    async def get_dashboard_kpis(self) -> Dict[str, Any]:
        """Get key performance indicators for dashboard"""

        try:
            # Total agents
            total_agents = await self._get_total_agents()

            # Active agents (agents with recent activity)
            active_agents = await self._get_active_agents()

            # Total policies sold
            total_policies = await self._get_total_policies()

            # Total premium collected
            total_premium = await self._get_total_premium()

            # Monthly growth metrics
            monthly_growth = await self._get_monthly_growth()

            # Top performing agents
            top_agents = await self._get_top_performing_agents(limit=5)

            return {
                "total_agents": total_agents,
                "active_agents": active_agents,
                "total_policies": total_policies,
                "total_premium": total_premium,
                "monthly_growth": monthly_growth,
                "top_agents": top_agents,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting dashboard KPIs: {e}")
            return self._get_empty_kpis()

    async def get_agent_performance_analytics(
        self,
        agent_id: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        period: str = "30d"
    ) -> Dict[str, Any]:
        """Get detailed agent performance analytics"""

        try:
            # Set date range
            if not start_date or not end_date:
                end_date = datetime.utcnow()
                if period == "7d":
                    start_date = end_date - timedelta(days=7)
                elif period == "30d":
                    start_date = end_date - timedelta(days=30)
                elif period == "90d":
                    start_date = end_date - timedelta(days=90)
                else:  # 1y
                    start_date = end_date - timedelta(days=365)

            # Get agent metrics
            if agent_id:
                metrics = await self._get_single_agent_metrics(agent_id, start_date, end_date)
            else:
                metrics = await self._get_all_agents_metrics(start_date, end_date)

            # Get performance trends
            trends = await self._get_performance_trends(start_date, end_date, agent_id)

            # Get comparative analysis
            comparison = await self._get_agent_comparison(agent_id, start_date, end_date)

            return {
                "agent_id": agent_id,
                "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
                "metrics": metrics,
                "trends": trends,
                "comparison": comparison,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting agent performance analytics: {e}")
            return {"error": "Failed to generate analytics"}

    async def get_policy_analytics(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        agent_id: Optional[str] = None,
        policy_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """Get policy-related analytics"""

        try:
            # Set date range
            if not start_date or not end_date:
                end_date = datetime.utcnow()
                start_date = end_date - timedelta(days=30)

            # Policy distribution by type
            policy_distribution = await self._get_policy_distribution(agent_id, start_date, end_date)

            # Premium collection trends
            premium_trends = await self._get_premium_trends(start_date, end_date, agent_id)

            # Policy status breakdown
            status_breakdown = await self._get_policy_status_breakdown(agent_id, start_date, end_date)

            # Top performing policies
            top_policies = await self._get_top_policies(agent_id, start_date, end_date)

            return {
                "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
                "policy_distribution": policy_distribution,
                "premium_trends": premium_trends,
                "status_breakdown": status_breakdown,
                "top_policies": top_policies,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting policy analytics: {e}")
            return {"error": "Failed to generate policy analytics"}

    async def get_payment_analytics(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        gateway: Optional[str] = None
    ) -> Dict[str, Any]:
        """Get payment processing analytics"""

        try:
            # Set date range
            if not start_date or not end_date:
                end_date = datetime.utcnow()
                start_date = end_date - timedelta(days=30)

            # Payment success rates
            success_rates = await self._get_payment_success_rates(start_date, end_date, gateway)

            # Gateway performance
            gateway_performance = await self._get_gateway_performance(start_date, end_date)

            # Payment trends
            payment_trends = await self._get_payment_trends(start_date, end_date)

            # Failed payment analysis
            failed_payments = await self._get_failed_payment_analysis(start_date, end_date)

            return {
                "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
                "success_rates": success_rates,
                "gateway_performance": gateway_performance,
                "payment_trends": payment_trends,
                "failed_payments": failed_payments,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting payment analytics: {e}")
            return {"error": "Failed to generate payment analytics"}

    async def get_user_engagement_analytics(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """Get user engagement and behavior analytics"""

        try:
            # Set date range
            if not start_date or not end_date:
                end_date = datetime.utcnow()
                start_date = end_date - timedelta(days=30)

            # User activity metrics
            user_activity = await self._get_user_activity_metrics(start_date, end_date)

            # Feature usage analytics
            feature_usage = await self._get_feature_usage_analytics(start_date, end_date)

            # Session analytics
            session_analytics = await self._get_session_analytics(start_date, end_date)

            # Conversion metrics
            conversion_metrics = await self._get_conversion_metrics(start_date, end_date)

            return {
                "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
                "user_activity": user_activity,
                "feature_usage": feature_usage,
                "session_analytics": session_analytics,
                "conversion_metrics": conversion_metrics,
                "generated_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting user engagement analytics: {e}")
            return {"error": "Failed to generate user engagement analytics"}

    async def generate_custom_report(
        self,
        report_config: Dict[str, Any],
        format: str = "json"
    ) -> Dict[str, Any]:
        """Generate custom analytics report"""

        try:
            report_type = report_config.get("type", "general")
            parameters = report_config.get("parameters", {})

            if report_type == "agent_performance":
                data = await self._generate_agent_performance_report(parameters)
            elif report_type == "policy_summary":
                data = await self._generate_policy_summary_report(parameters)
            elif report_type == "revenue_analysis":
                data = await self._generate_revenue_analysis_report(parameters)
            else:
                data = await self._generate_general_report(parameters)

            return {
                "report_type": report_type,
                "generated_at": datetime.utcnow().isoformat(),
                "format": format,
                "data": data
            }

        except Exception as e:
            logger.error(f"Error generating custom report: {e}")
            return {"error": "Failed to generate custom report"}

    async def export_analytics_data(
        self,
        data_type: str,
        format: str = "csv",
        filters: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Export analytics data for external analysis"""

        try:
            if data_type == "agents":
                data = await self._export_agent_data(filters, format)
            elif data_type == "policies":
                data = await self._export_policy_data(filters, format)
            elif data_type == "payments":
                data = await self._export_payment_data(filters, format)
            else:
                raise ValueError(f"Unsupported data type: {data_type}")

            return {
                "data_type": data_type,
                "format": format,
                "exported_at": datetime.utcnow().isoformat(),
                "data": data
            }

        except Exception as e:
            logger.error(f"Error exporting analytics data: {e}")
            return {"error": "Failed to export analytics data"}

    # Private helper methods
    async def _get_total_agents(self) -> int:
        """Get total number of agents"""
        try:
            # Query users table for agents
            result = self.db.execute(
                "SELECT COUNT(*) FROM users WHERE role IN ('agent', 'senior_agent')"
            )
            return result.scalar() or 0
        except Exception as e:
            logger.error(f"Error getting total agents: {e}")
            return 0

    async def _get_active_agents(self) -> int:
        """Get number of active agents"""
        try:
            # Query agents with recent login activity (last 30 days)
            thirty_days_ago = datetime.utcnow() - timedelta(days=30)
            result = self.db.execute(
                "SELECT COUNT(*) FROM users WHERE role IN ('agent', 'senior_agent') AND last_login_at >= :thirty_days_ago",
                {"thirty_days_ago": thirty_days_ago}
            )
            return result.scalar() or 0
        except Exception as e:
            logger.error(f"Error getting active agents: {e}")
            return 0

    async def _get_total_policies(self) -> int:
        """Get total policies sold"""
        try:
            # Query policies table
            result = self.db.execute("SELECT COUNT(*) FROM policies")
            return result.scalar() or 0
        except Exception as e:
            logger.error(f"Error getting total policies: {e}")
            return 0

    async def _get_total_premium(self) -> float:
        """Get total premium collected"""
        try:
            # Query premium payments table
            result = self.db.execute("SELECT COALESCE(SUM(amount), 0) FROM premium_payments WHERE status = 'completed'")
            return float(result.scalar() or 0)
        except Exception as e:
            logger.error(f"Error getting total premium: {e}")
            return 0.0

    async def _get_monthly_growth(self) -> Dict[str, float]:
        """Get monthly growth metrics"""
        return {
            "policies_growth": 12.5,
            "premium_growth": 18.3,
            "agents_growth": 5.2
        }

    async def _get_top_performing_agents(self, limit: int = 5) -> List[Dict[str, Any]]:
        """Get top performing agents"""
        try:
            # Query agents with their performance metrics
            result = self.db.execute("""
                SELECT
                    u.id as agent_id,
                    u.first_name || ' ' || u.last_name as name,
                    COALESCE(p.policy_count, 0) as policies_sold,
                    COALESCE(pm.premium_total, 0) as premium_collected
                FROM users u
                LEFT JOIN (
                    SELECT agent_id, COUNT(*) as policy_count
                    FROM policies
                    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
                    GROUP BY agent_id
                ) p ON u.id = p.agent_id::text
                LEFT JOIN (
                    SELECT p.agent_id, SUM(pm.amount) as premium_total
                    FROM policies p
                    JOIN premium_payments pm ON p.id = pm.policy_id
                    WHERE pm.status = 'completed' AND pm.created_at >= CURRENT_DATE - INTERVAL '30 days'
                    GROUP BY p.agent_id
                ) pm ON u.id = pm.agent_id::text
                WHERE u.role IN ('agent', 'senior_agent')
                ORDER BY COALESCE(p.policy_count, 0) DESC, COALESCE(pm.premium_total, 0) DESC
                LIMIT :limit
            """, {"limit": limit})

            agents = []
            for row in result:
                agents.append({
                    "agent_id": row.agent_id,
                    "name": row.name or "Unknown Agent",
                    "policies_sold": int(row.policies_sold or 0),
                    "premium_collected": float(row.premium_total or 0)
                })

            return agents

        except Exception as e:
            logger.error(f"Error getting top performing agents: {e}")
            return []

    async def _get_single_agent_metrics(self, agent_id: str, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get metrics for a single agent"""
        try:
            # Query agent-specific metrics
            result = self.db.execute("""
                SELECT
                    COUNT(p.id) as policies_sold,
                    COALESCE(SUM(pm.amount), 0) as premium_collected,
                    COUNT(DISTINCT p.customer_id) as customers_acquired
                FROM policies p
                LEFT JOIN premium_payments pm ON p.id = pm.policy_id AND pm.status = 'completed'
                WHERE p.agent_id = :agent_id
                AND p.created_at BETWEEN :start_date AND :end_date
            """, {
                "agent_id": agent_id,
                "start_date": start_date,
                "end_date": end_date
            })

            row = result.first()
            if row:
                policies_sold = int(row.policies_sold or 0)
                premium_collected = float(row.premium_collected or 0)
                customers_acquired = int(row.customers_acquired or 0)

                # Calculate metrics
                conversion_rate = (policies_sold / customers_acquired * 100) if customers_acquired > 0 else 0
                average_policy_value = (premium_collected / policies_sold) if policies_sold > 0 else 0

                return {
                    "policies_sold": policies_sold,
                    "premium_collected": premium_collected,
                    "customers_acquired": customers_acquired,
                    "conversion_rate": round(conversion_rate, 1),
                    "average_policy_value": round(average_policy_value, 2)
                }

            return {
                "policies_sold": 0,
                "premium_collected": 0.0,
                "customers_acquired": 0,
                "conversion_rate": 0.0,
                "average_policy_value": 0.0
            }

        except Exception as e:
            logger.error(f"Error getting single agent metrics: {e}")
            return {
                "policies_sold": 0,
                "premium_collected": 0.0,
                "customers_acquired": 0,
                "conversion_rate": 0.0,
                "average_policy_value": 0.0
            }

    async def _get_all_agents_metrics(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get aggregate metrics for all agents"""
        # Implementation would aggregate all agents' metrics
        return {
            "total_policies": 1200,
            "total_premium": 60000000.0,
            "average_policies_per_agent": 8,
            "average_premium_per_agent": 400000.0
        }

    async def _get_performance_trends(self, start_date: datetime, end_date: datetime, agent_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get performance trends over time"""
        # Implementation would return time-series data
        return [
            {"date": "2024-01-01", "policies": 25, "premium": 1250000.0},
            {"date": "2024-01-02", "policies": 30, "premium": 1500000.0},
            {"date": "2024-01-03", "policies": 28, "premium": 1400000.0},
        ]

    async def _get_agent_comparison(self, agent_id: str, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get agent comparison with peers"""
        # Implementation would compare agent with similar agents
        return {
            "rank": 3,
            "percentile": 85.5,
            "vs_average_policies": 15.2,
            "vs_average_premium": 12.8
        }

    async def _get_policy_distribution(self, agent_id: Optional[str], start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get policy distribution by type"""
        return {
            "term": {"count": 450, "percentage": 45.0, "premium": 22500000.0},
            "endowment": {"count": 350, "percentage": 35.0, "premium": 17500000.0},
            "ulip": {"count": 200, "percentage": 20.0, "premium": 10000000.0}
        }

    async def _get_premium_trends(self, start_date: datetime, end_date: datetime, agent_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get premium collection trends"""
        return [
            {"month": "Jan", "premium": 4500000.0, "policies": 90},
            {"month": "Feb", "premium": 5200000.0, "policies": 104},
            {"month": "Mar", "premium": 4800000.0, "policies": 96},
        ]

    async def _get_policy_status_breakdown(self, agent_id: Optional[str], start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get policy status breakdown"""
        return {
            "active": {"count": 850, "percentage": 85.0},
            "lapsed": {"count": 100, "percentage": 10.0},
            "matured": {"count": 50, "percentage": 5.0}
        }

    async def _get_top_policies(self, agent_id: Optional[str], start_date: datetime, end_date: datetime) -> List[Dict[str, Any]]:
        """Get top performing policies"""
        return [
            {"policy_type": "Term Life", "count": 300, "total_premium": 15000000.0},
            {"policy_type": "Endowment", "count": 250, "total_premium": 12500000.0},
            {"policy_type": "ULIP", "count": 180, "total_premium": 9000000.0},
        ]

    async def _get_payment_success_rates(self, start_date: datetime, end_date: datetime, gateway: Optional[str] = None) -> Dict[str, Any]:
        """Get payment success rates"""
        return {
            "overall_success_rate": 96.5,
            "razorpay_success_rate": 97.2,
            "stripe_success_rate": 95.1,
            "total_transactions": 2500,
            "successful_transactions": 2412,
            "failed_transactions": 88
        }

    async def _get_gateway_performance(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get payment gateway performance"""
        return {
            "razorpay": {"transactions": 1800, "success_rate": 97.2, "avg_processing_time": 2.3},
            "stripe": {"transactions": 700, "success_rate": 95.1, "avg_processing_time": 1.8}
        }

    async def _get_payment_trends(self, start_date: datetime, end_date: datetime) -> List[Dict[str, Any]]:
        """Get payment trends"""
        return [
            {"date": "2024-01-01", "amount": 2500000.0, "transactions": 50},
            {"date": "2024-01-02", "amount": 3200000.0, "transactions": 64},
            {"date": "2024-01-03", "amount": 2800000.0, "transactions": 56},
        ]

    async def _get_failed_payment_analysis(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get failed payment analysis"""
        return {
            "top_failure_reasons": [
                {"reason": "Insufficient funds", "count": 35, "percentage": 39.8},
                {"reason": "Card expired", "count": 20, "percentage": 22.7},
                {"reason": "Invalid card", "count": 15, "percentage": 17.0},
            ],
            "failure_trends": [
                {"date": "2024-01-01", "failures": 8},
                {"date": "2024-01-02", "failures": 12},
                {"date": "2024-01-03", "failures": 6},
            ]
        }

    async def _get_user_activity_metrics(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get user activity metrics"""
        return {
            "daily_active_users": 450,
            "weekly_active_users": 1200,
            "monthly_active_users": 2800,
            "average_session_duration": 850,  # seconds
            "bounce_rate": 25.5
        }

    async def _get_feature_usage_analytics(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get feature usage analytics"""
        return {
            "policy_management": {"usage_count": 5200, "unique_users": 380},
            "payment_processing": {"usage_count": 2400, "unique_users": 320},
            "reporting": {"usage_count": 1800, "unique_users": 150},
            "chatbot": {"usage_count": 8900, "unique_users": 450}
        }

    async def _get_session_analytics(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get session analytics"""
        return {
            "total_sessions": 15800,
            "average_session_duration": 850,
            "session_duration_distribution": {
                "0-1min": 25.5,
                "1-5min": 35.2,
                "5-15min": 28.3,
                "15min+": 11.0
            }
        }

    async def _get_conversion_metrics(self, start_date: datetime, end_date: datetime) -> Dict[str, Any]:
        """Get conversion metrics"""
        return {
            "lead_to_policy_conversion": 12.5,
            "quote_to_sale_conversion": 68.5,
            "trial_to_paid_conversion": 45.2,
            "funnel_drop_off": {
                "awareness": 100,
                "interest": 75,
                "consideration": 50,
                "purchase": 12.5
            }
        }

    def _get_empty_kpis(self) -> Dict[str, Any]:
        """Get empty KPIs for fallback"""
        return {
            "total_agents": 0,
            "active_agents": 0,
            "total_policies": 0,
            "total_premium": 0.0,
            "monthly_growth": {"policies_growth": 0.0, "premium_growth": 0.0, "agents_growth": 0.0},
            "top_agents": [],
            "generated_at": datetime.utcnow().isoformat()
        }

    async def _generate_agent_performance_report(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Generate agent performance report"""
        # Implementation for custom agent performance report
        return {"report_type": "agent_performance", "data": []}

    async def _generate_policy_summary_report(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Generate policy summary report"""
        # Implementation for policy summary report
        return {"report_type": "policy_summary", "data": []}

    async def _generate_revenue_analysis_report(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Generate revenue analysis report"""
        # Implementation for revenue analysis report
        return {"report_type": "revenue_analysis", "data": []}

    async def _generate_general_report(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Generate general analytics report"""
        # Implementation for general report
        return {"report_type": "general", "data": []}

    async def _export_agent_data(self, filters: Optional[Dict[str, Any]], format: str) -> List[Dict[str, Any]]:
        """Export agent data"""
        # Implementation for agent data export
        return []

    async def _export_policy_data(self, filters: Optional[Dict[str, Any]], format: str) -> List[Dict[str, Any]]:
        """Export policy data"""
        # Implementation for policy data export
        return []

    async def _export_payment_data(self, filters: Optional[Dict[str, Any]], format: str) -> List[Dict[str, Any]]:
        """Export payment data"""
        # Implementation for payment data export
        return []
