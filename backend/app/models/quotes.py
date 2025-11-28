"""
Daily Motivational Quotes Models
"""
from sqlalchemy import Column, String, Text, Date, TIMESTAMP, Boolean, JSON, UUID, Integer, func, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import Base, TimestampMixin, AuditMixin


class DailyQuote(Base, TimestampMixin, AuditMixin):
    """Daily motivational quotes with agent branding"""

    __tablename__ = "daily_quotes"

    quote_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    agent_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    quote_text = Column(Text, nullable=False)
    author = Column(String(255))
    category = Column(String(100), default="motivation")
    tags = Column(JSON)
    branding_settings = Column(JSON)  # font, colors, background image, logo placement
    is_active = Column(Boolean, default=True)
    scheduled_date = Column(Date)
    published_at = Column(TIMESTAMP)

    # Relationships
    agent = relationship("User", back_populates="daily_quotes")
    sharing_analytics = relationship("QuoteSharingAnalytics", back_populates="quote", primaryjoin="DailyQuote.quote_id == QuoteSharingAnalytics.quote_id")
    performance_metrics = relationship("QuotePerformance", back_populates="quote", primaryjoin="DailyQuote.quote_id == QuotePerformance.quote_id")

    def __repr__(self):
        return f"<DailyQuote(quote_id='{self.quote_id}', author='{self.author}')>"

    __table_args__ = (
        {"schema": "lic_schema"}
    )


class QuoteSharingAnalytics(Base, TimestampMixin):
    """Analytics for quote sharing across different platforms"""

    __tablename__ = "quote_sharing_analytics"

    share_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    quote_id = Column(UUID(as_uuid=True), ForeignKey("daily_quotes.quote_id", ondelete="CASCADE"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    platform = Column(String(50))  # whatsapp, sms, email, social_media
    recipient_count = Column(Integer, default=1)
    delivery_status = Column(String(50), default="sent")
    engagement_metrics = Column(JSON)  # views, likes, shares, responses
    shared_at = Column(TIMESTAMP, server_default=func.now())

    # Relationships
    quote = relationship("DailyQuote", back_populates="sharing_analytics")
    agent = relationship("User", back_populates="quote_shares")

    def __repr__(self):
        return f"<QuoteSharingAnalytics(share_id='{self.share_id}', platform='{self.platform}')>"

    __table_args__ = (
        {"schema": "lic_schema"}
    )


class QuotePerformance(Base, TimestampMixin):
    """Daily performance metrics for quotes"""

    __tablename__ = "quote_performance"

    performance_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    quote_id = Column(UUID(as_uuid=True), ForeignKey("daily_quotes.quote_id", ondelete="CASCADE"), nullable=False)
    agent_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    metric_date = Column(Date, server_default=func.current_date())
    views_count = Column(Integer, default=0)
    shares_count = Column(Integer, default=0)
    likes_count = Column(Integer, default=0)
    responses_count = Column(Integer, default=0)
    conversion_count = Column(Integer, default=0)  # leads generated from quote

    # Relationships
    quote = relationship("DailyQuote", back_populates="performance_metrics")
    agent = relationship("User", back_populates="quote_performance")

    __table_args__ = (
        {"schema": "lic_schema"}
    )

    def __repr__(self):
        return f"<QuotePerformance(quote_id='{self.quote_id}', date='{self.metric_date}')>"
