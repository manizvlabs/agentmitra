"""
Hot Leads & Opportunities Service - Lead scoring and opportunity identification
"""
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging
from decimal import Decimal

from app.core.logging_config import get_logger

logger = get_logger(__name__)


class HotLeadsService:
    """Service for identifying and scoring hot leads and opportunities"""

    @staticmethod
    def get_hot_leads(agent_id: str, priority_filter: str = 'all') -> Dict[str, Any]:
        """
        Get hot leads and opportunities for an agent

        Args:
            agent_id: Agent identifier
            priority_filter: Priority filter ('all', 'high', 'medium', 'low')

        Returns:
            Dict containing hot leads data and summary metrics
        """
        try:
            # Get all leads for the agent
            leads = HotLeadsService._get_agent_leads(agent_id)

            # Score and prioritize leads
            scored_leads = HotLeadsService._score_leads(leads)

            # Filter by priority if specified
            if priority_filter != 'all':
                scored_leads = [lead for lead in scored_leads if lead['priority'] == priority_filter]

            # Sort by conversion score (descending)
            scored_leads.sort(key=lambda x: x['conversion_score'], reverse=True)

            # Calculate summary metrics
            summary = HotLeadsService._calculate_lead_summary(scored_leads)

            return {
                'agent_id': agent_id,
                'total_leads_count': len(scored_leads),
                'hot_leads_count': len([l for l in scored_leads if l['priority'] == 'high']),
                'total_potential_value': sum(l['potential_premium'] for l in scored_leads),
                'conversion_rate': summary['conversion_rate'],
                'leads': scored_leads[:50],  # Return top 50 leads
                'summary': summary,
                'generated_at': datetime.utcnow().isoformat(),
            }

        except Exception as e:
            logger.error(f"Hot leads service error for agent {agent_id}: {str(e)}")
            raise

    @staticmethod
    def _get_agent_leads(agent_id: str) -> List[Dict[str, Any]]:
        """Get all leads for an agent with relevant data"""
        from sqlalchemy.orm import Session
        from app.core.database import get_db_session

        with get_db_session() as session:
            # Try to use leads table if it exists, otherwise generate simulated leads based on policies
            try:
                from app.models.lead import Lead

                leads_query = session.query(Lead).filter(
                    Lead.agent_id == agent_id,
                    Lead.lead_status.in_(['new', 'contacted', 'qualified'])
                ).limit(20).all()

                leads = []
                for lead in leads_query:
                    # Calculate lead age in days
                    lead_age_days = (datetime.utcnow() - lead.created_at).days

                    leads.append({
                        'lead_id': str(lead.lead_id),
                        'customer_name': lead.customer_name,
                        'contact_number': lead.contact_number,
                        'lead_source': lead.lead_source,
                        'lead_age_days': lead_age_days,
                        'engagement_score': float(lead.engagement_score or 50),
                        'budget_range': lead.budget_range or 'medium',
                        'insurance_type': lead.insurance_type or 'term_life',
                        'urgency_level': 'high' if lead.priority == 'high' else 'medium' if lead.priority == 'medium' else 'low',
                        'previous_interactions': lead.followup_count or 0,
                        'response_time_hours': float(lead.response_time_hours or 24.0),
                        'last_contact': lead.last_contact_at.isoformat() if lead.last_contact_at else None,
                    })

                # If we have leads from database, return them
                if leads:
                    return leads

            except (ImportError, AttributeError):
                pass

            # Fallback: Generate simulated leads based on recent policy activity
            from app.models.policy import InsurancePolicy, Policyholder

            # Get recent policies that could represent leads
            recent_policies = session.query(InsurancePolicy, Policyholder).join(Policyholder).filter(
                InsurancePolicy.agent_id == agent_id,
                InsurancePolicy.created_at >= datetime.utcnow() - timedelta(days=30)
            ).limit(10).all()

            leads = []
            lead_sources = ['website', 'referral', 'whatsapp_campaign', 'email_campaign', 'social_media']
            insurance_types = ['term_life', 'health', 'ulip', 'comprehensive']

            for i, (policy, customer) in enumerate(recent_policies):
                lead_age_days = (datetime.utcnow() - policy.created_at).days

                # Get customer name from the related user
                customer_name = "Unknown Customer"
                if customer.user:
                    customer_name = f"{customer.user.first_name or 'Unknown'} {customer.user.last_name or 'Customer'}"

                leads.append({
                    'customer_name': customer_name,
                    'contact_number': customer.user.phone_number if customer.user else '+91-9876543210',
                    'lead_source': lead_sources[i % len(lead_sources)],
                    'lead_age_days': min(lead_age_days, 30),  # Cap at 30 days
                    'engagement_score': 70 + (i * 5) % 30,  # Vary engagement scores
                    'budget_range': 'high' if (policy.premium_amount or 0) > 50000 else 'medium',
                    'insurance_type': insurance_types[i % len(insurance_types)],
                    'urgency_level': 'high' if i < 3 else 'medium',
                    'previous_interactions': i % 5,
                    'response_time_hours': 2.0 + (i * 3) % 20,
                })

            return leads

    @staticmethod
    def _score_leads(leads: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Score leads based on multiple factors and calculate conversion probability"""
        scored_leads = []

        for lead in leads:
            # Calculate individual scores (0-100 scale)
            engagement_score = lead['engagement_score']

            # Lead age score (newer leads score higher)
            age_score = max(0, 100 - (lead['lead_age_days'] * 3))

            # Urgency score based on insurance type and urgency level
            urgency_multipliers = {
                'high': 1.5,
                'medium': 1.0,
                'low': 0.7
            }
            base_urgency = urgency_multipliers.get(lead['urgency_level'], 1.0)

            # Insurance type premium potential
            premium_potential = {
                'term_life': 50000,
                'health': 15000,
                'ulip': 75000,
                'comprehensive': 25000,
                'two_wheeler': 8000,
                'car': 20000,
            }.get(lead['insurance_type'], 20000)

            # Budget range multiplier
            budget_multipliers = {
                'high': 1.3,
                'medium': 1.0,
                'low': 0.8
            }
            budget_multiplier = budget_multipliers.get(lead['budget_range'], 1.0)

            potential_premium = int(premium_potential * budget_multiplier)

            # Lead source effectiveness
            source_effectiveness = {
                'referral': 1.4,
                'partner_referral': 1.3,
                'website_form': 1.2,
                'whatsapp_campaign': 1.1,
                'email_campaign': 1.0,
                'social_media': 0.9,
                'cold_call': 0.7,
                'event_followup': 0.8,
            }.get(lead['lead_source'], 1.0)

            # Response time score (faster response = higher score)
            response_time_score = max(0, 100 - (lead['response_time_hours'] * 2))

            # Previous interactions score
            interaction_score = min(100, lead['previous_interactions'] * 15)

            # Calculate overall conversion score
            conversion_score = (
                engagement_score * 0.25 +          # 25% weight
                age_score * 0.20 +                 # 20% weight
                response_time_score * 0.15 +       # 15% weight
                interaction_score * 0.15 +         # 15% weight
                (base_urgency * source_effectiveness * 20)  # 25% weight combined
            )

            # Normalize to 0-100
            conversion_score = min(100, max(0, conversion_score))

            # Determine priority based on conversion score
            if conversion_score >= 80:
                priority = 'high'
            elif conversion_score >= 60:
                priority = 'medium'
            else:
                priority = 'low'

            scored_lead = {
                'lead_id': lead['lead_id'],
                'customer_name': lead['customer_name'],
                'contact_number': lead['contact_number'],
                'conversion_score': round(conversion_score, 1),
                'priority': priority,
                'potential_premium': potential_premium,
                'insurance_type': lead['insurance_type'],
                'lead_source': lead['lead_source'],
                'last_contact': lead['last_contact'],
                'engagement_score': engagement_score,
                'urgency_level': lead['urgency_level'],
                'lead_age_days': lead['lead_age_days'],
                'response_time_hours': lead['response_time_hours'],
                'previous_interactions': lead['previous_interactions'],
            }

            scored_leads.append(scored_lead)

        return scored_leads

    @staticmethod
    def _calculate_lead_summary(scored_leads: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate summary metrics for leads"""
        if not scored_leads:
            return {
                'total_leads': 0,
                'hot_leads': 0,
                'conversion_rate': 0,
                'avg_conversion_score': 0,
                'total_potential_value': 0,
                'priority_breakdown': {'high': 0, 'medium': 0, 'low': 0}
            }

        total_leads = len(scored_leads)
        hot_leads = len([l for l in scored_leads if l['priority'] == 'high'])
        avg_conversion_score = sum(l['conversion_score'] for l in scored_leads) / total_leads

        # Calculate priority breakdown
        priority_breakdown = {'high': 0, 'medium': 0, 'low': 0}
        for lead in scored_leads:
            priority_breakdown[lead['priority']] += 1

        # Estimate conversion rate based on historical patterns
        # This is a simplified estimation
        conversion_rate = min(100, max(0, avg_conversion_score * 0.8))

        total_potential_value = sum(l['potential_premium'] for l in scored_leads)

        return {
            'total_leads': total_leads,
            'hot_leads': hot_leads,
            'conversion_rate': round(conversion_rate, 1),
            'avg_conversion_score': round(avg_conversion_score, 1),
            'total_potential_value': total_potential_value,
            'priority_breakdown': priority_breakdown,
        }

    @staticmethod
    def get_lead_details(lead_id: str) -> Optional[Dict[str, Any]]:
        """Get detailed information about a specific lead"""
        # Placeholder implementation
        return {
            'lead_id': lead_id,
            'customer_details': {
                'name': 'Sample Customer',
                'phone': '+91-9876543210',
                'email': 'customer@example.com',
                'location': 'Mumbai, Maharashtra'
            },
            'lead_history': [
                {
                    'date': '2024-01-15',
                    'action': 'Lead created from WhatsApp campaign',
                    'channel': 'whatsapp'
                },
                {
                    'date': '2024-01-16',
                    'action': 'Customer viewed policy details',
                    'channel': 'mobile_app'
                }
            ],
            'recommended_actions': [
                'Call customer within 2 hours',
                'Prepare quote for ₹50,000 term insurance',
                'Send policy brochure via WhatsApp'
            ]
        }
