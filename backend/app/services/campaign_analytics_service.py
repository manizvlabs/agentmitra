"""
Campaign Analytics Service - Performance metrics and analytics
"""
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, func, desc
from uuid import UUID
from decimal import Decimal

from app.models.campaign import Campaign, CampaignExecution, CampaignResponse
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class CampaignAnalyticsService:
    """Service for campaign performance analytics"""

    @staticmethod
    def get_campaign_analytics(
        db: Session,
        campaign_id: UUID,
        agent_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """Get comprehensive analytics for a campaign"""
        campaign = db.query(Campaign).filter(Campaign.campaign_id == campaign_id).first()
        
        if not campaign:
            raise ValueError(f"Campaign not found: {campaign_id}")
        
        if agent_id and campaign.agent_id != agent_id:
            raise ValueError("Campaign does not belong to agent")

        # Get execution statistics
        executions = db.query(CampaignExecution).filter(
            CampaignExecution.campaign_id == campaign_id
        ).all()

        # Calculate metrics
        total_sent = len(executions)
        total_delivered = len([e for e in executions if e.delivered_at])
        total_opened = len([e for e in executions if e.opened_at])
        total_clicked = len([e for e in executions if e.clicked_at])
        total_converted = len([e for e in executions if e.converted])

        # Calculate rates
        delivery_rate = (total_delivered / total_sent * 100) if total_sent > 0 else 0
        open_rate = (total_opened / total_delivered * 100) if total_delivered > 0 else 0
        click_rate = (total_clicked / total_opened * 100) if total_opened > 0 else 0
        conversion_rate = (total_converted / total_sent * 100) if total_sent > 0 else 0

        # Calculate revenue
        total_revenue = sum(
            float(e.conversion_value or 0) for e in executions if e.converted
        )

        # Calculate ROI
        investment = float(campaign.budget or 0)
        roi = ((total_revenue - investment) / investment * 100) if investment > 0 else 0

        # Channel breakdown
        channel_breakdown = CampaignAnalyticsService._get_channel_breakdown(executions)

        # Customer responses
        responses = db.query(CampaignResponse).filter(
            CampaignResponse.campaign_id == campaign_id
        ).limit(10).all()

        customer_responses = [
            {
                'customer_name': r.policyholder.first_name if r.policyholder else 'Unknown',
                'response': r.response_text or '',
                'response_type': r.response_type,
                'timestamp': r.created_at.isoformat() if r.created_at else None,
            }
            for r in responses
        ]

        return {
            'campaign_id': str(campaign.campaign_id),
            'campaign_name': campaign.campaign_name,
            'campaign_type': campaign.campaign_type,
            'status': campaign.status,
            'total_sent': total_sent,
            'total_delivered': total_delivered,
            'total_opened': total_opened,
            'total_clicked': total_clicked,
            'total_converted': total_converted,
            'delivery_rate': round(delivery_rate, 2),
            'open_rate': round(open_rate, 2),
            'click_rate': round(click_rate, 2),
            'conversion_rate': round(conversion_rate, 2),
            'total_revenue': round(total_revenue, 2),
            'total_investment': round(investment, 2),
            'revenue_generated': round(total_revenue, 2),
            'roi': round(roi, 2),
            'break_even_amount': round(investment, 2),
            'channel_breakdown': channel_breakdown,
            'customer_responses': customer_responses,
        }

    @staticmethod
    def _get_channel_breakdown(executions: List[CampaignExecution]) -> List[Dict]:
        """Get performance breakdown by channel"""
        channel_stats = {}
        
        for execution in executions:
            channel = execution.channel
            if channel not in channel_stats:
                channel_stats[channel] = {
                    'name': channel,
                    'sent': 0,
                    'delivered': 0,
                    'response_rate': 0,
                }
            
            channel_stats[channel]['sent'] += 1
            if execution.delivered_at:
                channel_stats[channel]['delivered'] += 1
        
        # Calculate response rates
        for channel, stats in channel_stats.items():
            if stats['sent'] > 0:
                stats['response_rate'] = round(
                    (stats['delivered'] / stats['sent']) * 100, 2
                )
        
        return list(channel_stats.values())

    @staticmethod
    def get_campaign_performance_over_time(
        db: Session,
        campaign_id: UUID,
        days: int = 30
    ) -> List[Dict]:
        """Get campaign performance metrics over time"""
        start_date = datetime.utcnow() - timedelta(days=days)
        
        executions = db.query(CampaignExecution).filter(
            and_(
                CampaignExecution.campaign_id == campaign_id,
                CampaignExecution.sent_at >= start_date
            )
        ).order_by(CampaignExecution.sent_at).all()

        # Group by day
        daily_stats = {}
        for execution in executions:
            if execution.sent_at:
                day = execution.sent_at.date()
                if day not in daily_stats:
                    daily_stats[day] = {
                        'day': day.isoformat(),
                        'sent': 0,
                        'opened': 0,
                        'clicked': 0,
                    }
                
                daily_stats[day]['sent'] += 1
                if execution.opened_at:
                    daily_stats[day]['opened'] += 1
                if execution.clicked_at:
                    daily_stats[day]['clicked'] += 1

        return list(daily_stats.values())

