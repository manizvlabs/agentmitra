"""
Payment Tasks
=============

Celery tasks for payment processing and reconciliation.
"""

import logging
from datetime import datetime
from app.core.tasks import payment_task
from app.core.database import get_db
from app.services.payment_service import PaymentService

logger = logging.getLogger(__name__)


@payment_task("process_webhook")
def process_webhook(gateway: str, webhook_data: dict) -> bool:
    """Process payment gateway webhook"""
    try:
        with get_db() as db:
            payment_service = PaymentService(db)
            result = payment_service.process_payment_callback(
                gateway=gateway,
                callback_data=webhook_data
            )
            logger.info(f"Payment webhook processed for gateway: {gateway}")
            return result
    except Exception as e:
        logger.error(f"Failed to process payment webhook for {gateway}: {e}")
        raise


@payment_task("process_refund")
def process_refund(
    payment_id: str,
    refund_amount: float = None,
    reason: str = "customer_request"
) -> dict:
    """Process payment refund"""
    try:
        with get_db() as db:
            payment_service = PaymentService(db)
            result = payment_service.process_refund(
                payment_id=payment_id,
                refund_amount=refund_amount,
                reason=reason
            )
            logger.info(f"Refund processed for payment: {payment_id}")
            return result
    except Exception as e:
        logger.error(f"Failed to process refund for payment {payment_id}: {e}")
        raise


@payment_task("reconcile_payments")
def reconcile_payments(start_date: str, end_date: str) -> dict:
    """Reconcile payments with gateway statements"""
    try:
        with get_db() as db:
            payment_service = PaymentService(db)
            start_dt = datetime.fromisoformat(start_date)
            end_dt = datetime.fromisoformat(end_date)

            result = payment_service.reconcile_payments(
                start_date=start_dt,
                end_date=end_dt
            )
            logger.info(f"Payment reconciliation completed for {start_date} to {end_date}")
            return result
    except Exception as e:
        logger.error(f"Failed to reconcile payments: {e}")
        raise


@payment_task("create_payment_order")
def create_payment_order(
    policy_id: str,
    amount: float,
    currency: str = "INR",
    gateway: str = "razorpay"
) -> dict:
    """Create payment order asynchronously"""
    try:
        with get_db() as db:
            payment_service = PaymentService(db)
            result = payment_service.create_payment_order(
                policy_id=policy_id,
                amount=amount,
                currency=currency,
                gateway=gateway
            )
            logger.info(f"Payment order created for policy: {policy_id}")
            return result
    except Exception as e:
        logger.error(f"Failed to create payment order for policy {policy_id}: {e}")
        raise
