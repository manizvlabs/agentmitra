"""
Campaign Service - CRUD operations for marketing campaigns
"""
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from uuid import UUID

from app.models.campaign import Campaign, CampaignTrigger, CampaignExecution, CampaignTemplate, CampaignResponse
from app.models.policy import Policyholder
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class CampaignService:
    """Service for campaign CRUD operations"""

    @staticmethod
    def create_campaign(
        db: Session,
        tenant_id: UUID,
        agent_id: UUID,
        campaign_data: Dict[str, Any],
        created_by: UUID
    ) -> Campaign:
        """Create a new campaign"""
        try:
            campaign = Campaign(
                tenant_id=tenant_id,
                agent_id=agent_id,
                campaign_name=campaign_data.get("campaign_name"),
                campaign_type=campaign_data.get("campaign_type"),
                campaign_goal=campaign_data.get("campaign_goal"),
                description=campaign_data.get("description"),
                subject=campaign_data.get("subject"),
                message=campaign_data.get("message"),
                message_template_id=campaign_data.get("message_template_id"),
                personalization_tags=campaign_data.get("personalization_tags", []),
                attachments=campaign_data.get("attachments"),
                primary_channel=campaign_data.get("primary_channel", "whatsapp"),
                channels=campaign_data.get("channels", []),
                target_audience=campaign_data.get("target_audience", "all"),
                selected_segments=campaign_data.get("selected_segments", []),
                targeting_rules=campaign_data.get("targeting_rules"),
                estimated_reach=campaign_data.get("estimated_reach", 0),
                schedule_type=campaign_data.get("schedule_type", "immediate"),
                scheduled_at=campaign_data.get("scheduled_at"),
                start_date=campaign_data.get("start_date"),
                end_date=campaign_data.get("end_date"),
                is_automated=campaign_data.get("is_automated", False),
                automation_triggers=campaign_data.get("automation_triggers"),
                budget=campaign_data.get("budget", 0),
                estimated_cost=campaign_data.get("estimated_cost", 0),
                cost_per_recipient=campaign_data.get("cost_per_recipient", 0),
                ab_testing_enabled=campaign_data.get("ab_testing_enabled", False),
                ab_test_variants=campaign_data.get("ab_test_variants"),
                status=campaign_data.get("status", "draft"),
                created_by=created_by,
            )
            
            db.add(campaign)
            db.commit()
            db.refresh(campaign)
            
            # Create triggers if provided
            if campaign_data.get("triggers"):
                for trigger_data in campaign_data["triggers"]:
                    trigger = CampaignTrigger(
                        campaign_id=campaign.campaign_id,
                        trigger_type=trigger_data.get("trigger_type"),
                        trigger_value=trigger_data.get("trigger_value"),
                        additional_conditions=trigger_data.get("additional_conditions"),
                        is_active=trigger_data.get("is_active", True),
                    )
                    db.add(trigger)
                db.commit()
            
            logger.info(f"Campaign created: {campaign.campaign_id}")
            return campaign
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error creating campaign: {e}")
            raise

    @staticmethod
    def get_campaign(db: Session, campaign_id: UUID, agent_id: Optional[UUID] = None) -> Optional[Campaign]:
        """Get a campaign by ID"""
        query = db.query(Campaign).filter(Campaign.campaign_id == campaign_id)
        if agent_id:
            query = query.filter(Campaign.agent_id == agent_id)
        return query.first()

    @staticmethod
    def list_campaigns(
        db: Session,
        agent_id: Optional[UUID] = None,
        status: Optional[str] = None,
        campaign_type: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> List[Campaign]:
        """List campaigns with filters"""
        query = db.query(Campaign)
        
        if agent_id:
            query = query.filter(Campaign.agent_id == agent_id)
        if status:
            query = query.filter(Campaign.status == status)
        if campaign_type:
            query = query.filter(Campaign.campaign_type == campaign_type)
        
        return query.order_by(desc(Campaign.created_at)).limit(limit).offset(offset).all()

    @staticmethod
    def update_campaign(
        db: Session,
        campaign_id: UUID,
        agent_id: UUID,
        update_data: Dict[str, Any],
        updated_by: UUID
    ) -> Optional[Campaign]:
        """Update a campaign"""
        campaign = db.query(Campaign).filter(
            and_(
                Campaign.campaign_id == campaign_id,
                Campaign.agent_id == agent_id
            )
        ).first()
        
        if not campaign:
            return None
        
        try:
            for key, value in update_data.items():
                if hasattr(campaign, key) and key not in ["campaign_id", "created_at", "created_by"]:
                    setattr(campaign, key, value)
            
            campaign.updated_by = updated_by
            campaign.updated_at = datetime.utcnow()
            
            db.commit()
            db.refresh(campaign)
            
            logger.info(f"Campaign updated: {campaign_id}")
            return campaign
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error updating campaign: {e}")
            raise

    @staticmethod
    def delete_campaign(db: Session, campaign_id: UUID, agent_id: UUID) -> bool:
        """Delete a campaign"""
        campaign = db.query(Campaign).filter(
            and_(
                Campaign.campaign_id == campaign_id,
                Campaign.agent_id == agent_id
            )
        ).first()
        
        if not campaign:
            return False
        
        try:
            db.delete(campaign)
            db.commit()
            logger.info(f"Campaign deleted: {campaign_id}")
            return True
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error deleting campaign: {e}")
            raise

    @staticmethod
    def launch_campaign(db: Session, campaign_id: UUID, agent_id: UUID) -> Optional[Campaign]:
        """Launch a campaign"""
        campaign = db.query(Campaign).filter(
            and_(
                Campaign.campaign_id == campaign_id,
                Campaign.agent_id == agent_id
            )
        ).first()
        
        if not campaign:
            return None
        
        if campaign.status not in ["draft", "scheduled", "paused"]:
            raise ValueError(f"Cannot launch campaign with status: {campaign.status}")
        
        try:
            campaign.status = "active"
            campaign.launched_at = datetime.utcnow()
            if campaign.scheduled_at and campaign.scheduled_at > datetime.utcnow():
                campaign.scheduled_at = datetime.utcnow()
            
            db.commit()
            db.refresh(campaign)
            
            logger.info(f"Campaign launched: {campaign_id}")
            return campaign
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error launching campaign: {e}")
            raise

    @staticmethod
    def pause_campaign(db: Session, campaign_id: UUID, agent_id: UUID) -> Optional[Campaign]:
        """Pause an active campaign"""
        campaign = db.query(Campaign).filter(
            and_(
                Campaign.campaign_id == campaign_id,
                Campaign.agent_id == agent_id,
                Campaign.status == "active"
            )
        ).first()
        
        if not campaign:
            return None
        
        try:
            campaign.status = "paused"
            campaign.paused_at = datetime.utcnow()
            
            db.commit()
            db.refresh(campaign)
            
            logger.info(f"Campaign paused: {campaign_id}")
            return campaign
            
        except Exception as e:
            db.rollback()
            logger.error(f"Error pausing campaign: {e}")
            raise

    @staticmethod
    def get_campaign_templates(
        db: Session,
        category: Optional[str] = None,
        is_public: bool = True,
        limit: int = 50
    ) -> List[CampaignTemplate]:
        """Get campaign templates"""
        query = db.query(CampaignTemplate).filter(CampaignTemplate.status == "active")
        
        if category:
            query = query.filter(CampaignTemplate.category == category)
        if is_public:
            query = query.filter(CampaignTemplate.is_public == True)
        
        return query.order_by(desc(CampaignTemplate.usage_count)).limit(limit).all()

    @staticmethod
    def create_campaign_from_template(
        db: Session,
        tenant_id: UUID,
        agent_id: UUID,
        template_id: UUID,
        campaign_data: Dict[str, Any],
        created_by: UUID
    ) -> Campaign:
        """Create a campaign from a template"""
        template = db.query(CampaignTemplate).filter(CampaignTemplate.template_id == template_id).first()
        
        if not template:
            raise ValueError(f"Template not found: {template_id}")
        
        # Merge template data with campaign data
        merged_data = {
            "campaign_name": campaign_data.get("campaign_name", template.template_name),
            "campaign_type": campaign_data.get("campaign_type", template.category),
            "subject": campaign_data.get("subject", template.subject_template),
            "message": campaign_data.get("message", template.message_template),
            "personalization_tags": campaign_data.get("personalization_tags", template.personalization_tags or []),
            "channels": campaign_data.get("channels", template.suggested_channels or []),
            **campaign_data
        }
        
        campaign = CampaignService.create_campaign(db, tenant_id, agent_id, merged_data, created_by)
        
        # Update template usage count
        template.usage_count = (template.usage_count or 0) + 1
        db.commit()
        
        return campaign

