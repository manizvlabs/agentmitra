"""
Campaign Automation Service - Trigger-based campaign execution
"""
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from uuid import UUID

from app.models.campaign import Campaign, CampaignTrigger, CampaignExecution
from app.models.policy import Policyholder, InsurancePolicy, PremiumPayment
from app.services.campaign_service import CampaignService
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class CampaignAutomationService:
    """Service for automating campaign execution based on triggers"""

    @staticmethod
    def process_customer_events(db: Session) -> Dict[str, int]:
        """
        Process customer events and trigger relevant campaigns
        Returns: Dict with trigger counts and results
        """
        results = {
            'triggers_processed': 0,
            'campaigns_triggered': 0,
            'messages_sent': 0,
            'errors': 0,
        }

        try:
            # Get active automated campaigns
            active_campaigns = db.query(Campaign).filter(
                and_(
                    Campaign.status == 'active',
                    Campaign.is_automated == True
                )
            ).all()

            for campaign in active_campaigns:
                try:
                    # Get campaign triggers
                    triggers = db.query(CampaignTrigger).filter(
                        and_(
                            CampaignTrigger.campaign_id == campaign.campaign_id,
                            CampaignTrigger.is_active == True
                        )
                    ).all()

                    if not triggers:
                        continue

                    # Find customers matching trigger conditions
                    target_customers = CampaignAutomationService._find_target_customers(
                        db, campaign, triggers
                    )

                    for customer in target_customers:
                        # Check if already executed recently (avoid spam)
                        recent_execution = db.query(CampaignExecution).filter(
                            and_(
                                CampaignExecution.campaign_id == campaign.campaign_id,
                                CampaignExecution.policyholder_id == customer.policyholder_id,
                                CampaignExecution.sent_at >= datetime.utcnow() - timedelta(hours=24)
                            )
                        ).first()

                        if recent_execution:
                            continue

                        # Execute campaign for customer
                        success = CampaignAutomationService._execute_campaign_for_customer(
                            db, campaign, customer
                        )

                        if success:
                            results['messages_sent'] += 1
                            results['campaigns_triggered'] += 1

                    results['triggers_processed'] += len(triggers)

                except Exception as e:
                    logger.error(f"Error processing campaign {campaign.campaign_id}: {e}")
                    results['errors'] += 1

            return results

        except Exception as e:
            logger.error(f"Error in process_customer_events: {e}")
            results['errors'] += 1
            return results

    @staticmethod
    def _find_target_customers(
        db: Session,
        campaign: Campaign,
        triggers: List[CampaignTrigger]
    ) -> List[Policyholder]:
        """Find customers matching trigger conditions"""
        customers = []

        # Get agent's customers
        query = db.query(Policyholder).filter(
            Policyholder.agent_id == campaign.agent_id
        )

        # Apply targeting rules from campaign
        if campaign.targeting_rules:
            # Apply targeting rules (simplified - can be expanded)
            if campaign.target_audience == 'active':
                query = query.join(InsurancePolicy).filter(
                    InsurancePolicy.status == 'active'
                )

        customers = query.all()

        # Filter by trigger conditions
        matching_customers = []
        for customer in customers:
            for trigger in triggers:
                if CampaignAutomationService._matches_trigger(db, trigger, customer):
                    matching_customers.append(customer)
                    break

        return matching_customers

    @staticmethod
    def _matches_trigger(
        db: Session,
        trigger: CampaignTrigger,
        customer: Policyholder
    ) -> bool:
        """Check if customer matches trigger condition"""
        try:
            if trigger.trigger_type == 'policy_renewal':
                # Check if customer has policy renewing within trigger timeframe
                days_ahead = int(trigger.trigger_value or 30)
                renewal_date = datetime.utcnow() + timedelta(days=days_ahead)

                policy_count = db.query(func.count(InsurancePolicy.policy_id)).filter(
                    and_(
                        InsurancePolicy.policyholder_id == customer.policyholder_id,
                        InsurancePolicy.renewal_date <= renewal_date,
                        InsurancePolicy.renewal_date >= datetime.utcnow(),
                        InsurancePolicy.status == 'active'
                    )
                ).scalar() or 0

                return policy_count > 0

            elif trigger.trigger_type == 'birthday':
                # Check if it's customer's birthday month
                if customer.date_of_birth:
                    return (
                        customer.date_of_birth.month == datetime.utcnow().month
                    )
                return False

            elif trigger.trigger_type == 'payment_overdue':
                # Check if customer has overdue payments
                overdue_count = db.query(func.count(PremiumPayment.payment_id)).join(
                    InsurancePolicy
                ).filter(
                    and_(
                        InsurancePolicy.policyholder_id == customer.policyholder_id,
                        PremiumPayment.status == 'pending',
                        PremiumPayment.due_date < datetime.utcnow()
                    )
                ).scalar() or 0

                return overdue_count > 0

            elif trigger.trigger_type == 'inactive_days':
                # Check days since last interaction
                max_days = int(trigger.trigger_value or 90)
                if customer.last_interaction_at:
                    days_since = (datetime.utcnow() - customer.last_interaction_at).days
                    return days_since >= max_days
                return True  # Never interacted

            return False

        except Exception as e:
            logger.error(f"Error matching trigger: {e}")
            return False

    @staticmethod
    def _execute_campaign_for_customer(
        db: Session,
        campaign: Campaign,
        customer: Policyholder
    ) -> bool:
        """Execute a campaign for a specific customer"""
        try:
            # Personalize campaign content
            personalized_content = CampaignAutomationService._personalize_content(
                campaign, customer, db
            )

            # Create execution record
            execution = CampaignExecution(
                campaign_id=campaign.campaign_id,
                policyholder_id=customer.policyholder_id,
                channel=campaign.primary_channel,
                personalized_content=personalized_content,
                status='pending',
                created_at=datetime.utcnow()
            )

            db.add(execution)
            
            # Update campaign metrics
            campaign.total_sent = (campaign.total_sent or 0) + 1
            
            db.commit()

            # TODO: Actually send message via messaging service
            # For now, mark as sent
            execution.status = 'sent'
            execution.sent_at = datetime.utcnow()
            db.commit()

            logger.info(f"Campaign {campaign.campaign_id} executed for customer {customer.policyholder_id}")
            return True

        except Exception as e:
            db.rollback()
            logger.error(f"Error executing campaign for customer: {e}")
            return False

    @staticmethod
    def _personalize_content(
        campaign: Campaign,
        customer: Policyholder,
        db: Session
    ) -> Dict[str, Any]:
        """Personalize campaign content with customer data"""
        content = {
            'subject': campaign.subject or '',
            'message': campaign.message or '',
            'channel': campaign.primary_channel,
        }

        # Replace personalization tags
        replacements = {
            '{{customer_name}}': customer.first_name or 'Customer',
            '{{customer_phone}}': customer.phone_number or '',
        }

        # Get customer's active policies for personalization
        active_policies = db.query(InsurancePolicy).filter(
            and_(
                InsurancePolicy.policyholder_id == customer.policyholder_id,
                InsurancePolicy.status == 'active'
            )
        ).all()

        if active_policies:
            primary_policy = active_policies[0]
            replacements.update({
                '{{policy_number}}': primary_policy.policy_number or '',
                '{{premium_amount}}': str(primary_policy.premium_amount or 0),
            })

        # Apply replacements
        for key, value in replacements.items():
            content['subject'] = content['subject'].replace(key, value)
            content['message'] = content['message'].replace(key, value)

        return content

    @staticmethod
    def get_campaign_recommendations(db: Session, agent_id: UUID) -> List[Dict]:
        """Get personalized campaign recommendations for an agent"""
        recommendations = []

        try:
            # Analyze agent's customer base
            customer_stats = CampaignAutomationService._analyze_customer_base(db, agent_id)

            # Generate recommendations
            if customer_stats.get('lapsed_customers', 0) > 0:
                recommendations.append({
                    'type': 'retention',
                    'title': 'Re-engagement Campaign',
                    'description': f'Reach out to {customer_stats["lapsed_customers"]} lapsed customers',
                    'target_audience': 'lapsed_customers',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['lapsed_customers'],
                    'potential_roi': '25-40%',
                })

            if customer_stats.get('renewal_due', 0) > 0:
                recommendations.append({
                    'type': 'retention',
                    'title': 'Renewal Reminder',
                    'description': f'Remind {customer_stats["renewal_due"]} customers about upcoming renewals',
                    'target_audience': 'renewal_due_30_days',
                    'suggested_channel': 'whatsapp',
                    'estimated_reach': customer_stats['renewal_due'],
                    'potential_roi': '35-50%',
                })

            return recommendations

        except Exception as e:
            logger.error(f"Error getting campaign recommendations: {e}")
            return []

    @staticmethod
    def _analyze_customer_base(db: Session, agent_id: UUID) -> Dict:
        """Analyze agent's customer base for campaign recommendations"""
        # Lapsed customers (no activity in 90 days)
        lapsed_cutoff = datetime.utcnow() - timedelta(days=90)
        lapsed_customers = db.query(func.count(func.distinct(Policyholder.policyholder_id))).join(
            InsurancePolicy
        ).filter(
            and_(
                Policyholder.agent_id == agent_id,
                InsurancePolicy.status == 'lapsed'
            )
        ).scalar() or 0

        # Renewal due in next 30 days
        renewal_cutoff = datetime.utcnow() + timedelta(days=30)
        renewal_due = db.query(func.count(func.distinct(InsurancePolicy.policyholder_id))).filter(
            and_(
                InsurancePolicy.agent_id == agent_id,
                InsurancePolicy.renewal_date <= renewal_cutoff,
                InsurancePolicy.renewal_date >= datetime.utcnow(),
                InsurancePolicy.status == 'active'
            )
        ).scalar() or 0

        return {
            'lapsed_customers': lapsed_customers,
            'renewal_due': renewal_due,
        }

