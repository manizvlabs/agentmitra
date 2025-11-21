"""
Agent repository for database operations
"""
from sqlalchemy.orm import Session
from typing import Optional
from app.models.agent import Agent
from app.models.user import User
import uuid


class AgentRepository:
    """Repository for agent-related database operations"""

    def __init__(self, db: Session):
        self.db = db

    def _to_uuid(self, value):
        """Convert string to UUID if needed"""
        if isinstance(value, str):
            try:
                return uuid.UUID(value)
            except ValueError:
                return None
        return value

    def get_by_id(self, agent_id) -> Optional[Agent]:
        """Get agent by ID"""
        agent_id = self._to_uuid(agent_id)
        if not agent_id:
            return None
        return self.db.query(Agent).filter(Agent.agent_id == agent_id).first()

    def get_by_user_id(self, user_id) -> Optional[Agent]:
        """Get agent by user ID"""
        user_id = self._to_uuid(user_id)
        if not user_id:
            return None
        return self.db.query(Agent).filter(Agent.user_id == user_id).first()

    def get_by_agent_code(self, agent_code: str) -> Optional[Agent]:
        """Get agent by agent code"""
        return self.db.query(Agent).filter(Agent.agent_code == agent_code).first()

    def get_by_phone(self, phone_number: str) -> Optional[Agent]:
        """Get agent by phone number (via user)"""
        user = self.db.query(User).filter(User.phone_number == phone_number).first()
        if user:
            return self.get_by_user_id(user.user_id)
        return None

