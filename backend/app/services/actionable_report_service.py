"""
Actionable Report Service
=========================

Service for creating and managing actionable reports for agent callbacks.
Provides structured reports with conversation context for human agents.
"""

import json
import uuid
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.core.monitoring import monitoring
from app.core.logging_config import get_logger
from app.models.callback import Callback, CallbackStatus, PriorityLevel
from app.models.user import User

logger = get_logger(__name__)


class ActionableReportService:
    """Service for managing actionable reports and agent callbacks"""

    def __init__(self, db: Session):
        self.db = db

    async def create_actionable_report(
        self,
        customer_id: str,
        agent_id: str,
        conversation_context: Dict[str, Any],
        current_query: str,
        intent_analysis: Dict[str, Any],
        complexity_score: float,
        source: str = "chatbot",
        priority: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Create an actionable report for agent callback

        Args:
            customer_id: ID of the customer requesting callback
            agent_id: ID of the assigned agent
            conversation_context: Full conversation history and context
            current_query: The current user query that triggered the callback
            intent_analysis: Intent analysis results
            complexity_score: Complexity score (0-1)
            source: Source of the callback request (chatbot, whatsapp, etc.)
            priority: Priority level (auto-determined if not provided)

        Returns:
            Dict with callback and report information
        """

        # Determine priority based on complexity and intent
        if not priority:
            priority = self._determine_priority(complexity_score, intent_analysis)

        # Extract key information for the report
        report_data = self._build_report_data(
            customer_id=customer_id,
            conversation_context=conversation_context,
            current_query=current_query,
            intent_analysis=intent_analysis,
            complexity_score=complexity_score
        )

        # Create callback record
        callback = Callback(
            callback_id=f"AR-{uuid.uuid4().hex[:12].upper()}",
            customer_id=customer_id,
            agent_id=agent_id,
            subject=self._generate_callback_subject(intent_analysis, current_query),
            description=self._generate_callback_description(report_data),
            category=self._determine_category(intent_analysis),
            source=source,
            priority=CallbackPriority(priority),
            status=CallbackStatus.PENDING,
            metadata={
                "actionable_report": report_data,
                "conversation_summary": self._summarize_conversation(conversation_context),
                "escalation_reason": self._determine_escalation_reason(complexity_score, intent_analysis),
                "suggested_response_time": self._get_suggested_response_time(priority)
            },
            sla_target_minutes=self._get_sla_target(priority)
        )

        # Save to database
        self.db.add(callback)
        self.db.commit()
        self.db.refresh(callback)

        # Record metrics
        monitoring.record_business_metrics(
            "actionable_report_created",
            {
                "priority": priority,
                "source": source,
                "complexity_score": complexity_score,
                "category": callback.category
            }
        )

        logger.info(f"Actionable report created: {callback.callback_id} for customer {customer_id}")

        return {
            "callback_id": callback.callback_id,
            "priority": priority,
            "sla_target_minutes": callback.sla_target_minutes,
            "estimated_response_time": self._get_estimated_response_time(priority),
            "report_summary": report_data.get("summary", {}),
            "next_steps": self._get_next_steps_for_user(priority, callback.sla_target_minutes)
        }

    async def get_callback_reports(
        self,
        agent_id: Optional[str] = None,
        status: Optional[str] = None,
        priority: Optional[str] = None,
        limit: int = 50
    ) -> List[Dict[str, Any]]:
        """Get callback reports with optional filtering"""

        query = self.db.query(Callback)

        if agent_id:
            query = query.filter(Callback.agent_id == agent_id)

        if status:
            query = query.filter(Callback.status == CallbackStatus(status))

        if priority:
            query = query.filter(Callback.priority == CallbackPriority(priority))

        # Order by priority (high first) and creation time
        query = query.order_by(
            Callback.priority.desc(),
            Callback.created_at.desc()
        ).limit(limit)

        callbacks = query.all()

        reports = []
        for callback in callbacks:
            report = {
                "callback_id": callback.callback_id,
                "customer_id": callback.customer_id,
                "agent_id": callback.agent_id,
                "subject": callback.subject,
                "description": callback.description,
                "category": callback.category,
                "priority": callback.priority.value,
                "status": callback.status.value,
                "source": callback.source,
                "created_at": callback.created_at.isoformat(),
                "sla_target_minutes": callback.sla_target_minutes,
                "metadata": callback.metadata,
                "actionable_report": callback.metadata.get("actionable_report", {})
            }
            reports.append(report)

        return reports

    async def update_callback_status(
        self,
        callback_id: str,
        status: str,
        agent_notes: Optional[str] = None,
        resolution_details: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Update callback status and add resolution details"""

        callback = self.db.query(Callback).filter(Callback.callback_id == callback_id).first()

        if not callback:
            raise ValueError(f"Callback not found: {callback_id}")

        old_status = callback.status
        callback.status = CallbackStatus(status)

        if status == "completed":
            callback.completed_at = datetime.utcnow()
            callback.resolution_time_minutes = int(
                (callback.completed_at - callback.created_at).total_seconds() / 60
            )

        # Update metadata with agent notes and resolution
        if callback.metadata is None:
            callback.metadata = {}

        if agent_notes:
            callback.metadata["agent_notes"] = agent_notes

        if resolution_details:
            callback.metadata["resolution_details"] = resolution_details
            callback.metadata["resolution_timestamp"] = datetime.utcnow().isoformat()

        self.db.commit()

        # Record metrics
        monitoring.record_business_metrics(
            "callback_status_updated",
            {
                "callback_id": callback_id,
                "old_status": old_status.value,
                "new_status": status,
                "resolution_time_minutes": callback.resolution_time_minutes
            }
        )

        return {
            "callback_id": callback_id,
            "status": status,
            "updated_at": datetime.utcnow().isoformat(),
            "resolution_time_minutes": callback.resolution_time_minutes
        }

    async def get_callback_analytics(
        self,
        agent_id: Optional[str] = None,
        date_from: Optional[datetime] = None,
        date_to: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """Get analytics for callbacks"""

        query = self.db.query(Callback)

        if agent_id:
            query = query.filter(Callback.agent_id == agent_id)

        if date_from:
            query = query.filter(Callback.created_at >= date_from)

        if date_to:
            query = query.filter(Callback.created_at <= date_to)

        callbacks = query.all()

        # Calculate analytics
        total_callbacks = len(callbacks)
        completed_callbacks = len([c for c in callbacks if c.status == CallbackStatus.COMPLETED])
        pending_callbacks = len([c for c in callbacks if c.status == CallbackStatus.PENDING])

        completion_rate = (completed_callbacks / total_callbacks * 100) if total_callbacks > 0 else 0

        # Average resolution time for completed callbacks
        completed_times = [c.resolution_time_minutes for c in callbacks if c.resolution_time_minutes]
        avg_resolution_time = sum(completed_times) / len(completed_times) if completed_times else 0

        # Priority distribution
        priority_counts = {}
        for callback in callbacks:
            priority = callback.priority.value
            priority_counts[priority] = priority_counts.get(priority, 0) + 1

        # Category distribution
        category_counts = {}
        for callback in callbacks:
            category = callback.category
            category_counts[category] = category_counts.get(category, 0) + 1

        return {
            "total_callbacks": total_callbacks,
            "completed_callbacks": completed_callbacks,
            "pending_callbacks": pending_callbacks,
            "completion_rate": round(completion_rate, 2),
            "avg_resolution_time_minutes": round(avg_resolution_time, 1),
            "priority_distribution": priority_counts,
            "category_distribution": category_counts,
            "sla_compliance": self._calculate_sla_compliance(callbacks)
        }

    def _determine_priority(self, complexity_score: float, intent_analysis: Dict[str, Any]) -> str:
        """Determine callback priority based on complexity and intent"""

        intent = intent_analysis.get("intent", "").lower()
        urgency = intent_analysis.get("urgency", "low").lower()

        # High priority triggers
        high_priority_triggers = [
            complexity_score > 0.9,
            intent in ["complaint", "urgent_claim", "escalation_request"],
            urgency == "high",
            "emergency" in intent_analysis.get("message", "").lower(),
            "urgent" in intent_analysis.get("message", "").lower()
        ]

        # Medium priority triggers
        medium_priority_triggers = [
            complexity_score > 0.7,
            intent in ["claim_status", "payment_issue"],
            urgency == "medium"
        ]

        if any(high_priority_triggers):
            return "high"
        elif any(medium_priority_triggers):
            return "medium"
        else:
            return "low"

    def _build_report_data(
        self,
        customer_id: str,
        conversation_context: Dict[str, Any],
        current_query: str,
        intent_analysis: Dict[str, Any],
        complexity_score: float
    ) -> Dict[str, Any]:
        """Build comprehensive report data"""

        return {
            "customer_id": customer_id,
            "current_query": current_query,
            "intent_analysis": intent_analysis,
            "complexity_score": complexity_score,
            "conversation_summary": self._summarize_conversation(conversation_context),
            "key_issues": self._extract_key_issues(conversation_context, intent_analysis),
            "suggested_actions": self._suggest_actions(intent_analysis, complexity_score),
            "priority_factors": self._identify_priority_factors(intent_analysis, complexity_score),
            "timeline": self._build_conversation_timeline(conversation_context),
            "generated_at": datetime.utcnow().isoformat()
        }

    def _generate_callback_subject(self, intent_analysis: Dict[str, Any], current_query: str) -> str:
        """Generate appropriate callback subject"""

        intent = intent_analysis.get("intent", "general_inquiry")

        subject_templates = {
            "complaint": "Customer Complaint - {query}",
            "claim_status": "Claim Status Inquiry - {query}",
            "premium_payment": "Premium Payment Assistance - {query}",
            "policy_inquiry": "Policy Information Request - {query}",
            "escalation_request": "Urgent Customer Escalation - {query}",
            "general_info": "General Insurance Information - {query}"
        }

        template = subject_templates.get(intent, "Customer Support Request - {query}")
        query_preview = current_query[:50] + "..." if len(current_query) > 50 else current_query

        return template.format(query=query_preview)

    def _generate_callback_description(self, report_data: Dict[str, Any]) -> str:
        """Generate detailed callback description"""

        summary = report_data.get("conversation_summary", {})
        key_issues = report_data.get("key_issues", [])
        suggested_actions = report_data.get("suggested_actions", [])

        description = f"""
Customer requires human assistance with: {report_data.get('current_query', 'N/A')}

CONVERSATION SUMMARY:
- Total messages: {summary.get('total_messages', 0)}
- Session duration: {summary.get('duration_minutes', 0)} minutes
- Primary intent: {report_data.get('intent_analysis', {}).get('intent', 'unknown')}
- Complexity score: {report_data.get('complexity_score', 0):.2f}

KEY ISSUES IDENTIFIED:
{chr(10).join(f"- {issue}" for issue in key_issues[:3])}

SUGGESTED ACTIONS:
{chr(10).join(f"- {action}" for action in suggested_actions[:3])}

Please review the full conversation context and provide personalized assistance.
        """.strip()

        return description

    def _determine_category(self, intent_analysis: Dict[str, Any]) -> str:
        """Determine callback category"""

        intent = intent_analysis.get("intent", "").lower()

        category_mapping = {
            "complaint": "customer_complaint",
            "claim_status": "claims_assistance",
            "premium_payment": "payment_support",
            "policy_inquiry": "policy_assistance",
            "escalation_request": "urgent_support",
            "document_request": "document_services"
        }

        return category_mapping.get(intent, "general_support")

    def _get_sla_target(self, priority: str) -> int:
        """Get SLA target in minutes based on priority"""

        sla_targets = {
            "high": 60,    # 1 hour
            "medium": 240, # 4 hours
            "low": 1440    # 24 hours
        }

        return sla_targets.get(priority, 1440)

    def _get_suggested_response_time(self, priority: str) -> str:
        """Get human-readable suggested response time"""

        response_times = {
            "high": "within 1 hour",
            "medium": "within 4 hours",
            "low": "within 24 hours"
        }

        return response_times.get(priority, "within 24 hours")

    def _get_estimated_response_time(self, priority: str) -> str:
        """Get estimated response time for user communication"""

        estimated_times = {
            "high": "< 1 hour",
            "medium": "2-4 hours",
            "low": "6-24 hours"
        }

        return estimated_times.get(priority, "24 hours")

    def _get_next_steps_for_user(self, priority: str, sla_minutes: int) -> str:
        """Get next steps message for user"""

        if priority == "high":
            return f"Your request has been escalated to a senior agent. They will contact you within {sla_minutes} minutes."
        elif priority == "medium":
            return f"An agent will review your request and contact you within {sla_minutes // 60} hours."
        else:
            return f"Your request is being processed. An agent will contact you within 24 hours during business hours."

    def _summarize_conversation(self, conversation_context: Dict[str, Any]) -> Dict[str, Any]:
        """Summarize conversation for the report"""

        messages = conversation_context.get("messages", [])
        total_messages = len(messages)

        if not messages:
            return {"total_messages": 0, "duration_minutes": 0}

        # Calculate duration
        start_time = None
        end_time = None
        for msg in messages:
            timestamp = msg.get("timestamp")
            if timestamp:
                msg_time = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                if start_time is None or msg_time < start_time:
                    start_time = msg_time
                if end_time is None or msg_time > end_time:
                    end_time = msg_time

        duration_minutes = 0
        if start_time and end_time:
            duration_minutes = int((end_time - start_time).total_seconds() / 60)

        return {
            "total_messages": total_messages,
            "duration_minutes": duration_minutes,
            "start_time": start_time.isoformat() if start_time else None,
            "end_time": end_time.isoformat() if end_time else None
        }

    def _extract_key_issues(self, conversation_context: Dict[str, Any], intent_analysis: Dict[str, Any]) -> List[str]:
        """Extract key issues from conversation"""

        issues = []
        intent = intent_analysis.get("intent", "").lower()
        sentiment = intent_analysis.get("sentiment", "neutral")

        # Add intent-based issues
        if intent == "complaint":
            issues.append("Customer has expressed dissatisfaction")
        elif intent == "claim_status":
            issues.append("Customer needs claim status information")
        elif intent == "premium_payment":
            issues.append("Customer has payment-related questions")
        elif intent == "escalation_request":
            issues.append("Customer specifically requested human assistance")

        # Add sentiment-based issues
        if sentiment == "frustrated":
            issues.append("Customer appears frustrated with previous interactions")
        elif sentiment == "negative":
            issues.append("Customer expressed negative sentiment")

        # Add complexity-based issues
        complexity_score = intent_analysis.get("complexity_score", 0)
        if complexity_score > 0.8:
            issues.append("Query appears highly complex, requires expert assistance")

        return issues if issues else ["Requires human review and assistance"]

    def _suggest_actions(self, intent_analysis: Dict[str, Any], complexity_score: float) -> List[str]:
        """Suggest actions for the agent"""

        suggestions = []
        intent = intent_analysis.get("intent", "").lower()

        # Intent-specific suggestions
        if intent == "complaint":
            suggestions.extend([
                "Review previous interactions and identify resolution opportunities",
                "Provide empathetic response and clear resolution steps",
                "Offer compensation or goodwill gesture if appropriate"
            ])
        elif intent == "claim_status":
            suggestions.extend([
                "Verify claim details and current status",
                "Provide clear explanation of claim process",
                "Set appropriate expectations for resolution timeline"
            ])
        elif intent == "premium_payment":
            suggestions.extend([
                "Assist with payment method selection",
                "Verify payment status and confirm receipt",
                "Provide payment receipt and confirmation"
            ])
        elif complexity_score > 0.8:
            suggestions.extend([
                "Conduct thorough review of customer account",
                "Provide comprehensive solution addressing root cause",
                "Schedule follow-up to ensure complete resolution"
            ])

        # Default suggestions
        if not suggestions:
            suggestions = [
                "Review customer query and provide accurate information",
                "Address any specific concerns or questions raised",
                "Ensure customer understands next steps and resolution"
            ]

        return suggestions

    def _identify_priority_factors(self, intent_analysis: Dict[str, Any], complexity_score: float) -> List[str]:
        """Identify factors that influenced priority assignment"""

        factors = []

        if complexity_score > 0.8:
            factors.append(f"High complexity score ({complexity_score:.2f})")

        intent = intent_analysis.get("intent", "").lower()
        if intent in ["complaint", "escalation_request"]:
            factors.append(f"Critical intent: {intent}")

        urgency = intent_analysis.get("urgency", "low")
        if urgency == "high":
            factors.append("High urgency level")

        sentiment = intent_analysis.get("sentiment", "neutral")
        if sentiment in ["frustrated", "negative"]:
            factors.append(f"Negative sentiment: {sentiment}")

        return factors if factors else ["Standard priority assignment"]

    def _build_conversation_timeline(self, conversation_context: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Build conversation timeline for the report"""

        messages = conversation_context.get("messages", [])
        timeline = []

        for msg in messages[-10:]:  # Last 10 messages for brevity
            timeline.append({
                "timestamp": msg.get("timestamp"),
                "sender": msg.get("sender"),
                "content": msg.get("content", "")[:200] + "..." if len(msg.get("content", "")) > 200 else msg.get("content", ""),
                "intent": msg.get("intent")
            })

        return timeline

    def _calculate_sla_compliance(self, callbacks: List[Callback]) -> Dict[str, Any]:
        """Calculate SLA compliance metrics"""

        completed_callbacks = [c for c in callbacks if c.status == CallbackStatus.COMPLETED and c.resolution_time_minutes]

        if not completed_callbacks:
            return {"compliance_rate": 0, "avg_resolution_time": 0}

        compliant_callbacks = []
        for callback in completed_callbacks:
            sla_target = callback.sla_target_minutes or 1440  # Default 24 hours
            if callback.resolution_time_minutes <= sla_target:
                compliant_callbacks.append(callback)

        compliance_rate = (len(compliant_callbacks) / len(completed_callbacks) * 100) if completed_callbacks else 0

        avg_resolution_time = sum(c.resolution_time_minutes for c in completed_callbacks) / len(completed_callbacks)

        return {
            "compliance_rate": round(compliance_rate, 2),
            "avg_resolution_time_minutes": round(avg_resolution_time, 1),
            "total_completed": len(completed_callbacks),
            "compliant_count": len(compliant_callbacks)
        }
