"""
Presentation repository for database operations - updated for lic_schema
"""
from sqlalchemy.orm import Session, selectinload
from sqlalchemy import and_
from typing import Optional, List
from app.models.presentation import Presentation, Slide, PresentationTemplate
from app.models.agent import Agent
import uuid


class PresentationRepository:
    """Repository for presentation-related database operations"""

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

    # Presentation operations
    def get_by_id(self, presentation_id) -> Optional[Presentation]:
        """Get presentation by ID"""
        presentation_id = self._to_uuid(presentation_id)
        if not presentation_id:
            return None
        return (
            self.db.query(Presentation)
            .filter(Presentation.presentation_id == presentation_id)
            .first()
        )

    def get_active_by_agent(self, agent_id) -> Optional[Presentation]:
        """Get active presentation for an agent"""
        agent_id = self._to_uuid(agent_id)
        if not agent_id:
            return None

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
        agent_id,
        status: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> tuple[List[Presentation], int]:
        """Get all presentations for an agent"""
        agent_id = self._to_uuid(agent_id)
        if not agent_id:
            return [], 0

        query = self.db.query(Presentation).options(selectinload(Presentation.slides)).filter(
            Presentation.agent_id == agent_id
        )

        if status:
            query = query.filter(Presentation.status == status)

        total = query.count()
        presentations = query.order_by(Presentation.created_at.desc()).offset(offset).limit(limit).all()

        return presentations, total

    def create(self, presentation_data: dict) -> Presentation:
        """Create a new presentation"""
        agent_id = self._to_uuid(presentation_data.get("agent_id"))
        if not agent_id:
            raise ValueError("Invalid agent_id")

        template_id = None
        if presentation_data.get("template_id"):
            template_id = self._to_uuid(presentation_data.get("template_id"))

        presentation = Presentation(
            presentation_id=uuid.uuid4(),
            agent_id=agent_id,
            name=presentation_data.get("name"),
            description=presentation_data.get("description"),
            status=presentation_data.get("status", "draft"),
            is_active=presentation_data.get("is_active", False),
            template_id=template_id,
            tags=presentation_data.get("tags", []),
        )

        # Add slides if provided
        slides_data = presentation_data.get("slides", [])
        for slide_data in slides_data:
            slide = Slide(
                slide_id=uuid.uuid4(),
                presentation_id=presentation.presentation_id,
                slide_order=slide_data.get("slide_order", 0),
                slide_type=slide_data.get("slide_type", "text"),
                media_url=slide_data.get("media_url"),
                media_type=slide_data.get("media_type"),
                thumbnail_url=slide_data.get("thumbnail_url"),
                title=slide_data.get("title"),
                subtitle=slide_data.get("subtitle"),
                description=slide_data.get("description"),
                text_color=slide_data.get("text_color", "#FFFFFF"),
                background_color=slide_data.get("background_color", "#000000"),
                overlay_opacity=slide_data.get("overlay_opacity", 0.5),
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

    def update(self, presentation_id, presentation_data: dict) -> Optional[Presentation]:
        """Update a presentation"""
        presentation = self.get_by_id(presentation_id)
        if not presentation:
            return None

        # Update presentation fields
        for key, value in presentation_data.items():
            if key == "slides":
                # Handle slides separately
                continue
            if key == "agent_id":
                value = self._to_uuid(value)
            if key == "template_id" and value:
                value = self._to_uuid(value)
            if hasattr(presentation, key) and value is not None:
                setattr(presentation, key, value)

        # Update slides if provided
        if "slides" in presentation_data:
            # Delete existing slides
            self.db.query(Slide).filter(
                Slide.presentation_id == presentation.presentation_id
            ).delete()

            # Add new slides
            for slide_data in presentation_data["slides"]:
                slide = Slide(
                    slide_id=uuid.uuid4(),
                    presentation_id=presentation.presentation_id,
                    slide_order=slide_data.get("slide_order", 0),
                    slide_type=slide_data.get("slide_type", "text"),
                    media_url=slide_data.get("media_url"),
                    media_type=slide_data.get("media_type"),
                    thumbnail_url=slide_data.get("thumbnail_url"),
                    title=slide_data.get("title"),
                    subtitle=slide_data.get("subtitle"),
                    description=slide_data.get("description"),
                    text_color=slide_data.get("text_color", "#FFFFFF"),
                    background_color=slide_data.get("background_color", "#000000"),
                    overlay_opacity=slide_data.get("overlay_opacity", 0.5),
                    layout=slide_data.get("layout", "centered"),
                    duration=slide_data.get("duration", 4),
                    cta_button=slide_data.get("cta_button"),
                    agent_branding=slide_data.get("agent_branding"),
                )
                presentation.slides.append(slide)

        self.db.commit()
        self.db.refresh(presentation)
        return presentation

    def delete(self, presentation_id) -> bool:
        """Delete a presentation"""
        presentation = self.get_by_id(presentation_id)
        if not presentation:
            return False

        self.db.delete(presentation)
        self.db.commit()
        return True

    # Template operations
    def get_template_by_id(self, template_id) -> Optional[PresentationTemplate]:
        """Get template by ID"""
        template_id = self._to_uuid(template_id)
        if not template_id:
            return None
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
