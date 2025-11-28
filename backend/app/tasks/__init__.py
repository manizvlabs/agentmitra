"""
Celery Tasks Module
===================

This module contains all Celery task definitions for background processing.
"""

# Import all task modules to register them with Celery
from . import email_tasks, payment_tasks, reporting_tasks, import_tasks, whatsapp_tasks, maintenance_tasks, notification_tasks

__all__ = [
    'email_tasks',
    'payment_tasks',
    'reporting_tasks',
    'import_tasks',
    'whatsapp_tasks',
    'maintenance_tasks',
    'notification_tasks'
]
