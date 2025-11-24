"""
Callback Service - Callback request management
"""
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc
from uuid import UUID

from app.models.callback import CallbackRequest, CallbackActivity
from app.models.policy import Policyholder
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class CallbackPriorityManager:
    """Manages callback request prioritization"""

    @staticmethod
    def calculate_priority_score(
        request_type: str,
        urgency_level: str = 'medium',
        customer_value: str = 'bronze',
        age_hours: int = 0
    ) -> float:
        """Calculate priority score for callback requests (0-100)"""
        base_score = 0.0

        # Request type weights
        request_weights = {
            'policy_issue': 90,
            'payment_problem': 85,
            'claim_assistance': 80,
            'general_inquiry': 60,
            'feedback': 40,
            'suggestion': 30,
        }
        base_score += request_weights.get(request_type, 50)

        # Urgency level modifiers
        urgency_modifiers = {
            'critical': 20,
            'high': 15,
            'medium': 10,
            'low': 0,
        }
        base_score += urgency_modifiers.get(urgency_level, 0)

        # Customer value modifiers
        value_modifiers = {
            'platinum': 15,
            'gold': 10,
            'silver': 5,
            'bronze': 0,
        }
        base_score += value_modifiers.get(customer_value, 0)

        # Age-based urgency
        base_score += min(age_hours / 4, 10)

        return min(100.0, max(1.0, base_score))

    @staticmethod
    def assign_priority_category(score: float) -> str:
        """Convert priority score to category"""
        if score >= 85:
            return 'high'
        elif score >= 70:
            return 'medium'
        else:
            return 'low'

    @staticmethod
    def get_sla_timeframes(priority: str) -> Dict[str, int]:
        """Get SLA timeframes in minutes for different priorities"""
        sla_times = {
            'high': {
                'first_response': 15,  # minutes
                'resolution': 120,     # minutes
            },
            'medium': {
                'first_response': 60,  # minutes
                'resolution': 480,     # minutes
            },
            'low': {
                'first_response': 240, # minutes
                'resolution': 1440,    # minutes (24 hours)
            },
        }
        return sla_times.get(priority, sla_times['low'])


