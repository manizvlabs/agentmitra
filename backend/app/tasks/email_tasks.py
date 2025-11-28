"""
Email Tasks
===========

Celery tasks for email processing and sending.
"""

import logging
from app.core.tasks import email_task
from app.services.email_service import EmailService

logger = logging.getLogger(__name__)


@email_task("send_template_email")
def send_template_email(
    to_email: str,
    subject: str,
    template: str,
    context: dict
) -> bool:
    """Send template email asynchronously"""
    try:
        email_service = EmailService()
        result = email_service.send_template_email(
            to_email=to_email,
            subject=subject,
            template=template,
            context=context
        )
        logger.info(f"Email sent successfully to {to_email}")
        return result
    except Exception as e:
        logger.error(f"Failed to send email to {to_email}: {e}")
        raise


@email_task("send_bulk_email")
def send_bulk_email(
    to_emails: list,
    subject: str,
    template: str,
    context: dict
) -> dict:
    """Send bulk email asynchronously"""
    try:
        email_service = EmailService()
        result = email_service.send_bulk_email(
            to_emails=to_emails,
            subject=subject,
            template=template,
            context=context
        )
        logger.info(f"Bulk email sent to {len(to_emails)} recipients")
        return result
    except Exception as e:
        logger.error(f"Failed to send bulk email: {e}")
        raise


@email_task("send_password_reset_email")
def send_password_reset_email(to_email: str, reset_token: str) -> bool:
    """Send password reset email"""
    try:
        email_service = EmailService()
        result = email_service.send_password_reset_email(
            to_email=to_email,
            reset_token=reset_token
        )
        logger.info(f"Password reset email sent to {to_email}")
        return result
    except Exception as e:
        logger.error(f"Failed to send password reset email to {to_email}: {e}")
        raise


@email_task("send_welcome_email")
def send_welcome_email(to_email: str, user_name: str) -> bool:
    """Send welcome email to new users"""
    try:
        email_service = EmailService()
        result = email_service.send_welcome_email(
            to_email=to_email,
            user_name=user_name
        )
        logger.info(f"Welcome email sent to {to_email}")
        return result
    except Exception as e:
        logger.error(f"Failed to send welcome email to {to_email}: {e}")
        raise


@email_task("send_payment_confirmation_email")
def send_payment_confirmation_email(
    to_email: str,
    policy_number: str,
    amount: float,
    payment_date: str
) -> bool:
    """Send payment confirmation email"""
    try:
        email_service = EmailService()
        result = email_service.send_payment_confirmation_email(
            to_email=to_email,
            policy_number=policy_number,
            amount=amount,
            payment_date=payment_date
        )
        logger.info(f"Payment confirmation email sent to {to_email}")
        return result
    except Exception as e:
        logger.error(f"Failed to send payment confirmation email to {to_email}: {e}")
        raise
