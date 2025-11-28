"""
Daily Motivational Quotes Service
Handles CRUD operations for quotes, branding, and analytics
"""
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from app.models.quotes import DailyQuote, QuoteSharingAnalytics, QuotePerformance
from app.models.user import User
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class QuotesService:
    """Service for managing daily motivational quotes"""

    def __init__(self, db: Session):
        self.db = db

    def create_quote(self, agent_id: str, quote_data: Dict[str, Any]) -> DailyQuote:
        """Create a new motivational quote"""
        try:
            quote = DailyQuote(
                agent_id=agent_id,
                quote_text=quote_data["quote_text"],
                author=quote_data.get("author"),
                category=quote_data.get("category", "motivation"),
                tags=quote_data.get("tags", []),
                branding_settings=quote_data.get("branding_settings", {}),
                scheduled_date=quote_data.get("scheduled_date"),
                is_active=quote_data.get("is_active", True)
            )

            self.db.add(quote)
            self.db.commit()
            self.db.refresh(quote)

            logger.info(f"Created new quote {quote.quote_id} for agent {agent_id}")
            return quote

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating quote: {e}")
            raise

    def get_agent_quotes(self, agent_id: str, active_only: bool = False) -> List[DailyQuote]:
        """Get all quotes for an agent"""
        query = self.db.query(DailyQuote).filter(DailyQuote.agent_id == agent_id)

        if active_only:
            query = query.filter(DailyQuote.is_active == True)

        return query.order_by(DailyQuote.created_at.desc()).all()

    def get_quote_by_id(self, quote_id: str, agent_id: str = None) -> Optional[DailyQuote]:
        """Get a specific quote by ID"""
        query = self.db.query(DailyQuote).filter(DailyQuote.quote_id == quote_id)

        if agent_id:
            query = query.filter(DailyQuote.agent_id == agent_id)

        return query.first()

    def update_quote(self, quote_id: str, agent_id: str, update_data: Dict[str, Any]) -> Optional[DailyQuote]:
        """Update an existing quote"""
        try:
            quote = self.get_quote_by_id(quote_id, agent_id)
            if not quote:
                return None

            # Update allowed fields
            allowed_fields = [
                "quote_text", "author", "category", "tags",
                "branding_settings", "is_active", "scheduled_date"
            ]

            for field in allowed_fields:
                if field in update_data:
                    setattr(quote, field, update_data[field])

            quote.updated_at = datetime.utcnow()

            self.db.commit()
            self.db.refresh(quote)

            logger.info(f"Updated quote {quote_id}")
            return quote

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating quote {quote_id}: {e}")
            raise

    def delete_quote(self, quote_id: str, agent_id: str) -> bool:
        """Delete a quote"""
        try:
            quote = self.get_quote_by_id(quote_id, agent_id)
            if not quote:
                return False

            self.db.delete(quote)
            self.db.commit()

            logger.info(f"Deleted quote {quote_id}")
            return True

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error deleting quote {quote_id}: {e}")
            raise

    def publish_quote(self, quote_id: str, agent_id: str) -> Optional[DailyQuote]:
        """Publish a quote (set published_at timestamp)"""
        try:
            quote = self.get_quote_by_id(quote_id, agent_id)
            if not quote:
                return None

            quote.published_at = datetime.utcnow()
            quote.is_active = True

            self.db.commit()
            self.db.refresh(quote)

            logger.info(f"Published quote {quote_id}")
            return quote

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error publishing quote {quote_id}: {e}")
            raise

    def record_sharing_analytics(self, quote_id: str, agent_id: str, platform: str,
                                recipient_count: int = 1, engagement_metrics: Dict = None) -> QuoteSharingAnalytics:
        """Record quote sharing analytics"""
        try:
            analytics = QuoteSharingAnalytics(
                quote_id=quote_id,
                agent_id=agent_id,
                platform=platform,
                recipient_count=recipient_count,
                engagement_metrics=engagement_metrics or {}
            )

            self.db.add(analytics)
            self.db.commit()
            self.db.refresh(analytics)

            logger.info(f"Recorded sharing analytics for quote {quote_id} on {platform}")
            return analytics

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error recording sharing analytics: {e}")
            raise

    def update_performance_metrics(self, quote_id: str, agent_id: str,
                                  metric_date: date, metrics: Dict[str, int]) -> QuotePerformance:
        """Update or create performance metrics for a quote"""
        try:
            # Check if metrics already exist for this date
            existing = self.db.query(QuotePerformance).filter(
                and_(
                    QuotePerformance.quote_id == quote_id,
                    QuotePerformance.metric_date == metric_date
                )
            ).first()

            if existing:
                # Update existing metrics
                for metric, value in metrics.items():
                    if hasattr(existing, f"{metric}_count"):
                        setattr(existing, f"{metric}_count", value)
                existing.updated_at = datetime.utcnow()
                performance = existing
            else:
                # Create new metrics record
                performance = QuotePerformance(
                    quote_id=quote_id,
                    agent_id=agent_id,
                    metric_date=metric_date,
                    views_count=metrics.get("views", 0),
                    shares_count=metrics.get("shares", 0),
                    likes_count=metrics.get("likes", 0),
                    responses_count=metrics.get("responses", 0),
                    conversion_count=metrics.get("conversions", 0)
                )
                self.db.add(performance)

            self.db.commit()
            self.db.refresh(performance)

            return performance

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error updating performance metrics: {e}")
            raise

    def get_quote_analytics(self, quote_id: str, agent_id: str) -> Dict[str, Any]:
        """Get comprehensive analytics for a quote"""
        try:
            # Get total sharing metrics
            sharing_stats = self.db.query(
                func.sum(QuoteSharingAnalytics.recipient_count).label("total_shares"),
                func.count(QuoteSharingAnalytics.share_id).label("share_count")
            ).filter(
                and_(
                    QuoteSharingAnalytics.quote_id == quote_id,
                    QuoteSharingAnalytics.agent_id == agent_id
                )
            ).first()

            # Get performance metrics
            performance = self.db.query(
                func.sum(QuotePerformance.views_count).label("total_views"),
                func.sum(QuotePerformance.shares_count).label("performance_shares"),
                func.sum(QuotePerformance.likes_count).label("total_likes"),
                func.sum(QuotePerformance.responses_count).label("total_responses"),
                func.sum(QuotePerformance.conversion_count).label("total_conversions")
            ).filter(
                and_(
                    QuotePerformance.quote_id == quote_id,
                    QuotePerformance.agent_id == agent_id
                )
            ).first()

            # Get platform breakdown
            platform_stats = self.db.query(
                QuoteSharingAnalytics.platform,
                func.sum(QuoteSharingAnalytics.recipient_count).label("count")
            ).filter(
                and_(
                    QuoteSharingAnalytics.quote_id == quote_id,
                    QuoteSharingAnalytics.agent_id == agent_id
                )
            ).group_by(QuoteSharingAnalytics.platform).all()

            return {
                "quote_id": quote_id,
                "total_shares": sharing_stats.total_shares or 0,
                "share_count": sharing_stats.share_count or 0,
                "total_views": performance.total_views or 0,
                "performance_shares": performance.performance_shares or 0,
                "total_likes": performance.total_likes or 0,
                "total_responses": performance.total_responses or 0,
                "total_conversions": performance.total_conversions or 0,
                "platform_breakdown": [
                    {"platform": stat.platform, "count": stat.count}
                    for stat in platform_stats
                ]
            }

        except Exception as e:
            logger.error(f"Error getting quote analytics: {e}")
            return {}

    def get_agent_quotes_analytics(self, agent_id: str, period_days: int = 30) -> Dict[str, Any]:
        """Get analytics summary for all agent's quotes"""
        try:
            from datetime import timedelta

            cutoff_date = datetime.utcnow() - timedelta(days=period_days)

            # Get quote counts
            quote_counts = self.db.query(
                func.count(DailyQuote.quote_id).label("total_quotes"),
                func.count(DailyQuote.quote_id).filter(DailyQuote.is_active == True).label("active_quotes"),
                func.count(DailyQuote.quote_id).filter(DailyQuote.published_at.isnot(None)).label("published_quotes")
            ).filter(
                and_(
                    DailyQuote.agent_id == agent_id,
                    DailyQuote.created_at >= cutoff_date
                )
            ).first()

            # Get total performance metrics
            performance = self.db.query(
                func.sum(QuotePerformance.views_count).label("total_views"),
                func.sum(QuotePerformance.shares_count).label("total_shares"),
                func.sum(QuotePerformance.likes_count).label("total_likes"),
                func.sum(QuotePerformance.responses_count).label("total_responses"),
                func.sum(QuotePerformance.conversion_count).label("total_conversions")
            ).join(DailyQuote).filter(
                and_(
                    DailyQuote.agent_id == agent_id,
                    QuotePerformance.metric_date >= cutoff_date.date()
                )
            ).first()

            return {
                "period_days": period_days,
                "total_quotes": quote_counts.total_quotes or 0,
                "active_quotes": quote_counts.active_quotes or 0,
                "published_quotes": quote_counts.published_quotes or 0,
                "total_views": performance.total_views or 0,
                "total_shares": performance.total_shares or 0,
                "total_likes": performance.total_likes or 0,
                "total_responses": performance.total_responses or 0,
                "total_conversions": performance.total_conversions or 0
            }

        except Exception as e:
            logger.error(f"Error getting agent quotes analytics: {e}")
            return {}
