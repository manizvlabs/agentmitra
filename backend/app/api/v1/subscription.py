"""
Subscription Management API Endpoints
=====================================

API endpoints for:
- Subscription plan management
- User subscription operations (create, upgrade, downgrade, cancel)
- Billing history and invoices
- Trial to subscription conversion
- Payment processing integration
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from datetime import datetime
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.services.subscription_service import SubscriptionService
from app.models.user import User

router = APIRouter(prefix="/subscription", tags=["subscription"])


# Pydantic models for API
class SubscriptionPlanResponse(BaseModel):
    plan_id: str
    plan_name: str
    plan_type: str
    display_name: str
    description: Optional[str]
    price_monthly: Optional[float]
    price_yearly: Optional[float]
    currency: str
    features: List[str]
    limitations: Dict[str, Any]
    max_users: Optional[int]
    max_storage_gb: Optional[int]
    max_policies: Optional[int]
    is_popular: bool
    trial_days: int
    sort_order: int


class SubscriptionCreateRequest(BaseModel):
    plan_id: str
    billing_cycle: str = "monthly"
    payment_method_id: Optional[str] = None

    @validator('billing_cycle')
    def validate_billing_cycle(cls, v):
        if v not in ['monthly', 'yearly']:
            raise ValueError('Billing cycle must be either monthly or yearly')
        return v


class SubscriptionUpgradeRequest(BaseModel):
    new_plan_id: str
    proration_mode: str = "immediate"

    @validator('proration_mode')
    def validate_proration_mode(cls, v):
        if v not in ['immediate', 'next_billing_cycle']:
            raise ValueError('Proration mode must be immediate or next_billing_cycle')
        return v


class SubscriptionDowngradeRequest(BaseModel):
    new_plan_id: str
    effective_date: str = "end_of_period"

    @validator('effective_date')
    def validate_effective_date(cls, v):
        if v not in ['immediate', 'end_of_period']:
            raise ValueError('Effective date must be immediate or end_of_period')
        return v


class SubscriptionCancelRequest(BaseModel):
    cancel_at_period_end: bool = True
    reason: Optional[str] = None


class SubscriptionDetailsResponse(BaseModel):
    subscription_id: str
    plan: SubscriptionPlanResponse
    billing_cycle: str
    status: str
    current_period_start: Optional[str]
    current_period_end: Optional[str]
    trial_end: Optional[str]
    amount: Optional[float]
    currency: str
    cancel_at_period_end: bool
    next_payment_date: Optional[str]


class BillingHistoryResponse(BaseModel):
    billing_id: str
    subscription_id: str
    amount: float
    currency: str
    billing_date: str
    billing_period_start: Optional[str]
    billing_period_end: Optional[str]
    payment_gateway: Optional[str]
    gateway_transaction_id: Optional[str]
    status: str
    invoice_url: Optional[str]
    receipt_url: Optional[str]


@router.get("/plans", response_model=List[SubscriptionPlanResponse])
async def get_subscription_plans(
    plan_type: Optional[str] = Query(None, description="Filter by plan type (agent, customer, enterprise)"),
    db: Session = Depends(get_db)
):
    """
    Get all active subscription plans

    - **plan_type**: Optional filter by plan type
    """
    try:
        subscription_service = SubscriptionService(db)
        plans = subscription_service.get_active_plans(plan_type=plan_type)

        return [
            SubscriptionPlanResponse(
                plan_id=str(plan.plan_id),
                plan_name=plan.plan_name,
                plan_type=plan.plan_type,
                display_name=plan.display_name,
                description=plan.description,
                price_monthly=float(plan.price_monthly) if plan.price_monthly else None,
                price_yearly=float(plan.price_yearly) if plan.price_yearly else None,
                currency=plan.currency,
                features=plan.features or [],
                limitations=plan.limitations or {},
                max_users=plan.max_users,
                max_storage_gb=plan.max_storage_gb,
                max_policies=plan.max_policies,
                is_popular=plan.is_popular,
                trial_days=plan.trial_days,
                sort_order=plan.sort_order
            )
            for plan in plans
        ]

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get subscription plans: {str(e)}")


@router.get("/plans/{plan_id}", response_model=SubscriptionPlanResponse)
async def get_subscription_plan(
    plan_id: str,
    db: Session = Depends(get_db)
):
    """
    Get subscription plan details by ID

    - **plan_id**: Plan identifier
    """
    try:
        subscription_service = SubscriptionService(db)
        plan = subscription_service.get_plan_by_id(plan_id)

        if not plan:
            raise HTTPException(status_code=404, detail="Subscription plan not found")

        return SubscriptionPlanResponse(
            plan_id=str(plan.plan_id),
            plan_name=plan.plan_name,
            plan_type=plan.plan_type,
            display_name=plan.display_name,
            description=plan.description,
            price_monthly=float(plan.price_monthly) if plan.price_monthly else None,
            price_yearly=float(plan.price_yearly) if plan.price_yearly else None,
            currency=plan.currency,
            features=plan.features or [],
            limitations=plan.limitations or {},
            max_users=plan.max_users,
            max_storage_gb=plan.max_storage_gb,
            max_policies=plan.max_policies,
            is_popular=plan.is_popular,
            trial_days=plan.trial_days,
            sort_order=plan.sort_order
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get subscription plan: {str(e)}")


@router.post("/create")
async def create_subscription(
    subscription_data: SubscriptionCreateRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Create a new subscription for the current user

    - **plan_id**: Subscription plan ID
    - **billing_cycle**: Billing cycle (monthly/yearly)
    - **payment_method_id**: Payment method identifier (optional)
    """
    try:
        subscription_service = SubscriptionService(db)
        subscription = subscription_service.create_subscription(
            user=current_user,
            plan_id=subscription_data.plan_id,
            billing_cycle=subscription_data.billing_cycle,
            payment_method_id=subscription_data.payment_method_id
        )

        return {
            "success": True,
            "message": "Subscription created successfully",
            "data": {
                "subscription_id": str(subscription.subscription_id),
                "status": subscription.status,
                "trial_end": subscription.trial_end.isoformat() if subscription.trial_end else None,
                "next_payment_date": subscription.next_payment_date.isoformat() if subscription.next_payment_date else None
            }
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create subscription: {str(e)}")


@router.get("/details", response_model=SubscriptionDetailsResponse)
async def get_user_subscription_details(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get current user's subscription details
    """
    try:
        subscription_service = SubscriptionService(db)
        details = subscription_service.get_subscription_details(str(current_user.user_id))

        if not details:
            raise HTTPException(status_code=404, detail="No active subscription found")

        return SubscriptionDetailsResponse(**details)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get subscription details: {str(e)}")


@router.post("/upgrade")
async def upgrade_subscription(
    upgrade_data: SubscriptionUpgradeRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Upgrade current user's subscription to a higher plan

    - **new_plan_id**: New subscription plan ID
    - **proration_mode**: Proration calculation mode
    """
    try:
        subscription_service = SubscriptionService(db)
        result = subscription_service.upgrade_subscription(
            user_id=str(current_user.user_id),
            new_plan_id=upgrade_data.new_plan_id,
            proration_mode=upgrade_data.proration_mode
        )

        return {
            "success": True,
            "message": "Subscription upgraded successfully",
            "data": result
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to upgrade subscription: {str(e)}")


@router.post("/downgrade")
async def downgrade_subscription(
    downgrade_data: SubscriptionDowngradeRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Downgrade current user's subscription to a lower plan

    - **new_plan_id**: New subscription plan ID
    - **effective_date**: When the change takes effect
    """
    try:
        subscription_service = SubscriptionService(db)
        result = subscription_service.downgrade_subscription(
            user_id=str(current_user.user_id),
            new_plan_id=downgrade_data.new_plan_id,
            effective_date=downgrade_data.effective_date
        )

        return {
            "success": True,
            "message": "Subscription downgrade scheduled successfully",
            "data": result
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to downgrade subscription: {str(e)}")


@router.post("/cancel")
async def cancel_subscription(
    cancel_data: SubscriptionCancelRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Cancel current user's subscription

    - **cancel_at_period_end**: Cancel at end of billing period
    - **reason**: Reason for cancellation (optional)
    """
    try:
        subscription_service = SubscriptionService(db)
        result = subscription_service.cancel_subscription(
            user_id=str(current_user.user_id),
            cancel_at_period_end=cancel_data.cancel_at_period_end,
            reason=cancel_data.reason
        )

        return {
            "success": True,
            "message": "Subscription cancelled successfully",
            "data": result
        }

    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to cancel subscription: {str(e)}")


@router.get("/billing-history", response_model=List[BillingHistoryResponse])
async def get_billing_history(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get user's billing history

    - **page**: Page number
    - **limit**: Items per page
    """
    try:
        from app.models.subscription import SubscriptionBillingHistory
        from sqlalchemy import desc

        # Get user's subscriptions first
        user_subscriptions = db.query(UserSubscription).filter(
            UserSubscription.user_id == current_user.user_id
        ).all()

        subscription_ids = [str(sub.subscription_id) for sub in user_subscriptions]

        if not subscription_ids:
            return []

        # Get billing history
        billing_history = db.query(SubscriptionBillingHistory).filter(
            SubscriptionBillingHistory.subscription_id.in_(subscription_ids)
        ).order_by(desc(SubscriptionBillingHistory.billing_date)).offset((page - 1) * limit).limit(limit).all()

        return [
            BillingHistoryResponse(
                billing_id=str(billing.billing_id),
                subscription_id=str(billing.subscription_id),
                amount=float(billing.amount),
                currency=billing.currency,
                billing_date=billing.billing_date.isoformat(),
                billing_period_start=billing.billing_period_start.isoformat() if billing.billing_period_start else None,
                billing_period_end=billing.billing_period_end.isoformat() if billing.billing_period_end else None,
                payment_gateway=billing.payment_gateway,
                gateway_transaction_id=billing.gateway_transaction_id,
                status=billing.status,
                invoice_url=billing.invoice_url,
                receipt_url=billing.receipt_url
            )
            for billing in billing_history
        ]

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get billing history: {str(e)}")


@router.post("/process-trial-expiration")
async def process_trial_expiration(
    user_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Process trial expiration for a user (admin only)

    - **user_id**: User whose trial has expired
    """
    try:
        # Check permissions (admin only)
        if current_user.role not in ['super_admin', 'provider_admin']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to process trial expiration"
            )

        subscription_service = SubscriptionService(db)
        result = subscription_service.process_trial_expiration(user_id)

        return {
            "success": True,
            "message": "Trial expiration processed",
            "data": result
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process trial expiration: {str(e)}")


@router.get("/available-upgrades")
async def get_available_upgrades(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get available upgrade options for current user's subscription
    """
    try:
        subscription_service = SubscriptionService(db)
        current_subscription = subscription_service.get_user_subscription(str(current_user.user_id))

        if not current_subscription:
            raise HTTPException(status_code=404, detail="No active subscription found")

        current_plan = current_subscription.plan

        # Get plans of same type with higher pricing
        current_amount = current_subscription.amount or 0
        available_upgrades = []

        for plan in subscription_service.get_active_plans(plan_type=current_plan.plan_type):
            plan_amount = plan.price_monthly if current_subscription.billing_cycle == "monthly" else plan.price_yearly
            if plan_amount > current_amount:
                available_upgrades.append({
                    "plan_id": str(plan.plan_id),
                    "plan_name": plan.plan_name,
                    "display_name": plan.display_name,
                    "price": float(plan_amount),
                    "currency": plan.currency,
                    "features": plan.features,
                    "savings_percentage": round(((plan_amount - current_amount) / current_amount) * 100, 1) if current_amount > 0 else 0
                })

        # Sort by price
        available_upgrades.sort(key=lambda x: x["price"])

        return {
            "success": True,
            "data": {
                "current_plan": {
                    "plan_name": current_plan.plan_name,
                    "display_name": current_plan.display_name,
                    "price": float(current_amount),
                    "currency": current_subscription.currency
                },
                "available_upgrades": available_upgrades
            }
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get available upgrades: {str(e)}")


@router.get("/compare-plans")
async def compare_subscription_plans(
    plan_ids: str = Query(..., description="Comma-separated list of plan IDs to compare"),
    db: Session = Depends(get_db)
):
    """
    Compare multiple subscription plans

    - **plan_ids**: Comma-separated list of plan IDs
    """
    try:
        subscription_service = SubscriptionService(db)
        plan_id_list = [pid.strip() for pid in plan_ids.split(",")]

        plans = []
        for plan_id in plan_id_list:
            plan = subscription_service.get_plan_by_id(plan_id)
            if plan:
                plans.append(plan)

        if not plans:
            raise HTTPException(status_code=404, detail="No valid plans found")

        # Create comparison data
        comparison = {
            "plans": [],
            "features_comparison": {},
            "pricing_comparison": {}
        }

        for plan in plans:
            plan_data = {
                "plan_id": str(plan.plan_id),
                "plan_name": plan.plan_name,
                "display_name": plan.display_name,
                "plan_type": plan.plan_type,
                "price_monthly": float(plan.price_monthly) if plan.price_monthly else None,
                "price_yearly": float(plan.price_yearly) if plan.price_yearly else None,
                "currency": plan.currency,
                "features": plan.features or [],
                "limitations": plan.limitations or {},
                "max_users": plan.max_users,
                "max_storage_gb": plan.max_storage_gb,
                "max_policies": plan.max_policies,
                "trial_days": plan.trial_days
            }
            comparison["plans"].append(plan_data)

        return {
            "success": True,
            "data": comparison
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to compare plans: {str(e)}")
