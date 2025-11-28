"""
Callback Management Service
===========================

Comprehensive callback management with priority scoring, SLA tracking, and intelligent routing.
"""

import logging
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, desc

from app.core.monitoring import monitoring
from app.core.logging_config import get_logger
from app.models.callback import (
    Callback, CallbackHistory, CallbackSLA, CallbackAnalytics,
    PriorityLevel, CallbackStatus, CallbackSource
)

logger = logging.getLogger(__name__)


class CallbackService:
    """Comprehensive callback management service"""

    def __init__(self, db: Session):
        self.db = db

    async def create_callback(
        self,
        customer_name: str,
        customer_phone: str,
        subject: str,
        description: Optional[str] = None,
        category: Optional[str] = None,
        source: CallbackSource = CallbackSource.CUSTOMER_PORTAL,
        source_reference: Optional[str] = None,
        customer_email: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
        created_by: Optional[str] = None
    ) -> Callback:
        """Create a new callback request with priority scoring"""

        # Calculate priority score
        priority_score = self._calculate_priority_score(
            category=category,
            source=source,
            customer_phone=customer_phone,
            metadata=metadata
        )

        # Determine priority level
        priority = self._determine_priority_level(priority_score)

        # Create callback
        callback = Callback(
            callback_id=self._generate_callback_id(),
            customer_name=customer_name,
            customer_phone=customer_phone,
            customer_email=customer_email,
            subject=subject,
            description=description,
            category=category,
            priority=priority,
            priority_score=priority_score,
            urgency_factors=self._get_urgency_factors(metadata),
            source=source,
            source_reference=source_reference,
            metadata=metadata or {},
            status=CallbackStatus.PENDING
        )

        # Set SLA targets
        sla_config = self._get_sla_config(category, priority, source)
        if sla_config:
            callback.sla_target_minutes = sla_config.resolution_time_minutes
            callback.sla_started_at = datetime.utcnow()

        self.db.add(callback)
        self.db.commit()
        self.db.refresh(callback)

        # Log creation
        await self._log_callback_action(
            callback.id,
            "created",
            created_by or "system",
            f"Callback created with priority {priority.value}"
        )

        # Trigger auto-assignment if configured
        await self._auto_assign_callback(callback)

        # Record metrics
        monitoring.record_business_metrics("callback_created", {
            "priority": priority.value,
            "source": source.value,
            "category": category
        })

        logger.info(f"Callback created: {callback.callback_id}, priority: {priority.value}")
        return callback

    async def assign_callback(
        self,
        callback_id: str,
        agent_id: str,
        assigned_by: str,
        notes: Optional[str] = None
    ) -> Callback:
        """Assign callback to an agent"""

        callback = self.db.query(Callback).filter(Callback.callback_id == callback_id).first()
        if not callback:
            raise ValueError(f"Callback not found: {callback_id}")

        if callback.status != CallbackStatus.PENDING:
            raise ValueError(f"Callback is not in assignable state: {callback.status.value}")

        # Update assignment
        previous_assigned_to = callback.assigned_to
        callback.assigned_to = agent_id
        callback.assigned_by = assigned_by
        callback.assigned_at = datetime.utcnow()
        callback.status = CallbackStatus.ASSIGNED

        self.db.commit()

        # Log assignment
        await self._log_callback_action(
            callback.id,
            "assigned",
            assigned_by,
            f"Assigned to agent {agent_id}",
            notes=notes,
            previous_assigned_to=previous_assigned_to,
            new_assigned_to=agent_id
        )

        # Check SLA status
        await self._check_sla_status(callback)

        logger.info(f"Callback assigned: {callback_id} to agent {agent_id}")
        return callback

    async def update_callback_status(
        self,
        callback_id: str,
        new_status: CallbackStatus,
        updated_by: str,
        resolution_notes: Optional[str] = None,
        resolution_category: Optional[str] = None
    ) -> Callback:
        """Update callback status"""

        callback = self.db.query(Callback).filter(Callback.callback_id == callback_id).first()
        if not callback:
            raise ValueError(f"Callback not found: {callback_id}")

        # Validate status transition
        if not self._is_valid_status_transition(callback.status, new_status):
            raise ValueError(f"Invalid status transition: {callback.status.value} -> {new_status.value}")

        previous_status = callback.status
        callback.status = new_status

        # Handle status-specific updates
        if new_status == CallbackStatus.IN_PROGRESS:
            # No specific action needed
            pass
        elif new_status in [CallbackStatus.RESOLVED, CallbackStatus.CLOSED]:
            callback.resolved_at = datetime.utcnow()
            callback.resolved_by = updated_by
            callback.resolution_notes = resolution_notes
            callback.resolution_category = resolution_category

            # Check SLA compliance
            await self._check_sla_compliance(callback)

        self.db.commit()

        # Log status change
        await self._log_callback_action(
            callback.id,
            "status_changed",
            updated_by,
            f"Status changed from {previous_status.value} to {new_status.value}",
            resolution_notes,
            previous_status=previous_status,
            new_status=new_status
        )

        # Record metrics
        if new_status in [CallbackStatus.RESOLVED, CallbackStatus.CLOSED]:
            monitoring.record_business_metrics("callback_resolved", {
                "priority": callback.priority.value,
                "resolution_time_minutes": self._calculate_resolution_time(callback)
            })

        logger.info(f"Callback status updated: {callback_id} -> {new_status.value}")
        return callback

    async def escalate_callback(
        self,
        callback_id: str,
        escalated_by: str,
        escalation_reason: str,
        escalate_to: Optional[str] = None
    ) -> Callback:
        """Escalate callback to higher priority or different agent"""

        callback = self.db.query(Callback).filter(Callback.callback_id == callback_id).first()
        if not callback:
            raise ValueError(f"Callback not found: {callback_id}")

        callback.escalated = True
        callback.escalated_at = datetime.utcnow()
        callback.escalation_reason = escalation_reason

        if escalate_to:
            callback.escalated_to = escalate_to

        # Increase priority if not already urgent
        if callback.priority != PriorityLevel.URGENT:
            callback.priority = PriorityLevel.URGENT
            callback.priority_score = 100.0

        self.db.commit()

        # Log escalation
        await self._log_callback_action(
            callback.id,
            "escalated",
            escalated_by,
            f"Escalated: {escalation_reason}",
            escalation_reason
        )

        monitoring.record_business_metrics("callback_escalated", {
            "reason": escalation_reason,
            "original_priority": callback.priority.value
        })

        logger.info(f"Callback escalated: {callback_id}")
        return callback

    async def get_callback(self, callback_id: str) -> Optional[Callback]:
        """Get callback by ID"""
        return self.db.query(Callback).filter(Callback.callback_id == callback_id).first()

    async def list_callbacks(
        self,
        status: Optional[CallbackStatus] = None,
        priority: Optional[PriorityLevel] = None,
        assigned_to: Optional[str] = None,
        category: Optional[str] = None,
        limit: int = 50,
        offset: int = 0
    ) -> List[Callback]:
        """List callbacks with filtering"""

        query = self.db.query(Callback)

        if status:
            query = query.filter(Callback.status == status)
        if priority:
            query = query.filter(Callback.priority == priority)
        if assigned_to:
            query = query.filter(Callback.assigned_to == assigned_to)
        if category:
            query = query.filter(Callback.category == category)

        return query.order_by(desc(Callback.created_at)).offset(offset).limit(limit).all()

    async def get_callback_analytics(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        period: str = "daily"
    ) -> Dict[str, Any]:
        """Get callback analytics"""

        if not start_date:
            start_date = datetime.utcnow() - timedelta(days=30)
        if not end_date:
            end_date = datetime.utcnow()

        # Get basic metrics
        total_callbacks = self.db.query(func.count(Callback.id)).filter(
            and_(Callback.created_at >= start_date, Callback.created_at <= end_date)
        ).scalar()

        resolved_callbacks = self.db.query(func.count(Callback.id)).filter(
            and_(
                Callback.created_at >= start_date,
                Callback.created_at <= end_date,
                Callback.status.in_([CallbackStatus.RESOLVED, CallbackStatus.CLOSED])
            )
        ).scalar()

        # Average resolution time
        avg_resolution_time = self.db.query(
            func.avg(
                func.extract('epoch', Callback.resolved_at - Callback.created_at) / 60
            )
        ).filter(
            and_(
                Callback.created_at >= start_date,
                Callback.created_at <= end_date,
                Callback.resolved_at.isnot(None)
            )
        ).scalar()

        # SLA compliance
        sla_compliant = self.db.query(func.count(Callback.id)).filter(
            and_(
                Callback.created_at >= start_date,
                Callback.created_at <= end_date,
                Callback.sla_met == True
            )
        ).scalar()

        sla_compliance_rate = (sla_compliant / total_callbacks * 100) if total_callbacks > 0 else 0

        return {
            "period": {"start": start_date.isoformat(), "end": end_date.isoformat()},
            "metrics": {
                "total_callbacks": total_callbacks,
                "resolved_callbacks": resolved_callbacks,
                "resolution_rate": (resolved_callbacks / total_callbacks * 100) if total_callbacks > 0 else 0,
                "avg_resolution_time_minutes": float(avg_resolution_time) if avg_resolution_time else None,
                "sla_compliance_rate": sla_compliance_rate
            }
        }

    def _calculate_priority_score(
        self,
        category: Optional[str],
        source: CallbackSource,
        customer_phone: str,
        metadata: Optional[Dict[str, Any]]
    ) -> float:
        """Calculate priority score based on various factors"""

        score = 50.0  # Base score

        # Category-based scoring
        category_scores = {
            "complaint": 30,
            "claim": 25,
            "policy_issue": 20,
            "inquiry": -10,
            "feedback": -15
        }
        if category and category in category_scores:
            score += category_scores[category]

        # Source-based scoring
        source_scores = {
            CallbackSource.PHONE: 20,
            CallbackSource.WHATSAPP: 15,
            CallbackSource.EMAIL: 5,
            CallbackSource.CHATBOT: 10,
            CallbackSource.CUSTOMER_PORTAL: 0,
            CallbackSource.AGENT_PORTAL: -5
        }
        score += source_scores.get(source, 0)

        # Urgency factors from metadata
        if metadata:
            if metadata.get("urgent", False):
                score += 25
            if metadata.get("vip_customer", False):
                score += 15
            if metadata.get("repeat_customer", False):
                score += 5

        # Clamp score between 0 and 100
        return max(0, min(100, score))

    def _determine_priority_level(self, score: float) -> PriorityLevel:
        """Determine priority level from score"""
        if score >= 80:
            return PriorityLevel.URGENT
        elif score >= 60:
            return PriorityLevel.HIGH
        elif score >= 30:
            return PriorityLevel.MEDIUM
        else:
            return PriorityLevel.LOW

    def _get_urgency_factors(self, metadata: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Extract urgency factors from metadata"""
        if not metadata:
            return None

        factors = {}
        if metadata.get("urgent"):
            factors["urgent"] = True
        if metadata.get("vip_customer"):
            factors["vip_customer"] = True
        if metadata.get("high_value_policy"):
            factors["high_value_policy"] = True

        return factors if factors else None

    def _generate_callback_id(self) -> str:
        """Generate unique callback ID"""
        import uuid
        return f"CB-{datetime.utcnow().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"

    def _get_sla_config(
        self,
        category: Optional[str],
        priority: PriorityLevel,
        source: CallbackSource
    ) -> Optional[CallbackSLA]:
        """Get SLA configuration for callback type"""
        return self.db.query(CallbackSLA).filter(
            and_(
                or_(CallbackSLA.category == category, CallbackSLA.category.is_(None)),
                CallbackSLA.priority == priority,
                or_(CallbackSLA.source == source, CallbackSLA.source.is_(None)),
                CallbackSLA.is_active == True
            )
        ).order_by(desc(CallbackSLA.created_at)).first()

    async def _auto_assign_callback(self, callback: Callback):
        """Auto-assign callback based on rules"""
        # Implementation for auto-assignment logic
        # This would find the best available agent based on workload, expertise, etc.
        pass

    async def _check_sla_status(self, callback: Callback):
        """Check and update SLA status"""
        if not callback.sla_target_minutes or not callback.sla_started_at:
            return

        elapsed_minutes = (datetime.utcnow() - callback.sla_started_at).total_seconds() / 60

        if elapsed_minutes > callback.sla_target_minutes and not callback.sla_breached_at:
            callback.sla_breached_at = datetime.utcnow()
            callback.sla_met = False
            self.db.commit()

            # Trigger escalation
            await self.escalate_callback(
                callback.callback_id,
                "system",
                f"SLA breached after {elapsed_minutes:.1f} minutes"
            )

    async def _check_sla_compliance(self, callback: Callback):
        """Check SLA compliance on resolution"""
        if not callback.sla_started_at or not callback.resolved_at:
            return

        resolution_time_minutes = (callback.resolved_at - callback.sla_started_at).total_seconds() / 60

        if callback.sla_target_minutes and resolution_time_minutes <= callback.sla_target_minutes:
            callback.sla_met = True
        else:
            callback.sla_met = False

        self.db.commit()

    def _calculate_resolution_time(self, callback: Callback) -> Optional[float]:
        """Calculate resolution time in minutes"""
        if not callback.created_at or not callback.resolved_at:
            return None
        return (callback.resolved_at - callback.created_at).total_seconds() / 60

    def _is_valid_status_transition(self, current_status: CallbackStatus, new_status: CallbackStatus) -> bool:
        """Validate status transition"""
        valid_transitions = {
            CallbackStatus.PENDING: [CallbackStatus.ASSIGNED, CallbackStatus.ESCALATED],
            CallbackStatus.ASSIGNED: [CallbackStatus.IN_PROGRESS, CallbackStatus.ESCALATED],
            CallbackStatus.IN_PROGRESS: [CallbackStatus.RESOLVED, CallbackStatus.CLOSED, CallbackStatus.ESCALATED],
            CallbackStatus.RESOLVED: [CallbackStatus.CLOSED],
            CallbackStatus.CLOSED: [],
            CallbackStatus.ESCALATED: [CallbackStatus.ASSIGNED, CallbackStatus.IN_PROGRESS]
        }

        return new_status in valid_transitions.get(current_status, [])

    async def _log_callback_action(
        self,
        callback_id: str,
        action: str,
        action_by: str,
        notes: Optional[str] = None,
        **kwargs
    ):
        """Log callback action"""
        history = CallbackHistory(
            callback_id=callback_id,
            action=action,
            action_by=action_by,
            action_notes=notes,
            metadata=kwargs if kwargs else None
        )

        self.db.add(history)
        self.db.commit()