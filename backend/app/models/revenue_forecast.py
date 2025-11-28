"""
Revenue forecasting scenarios model
"""
from sqlalchemy import Column, String, Float, DateTime, UUID, ForeignKey, JSON, func, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSONB

from app.models.base import Base


class RevenueForecastScenario(Base):
    __tablename__ = "revenue_forecast_scenarios"
    __table_args__ = {'schema': 'lic_schema'}

    scenario_id = Column(UUID(as_uuid=True), primary_key=True, server_default=func.gen_random_uuid())
    agent_id = Column(UUID(as_uuid=True), ForeignKey('lic_schema.agents.agent_id'))

    # Scenario details
    scenario_name = Column(String(255), nullable=False)
    scenario_type = Column(String(50), nullable=False)  # 'best_case', 'base_case', 'worst_case'
    forecast_period = Column(String(20), nullable=False)  # '1m', '3m', '6m', '1y'

    # Forecast data
    projected_revenue = Column(Float, nullable=False)
    revenue_growth_rate = Column(Float)
    confidence_level = Column(Float)

    # Scenario parameters
    assumptions = Column(JSONB)
    risk_factors = Column(JSONB)
    mitigation_strategies = Column(JSONB)

    # Metadata
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now())

    # Constraints
    __table_args__ = (
        UniqueConstraint('agent_id', 'scenario_name', 'forecast_period', name='unique_agent_scenario_period'),
        {'schema': 'lic_schema'}
    )

    # Relationships
    agent = relationship("Agent")
