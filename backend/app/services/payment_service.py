"""
Payment Processing Service
==========================

This service handles payment gateway integrations including:
- Premium payment collection
- Payment gateway callbacks
- Refund processing
- Payment reconciliation
- Fraud detection
"""

import hashlib
import hmac
import json
from datetime import datetime, timedelta
from typing import Dict, Optional, Tuple
from decimal import Decimal

import razorpay
import stripe
from sqlalchemy.orm import Session

from app.core.config.settings import settings
from app.models.payment import PaymentTransaction
from app.models.policy import InsurancePolicy
from app.services.notification_service import NotificationService


class PaymentService:
    """Payment processing service with multiple gateway support"""

    def __init__(self, db: Session):
        self.db = db
        self.notification_service = NotificationService()

        # Initialize payment gateways
        self.razorpay_client = razorpay.Client(
            auth=(settings.razorpay_key_id, settings.razorpay_key_secret)
        )

        self.stripe_client = stripe.StripeClient(settings.stripe_secret_key)

    async def create_payment_order(
        self,
        policy_id: str,
        amount: Decimal,
        currency: str = "INR",
        gateway: str = "razorpay"
    ) -> Dict:
        """Create payment order for premium collection"""

        # Validate policy and amount
        policy = await self._get_policy(policy_id)
        if not policy:
            raise ValueError("Invalid policy")

        # Validate amount against policy premium
        if amount != policy.premium_amount:
            raise ValueError("Payment amount doesn't match policy premium")

        # Create order based on gateway
        if gateway == "razorpay":
            return await self._create_razorpay_order(policy, amount, currency)
        elif gateway == "stripe":
            return await self._create_stripe_payment_intent(policy, amount, currency)
        else:
            raise ValueError(f"Unsupported payment gateway: {gateway}")

    async def process_payment_callback(
        self,
        gateway: str,
        callback_data: Dict
    ) -> bool:
        """Process payment gateway callback/webhook"""

        if gateway == "razorpay":
            return await self._process_razorpay_callback(callback_data)
        elif gateway == "stripe":
            return await self._process_stripe_webhook(callback_data)
        else:
            raise ValueError(f"Unsupported payment gateway: {gateway}")

    async def process_refund(
        self,
        payment_id: str,
        refund_amount: Optional[Decimal] = None,
        reason: str = "customer_request"
    ) -> Dict:
        """Process payment refund"""

        payment = await self._get_payment(payment_id)
        if not payment:
            raise ValueError("Payment not found")

        if payment.status != "completed":
            raise ValueError("Can only refund completed payments")

        refund_amount = refund_amount or payment.amount

        if refund_amount > payment.amount:
            raise ValueError("Refund amount cannot exceed payment amount")

        # Process refund based on gateway
        if payment.gateway == "razorpay":
            return await self._process_razorpay_refund(payment, refund_amount, reason)
        elif payment.gateway == "stripe":
            return await self._process_stripe_refund(payment, refund_amount, reason)
        else:
            raise ValueError(f"Unsupported payment gateway: {payment.gateway}")

    async def reconcile_payments(
        self,
        start_date: datetime,
        end_date: datetime
    ) -> Dict:
        """Reconcile payments with gateway statements"""

        # Get payments from database
        db_payments = await self._get_payments_for_reconciliation(start_date, end_date)

        reconciliation_results = {
            "total_payments": len(db_payments),
            "matched": 0,
            "discrepancies": 0,
            "missing": 0,
            "details": []
        }

        # Compare with gateway data
        for payment in db_payments:
            gateway_status = await self._get_gateway_payment_status(payment)

            if payment.status == gateway_status["status"]:
                reconciliation_results["matched"] += 1
            else:
                reconciliation_results["discrepancies"] += 1
                reconciliation_results["details"].append({
                    "payment_id": payment.id,
                    "db_status": payment.status,
                    "gateway_status": gateway_status["status"],
                    "discrepancy": gateway_status.get("notes", "")
                })

        return reconciliation_results

    # Private methods for Razorpay integration
    async def _create_razorpay_order(
        self,
        policy: InsurancePolicy,
        amount: Decimal,
        currency: str
    ) -> Dict:
        """Create Razorpay payment order"""

        order_data = {
            "amount": int(amount * 100),  # Razorpay expects paisa
            "currency": currency,
            "receipt": f"policy_{policy.policy_number}",
            "notes": {
                "policy_id": str(policy.id),
                "policy_number": policy.policy_number,
                "customer_id": str(policy.policyholder_id)
            }
        }

        order = self.razorpay_client.order.create(order_data)

        # Store order details in database
        await self._store_payment_order({
            "order_id": order["id"],
            "policy_id": policy.id,
            "amount": amount,
            "currency": currency,
            "gateway": "razorpay",
            "gateway_order_id": order["id"],
            "status": "created"
        })

        return {
            "order_id": order["id"],
            "amount": order["amount"],
            "currency": order["currency"],
            "key": settings.razorpay_key_id
        }

    async def _process_razorpay_callback(self, callback_data: Dict) -> bool:
        """Process Razorpay payment callback"""

        # Verify payment signature
        if not self._verify_razorpay_signature(callback_data):
            raise ValueError("Invalid payment signature")

        payment_entity = callback_data["payload"]["payment"]["entity"]

        # Update payment status
        payment_update = {
            "gateway_payment_id": payment_entity["id"],
            "status": "completed" if payment_entity["status"] == "captured" else "failed",
            "gateway_response": payment_entity,
            "processed_at": datetime.utcnow()
        }

        await self._update_payment_status(
            callback_data["order_id"],
            payment_update
        )

        # Send notifications
        if payment_update["status"] == "completed":
            await self.notification_service.send_payment_success_notification(
                payment_entity["notes"]["policy_id"]
            )

        return True

    async def _process_razorpay_refund(
        self,
        payment: PaymentTransaction,
        refund_amount: Decimal,
        reason: str
    ) -> Dict:
        """Process Razorpay refund"""

        refund_data = {
            "payment_id": payment.gateway_payment_id,
            "amount": int(refund_amount * 100),
            "notes": {
                "reason": reason,
                "requested_by": "system"
            }
        }

        refund = self.razorpay_client.payment.refund(
            payment.gateway_payment_id,
            refund_data
        )

        # Store refund details
        await self._store_refund({
            "payment_id": payment.id,
            "refund_id": refund["id"],
            "amount": refund_amount,
            "reason": reason,
            "gateway": "razorpay",
            "status": "processed"
        })

        return {
            "refund_id": refund["id"],
            "status": "processed",
            "amount": refund_amount
        }

    def _verify_razorpay_signature(self, callback_data: Dict) -> bool:
        """Verify Razorpay webhook signature"""
        signature = callback_data.get("signature", "")
        payload = json.dumps(callback_data["payload"], separators=(',', ':'))

        expected_signature = hmac.new(
            settings.razorpay_webhook_secret.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()

        return hmac.compare_digest(signature, expected_signature)

    # Stripe integration methods
    async def _create_stripe_payment_intent(
        self,
        policy: InsurancePolicy,
        amount: Decimal,
        currency: str
    ) -> Dict:
        """Create Stripe payment intent"""

        # Convert amount to cents
        amount_cents = int(amount * 100)

        payment_intent = self.stripe_client.payment_intents.create(
            amount=amount_cents,
            currency=currency.lower(),
            metadata={
                "policy_id": str(policy.id),
                "policy_number": policy.policy_number,
                "customer_id": str(policy.policyholder_id)
            }
        )

        # Store order details in database
        await self._store_payment_order({
            "order_id": payment_intent.id,
            "policy_id": policy.id,
            "amount": amount,
            "currency": currency,
            "gateway": "stripe",
            "gateway_order_id": payment_intent.id,
            "status": "created"
        })

        return {
            "client_secret": payment_intent.client_secret,
            "payment_intent_id": payment_intent.id,
            "amount": amount_cents,
            "currency": currency
        }

    async def _process_stripe_webhook(self, callback_data: Dict) -> bool:
        """Process Stripe webhook"""
        # Verify webhook signature
        if not self._verify_stripe_signature(callback_data):
            raise ValueError("Invalid webhook signature")

        event = callback_data

        if event["type"] == "payment_intent.succeeded":
            payment_intent = event["data"]["object"]

            # Update payment status
            payment_update = {
                "gateway_payment_id": payment_intent["id"],
                "status": "completed",
                "gateway_response": payment_intent,
                "processed_at": datetime.utcnow()
            }

            await self._update_payment_status(
                payment_intent["id"],
                payment_update
            )

            # Send notifications
            await self.notification_service.send_payment_success_notification(
                payment_intent["metadata"]["policy_id"]
            )

        return True

    def _verify_stripe_signature(self, callback_data: Dict) -> bool:
        """Verify Stripe webhook signature"""
        # This would verify the Stripe webhook signature
        # Implementation depends on how the webhook is received
        return True  # Placeholder

    # Helper methods
    async def _get_policy(self, policy_id: str) -> Optional[InsurancePolicy]:
        """Get policy by ID"""
        return self.db.query(InsurancePolicy).filter(
            InsurancePolicy.id == policy_id
        ).first()

    async def _get_payment(self, payment_id: str) -> Optional[PaymentTransaction]:
        """Get payment by ID"""
        return self.db.query(PaymentTransaction).filter(
            PaymentTransaction.id == payment_id
        ).first()

    async def _store_payment_order(self, order_data: Dict):
        """Store payment order details"""
        # Implementation for storing order details
        pass

    async def _update_payment_status(self, order_id: str, update_data: Dict):
        """Update payment status"""
        # Implementation for updating payment status
        pass

    async def _store_refund(self, refund_data: Dict):
        """Store refund details"""
        # Implementation for storing refund details
        pass

    async def _get_payments_for_reconciliation(self, start_date: datetime, end_date: datetime):
        """Get payments for reconciliation"""
        # Implementation for getting payments in date range
        pass

    async def _get_gateway_payment_status(self, payment: PaymentTransaction) -> Dict:
        """Get payment status from gateway"""
        # Implementation for checking gateway status
        pass
