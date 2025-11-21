"""
Analytics models for business intelligence and reporting
"""
from datetime import datetime, date
from typing import Optional, Dict, List, Any
from pydantic import BaseModel


class DashboardKPIs(BaseModel):
    """Key Performance Indicators for dashboard"""
    total_policies: int = 0
    active_policies: int = 0
    total_premium_collected: float = 0.0
    monthly_premium_collected: float = 0.0
    total_customers: int = 0
    active_customers: int = 0
    new_customers_this_month: int = 0
    customer_satisfaction_score: Optional[float] = None
    conversion_rate: float = 0.0
    average_policy_value: float = 0.0


class AgentPerformanceMetrics(BaseModel):
    """Agent performance analytics"""
    agent_id: str
    agent_name: str
    total_policies_sold: int = 0
    total_premium_collected: float = 0.0
    active_policyholders: int = 0
    new_policies_this_month: int = 0
    monthly_target: Optional[float] = None
    monthly_achievement_percentage: float = 0.0
    customer_satisfaction_score: Optional[float] = None
    average_policy_value: float = 0.0
    conversion_rate: float = 0.0
    rank_in_team: Optional[int] = None


class PolicyAnalytics(BaseModel):
    """Policy-related analytics"""
    total_policies: int = 0
    active_policies: int = 0
    pending_policies: int = 0
    draft_policies: int = 0
    cancelled_policies: int = 0
    policies_by_status: Dict[str, int] = {}
    policies_by_type: Dict[str, int] = {}
    policies_by_category: Dict[str, int] = {}
    monthly_policy_trends: List[Dict[str, Any]] = []
    conversion_funnel: Dict[str, int] = {}


class RevenueAnalytics(BaseModel):
    """Revenue and commission analytics"""
    total_revenue: float = 0.0
    monthly_revenue: float = 0.0
    quarterly_revenue: float = 0.0
    yearly_revenue: float = 0.0
    commission_earned: float = 0.0
    monthly_commission: float = 0.0
    average_commission_rate: float = 0.0
    revenue_by_provider: Dict[str, float] = {}
    revenue_trends: List[Dict[str, Any]] = []
    commission_forecast: Optional[float] = None


class PresentationAnalytics(BaseModel):
    """Presentation and content analytics"""
    presentation_id: str
    presentation_name: str
    total_views: int = 0
    unique_views: int = 0
    total_shares: int = 0
    cta_clicks: int = 0
    conversion_rate: float = 0.0
    average_view_duration: Optional[int] = None  # seconds
    top_performing_slides: List[Dict[str, Any]] = []
    view_trends: List[Dict[str, Any]] = []
    geographic_distribution: Dict[str, int] = {}


class CustomerAnalytics(BaseModel):
    """Customer behavior and analytics"""
    total_customers: int = 0
    active_customers: int = 0
    new_customers_this_month: int = 0
    customer_lifetime_value: float = 0.0
    churn_rate: float = 0.0
    retention_rate: float = 0.0
    customer_segments: Dict[str, int] = {}
    engagement_metrics: Dict[str, Any] = {}
    demographic_breakdown: Dict[str, Any] = {}


class DateRangeFilter(BaseModel):
    """Date range filter for analytics"""
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    period: Optional[str] = "month"  # "day", "week", "month", "quarter", "year"


class AnalyticsFilter(BaseModel):
    """General analytics filter"""
    date_range: Optional[DateRangeFilter] = None
    agent_id: Optional[str] = None
    provider_id: Optional[str] = None
    territory: Optional[str] = None
    policy_type: Optional[str] = None
    status: Optional[str] = None


class ChartDataPoint(BaseModel):
    """Data point for charts and graphs"""
    label: str
    value: float
    metadata: Optional[Dict[str, Any]] = None


class TrendData(BaseModel):
    """Time series data for trends"""
    date: str
    value: float
    label: Optional[str] = None
    category: Optional[str] = None


class TopPerformer(BaseModel):
    """Top performer data"""
    id: str
    name: str
    value: float
    rank: int
    change_percentage: Optional[float] = None


# =====================================================
# CHATBOT AND KNOWLEDGE BASE MODELS
# =====================================================

class KnowledgeBaseArticle(BaseModel):
    """Knowledge base article for chatbot training"""
    article_id: str
    title: str
    content: str
    category: str
    tags: List[str] = []
    is_active: bool = True
    created_at: datetime
    updated_at: datetime
    view_count: int = 0
    helpful_votes: int = 0
    total_votes: int = 0


class ChatbotSession(BaseModel):
    """Chatbot conversation session"""
    session_id: str
    user_id: Optional[str] = None
    conversation_id: str
    started_at: datetime
    ended_at: Optional[datetime] = None
    duration_seconds: Optional[int] = None
    message_count: int = 0
    resolution_status: Optional[str] = None  # 'resolved', 'escalated', 'abandoned'
    user_satisfaction_score: Optional[int] = None  # 1-5 scale
    device_info: Optional[Dict[str, Any]] = None
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None


class ChatMessage(BaseModel):
    """Individual chat message"""
    message_id: str
    session_id: str
    user_id: Optional[str] = None
    message_type: str = "text"  # 'text', 'button_click', 'file_upload'
    content: str
    is_from_user: bool = True
    intent_detected: Optional[str] = None
    confidence_score: Optional[float] = None
    entities_detected: Optional[Dict[str, Any]] = None
    response_generated: Optional[str] = None
    response_time_ms: Optional[int] = None
    suggested_actions: Optional[List[Dict[str, Any]]] = None
    timestamp: datetime


class ChatbotAnalytics(BaseModel):
    """Chatbot performance analytics"""
    total_sessions: int = 0
    total_messages: int = 0
    average_session_duration: float = 0.0
    average_response_time: float = 0.0
    resolution_rate: float = 0.0
    escalation_rate: float = 0.0
    user_satisfaction_score: float = 0.0
    top_intents: List[Dict[str, Any]] = []
    session_trends: List[Dict[str, Any]] = []
    peak_hours: List[Dict[str, Any]] = []


class ChatbotIntent(BaseModel):
    """Chatbot intent classification"""
    intent_name: str
    description: str
    training_examples: List[str] = []
    response_templates: List[str] = []
    confidence_threshold: float = 0.7
    is_active: bool = True
    usage_count: int = 0
