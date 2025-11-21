"""
User repository for database operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import Optional
from app.models.user import User, UserSession
import uuid
from datetime import datetime, timedelta


class UserRepository:
    """Repository for user-related database operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, user_id: str) -> Optional[User]:
        """Get user by ID"""
        return self.db.query(User).filter(User.user_id == user_id).first()

    def get_by_phone(self, phone_number: str) -> Optional[User]:
        """Get user by phone number"""
        return self.db.query(User).filter(User.phone_number == phone_number).first()

    def get_by_agent_code(self, agent_code: str) -> Optional[User]:
        """Get user by agent code"""
        return self.db.query(User).filter(User.agent_code == agent_code).first()

    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return self.db.query(User).filter(User.email == email).first()

    def create(self, user_data: dict) -> User:
        """Create a new user"""
        user = User(
            user_id=str(uuid.uuid4()),
            phone_number=user_data.get("phone_number"),
            email=user_data.get("email"),
            full_name=user_data.get("full_name"),
            agent_code=user_data.get("agent_code"),
            role=user_data.get("role", "customer"),
            is_verified=user_data.get("is_verified", False),
            password_hash=user_data.get("password_hash"),
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def update(self, user_id: str, user_data: dict) -> Optional[User]:
        """Update user"""
        user = self.get_by_id(user_id)
        if not user:
            return None

        for key, value in user_data.items():
            if hasattr(user, key) and value is not None:
                setattr(user, key, value)

        self.db.commit()
        self.db.refresh(user)
        return user

    def delete(self, user_id: str) -> bool:
        """Delete user"""
        user = self.get_by_id(user_id)
        if not user:
            return False

        self.db.delete(user)
        self.db.commit()
        return True

    def create_session(
        self,
        user_id: str,
        access_token: str,
        refresh_token: str,
        expires_in: int = 1800,
        device_info: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> UserSession:
        """Create a new user session"""
        session = UserSession(
            session_id=str(uuid.uuid4()),
            user_id=user_id,
            access_token=access_token,
            refresh_token=refresh_token,
            expires_at=datetime.utcnow() + timedelta(seconds=expires_in),
            device_info=device_info,
            ip_address=ip_address,
            is_active=True,
        )
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session

    def get_active_session(self, user_id: str) -> Optional[UserSession]:
        """Get active session for user"""
        return (
            self.db.query(UserSession)
            .filter(
                and_(
                    UserSession.user_id == user_id,
                    UserSession.is_active == True,
                    UserSession.expires_at > datetime.utcnow(),
                )
            )
            .first()
        )

    def deactivate_session(self, session_id: str) -> bool:
        """Deactivate a session"""
        session = (
            self.db.query(UserSession)
            .filter(UserSession.session_id == session_id)
            .first()
        )
        if not session:
            return False

        session.is_active = False
        self.db.commit()
        return True

    def deactivate_all_sessions(self, user_id: str) -> int:
        """Deactivate all sessions for a user"""
        sessions = (
            self.db.query(UserSession)
            .filter(
                and_(
                    UserSession.user_id == user_id,
                    UserSession.is_active == True,
                )
            )
            .all()
        )

        for session in sessions:
            session.is_active = False

        self.db.commit()
        return len(sessions)