class CallbackService:
    """Service for callback request management"""

    @staticmethod
    def create_callback_request(
        db: Session,
        policyholder_id: UUID,
        request_data: Dict[str, Any],
        created_by: UUID
    ) -> CallbackRequest:
        """Create a new callback request"""
        try:
            # Get policyholder info
            policyholder = db.query(Policyholder).filter(
                Policyholder.policyholder_id == policyholder_id
            ).first()

            if not policyholder:
                raise ValueError(f"Policyholder not found: {policyholder_id}")

            # Calculate priority score
            priority_score = CallbackPriorityManager.calculate_priority_score(
                request_type=request_data.get('request_type', 'general_inquiry'),
                urgency_level=request_data.get('urgency_level', 'medium'),
                customer_value=request_data.get('customer_value', 'bronze'),
            )

            # Assign priority category
            priority = CallbackPriorityManager.assign_priority_category(priority_score)

            # Calculate due date based on SLA
            sla_hours = CallbackPriorityManager.get_sla_timeframes(priority)['resolution'] / 60
            due_at = datetime.utcnow() + timedelta(hours=int(sla_hours))

            callback = CallbackRequest(
                policyholder_id=policyholder_id,
                agent_id=policyholder.agent_id,
                request_type=request_data.get('request_type'),
                description=request_data.get('description'),
                priority=priority,
                priority_score=priority_score,
                customer_name=f"{policyholder.first_name or ''} {policyholder.last_name or ''}".strip(),
                customer_phone=policyholder.phone_number or '',
                customer_email=policyholder.email or '',
                sla_hours=int(sla_hours),
                due_at=due_at,
                source=request_data.get('source', 'mobile'),
                tags=request_data.get('tags', []),
                category=request_data.get('category'),
                urgency_level=request_data.get('urgency_level', 'medium'),
                customer_value=request_data.get('customer_value', 'bronze'),
                created_by=created_by,
            )

            db.add(callback)
            db.commit()
            db.refresh(callback)

            # Create activity log
            activity = CallbackActivity(
                callback_request_id=callback.callback_request_id,
                activity_type='created',
                description=f'Callback request created: {request_data.get("request_type")}',
            )
            db.add(activity)
            db.commit()

            logger.info(f"Callback request created: {callback.callback_request_id}")
            return callback

        except Exception as e:
            db.rollback()
            logger.error(f"Error creating callback request: {e}")
            raise

    @staticmethod
    def get_callback_requests(
        db: Session,
        agent_id: Optional[UUID] = None,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> List[CallbackRequest]:
        """Get callback requests with filters"""
        query = db.query(CallbackRequest)

        if agent_id:
            query = query.filter(CallbackRequest.agent_id == agent_id)
        if status:
            query = query.filter(CallbackRequest.status == status)
        if priority:
            query = query.filter(CallbackRequest.priority == priority)

        return query.order_by(
            desc(CallbackRequest.priority_score),
            CallbackRequest.created_at
        ).limit(limit).offset(offset).all()

    @staticmethod
    def update_callback_status(
        db: Session,
        callback_id: UUID,
        status: str,
        agent_id: Optional[UUID] = None,
        updated_by: UUID = None
    ) -> Optional[CallbackRequest]:
        """Update callback request status"""
        query = db.query(CallbackRequest).filter(CallbackRequest.callback_request_id == callback_id)
        
        if agent_id:
            query = query.filter(CallbackRequest.agent_id == agent_id)
        
        callback = query.first()
        
        if not callback:
            return None

        try:
            old_status = callback.status
            callback.status = status
            callback.last_updated_by = updated_by
            callback.last_updated_at = datetime.utcnow()

            # Update timestamps based on status
            if status == 'assigned' and old_status != 'assigned':
                callback.assigned_at = datetime.utcnow()
            elif status == 'in_progress' and old_status != 'in_progress':
                callback.started_at = datetime.utcnow()
            elif status == 'completed' and old_status != 'completed':
                callback.completed_at = datetime.utcnow()

            # Create activity log
            activity = CallbackActivity(
                callback_request_id=callback.callback_request_id,
                agent_id=agent_id,
                activity_type='status_changed',
                description=f'Status changed from {old_status} to {status}',
            )
            db.add(activity)
            
            db.commit()
            db.refresh(callback)

            logger.info(f"Callback status updated: {callback_id} -> {status}")
            return callback

        except Exception as e:
            db.rollback()
            logger.error(f"Error updating callback status: {e}")
            raise

    @staticmethod
    def assign_callback(
        db: Session,
        callback_id: UUID,
        agent_id: UUID,
        assigned_by: UUID
    ) -> Optional[CallbackRequest]:
        """Assign callback request to an agent"""
        callback = db.query(CallbackRequest).filter(
            CallbackRequest.callback_request_id == callback_id
        ).first()

        if not callback:
            return None

        try:
            callback.agent_id = agent_id
            callback.assigned_by = assigned_by
            callback.status = 'assigned'
            callback.assigned_at = datetime.utcnow()
            callback.last_updated_by = assigned_by
            callback.last_updated_at = datetime.utcnow()

            # Create activity log
            activity = CallbackActivity(
                callback_request_id=callback.callback_request_id,
                agent_id=agent_id,
                activity_type='assigned',
                description=f'Callback assigned to agent',
            )
            db.add(activity)
            
            db.commit()
            db.refresh(callback)

            logger.info(f"Callback assigned: {callback_id} -> agent {agent_id}")
            return callback

        except Exception as e:
            db.rollback()
            logger.error(f"Error assigning callback: {e}")
            raise

    @staticmethod
    def complete_callback(
        db: Session,
        callback_id: UUID,
        resolution: str,
        resolution_category: str,
        satisfaction_rating: Optional[int] = None,
        completed_by: UUID = None
    ) -> Optional[CallbackRequest]:
        """Complete a callback request"""
        callback = db.query(CallbackRequest).filter(
            CallbackRequest.callback_request_id == callback_id
        ).first()

        if not callback:
            return None

        try:
            callback.status = 'completed'
            callback.resolution = resolution
            callback.resolution_category = resolution_category
            callback.satisfaction_rating = satisfaction_rating
            callback.completed_by = completed_by
            callback.completed_at = datetime.utcnow()
            callback.last_updated_by = completed_by
            callback.last_updated_at = datetime.utcnow()

            # Create activity log
            activity = CallbackActivity(
                callback_request_id=callback.callback_request_id,
                agent_id=callback.agent_id,
                activity_type='completed',
                description=f'Callback completed: {resolution_category}',
                notes=resolution,
            )
            db.add(activity)
            
            db.commit()
            db.refresh(callback)

            logger.info(f"Callback completed: {callback_id}")
            return callback

        except Exception as e:
            db.rollback()
            logger.error(f"Error completing callback: {e}")
            raise

