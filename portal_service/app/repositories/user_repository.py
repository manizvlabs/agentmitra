"""
Portal User Repository
======================

User data access layer for the portal service.
"""

from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID

from app.models.user import User


class UserRepository:
    """User repository for database operations"""

    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, user_id: str) -> Optional[User]:
        """Get user by ID"""
        try:
            uuid_obj = UUID(user_id)
            return self.db.query(User).filter(User.id == uuid_obj).first()
        except ValueError:
            return None

    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        return self.db.query(User).filter(User.email == email).first()

    def get_by_username(self, username: str) -> Optional[User]:
        """Get user by username"""
        return self.db.query(User).filter(User.username == username).first()

    def get_by_username_or_email(self, identifier: str) -> Optional[User]:
        """Get user by username or email"""
        return self.db.query(User).filter(
            (User.username == identifier) | (User.email == identifier)
        ).first()

    def get_agents(self, status: Optional[str] = None, limit: int = 20, offset: int = 0) -> List[User]:
        """Get agents with optional filtering"""
        query = self.db.query(User).filter(User.role.in_(["agent", "senior_agent"]))

        if status:
            query = query.filter(User.status == status)

        return query.offset(offset).limit(limit).all()

    def count_agents(self, status: Optional[str] = None) -> int:
        """Count agents with optional status filter"""
        query = self.db.query(User).filter(User.role.in_(["agent", "senior_agent"]))

        if status:
            query = query.filter(User.status == status)

        return query.count()

    def create(self, user: User) -> User:
        """Create new user"""
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def update(self, user: User) -> User:
        """Update existing user"""
        self.db.commit()
        self.db.refresh(user)
        return user

    def delete(self, user_id: str) -> bool:
        """Delete user by ID"""
        try:
            uuid_obj = UUID(user_id)
            user = self.db.query(User).filter(User.id == uuid_obj).first()
            if user:
                self.db.delete(user)
                self.db.commit()
                return True
            return False
        except ValueError:
            return False
