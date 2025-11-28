"""
Template Service
================

Service for managing message templates for WhatsApp, SMS, and email communications.
"""

from typing import List, Dict, Optional, Any
from sqlalchemy.orm import Session

from app.models.whatsapp_template import WhatsAppTemplate


class TemplateService:
    """Template management service"""

    def __init__(self, db: Session):
        self.db = db

    async def get_template(self, template_name: str, language: str = "en") -> Optional[WhatsAppTemplate]:
        """Get template by name and language"""
        return self.db.query(WhatsAppTemplate).filter(
            WhatsAppTemplate.name == template_name,
            WhatsAppTemplate.language == language,
            WhatsAppTemplate.is_active == True,
            WhatsAppTemplate.status == "approved"
        ).first()

    async def create_template(self, template_data: Dict[str, Any]) -> WhatsAppTemplate:
        """Create new template"""
        template = WhatsAppTemplate(**template_data)
        self.db.add(template)
        await self.db.commit()
        await self.db.refresh(template)
        return template

    async def update_template_status(self, template_id: str, status: str, rejection_reason: Optional[str] = None):
        """Update template approval status"""
        template = await self.get_template_by_id(template_id)
        if template:
            template.status = status
            if rejection_reason:
                template.rejection_reason = rejection_reason
            await self.db.commit()

    async def get_template_by_id(self, template_id: str) -> Optional[WhatsAppTemplate]:
        """Get template by ID"""
        return self.db.query(WhatsAppTemplate).filter(
            WhatsAppTemplate.template_id == template_id
        ).first()

    async def list_templates(self, category: Optional[str] = None, language: str = "en") -> List[WhatsAppTemplate]:
        """List templates with optional filtering"""
        query = self.db.query(WhatsAppTemplate).filter(
            WhatsAppTemplate.language == language,
            WhatsAppTemplate.is_active == True
        )

        if category:
            query = query.filter(WhatsAppTemplate.category == category)

        return query.all()

    async def deactivate_template(self, template_id: str):
        """Deactivate template"""
        template = await self.get_template_by_id(template_id)
        if template:
            template.is_active = False
            await self.db.commit()
