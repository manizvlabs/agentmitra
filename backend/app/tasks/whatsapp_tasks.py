"""
WhatsApp Tasks
==============

Celery tasks for WhatsApp message processing.
"""

import logging
from typing import Optional, Dict, Any
from app.core.tasks import whatsapp_task
from app.core.database import get_db
from app.services.whatsapp_service import WhatsAppService

logger = logging.getLogger(__name__)


@whatsapp_task("send_message")
def send_message(
    to_phone: str,
    message_type: str,
    content: Dict[str, Any],
    template_name: Optional[str] = None
) -> dict:
    """Send WhatsApp message asynchronously"""
    try:
        with get_db() as db:
            whatsapp_service = WhatsAppService(db)
            result = whatsapp_service.send_message(
                to_phone=to_phone,
                message_type=message_type,
                content=content,
                template_name=template_name
            )
            logger.info(f"WhatsApp message sent to {to_phone}")
            return result
    except Exception as e:
        logger.error(f"Failed to send WhatsApp message to {to_phone}: {e}")
        raise


@whatsapp_task("process_webhook")
def process_webhook(webhook_data: dict) -> bool:
    """Process WhatsApp webhook asynchronously"""
    try:
        with get_db() as db:
            whatsapp_service = WhatsAppService(db)
            result = whatsapp_service.process_webhook(webhook_data)
            logger.info("WhatsApp webhook processed successfully")
            return result
    except Exception as e:
        logger.error(f"Failed to process WhatsApp webhook: {e}")
        raise


@whatsapp_task("create_template")
def create_template(
    name: str,
    category: str,
    language: str,
    content: str,
    variables: list
) -> dict:
    """Create WhatsApp template asynchronously"""
    try:
        with get_db() as db:
            whatsapp_service = WhatsAppService(db)
            result = whatsapp_service.create_template(
                name=name,
                category=category,
                language=language,
                content=content,
                variables=variables
            )
            logger.info(f"WhatsApp template created: {name}")
            return result
    except Exception as e:
        logger.error(f"Failed to create WhatsApp template {name}: {e}")
        raise


@whatsapp_task("send_bulk_messages")
def send_bulk_messages(
    recipients: list,
    message_type: str,
    content: Dict[str, Any],
    template_name: Optional[str] = None
) -> dict:
    """Send bulk WhatsApp messages"""
    results = {"successful": 0, "failed": 0, "details": []}

    for phone in recipients:
        try:
            send_message.delay(
                to_phone=phone,
                message_type=message_type,
                content=content,
                template_name=template_name
            )
            results["successful"] += 1
            results["details"].append({"phone": phone, "status": "queued"})
        except Exception as e:
            results["failed"] += 1
            results["details"].append({"phone": phone, "status": "failed", "error": str(e)})

    logger.info(f"Bulk WhatsApp messages queued: {results}")
    return results
