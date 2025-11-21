"""
User repository for database operations - updated for lic_schema
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import Optional
from app.models.user import User, UserSession
from app.models.agent import Agent
import uuid
from datetime import datetime, timedelta


class UserRepository:
    """Repository for user-related database operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, user_id) -> Optional[User]:
        """Get user by ID (UUID or string)"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                return None
        return self.db.query(User).filter(User.user_id == user_id).first()

    def get_by_phone(self, phone_number: str) -> Optional[User]:
        """Get user by phone number"""
        return self.db.query(User).filter(User.phone_number == phone_number).first()

    def get_by_agent_code(self, agent_code: str) -> Optional[User]:
        """Get user by agent code (looks up in agents table)"""
        agent = self.db.query(Agent).filter(Agent.agent_code == agent_code).first()
        if agent:
            return agent.user
        return None

    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return self.db.query(User).filter(User.email == email).first()

    def create(self, user_data: dict) -> User:
        """Create a new user"""
        user = User(
            user_id=uuid.uuid4(),
            phone_number=user_data.get("phone_number"),
            email=user_data.get("email"),
            first_name=user_data.get("first_name") or user_data.get("full_name", "").split()[0] if user_data.get("full_name") else None,
            last_name=user_data.get("last_name") or " ".join(user_data.get("full_name", "").split()[1:]) if user_data.get("full_name") and len(user_data.get("full_name", "").split()) > 1 else None,
            display_name=user_data.get("display_name") or user_data.get("full_name"),
            role=user_data.get("role", "policyholder"),
            phone_verified=user_data.get("phone_verified", user_data.get("is_verified", False)),
            password_hash=user_data.get("password_hash", ""),
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def update(self, user_id, user_data: dict) -> Optional[User]:
        """Update user"""
        user = self.get_by_id(user_id)
        if not user:
            return None

        # Handle full_name -> first_name/last_name conversion
        if "full_name" in user_data:
            full_name = user_data.pop("full_name")
            if full_name:
                parts = full_name.split(maxsplit=1)
                user_data["first_name"] = parts[0]
                user_data["last_name"] = parts[1] if len(parts) > 1 else None
                user_data["display_name"] = full_name

        # Handle is_verified -> phone_verified conversion
        if "is_verified" in user_data:
            user_data["phone_verified"] = user_data.pop("is_verified")

        for key, value in user_data.items():
            if hasattr(user, key) and value is not None:
                setattr(user, key, value)

        self.db.commit()
        self.db.refresh(user)
        return user

    def delete(self, user_id) -> bool:
        """Delete user"""
        user = self.get_by_id(user_id)
        if not user:
            return False

        self.db.delete(user)
        self.db.commit()
        return True

    def create_session(
        self,
        user_id,
        access_token: str,
        refresh_token: str,
        expires_in: int = 1800,
        device_info: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> UserSession:
        """Create a new user session"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                raise ValueError(f"Invalid user_id format: {user_id}")

        session = UserSession(
            session_id=uuid.uuid4(),
            user_id=user_id,
            session_token=access_token,  # Using session_token for access_token
            refresh_token=refresh_token,
            expires_at=datetime.utcnow() + timedelta(seconds=expires_in),
            device_info=device_info,
            ip_address=ip_address,
        )
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session

    def get_active_session(self, user_id) -> Optional[UserSession]:
        """Get active session for user"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                return None

        return (
            self.db.query(UserSession)
            .filter(
                and_(
                    UserSession.user_id == user_id,
                    UserSession.expires_at > datetime.utcnow(),
                )
            )
            .first()
        )

    def deactivate_session(self, session_id) -> bool:
        """Deactivate a session"""
        if isinstance(session_id, str):
            try:
                session_id = uuid.UUID(session_id)
            except ValueError:
                return False

        # Since UserSession doesn't have is_active, we'll delete it or mark expires_at
        session = (
            self.db.query(UserSession)
            .filter(UserSession.session_id == session_id)
            .first()
        )
        if not session:
            return False

        # Set expires_at to past to deactivate
        session.expires_at = datetime.utcnow() - timedelta(seconds=1)
        self.db.commit()
        return True

    def deactivate_all_sessions(self, user_id) -> int:
        """Deactivate all sessions for a user"""
        if isinstance(user_id, str):
            try:
                user_id = uuid.UUID(user_id)
            except ValueError:
                return 0

        sessions = (
            self.db.query(UserSession)
            .filter(
                and_(
                    UserSession.user_id == user_id,
                    UserSession.expires_at > datetime.utcnow(),
                )
            )
            .all()
        )

        # Set expires_at to past for all sessions
        for session in sessions:
            session.expires_at = datetime.utcnow() - timedelta(seconds=1)

        self.db.commit()
        return len(sessions)
