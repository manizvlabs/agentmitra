"""
Subscription Service
===================

Handles subscription plan management, user subscriptions, billing, and upgrades/downgrades.
"""

from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from decimal import Decimal
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func

from app.models.subscription import SubscriptionPlan, UserSubscription, SubscriptionBillingHistory, SubscriptionChange
from app.models.user import User
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class SubscriptionService:
    """Service for managing subscriptions and billing"""

    def __init__(self, db: Session):
        self.db = db

    def get_active_plans(self, plan_type: str = None) -> List[SubscriptionPlan]:
        """Get all active subscription plans"""
        query = self.db.query(SubscriptionPlan).filter(SubscriptionPlan.is_active == True)

        if plan_type:
            query = query.filter(SubscriptionPlan.plan_type == plan_type)

        return query.order_by(SubscriptionPlan.sort_order).all()

    def get_plan_by_id(self, plan_id: str) -> Optional[SubscriptionPlan]:
        """Get subscription plan by ID"""
        return self.db.query(SubscriptionPlan).filter(SubscriptionPlan.plan_id == plan_id).first()

    def get_plan_by_name(self, plan_name: str) -> Optional[SubscriptionPlan]:
        """Get subscription plan by name"""
        return self.db.query(SubscriptionPlan).filter(SubscriptionPlan.plan_name == plan_name).first()

    def get_user_subscription(self, user_id: str) -> Optional[UserSubscription]:
        """Get active subscription for user"""
        return self.db.query(UserSubscription).filter(
            and_(
                UserSubscription.user_id == user_id,
                UserSubscription.status.in_(['active', 'trialing'])
            )
        ).first()

    def create_subscription(self, user: User, plan_id: str, billing_cycle: str = "monthly",
                          payment_method_id: str = None) -> UserSubscription:
        """Create a new subscription for user"""
        try:
            plan = self.get_plan_by_id(plan_id)
            if not plan:
                raise ValueError("Invalid subscription plan")

            # Calculate pricing
            amount = plan.price_monthly if billing_cycle == "monthly" else plan.price_yearly

            # Set subscription dates
            now = datetime.utcnow()
            period_end = now + timedelta(days=30 if billing_cycle == "monthly" else 365)

            # Check if user has trial
            trial_end = None
            if plan.trial_days and plan.trial_days > 0:
                trial_end = now + timedelta(days=plan.trial_days)
                if trial_end > period_end:
                    period_end = trial_end

            subscription = UserSubscription(
                user_id=user.user_id,
                plan_id=plan.plan_id,
                billing_cycle=billing_cycle,
                status="trialing" if trial_end else "active",
                current_period_start=now,
                current_period_end=period_end,
                trial_start=now if trial_end else None,
                trial_end=trial_end,
                payment_method_id=payment_method_id,
                amount=amount,
                currency=plan.currency,
                next_payment_date=trial_end if trial_end else period_end
            )

            self.db.add(subscription)

            # Create billing history record if not trial
            if not trial_end:
                billing_history = SubscriptionBillingHistory(
                    subscription_id=subscription.subscription_id,
                    user_id=user.user_id,
                    amount=amount,
                    currency=plan.currency,
                    billing_date=now,
                    billing_period_start=now,
                    billing_period_end=period_end,
                    status="paid"  # Assume paid for now
                )
                self.db.add(billing_history)

            self.db.commit()
            self.db.refresh(subscription)

            logger.info(f"Created subscription {subscription.subscription_id} for user {user.user_id}")
            return subscription

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error creating subscription for user {user.user_id}: {e}")
            raise

    def upgrade_subscription(self, user_id: str, new_plan_id: str,
                           proration_mode: str = "immediate") -> Dict[str, Any]:
        """Upgrade user subscription to a higher plan"""
        try:
            current_subscription = self.get_user_subscription(user_id)
            if not current_subscription:
                raise ValueError("No active subscription found")

            new_plan = self.get_plan_by_id(new_plan_id)
            if not new_plan:
                raise ValueError("Invalid new plan")

            # Check if it's actually an upgrade (compare pricing)
            current_amount = current_subscription.amount or 0
            new_amount = new_plan.price_monthly if current_subscription.billing_cycle == "monthly" else new_plan.price_yearly

            if new_amount <= current_amount:
                raise ValueError("New plan is not an upgrade (same or lower price)")

            # Calculate proration
            proration_amount = self._calculate_proration(
                current_subscription, new_plan, proration_mode
            )

            # Update subscription
            old_plan_id = current_subscription.plan_id
            current_subscription.plan_id = new_plan.plan_id
            current_subscription.amount = new_amount
            current_subscription.updated_at = datetime.utcnow()

            # Record the change
            change = SubscriptionChange(
                subscription_id=current_subscription.subscription_id,
                user_id=user_id,
                from_plan_id=old_plan_id,
                to_plan_id=new_plan.plan_id,
                change_type="upgrade",
                proration_amount=proration_amount,
                reason="User requested upgrade"
            )
            self.db.add(change)

            # Create billing record for upgrade fee if any
            if proration_amount > 0:
                billing = SubscriptionBillingHistory(
                    subscription_id=current_subscription.subscription_id,
                    user_id=user_id,
                    amount=proration_amount,
                    currency=current_subscription.currency,
                    billing_date=datetime.utcnow(),
                    status="paid",
                    metadata={"change_type": "upgrade", "from_plan": str(old_plan_id), "to_plan": new_plan_id}
                )
                self.db.add(billing)

            self.db.commit()

            return {
                "subscription_id": str(current_subscription.subscription_id),
                "old_plan": str(old_plan_id),
                "new_plan": new_plan_id,
                "proration_amount": float(proration_amount),
                "effective_date": datetime.utcnow().isoformat()
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error upgrading subscription for user {user_id}: {e}")
            raise

    def downgrade_subscription(self, user_id: str, new_plan_id: str,
                             effective_date: str = "end_of_period") -> Dict[str, Any]:
        """Downgrade user subscription (takes effect at end of billing period or immediately)"""
        try:
            current_subscription = self.get_user_subscription(user_id)
            if not current_subscription:
                raise ValueError("No active subscription found")

            new_plan = self.get_plan_by_id(new_plan_id)
            if not new_plan:
                raise ValueError("Invalid new plan")

            # Check if it's actually a downgrade
            current_amount = current_subscription.amount or 0
            new_amount = new_plan.price_monthly if current_subscription.billing_cycle == "monthly" else new_plan.price_yearly

            if new_amount >= current_amount:
                raise ValueError("New plan is not a downgrade (same or higher price)")

            # For downgrades, typically apply at end of billing period
            effective_datetime = current_subscription.current_period_end if effective_date == "end_of_period" else datetime.utcnow()

            # Record the change
            change = SubscriptionChange(
                subscription_id=current_subscription.subscription_id,
                user_id=user_id,
                from_plan_id=current_subscription.plan_id,
                to_plan_id=new_plan.plan_id,
                change_type="downgrade",
                effective_date=effective_datetime,
                reason="User requested downgrade"
            )
            self.db.add(change)

            # If immediate, update subscription now
            if effective_date == "immediate":
                current_subscription.plan_id = new_plan.plan_id
                current_subscription.amount = new_amount
                current_subscription.updated_at = datetime.utcnow()

            # Mark for change at period end
            elif effective_date == "end_of_period":
                # This would be handled by a background job that processes scheduled changes
                current_subscription.cancel_at_period_end = True

            self.db.commit()

            return {
                "subscription_id": str(current_subscription.subscription_id),
                "old_plan": str(current_subscription.plan_id),
                "new_plan": new_plan_id,
                "effective_date": effective_datetime.isoformat(),
                "scheduled_change": effective_date == "end_of_period"
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error downgrading subscription for user {user_id}: {e}")
            raise

    def cancel_subscription(self, user_id: str, cancel_at_period_end: bool = True,
                          reason: str = None) -> Dict[str, Any]:
        """Cancel user subscription"""
        try:
            subscription = self.get_user_subscription(user_id)
            if not subscription:
                raise ValueError("No active subscription found")

            subscription.cancel_at_period_end = cancel_at_period_end
            subscription.canceled_at = datetime.utcnow()
            subscription.updated_at = datetime.utcnow()

            if not cancel_at_period_end:
                subscription.status = "canceled"
                subscription.current_period_end = datetime.utcnow()

            # Record the change
            change = SubscriptionChange(
                subscription_id=subscription.subscription_id,
                user_id=user_id,
                from_plan_id=subscription.plan_id,
                change_type="cancellation",
                reason=reason or "User requested cancellation"
            )
            self.db.add(change)

            self.db.commit()

            return {
                "subscription_id": str(subscription.subscription_id),
                "cancel_at_period_end": cancel_at_period_end,
                "effective_date": subscription.current_period_end.isoformat() if cancel_at_period_end else datetime.utcnow().isoformat()
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error canceling subscription for user {user_id}: {e}")
            raise

    def process_trial_expiration(self, user_id: str) -> Dict[str, Any]:
        """Process trial expiration for a user"""
        try:
            subscription = self.db.query(UserSubscription).filter(
                and_(
                    UserSubscription.user_id == user_id,
                    UserSubscription.status == "trialing",
                    UserSubscription.trial_end <= datetime.utcnow()
                )
            ).first()

            if not subscription:
                return {"processed": False, "reason": "No expiring trial found"}

            # Convert to active subscription or cancel
            # For now, we'll mark as incomplete (requires payment)
            subscription.status = "incomplete"
            subscription.updated_at = datetime.utcnow()

            # Get user for notification
            user = self.db.query(User).filter(User.user_id == user_id).first()

            self.db.commit()

            return {
                "processed": True,
                "subscription_id": str(subscription.subscription_id),
                "new_status": "incomplete",
                "requires_payment": True,
                "trial_expired": True
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error processing trial expiration for user {user_id}: {e}")
            raise

    def get_subscription_details(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get detailed subscription information for user"""
        subscription = self.get_user_subscription(user_id)
        if not subscription:
            return None

        plan = subscription.plan

        return {
            "subscription_id": str(subscription.subscription_id),
            "plan": {
                "plan_id": str(plan.plan_id),
                "plan_name": plan.plan_name,
                "plan_type": plan.plan_type,
                "display_name": plan.display_name,
                "description": plan.description,
                "price_monthly": float(plan.price_monthly) if plan.price_monthly else None,
                "price_yearly": float(plan.price_yearly) if plan.price_yearly else None,
                "currency": plan.currency,
                "features": plan.features or [],
                "limitations": plan.limitations or {},
                "max_users": plan.max_users,
                "max_storage_gb": plan.max_storage_gb,
                "max_policies": plan.max_policies,
                "is_popular": plan.is_popular,
                "trial_days": plan.trial_days,
                "sort_order": plan.sort_order
            },
            "billing_cycle": subscription.billing_cycle,
            "status": subscription.status,
            "current_period_start": subscription.current_period_start.isoformat() if subscription.current_period_start else None,
            "current_period_end": subscription.current_period_end.isoformat() if subscription.current_period_end else None,
            "trial_end": subscription.trial_end.isoformat() if subscription.trial_end else None,
            "amount": float(subscription.amount) if subscription.amount else None,
            "currency": subscription.currency,
            "cancel_at_period_end": subscription.cancel_at_period_end,
            "next_payment_date": subscription.next_payment_date.isoformat() if subscription.next_payment_date else None
        }

    def _calculate_proration(self, subscription: UserSubscription, new_plan: SubscriptionPlan,
                           mode: str = "immediate") -> Decimal:
        """Calculate proration amount for plan changes"""
        # Simple proration calculation - can be enhanced
        if mode == "immediate":
            # Calculate remaining days in current period
            now = datetime.utcnow()
            period_end = subscription.current_period_end or now
            total_days = (period_end - subscription.current_period_start).days if subscription.current_period_start else 30
            remaining_days = max(0, (period_end - now).days)

            current_daily_rate = (subscription.amount or 0) / total_days
            new_daily_rate = (new_plan.price_monthly if subscription.billing_cycle == "monthly" else new_plan.price_yearly) / 30

            return Decimal(str(round((new_daily_rate - current_daily_rate) * remaining_days, 2)))

        return Decimal('0')
