"""
Presentation repository for database operations
"""
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import Optional, List
from app.models.presentation import Presentation, Slide, PresentationTemplate
import uuid


class PresentationRepository:
    """Repository for presentation-related database operations"""

    def __init__(self, db: Session):
        self.db = db

    # Presentation operations
    def get_by_id(self, presentation_id: str) -> Optional[Presentation]:
        """Get presentation by ID"""
        return (
            self.db.query(Presentation)
            .filter(Presentation.presentation_id == presentation_id)
            .first()
        )

    def get_active_by_agent(self, agent_id: str) -> Optional[Presentation]:
        """Get active presentation for an agent"""
        return (
            self.db.query(Presentation)
            .filter(
                and_(
                    Presentation.agent_id == agent_id,
                    Presentation.is_active == True,
                    Presentation.status == "published",
                )
            )
            .first()
        )

    def get_by_agent(
        self,
        agent_id: str,
        status: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> tuple[List[Presentation], int]:
        """Get all presentations for an agent"""
        query = self.db.query(Presentation).filter(
            Presentation.agent_id == agent_id
        )

        if status:
            query = query.filter(Presentation.status == status)

        total = query.count()
        presentations = query.order_by(Presentation.created_at.desc()).offset(offset).limit(limit).all()

        return presentations, total

    def create(self, presentation_data: dict) -> Presentation:
        """Create a new presentation"""
        presentation = Presentation(
            presentation_id=str(uuid.uuid4()),
            agent_id=presentation_data.get("agent_id"),
            name=presentation_data.get("name"),
            description=presentation_data.get("description"),
            status=presentation_data.get("status", "draft"),
            is_active=presentation_data.get("is_active", False),
            template_id=presentation_data.get("template_id"),
            tags=presentation_data.get("tags", []),
        )

        # Add slides if provided
        slides_data = presentation_data.get("slides", [])
        for slide_data in slides_data:
            slide = Slide(
                slide_id=str(uuid.uuid4()),
                presentation_id=presentation.presentation_id,
                slide_order=slide_data.get("slide_order", 0),
                slide_type=slide_data.get("slide_type", "text"),
                media_url=slide_data.get("media_url"),
                thumbnail_url=slide_data.get("thumbnail_url"),
                title=slide_data.get("title"),
                subtitle=slide_data.get("subtitle"),
                text_color=slide_data.get("text_color", "#FFFFFF"),
                background_color=slide_data.get("background_color", "#000000"),
                layout=slide_data.get("layout", "centered"),
                duration=slide_data.get("duration", 4),
                cta_button=slide_data.get("cta_button"),
                agent_branding=slide_data.get("agent_branding"),
            )
            presentation.slides.append(slide)

        self.db.add(presentation)
        self.db.commit()
        self.db.refresh(presentation)
        return presentation

    def update(self, presentation_id: str, presentation_data: dict) -> Optional[Presentation]:
        """Update a presentation"""
        presentation = self.get_by_id(presentation_id)
        if not presentation:
            return None

        # Update presentation fields
        for key, value in presentation_data.items():
            if key == "slides":
                # Handle slides separately
                continue
            if hasattr(presentation, key) and value is not None:
                setattr(presentation, key, value)

        # Update slides if provided
        if "slides" in presentation_data:
            # Delete existing slides
            self.db.query(Slide).filter(
                Slide.presentation_id == presentation_id
            ).delete()

            # Add new slides
            for slide_data in presentation_data["slides"]:
                slide = Slide(
                    slide_id=str(uuid.uuid4()),
                    presentation_id=presentation.presentation_id,
                    slide_order=slide_data.get("slide_order", 0),
                    slide_type=slide_data.get("slide_type", "text"),
                    media_url=slide_data.get("media_url"),
                    thumbnail_url=slide_data.get("thumbnail_url"),
                    title=slide_data.get("title"),
                    subtitle=slide_data.get("subtitle"),
                    text_color=slide_data.get("text_color", "#FFFFFF"),
                    background_color=slide_data.get("background_color", "#000000"),
                    layout=slide_data.get("layout", "centered"),
                    duration=slide_data.get("duration", 4),
                    cta_button=slide_data.get("cta_button"),
                    agent_branding=slide_data.get("agent_branding"),
                )
                presentation.slides.append(slide)

        self.db.commit()
        self.db.refresh(presentation)
        return presentation

    def delete(self, presentation_id: str) -> bool:
        """Delete a presentation"""
        presentation = self.get_by_id(presentation_id)
        if not presentation:
            return False

        self.db.delete(presentation)
        self.db.commit()
        return True

    # Template operations
    def get_template_by_id(self, template_id: str) -> Optional[PresentationTemplate]:
        """Get template by ID"""
        return (
            self.db.query(PresentationTemplate)
            .filter(PresentationTemplate.template_id == template_id)
            .first()
        )

    def get_templates(
        self, category: Optional[str] = None, is_public: bool = True
    ) -> List[PresentationTemplate]:
        """Get presentation templates"""
        query = self.db.query(PresentationTemplate).filter(
            PresentationTemplate.is_public == is_public
        )

        if category:
            query = query.filter(PresentationTemplate.category == category)

        return query.all()

