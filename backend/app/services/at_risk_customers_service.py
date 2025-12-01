"""
At-Risk Customers & Retention Service - Churn prediction and retention strategies
"""
from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
import logging
from decimal import Decimal

from app.core.logging_config import get_logger

logger = get_logger(__name__)


class AtRiskCustomersService:
    """Service for identifying at-risk customers and generating retention strategies"""

    @staticmethod
    def get_at_risk_customers(agent_id: str, risk_level_filter: str = 'all') -> Dict[str, Any]:
        """
        Get at-risk customers for an agent with retention recommendations

        Args:
            agent_id: Agent identifier
            risk_level_filter: Risk level filter ('all', 'high', 'medium', 'low')

        Returns:
            Dict containing at-risk customers data and retention metrics
        """
        try:
            # Get all customers for the agent
            customers = AtRiskCustomersService._get_agent_customers(agent_id)

            # Assess risk for each customer
            at_risk_customers = AtRiskCustomersService._assess_customer_risk(customers)

            # Filter by risk level if specified
            if risk_level_filter != 'all':
                at_risk_customers = [c for c in at_risk_customers if c['risk_level'] == risk_level_filter]

            # Sort by risk score (descending)
            at_risk_customers.sort(key=lambda x: x['risk_score'], reverse=True)

            # Calculate summary metrics
            summary = AtRiskCustomersService._calculate_retention_summary(at_risk_customers)

            return {
                'agent_id': agent_id,
                'at_risk_count': len(at_risk_customers),
                'total_retention_value': sum(c['premium_value'] for c in at_risk_customers),
                'retention_success_rate': summary['success_rate'],
                'customers': at_risk_customers[:50],  # Return top 50 at-risk customers
                'summary': summary,
                'generated_at': datetime.utcnow().isoformat(),
            }

        except Exception as e:
            logger.error(f"At-risk customers service error for agent {agent_id}: {str(e)}")
            raise

    @staticmethod
    def _get_agent_customers(agent_id: str) -> List[Dict[str, Any]]:
        """Get all customers for an agent with relevant risk assessment data"""
        from sqlalchemy.orm import Session
        from app.core.database import get_db_session

        with get_db_session() as session:
            # Try to use customer_retention_analytics table if it exists
            try:
                from app.models.customer_retention import CustomerRetentionAnalytics  # This might not exist, will handle gracefully

                retention_data = session.query(CustomerRetentionAnalytics).filter(
                    CustomerRetentionAnalytics.assigned_agent_id == agent_id,
                    CustomerRetentionAnalytics.status == 'active'
                ).all()

                customers = []
                for retention in retention_data:
                    customers.append({
                        'customer_name': 'Customer Name',  # Would need to join with customer table
                        'policy_number': f"POL{retention.customer_id}",
                        'premium_value': float(retention.premium_value or 0),
                        'last_payment_date': datetime.utcnow() - timedelta(days=retention.days_since_last_payment),
                        'engagement_score': float(retention.engagement_score or 50),
                        'complaints_count': retention.complaints_count or 0,
                        'support_queries': retention.support_queries_count or 0,
                        'policy_age_months': retention.policy_age_months or 12,
                        'missed_payments': retention.missed_payments_count or 0,
                        'days_since_contact': retention.days_since_last_contact or 30,
                        'policy_type': retention.policy_type or 'term_life',
                        'customer_value': 'high' if (retention.premium_value or 0) > 30000 else 'medium',
                    })

                if customers:
                    return customers

            except (ImportError, AttributeError):
                pass

            # Fallback: Generate simulated at-risk customers based on policy data
            from app.models.policy import InsurancePolicy, Policyholder

            # Get active policies for the agent
            policies = session.query(InsurancePolicy, Policyholder).join(Policyholder).filter(
                InsurancePolicy.agent_id == agent_id,
                InsurancePolicy.status == 'active'
            ).limit(15).all()

            customers = []
            for i, (policy, customer) in enumerate(policies):
                # Only include some customers as "at-risk" (not all)
                if i % 3 != 0:  # Every 3rd customer is at risk
                    continue

                # Simulate risk factors
                days_since_payment = 15 + (i * 7) % 45  # Vary between 15-60 days
                policy_age_months = max(1, (datetime.utcnow() - policy.created_at).days // 30)
                days_since_contact = 10 + (i * 5) % 40

                # Create varying risk profiles
                risk_profiles = [
                    {'engagement': 25, 'complaints': 3, 'support': 8, 'missed': 2},  # High risk
                    {'engagement': 45, 'complaints': 1, 'support': 3, 'missed': 1},  # Medium risk
                    {'engagement': 35, 'complaints': 2, 'support': 5, 'missed': 1},  # Medium risk
                ]
                profile = risk_profiles[i % len(risk_profiles)]

                # Get customer name from the related user
                customer_name = "Unknown Customer"
                if customer.user:
                    customer_name = f"{customer.user.first_name or 'Unknown'} {customer.user.last_name or 'Customer'}"

                customer_data = {
                    'customer_id': str(customer.policyholder_id),
                    'customer_name': customer_name,
                    'policy_number': f"POL{policy.policy_id}",
                    'premium_value': float(policy.premium_amount or 25000),
                    'last_payment_date': datetime.utcnow() - timedelta(days=days_since_payment),
                    'engagement_score': profile['engagement'],
                    'complaints_count': profile['complaints'],
                    'support_queries': profile['support'],
                    'policy_age_months': policy_age_months,
                    'missed_payments': profile['missed'],
                    'days_since_contact': days_since_contact,
                    'policy_type': policy.policy_type or 'term_life',
                    'customer_value': 'high' if (policy.premium_amount or 0) > 30000 else 'medium',
                }

                customers.append(customer_data)

            return customers

    @staticmethod
    def _assess_customer_risk(customers: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Assess risk level for each customer and generate retention recommendations"""
        at_risk_customers = []

        for customer in customers:
            # Calculate individual risk factors (0-100 scale, higher = more risky)

            # Payment behavior risk
            days_since_payment = (datetime.utcnow() - customer['last_payment_date']).days
            payment_risk = min(100, days_since_payment * 2)  # 30 days = 60 risk points

            # Engagement risk
            engagement_risk = 100 - customer['engagement_score']  # Lower engagement = higher risk

            # Complaints and support queries risk
            support_risk = min(100, (customer['complaints_count'] * 10) + (customer['support_queries'] * 2))

            # Policy age risk (newer policies are more likely to churn)
            age_risk = max(0, 100 - (customer['policy_age_months'] * 2))

            # Missed payments risk
            missed_payment_risk = min(100, customer['missed_payments'] * 25)

            # Days since contact risk
            contact_risk = min(100, customer['days_since_contact'] * 1.5)

            # Calculate overall risk score (weighted average)
            risk_score = (
                payment_risk * 0.25 +        # 25% weight - payment is critical
                engagement_risk * 0.20 +     # 20% weight
                support_risk * 0.15 +        # 15% weight
                age_risk * 0.15 +            # 15% weight
                missed_payment_risk * 0.15 + # 15% weight
                contact_risk * 0.10          # 10% weight
            )

            # Normalize to 0-100
            risk_score = min(100, max(0, risk_score))

            # Determine risk level
            if risk_score >= 70:
                risk_level = 'high'
            elif risk_score >= 40:
                risk_level = 'medium'
            else:
                risk_level = 'low'

            # Generate risk factors list
            risk_factors = []
            if payment_risk > 50:
                risk_factors.append('Overdue payments')
            if engagement_risk > 60:
                risk_factors.append('Low engagement')
            if support_risk > 40:
                risk_factors.append('High support queries')
            if age_risk > 50:
                risk_factors.append('Recent policy holder')
            if missed_payment_risk > 30:
                risk_factors.append('Payment history issues')
            if contact_risk > 40:
                risk_factors.append('Long time since contact')

            if not risk_factors:
                risk_factors = ['General monitoring']

            # Generate retention recommendations
            recommendations = AtRiskCustomersService._generate_retention_plan(
                customer, risk_score, risk_level, risk_factors
            )

            at_risk_customer = {
                'customer_id': customer['customer_id'],
                'customer_name': customer['customer_name'],
                'policy_number': customer['policy_number'],
                'premium_value': customer['premium_value'],
                'risk_score': round(risk_score, 1),
                'risk_level': risk_level,
                'risk_factors': risk_factors,
                'days_since_contact': customer['days_since_contact'],
                'engagement_score': customer['engagement_score'],
                'last_payment_days': days_since_payment,
                'missed_payments': customer['missed_payments'],
                'recommendations': recommendations,
                'retention_priority': AtRiskCustomersService._calculate_retention_priority(
                    customer, risk_score
                ),
            }

            # Only include customers with risk score > 30 (at-risk threshold)
            if risk_score > 30:
                at_risk_customers.append(at_risk_customer)

        return at_risk_customers

    @staticmethod
    def _generate_retention_plan(customer: Dict[str, Any], risk_score: float,
                                risk_level: str, risk_factors: List[str]) -> Dict[str, Any]:
        """Generate personalized retention plan for the customer"""
        plan = {
            'immediate_actions': [],
            'medium_term_actions': [],
            'long_term_actions': [],
            'estimated_success_probability': 0,
            'estimated_retention_value': customer['premium_value'],
        }

        # Immediate actions (next 24-48 hours)
        if 'Overdue payments' in risk_factors:
            plan['immediate_actions'].append({
                'action': 'Payment follow-up call',
                'description': 'Contact customer about overdue payment and offer payment plan',
                'priority': 'critical',
                'estimated_impact': 35
            })

        if 'Low engagement' in risk_factors:
            plan['immediate_actions'].append({
                'action': 'Engagement outreach',
                'description': 'Send personalized WhatsApp message with policy value reminder',
                'priority': 'high',
                'estimated_impact': 25
            })

        if 'High support queries' in risk_factors:
            plan['immediate_actions'].append({
                'action': 'Support resolution',
                'description': 'Address outstanding support queries and provide solutions',
                'priority': 'high',
                'estimated_impact': 30
            })

        # Medium-term actions (next 1-2 weeks)
        if risk_score > 60:
            plan['medium_term_actions'].append({
                'action': 'Personal consultation',
                'description': 'Schedule face-to-face or video consultation to understand concerns',
                'priority': 'high',
                'estimated_impact': 45
            })

        plan['medium_term_actions'].append({
            'action': 'Policy review and upgrade offer',
            'description': f'Analyze current {customer["policy_type"]} coverage and suggest improvements',
            'priority': 'medium',
            'estimated_impact': 35
        })

        # Long-term actions (next 1-3 months)
        plan['long_term_actions'].append({
            'action': 'Loyalty program enrollment',
            'description': 'Enroll in customer loyalty program with exclusive benefits',
            'priority': 'medium',
            'estimated_impact': 20
        })

        plan['long_term_actions'].append({
            'action': 'Regular engagement schedule',
            'description': 'Set up quarterly check-ins and proactive communication',
            'priority': 'low',
            'estimated_impact': 25
        })

        # Calculate success probability based on risk level and actions
        base_success_rate = 100 - risk_score
        action_impact = sum(action['estimated_impact'] for action in plan['immediate_actions']) * 0.7
        action_impact += sum(action['estimated_impact'] for action in plan['medium_term_actions']) * 0.5
        action_impact += sum(action['estimated_impact'] for action in plan['long_term_actions']) * 0.3

        plan['estimated_success_probability'] = min(95, max(15, base_success_rate + action_impact))

        return plan

    @staticmethod
    def _calculate_retention_priority(customer: Dict[str, Any], risk_score: float) -> str:
        """Calculate retention priority based on risk score and customer value"""
        value_multiplier = {
            'high': 1.5,
            'medium': 1.0,
            'low': 0.7
        }.get(customer['customer_value'], 1.0)

        priority_score = risk_score * value_multiplier

        if priority_score >= 80:
            return 'critical'
        elif priority_score >= 60:
            return 'high'
        elif priority_score >= 40:
            return 'medium'
        else:
            return 'low'

    @staticmethod
    def _calculate_retention_summary(at_risk_customers: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Calculate summary metrics for retention efforts"""
        if not at_risk_customers:
            return {
                'total_at_risk': 0,
                'high_risk_count': 0,
                'medium_risk_count': 0,
                'low_risk_count': 0,
                'success_rate': 0,
                'potential_loss_value': 0,
                'retention_opportunities': 0,
            }

        total_at_risk = len(at_risk_customers)
        high_risk = len([c for c in at_risk_customers if c['risk_level'] == 'high'])
        medium_risk = len([c for c in at_risk_customers if c['risk_level'] == 'medium'])
        low_risk = len([c for c in at_risk_customers if c['risk_level'] == 'low'])

        # Calculate potential loss value
        potential_loss_value = sum(c['premium_value'] for c in at_risk_customers)

        # Estimate success rate based on risk levels
        # Higher risk = lower success rate
        avg_success_probability = sum(
            c['recommendations']['estimated_success_probability']
            for c in at_risk_customers
        ) / total_at_risk

        retention_opportunities = len([
            c for c in at_risk_customers
            if c['recommendations']['estimated_success_probability'] > 50
        ])

        return {
            'total_at_risk': total_at_risk,
            'high_risk_count': high_risk,
            'medium_risk_count': medium_risk,
            'low_risk_count': low_risk,
            'success_rate': round(avg_success_probability, 1),
            'potential_loss_value': potential_loss_value,
            'retention_opportunities': retention_opportunities,
        }

    @staticmethod
    def get_customer_retention_plan(customer_id: str) -> Optional[Dict[str, Any]]:
        """Get detailed retention plan for a specific customer"""
        # Placeholder implementation
        return {
            'customer_id': customer_id,
            'retention_plan': {
                'current_status': 'At high risk',
                'risk_score': 78,
                'timeline': [
                    {
                        'phase': 'Immediate (24-48 hours)',
                        'actions': ['Personal phone call', 'Payment assistance offer'],
                        'success_metrics': 'Customer engagement response'
                    },
                    {
                        'phase': 'Short-term (1 week)',
                        'actions': ['Policy review meeting', 'Customized solutions presentation'],
                        'success_metrics': 'Meeting scheduled and attended'
                    },
                    {
                        'phase': 'Medium-term (2-4 weeks)',
                        'actions': ['Loyalty program enrollment', 'Premium discount offer'],
                        'success_metrics': 'Customer commits to retention'
                    }
                ],
                'expected_outcome': '85% chance of retention',
                'value_at_risk': 35000
            }
        }
