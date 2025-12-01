"""
Pioneer Repository
Repository for Pioneer feature flag database operations
"""

import logging
import os
from typing import List, Dict, Any, Optional
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

from app.models.pioneer import PioneerFlag, PioneerKey, PioneerLog
from app.core.config.settings import settings

logger = logging.getLogger(__name__)


class PioneerRepository:
    """Repository for Pioneer feature flag operations"""

    def __init__(self, db_url: Optional[str] = None):
        """Initialize with Pioneer database connection"""
        # When running locally (not in Docker), connect to localhost
        # When in Docker, connect to host.docker.internal
        host = os.getenv("PIONEER_DB_HOST", "localhost")  # Default to localhost for local development
        self.db_url = db_url or f"postgresql://pioneer:pioneer123@{host}:5432/pioneer"
        self.engine = create_engine(self.db_url, echo=settings.db_echo)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)

    def get_db(self) -> Session:
        """Get database session"""
        return self.SessionLocal()

    def get_all_flags(self) -> List[Dict[str, Any]]:
        """Get all feature flags from Pioneer database"""
        try:
            with self.get_db() as db:
                flags = db.query(PioneerFlag).all()
                return [{
                    "id": flag.id,
                    "title": flag.title,
                    "description": flag.description,
                    "is_active": flag.is_active,
                    "version": flag.version,
                    "rollout": flag.rollout,
                    "updated_at": flag.updated_at.isoformat() if flag.updated_at else None,
                    "created_at": flag.created_at.isoformat() if flag.created_at else None
                } for flag in flags]
        except Exception as e:
            logger.error(f"Error fetching flags from Pioneer: {e}")
            return []

    def get_flag_by_title(self, title: str) -> Optional[Dict[str, Any]]:
        """Get a specific flag by title"""
        try:
            with self.get_db() as db:
                flag = db.query(PioneerFlag).filter(PioneerFlag.title == title).first()
                if flag:
                    return {
                        "id": flag.id,
                        "title": flag.title,
                        "description": flag.description,
                        "is_active": flag.is_active,
                        "version": flag.version,
                        "rollout": flag.rollout,
                        "updated_at": flag.updated_at.isoformat() if flag.updated_at else None,
                        "created_at": flag.created_at.isoformat() if flag.created_at else None
                    }
                return None
        except Exception as e:
            logger.error(f"Error fetching flag '{title}' from Pioneer: {e}")
            return None

    def is_flag_active(self, title: str) -> bool:
        """Check if a flag is active (is_active=True and rollout=100)"""
        try:
            with self.get_db() as db:
                flag = db.query(PioneerFlag).filter(PioneerFlag.title == title).first()
                if flag:
                    # Flag is active if is_active=True AND rollout=100
                    return flag.is_active and flag.rollout == 100
                return False
        except Exception as e:
            logger.error(f"Error checking flag '{title}' status: {e}")
            return False

    def get_user_flags(self, user_id: Optional[str] = None) -> Dict[str, bool]:
        """Get all flags as a dictionary suitable for user context"""
        try:
            flags_data = self.get_all_flags()
            result = {}

            for flag in flags_data:
                flag_name = flag["title"]
                # Flag is enabled if is_active=True and rollout=100
                is_enabled = flag["is_active"] and flag["rollout"] == 100
                result[flag_name] = is_enabled

            logger.info(f"Retrieved {len(result)} feature flags from Pioneer database")
            return result

        except Exception as e:
            logger.error(f"Error getting user flags from Pioneer: {e}")
            return {}

    def create_flag(self, title: str, description: str = "", is_active: bool = False, rollout: int = 0) -> bool:
        """Create a new feature flag"""
        try:
            with self.get_db() as db:
                # Check if flag already exists
                existing = db.query(PioneerFlag).filter(PioneerFlag.title == title).first()
                if existing:
                    logger.warning(f"Flag '{title}' already exists")
                    return False

                new_flag = PioneerFlag(
                    title=title,
                    description=description or "No description provided.",
                    is_active=is_active,
                    rollout=rollout
                )
                db.add(new_flag)
                db.commit()
                logger.info(f"Created new flag: {title}")
                return True

        except Exception as e:
            logger.error(f"Error creating flag '{title}': {e}")
            return False

    def update_flag(self, title: str, is_active: Optional[bool] = None, rollout: Optional[int] = None, description: Optional[str] = None) -> bool:
        """Update an existing feature flag"""
        try:
            with self.get_db() as db:
                flag = db.query(PioneerFlag).filter(PioneerFlag.title == title).first()
                if not flag:
                    logger.warning(f"Flag '{title}' not found")
                    return False

                if is_active is not None:
                    flag.is_active = is_active
                if rollout is not None:
                    flag.rollout = rollout
                if description is not None:
                    flag.description = description

                db.commit()
                logger.info(f"Updated flag: {title}")
                return True

        except Exception as e:
            logger.error(f"Error updating flag '{title}': {e}")
            return False

    def delete_flag(self, title: str) -> bool:
        """Delete a feature flag"""
        try:
            with self.get_db() as db:
                flag = db.query(PioneerFlag).filter(PioneerFlag.title == title).first()
                if not flag:
                    logger.warning(f"Flag '{title}' not found")
                    return False

                db.delete(flag)
                db.commit()
                logger.info(f"Deleted flag: {title}")
                return True

        except Exception as e:
            logger.error(f"Error deleting flag '{title}': {e}")
            return False

    def health_check(self) -> bool:
        """Check if Pioneer database is accessible"""
        try:
            with self.get_db() as db:
                # Simple query to test connection
                result = db.execute(text("SELECT 1")).fetchone()
                return result is not None
        except Exception as e:
            logger.error(f"Pioneer database health check failed: {e}")
            return False


# Global repository instance
_pioneer_repo = None

def get_pioneer_repository() -> PioneerRepository:
    """Get global Pioneer repository instance"""
    global _pioneer_repo
    if _pioneer_repo is None:
        _pioneer_repo = PioneerRepository()
    return _pioneer_repo
