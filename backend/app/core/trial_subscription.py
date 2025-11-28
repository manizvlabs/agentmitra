"""
Trial and Subscription Management
Handles trial period checking and subscription verification
"""
from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta, date
from sqlalchemy.orm import Session
from sqlalchemy import and_, func, or_
from app.models.user import User
from app.models.trial import TrialSubscription, TrialEngagement
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class TrialSubscriptionService:
    """Service for managing trial periods and subscriptions"""

    DEFAULT_TRIAL_DAYS = 14

    def __init__(self, db: Session = None):
        self.db = db
    
    @staticmethod
    def check_trial_status(user: User) -> Dict[str, Any]:
        """
        Check user's trial and subscription status
        
        Returns:
            Dict with trial_status, subscription_status, and related info
        """
        result = {
            "is_trial": False,
            "trial_expired": False,
            "trial_end_date": None,
            "subscription_active": False,
            "subscription_status": None,
            "can_access_features": True,
        }
        
        # Check if user has trial_end_date
        if hasattr(user, 'trial_end_date') and user.trial_end_date:
            result["is_trial"] = True
            result["trial_end_date"] = user.trial_end_date.isoformat() if isinstance(user.trial_end_date, datetime) else str(user.trial_end_date)
            
            # Check if trial expired
            trial_end = user.trial_end_date
            if isinstance(trial_end, str):
                trial_end = datetime.fromisoformat(trial_end.replace('Z', '+00:00'))
            
            if datetime.utcnow() > trial_end:
                result["trial_expired"] = True
                result["can_access_features"] = False
        
        # Check subscription status
        if hasattr(user, 'subscription_status'):
            result["subscription_status"] = user.subscription_status
            
            if user.subscription_status == "active":
                result["subscription_active"] = True
                result["can_access_features"] = True
            elif user.subscription_status in ["cancelled", "expired", "suspended"]:
                result["can_access_features"] = False
        
        # If user is not on trial and has no subscription, check role
        # Admins and agents might have different access
        if not result["is_trial"] and not result["subscription_active"]:
            # Policyholders need subscription, but agents/admins might have different rules
            if user.role in ["policyholder", "guest"]:
                result["can_access_features"] = False
        
        return result
    
    @staticmethod
    def is_trial_expired(user: User) -> bool:
        """Check if user's trial has expired"""
        status = TrialSubscriptionService.check_trial_status(user)
        return status.get("trial_expired", False)
    
    @staticmethod
    def has_active_subscription(user: User) -> bool:
        """Check if user has active subscription"""
        status = TrialSubscriptionService.check_trial_status(user)
        return status.get("subscription_active", False)
    
    @staticmethod
    def can_access_features(user: User) -> bool:
        """Check if user can access features (not expired trial, has subscription, or is admin/agent)"""
        status = TrialSubscriptionService.check_trial_status(user)
        return status.get("can_access_features", True)
    
    @staticmethod
    def start_trial(user: User, trial_days: int = None) -> datetime:
        """
        Start trial period for user
        
        Args:
            user: User object
            trial_days: Number of days for trial (default: 14)
        
        Returns:
            Trial end date
        """
        if trial_days is None:
            trial_days = TrialSubscriptionService.DEFAULT_TRIAL_DAYS
        
        trial_end = datetime.utcnow() + timedelta(days=trial_days)
        
        # Update user
        if hasattr(user, 'trial_end_date'):
            user.trial_end_date = trial_end
        if hasattr(user, 'subscription_status'):
            user.subscription_status = "trial"
        
        return trial_end
    
    @staticmethod
    def activate_subscription(user: User, plan: str = "premium") -> bool:
        """
        Activate subscription for user

        Args:
            user: User object
            plan: Subscription plan name

        Returns:
            True if successful
        """
        if hasattr(user, 'subscription_status'):
            user.subscription_status = "active"
        if hasattr(user, 'subscription_plan'):
            user.subscription_plan = plan

        return True

    def setup_trial(self, user: User, plan_type: str = "policyholder_trial",
                   custom_trial_days: int = None, extension_days: int = None) -> Dict[str, Any]:
        """Set up trial subscription for a user"""
        try:
            trial_days = custom_trial_days or self.DEFAULT_TRIAL_DAYS
            start_date = datetime.utcnow()
            end_date = start_date + timedelta(days=trial_days + (extension_days or 0))

            # Create trial subscription record
            trial_subscription = TrialSubscription(
                user_id=user.user_id,
                plan_type=plan_type,
                trial_start_date=start_date,
                trial_end_date=end_date,
                extension_days=extension_days or 0,
                trial_status="active"
            )

            if self.db:
                self.db.add(trial_subscription)
                self.db.commit()
                self.db.refresh(trial_subscription)

            # Update user record
            user.trial_end_date = end_date
            user.subscription_status = "trial"

            if self.db:
                self.db.commit()

            return {
                "trial_id": str(trial_subscription.trial_id),
                "plan_type": plan_type,
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                "trial_days": trial_days,
                "extension_days": extension_days or 0,
                "status": "active"
            }

        except Exception as e:
            if self.db:
                self.db.rollback()
            logger.error(f"Error setting up trial for user {user.user_id}: {e}")
            raise

    def extend_trial(self, user: User, extension_days: int, reason: str,
                    approved_by: str = None) -> Dict[str, Any]:
        """Extend trial period for a user"""
        try:
            # Find active trial
            trial = self.db.query(TrialSubscription).filter(
                and_(
                    TrialSubscription.user_id == user.user_id,
                    TrialSubscription.trial_status == "active"
                )
            ).first()

            if not trial:
                raise ValueError("No active trial found for user")

            # Extend trial
            trial.trial_end_date = trial.trial_end_date + timedelta(days=extension_days)
            trial.extension_days += extension_days
            trial.updated_at = datetime.utcnow()

            # Update user record
            user.trial_end_date = trial.trial_end_date

            self.db.commit()

            return {
                "trial_id": str(trial.trial_id),
                "extended_by_days": extension_days,
                "new_end_date": trial.trial_end_date.isoformat(),
                "total_extension_days": trial.extension_days
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error extending trial for user {user.user_id}: {e}")
            raise

    def convert_trial_to_subscription(self, user: User, conversion_plan: str) -> Dict[str, Any]:
        """Convert trial to paid subscription"""
        try:
            # Find active trial
            trial = self.db.query(TrialSubscription).filter(
                and_(
                    TrialSubscription.user_id == user.user_id,
                    TrialSubscription.trial_status == "active"
                )
            ).first()

            if not trial:
                raise ValueError("No active trial found for user")

            # Convert trial
            conversion_date = datetime.utcnow()
            trial.actual_conversion_date = conversion_date
            trial.conversion_plan = conversion_plan
            trial.trial_status = "converted"
            trial.updated_at = conversion_date

            # Update user record
            user.subscription_status = "active"
            user.subscription_plan = conversion_plan

            self.db.commit()

            return {
                "trial_id": str(trial.trial_id),
                "conversion_date": conversion_date.isoformat(),
                "conversion_plan": conversion_plan,
                "trial_duration_days": (conversion_date - trial.trial_start_date).days
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error converting trial for user {user.user_id}: {e}")
            raise

    def record_engagement(self, user_id: str, feature_used: str,
                         engagement_type: str, metadata: Dict = None) -> Dict[str, Any]:
        """Record trial user engagement"""
        try:
            # Find active trial
            trial = self.db.query(TrialSubscription).filter(
                and_(
                    TrialSubscription.user_id == user_id,
                    TrialSubscription.trial_status == "active"
                )
            ).first()

            if not trial:
                return {"recorded": False, "reason": "No active trial found"}

            # Record engagement
            engagement = TrialEngagement(
                trial_id=trial.trial_id,
                feature_used=feature_used,
                engagement_type=engagement_type,
                metadata=metadata or {}
            )

            self.db.add(engagement)
            self.db.commit()

            return {
                "recorded": True,
                "engagement_id": str(engagement.engagement_id),
                "trial_id": str(trial.trial_id)
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error recording engagement for user {user_id}: {e}")
            return {"recorded": False, "error": str(e)}

    def get_trial_analytics(self) -> Dict[str, Any]:
        """Get comprehensive trial analytics"""
        try:
            # Get trial counts
            trial_counts = self.db.query(
                func.count(TrialSubscription.trial_id).label("total_trials"),
                func.sum(func.case((TrialSubscription.trial_status == "active", 1), else_=0)).label("active_trials"),
                func.sum(func.case((TrialSubscription.trial_status == "expired", 1), else_=0)).label("expired_trials"),
                func.sum(func.case((TrialSubscription.trial_status == "converted", 1), else_=0)).label("converted_trials")
            ).first()

            # Calculate conversion rate
            total_trials = trial_counts.total_trials or 0
            converted_trials = trial_counts.converted_trials or 0
            conversion_rate = (converted_trials / total_trials * 100) if total_trials > 0 else 0

            # Average trial duration for converted trials
            avg_duration = self.db.query(
                func.avg(
                    func.extract('epoch', TrialSubscription.actual_conversion_date - TrialSubscription.trial_start_date) / 86400
                )
            ).filter(TrialSubscription.trial_status == "converted").scalar()

            # Trials by plan type
            plan_types = self.db.query(
                TrialSubscription.plan_type,
                func.count(TrialSubscription.trial_id).label("count")
            ).group_by(TrialSubscription.plan_type).all()

            # Trials expiring in next 7 days
            expiry_cutoff = datetime.utcnow() + timedelta(days=7)
            expiring_soon = self.db.query(func.count(TrialSubscription.trial_id)).filter(
                and_(
                    TrialSubscription.trial_status == "active",
                    TrialSubscription.trial_end_date <= expiry_cutoff,
                    TrialSubscription.trial_end_date > datetime.utcnow()
                )
            ).scalar()

            return {
                "total_trial_users": total_trials,
                "active_trials": trial_counts.active_trials or 0,
                "expired_trials": trial_counts.expired_trials or 0,
                "converted_trials": converted_trials,
                "conversion_rate": round(conversion_rate, 2),
                "average_trial_duration": round(avg_duration or 0, 1),
                "trials_by_plan_type": {plan.plan_type: plan.count for plan in plan_types} if plan_types else {},
                "trials_expiring_soon": expiring_soon or 0
            }

        except Exception as e:
            logger.error(f"Error getting trial analytics: {e}")
            # Return default values instead of empty dict
            return {
                "total_trial_users": 0,
                "active_trials": 0,
                "expired_trials": 0,
                "converted_trials": 0,
                "conversion_rate": 0.0,
                "average_trial_duration": 0.0,
                "trials_by_plan_type": {},
                "trials_expiring_soon": 0
            }

    def get_expiring_trials(self, days: int = 7) -> List[Dict[str, Any]]:
        """Get trials expiring within specified days"""
        try:
            expiry_cutoff = datetime.utcnow() + timedelta(days=days)

            trials = self.db.query(TrialSubscription).join(User).filter(
                and_(
                    TrialSubscription.trial_status == "active",
                    TrialSubscription.trial_end_date <= expiry_cutoff,
                    TrialSubscription.trial_end_date > datetime.utcnow()
                )
            ).all()

            result = []
            for trial in trials:
                days_remaining = (trial.trial_end_date - datetime.utcnow()).days
                result.append({
                    "trial_id": str(trial.trial_id),
                    "user_id": str(trial.user_id),
                    "user_name": trial.user.full_name,
                    "user_email": trial.user.email,
                    "plan_type": trial.plan_type,
                    "end_date": trial.trial_end_date.isoformat(),
                    "days_remaining": days_remaining,
                    "extension_days": trial.extension_days
                })

            return result

        except Exception as e:
            logger.error(f"Error getting expiring trials: {e}")
            return []

    def send_expiration_reminder(self, user: User, reminder_type: str = "email") -> Dict[str, Any]:
        """Send trial expiration reminder"""
        try:
            # Find active trial
            trial = self.db.query(TrialSubscription).filter(
                and_(
                    TrialSubscription.user_id == user.user_id,
                    TrialSubscription.trial_status == "active"
                )
            ).first()

            if not trial:
                raise ValueError("No active trial found for user")

            # Calculate days remaining
            days_remaining = (trial.trial_end_date - datetime.utcnow()).days

            # Here you would integrate with email/SMS service
            # For now, just mark as sent
            trial.reminder_sent = True
            self.db.commit()

            return {
                "user_id": str(user.user_id),
                "reminder_type": reminder_type,
                "days_remaining": days_remaining,
                "sent_at": datetime.utcnow().isoformat()
            }

        except Exception as e:
            self.db.rollback()
            logger.error(f"Error sending reminder to user {user.user_id}: {e}")
            raise

