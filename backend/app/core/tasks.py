"""
Background Task Processing
==========================

This module provides background task processing using:
- FastAPI BackgroundTasks for simple tasks
- Celery for complex distributed tasks
- Redis Queue for job queuing
- Scheduled tasks with cron-like scheduling
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, Optional

from fastapi import BackgroundTasks
from celery import Celery
from redis import Redis

from app.core.config.settings import settings

logger = logging.getLogger(__name__)

# Celery configuration
celery_app = Celery(
    "agent_mitra",
    broker=settings.redis_url,
    backend=settings.redis_url,
    include=["app.tasks"]
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_routes={
        "app.tasks.email_tasks.*": {"queue": "email"},
        "app.tasks.payment_tasks.*": {"queue": "payment"},
        "app.tasks.reporting_tasks.*": {"queue": "reporting"},
        "app.tasks.notification_tasks.*": {"queue": "notifications"},
        "app.tasks.import_tasks.*": {"queue": "import"},
        "app.tasks.maintenance_tasks.*": {"queue": "maintenance"},
    }
)

# Redis connection for simple queuing
redis_client = Redis.from_url(settings.redis_url)


class TaskManager:
    """Background task manager"""

    @staticmethod
    async def send_email_async(
        background_tasks: BackgroundTasks,
        to_email: str,
        subject: str,
        template: str,
        context: Dict[str, Any]
    ):
        """Send email asynchronously"""
        from app.services.email_service import EmailService

        background_tasks.add_task(
            EmailService.send_template_email,
            to_email, subject, template, context
        )

    @staticmethod
    async def send_sms_async(
        background_tasks: BackgroundTasks,
        to_phone: str,
        message: str
    ):
        """Send SMS asynchronously"""
        from app.services.sms_service import SMSService

        background_tasks.add_task(
            SMSService.send_sms,
            to_phone, message
        )

    @staticmethod
    def process_payment_webhook(gateway: str, webhook_data: Dict):
        """Process payment webhook asynchronously"""
        from app.services.payment_service import PaymentService

        # Queue payment processing task
        celery_app.send_task(
            "app.tasks.payment_tasks.process_webhook",
            args=[gateway, webhook_data],
            queue="payment"
        )

    @staticmethod
    def generate_monthly_report(user_id: str, report_type: str):
        """Generate monthly report asynchronously"""
        celery_app.send_task(
            "app.tasks.reporting_tasks.generate_monthly_report",
            args=[user_id, report_type],
            queue="reporting",
            eta=datetime.utcnow() + timedelta(hours=1)  # Delay by 1 hour
        )

    @staticmethod
    def schedule_daily_maintenance():
        """Schedule daily maintenance tasks"""
        # Clean up old sessions
        celery_app.send_task(
            "app.tasks.maintenance_tasks.cleanup_sessions",
            queue="maintenance"
        )

        # Generate daily reports
        celery_app.send_task(
            "app.tasks.reporting_tasks.generate_daily_reports",
            queue="reporting"
        )

        # Process pending notifications
        celery_app.send_task(
            "app.tasks.notification_tasks.process_pending_notifications",
            queue="notifications"
        )

    @staticmethod
    def queue_video_processing(video_id: str, video_url: str):
        """Queue video processing task"""
        celery_app.send_task(
            "app.tasks.video_tasks.process_video",
            args=[video_id, video_url],
            queue="video"
        )

    @staticmethod
    def process_excel_import(agent_id: str, file_path: str, import_type: str = "customer_data"):
        """Queue Excel import processing"""
        celery_app.send_task(
            "app.tasks.import_tasks.process_excel_import",
            args=[agent_id, file_path, import_type],
            queue="import"
        )

    @staticmethod
    def send_whatsapp_message(to_phone: str, message_type: str, content: Dict, template_name: Optional[str] = None):
        """Queue WhatsApp message sending"""
        celery_app.send_task(
            "app.tasks.whatsapp_tasks.send_message",
            args=[to_phone, message_type, content, template_name],
            queue="whatsapp"
        )

    @staticmethod
    def reconcile_payments(start_date: str, end_date: str):
        """Queue payment reconciliation"""
        celery_app.send_task(
            "app.tasks.payment_tasks.reconcile_payments",
            args=[start_date, end_date],
            queue="payment"
        )

    @staticmethod
    def sync_agent_data(agent_id: str):
        """Queue agent data synchronization"""
        celery_app.send_task(
            "app.tasks.sync_tasks.sync_agent_data",
            args=[agent_id],
            queue="sync"
        )


# Task decorators for Celery
def email_task(name: str):
    """Decorator for email-related tasks"""
    def decorator(func):
        func.name = f"app.tasks.email_tasks.{name}"
        return celery_app.task(func)
    return decorator


def payment_task(name: str):
    """Decorator for payment-related tasks"""
    def decorator(func):
        func.name = f"app.tasks.payment_tasks.{name}"
        return celery_app.task(func)
    return decorator


def reporting_task(name: str):
    """Decorator for reporting tasks"""
    def decorator(func):
        func.name = f"app.tasks.reporting_tasks.{name}"
        return celery_app.task(func)
    return decorator


def import_task(name: str):
    """Decorator for import tasks"""
    def decorator(func):
        func.name = f"app.tasks.import_tasks.{name}"
        return celery_app.task(func)
    return decorator


def whatsapp_task(name: str):
    """Decorator for WhatsApp tasks"""
    def decorator(func):
        func.name = f"app.tasks.whatsapp_tasks.{name}"
        return celery_app.task(func)
    return decorator
