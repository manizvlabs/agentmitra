"""
Presentation Service
===================

Service layer for presentation-related operations.
"""

from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from app.repositories.presentation_repository import PresentationRepository


class PresentationService:
    """Service for presentation operations"""

    def __init__(self, db: Session):
        self.db = db
        self.repository = PresentationRepository(db)

    async def get_user_presentations(
        self,
        user_id: str,
        limit: int = 10,
        include_featured: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Get presentations for a user

        Args:
            user_id: User ID to get presentations for
            limit: Maximum number of presentations to return
            include_featured: Whether to include featured presentations

        Returns:
            List of presentation dictionaries
        """
        try:
            # Get presentations from repository
            presentations = self.repository.get_user_presentations(user_id, limit)

            result = []
            for presentation in presentations:
                result.append({
                    "presentation_id": str(presentation.presentation_id),
                    "title": presentation.title or "Untitled Presentation",
                    "description": presentation.description or "",
                    "thumbnail_url": getattr(presentation, 'thumbnail_url', None),
                    "created_at": presentation.created_at.isoformat() if presentation.created_at else None,
                    "updated_at": presentation.updated_at.isoformat() if presentation.updated_at else None,
                    "status": getattr(presentation, 'status', 'draft'),
                    "is_featured": getattr(presentation, 'is_featured', False)
                })

            return result

        except Exception as e:
            # Return empty list on error to prevent dashboard failures
            print(f"Error getting user presentations: {e}")
            return []

    def get_presentation_by_id(self, presentation_id: str) -> Optional[Dict[str, Any]]:
        """Get presentation by ID"""
        try:
            presentation = self.repository.get_by_id(presentation_id)
            if presentation:
                return {
                    "presentation_id": str(presentation.presentation_id),
                    "title": presentation.title,
                    "description": presentation.description,
                    "slides": [],  # Would need to implement slide retrieval
                    "created_at": presentation.created_at.isoformat() if presentation.created_at else None,
                    "updated_at": presentation.updated_at.isoformat() if presentation.updated_at else None
                }
            return None
        except Exception as e:
            print(f"Error getting presentation by ID: {e}")
            return None
