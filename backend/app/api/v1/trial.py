"""
Trial Subscription Management API Endpoints
============================================

API endpoints for:
- Trial user setup and management
- Trial expiration and subscription upgrade
- Trial analytics and engagement tracking
"""

from typing import List, Optional, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from datetime import datetime, timedelta
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.auth import get_current_user_context
from app.core.trial_subscription import TrialSubscriptionService
from app.models.user import User

router = APIRouter(prefix="/trial", tags=["trial"])


# Pydantic models for API
class TrialSetupRequest(BaseModel):
    plan_type: str = "policyholder_trial"
    custom_trial_days: Optional[int] = None
    extension_days: Optional[int] = None

    @validator('plan_type')
    def validate_plan_type(cls, v):
        valid_types = ['agent_trial', 'policyholder_trial', 'enterprise_trial']
        if v not in valid_types:
            raise ValueError(f'Plan type must be one of: {", ".join(valid_types)}')
        return v

    @validator('custom_trial_days')
    def validate_trial_days(cls, v):
        if v is not None and (v < 1 or v > 365):
            raise ValueError('Trial days must be between 1 and 365')
        return v


class TrialExtensionRequest(BaseModel):
    extension_days: int
    reason: str
    approved_by: Optional[str] = None

    @validator('extension_days')
    def validate_extension_days(cls, v):
        if v < 1 or v > 90:
            raise ValueError('Extension days must be between 1 and 90')
        return v


class TrialStatusResponse(BaseModel):
    user_id: str
    is_trial: bool
    trial_start_date: Optional[str]
    trial_end_date: Optional[str]
    actual_conversion_date: Optional[str]
    conversion_plan: Optional[str]
    trial_status: str
    extension_days: int
    days_remaining: Optional[int]
    can_access_features: bool
    reminder_sent: bool
    trial_percentage_complete: Optional[float]


class TrialAnalyticsResponse(BaseModel):
    total_trial_users: int
    active_trials: int
    expired_trials: int
    converted_trials: int
    conversion_rate: float
    average_trial_duration: float
    trials_by_plan_type: Dict[str, int]
    trials_expiring_soon: int  # Next 7 days


class TrialEngagementData(BaseModel):
    feature_used: str
    engagement_type: str
    metadata: Dict[str, Any]
    engaged_at: str


