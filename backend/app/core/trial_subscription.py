"""
Trial and Subscription Management
Handles trial period checking and subscription verification
"""
from typing import Optional, Dict, Any
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.models.user import User
from app.core.logging_config import get_logger

logger = get_logger(__name__)


class TrialSubscriptionService:
    """Service for managing trial periods and subscriptions"""
    
    DEFAULT_TRIAL_DAYS = 14
    
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