@router.post("/setup")
async def setup_trial_user(
    trial_data: TrialSetupRequest,
    user_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Set up trial period for a user

    - **user_id**: Target user ID (from query param)
    - **plan_type**: Type of trial plan
    - **custom_trial_days**: Custom trial duration (optional)
    - **extension_days**: Additional extension days (optional)
    """
    try:
        # Verify permissions (admin or agent manager can set up trials)
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to manage trials"
            )

        trial_service = TrialSubscriptionService(db)

        # Get user from database
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user = user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Set up trial
        trial_info = trial_service.setup_trial(
            user=user,
            plan_type=trial_data.plan_type,
            custom_trial_days=trial_data.custom_trial_days,
            extension_days=trial_data.extension_days
        )

        return {
            "success": True,
            "message": "Trial setup completed successfully",
            "data": trial_info
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to setup trial: {str(e)}")


@router.get("/status/{user_id}", response_model=TrialStatusResponse)
async def get_trial_status(
    user_id: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get trial status for a specific user

    - **user_id**: User identifier
    """
    try:
        # Verify permissions (user can check their own status, or admin can check any)
        if str(current_user.user_id) != user_id and current_user.role not in ['super_admin', 'provider_admin', 'regional_manager']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot access trial status for this user"
            )

        # Get user from database
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user = user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        trial_service = TrialSubscriptionService(db)
        trial_status = trial_service.check_trial_status(user)

        # Calculate additional metrics
        days_remaining = None
        trial_percentage_complete = None

        if trial_status.get("is_trial") and trial_status.get("trial_end_date"):
            try:
                end_date = datetime.fromisoformat(trial_status["trial_end_date"].replace('Z', '+00:00'))
                days_remaining = (end_date - datetime.utcnow()).days

                if trial_status.get("trial_start_date"):
                    start_date = datetime.fromisoformat(trial_status["trial_start_date"].replace('Z', '+00:00'))
                    total_days = (end_date - start_date).days
                    if total_days > 0:
                        elapsed_days = (datetime.utcnow() - start_date).days
                        trial_percentage_complete = min(100, max(0, (elapsed_days / total_days) * 100))
            except (ValueError, AttributeError):
                pass

        return TrialStatusResponse(
            user_id=user_id,
            is_trial=trial_status.get("is_trial", False),
            trial_start_date=trial_status.get("trial_start_date"),
            trial_end_date=trial_status.get("trial_end_date"),
            actual_conversion_date=trial_status.get("actual_conversion_date"),
            conversion_plan=trial_status.get("conversion_plan"),
            trial_status=trial_status.get("trial_status", "none"),
            extension_days=trial_status.get("extension_days", 0),
            days_remaining=days_remaining,
            can_access_features=trial_status.get("can_access_features", True),
            reminder_sent=trial_status.get("reminder_sent", False),
            trial_percentage_complete=trial_percentage_complete
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get trial status: {str(e)}")


@router.post("/extend/{user_id}")
async def extend_trial(
    user_id: str,
    extension_data: TrialExtensionRequest,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Extend trial period for a user

    - **user_id**: User identifier
    - **extension_days**: Number of days to extend
    - **reason**: Reason for extension
    - **approved_by**: Who approved the extension (optional)
    """
    try:
        # Verify permissions
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to extend trials"
            )

        # Get user from database
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user = user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        trial_service = TrialSubscriptionService(db)
        result = trial_service.extend_trial(
            user=user,
            extension_days=extension_data.extension_days,
            reason=extension_data.reason,
            approved_by=extension_data.approved_by or str(current_user.user_id)
        )

        return {
            "success": True,
            "message": "Trial extended successfully",
            "data": result
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to extend trial: {str(e)}")


@router.post("/convert/{user_id}")
async def convert_trial_to_subscription(
    user_id: str,
    conversion_plan: str,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Convert trial user to paid subscription

    - **user_id**: User identifier
    - **conversion_plan**: Target subscription plan
    """
    try:
        # Verify permissions
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to convert trials"
            )

        # Get user from database
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user = user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        trial_service = TrialSubscriptionService(db)
        result = trial_service.convert_trial_to_subscription(
            user=user,
            conversion_plan=conversion_plan
        )

        return {
            "success": True,
            "message": "Trial converted to subscription successfully",
            "data": result
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to convert trial: {str(e)}")


@router.post("/engagement/{user_id}")
async def record_trial_engagement(
    user_id: str,
    engagement_data: TrialEngagementData,
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Record trial user engagement

    - **user_id**: User identifier
    - **feature_used**: Feature that was used
    - **engagement_type**: Type of engagement (view, interaction, completion)
    - **metadata**: Additional engagement data
    """
    try:
        # Users can only record their own engagement, or admins can record for anyone
        if str(current_user.user_id) != user_id and current_user.role not in ['super_admin', 'provider_admin']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot record engagement for this user"
            )

        trial_service = TrialSubscriptionService(db)
        result = trial_service.record_engagement(
            user_id=user_id,
            feature_used=engagement_data.feature_used,
            engagement_type=engagement_data.engagement_type,
            metadata=engagement_data.metadata
        )

        return {
            "success": True,
            "message": "Engagement recorded successfully",
            "data": result
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to record engagement: {str(e)}")


@router.get("/analytics/overview", response_model=TrialAnalyticsResponse)
async def get_trial_analytics_overview(
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get trial analytics overview

    Returns comprehensive analytics about trial usage and conversion
    """
    try:
        # Verify permissions
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager', 'senior_agent']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to view trial analytics"
            )

        trial_service = TrialSubscriptionService(db)
        analytics = trial_service.get_trial_analytics()

        return TrialAnalyticsResponse(**analytics)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get trial analytics: {str(e)}")


@router.get("/expiring-soon")
async def get_trials_expiring_soon(
    days: int = Query(7, ge=1, le=30, description="Number of days to look ahead"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Get trials expiring within specified number of days

    - **days**: Number of days to look ahead (default: 7)
    """
    try:
        # Verify permissions
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager', 'senior_agent']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to view expiring trials"
            )

        trial_service = TrialSubscriptionService(db)
        expiring_trials = trial_service.get_expiring_trials(days=days)

        return {
            "success": True,
            "data": expiring_trials,
            "count": len(expiring_trials)
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get expiring trials: {str(e)}")


@router.post("/send-reminder/{user_id}")
async def send_trial_expiration_reminder(
    user_id: str,
    reminder_type: str = Query("email", regex="^(email|sms|push)$"),
    current_user: User = Depends(get_current_user_context),
    db: Session = Depends(get_db)
):
    """
    Send trial expiration reminder to user

    - **user_id**: User identifier
    - **reminder_type**: Type of reminder (email, sms, push)
    """
    try:
        # Verify permissions
        if current_user.role not in ['super_admin', 'provider_admin', 'regional_manager']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions to send reminders"
            )

        # Get user from database
        from app.repositories.user_repository import UserRepository
        user_repo = UserRepository(db)
        user = user_repo.get_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        trial_service = TrialSubscriptionService(db)
        result = trial_service.send_expiration_reminder(
            user=user,
            reminder_type=reminder_type
        )

        return {
            "success": True,
            "message": "Trial expiration reminder sent successfully",
            "data": result
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send reminder: {str(e)}")
