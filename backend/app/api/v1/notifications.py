from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query, BackgroundTasks
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field

from ...core.database import get_db
from ...core.auth import get_current_user_context, get_current_user_optional, get_current_user
from ...models.user import User
from ...services.notification_service import NotificationService

router = APIRouter(prefix="/notifications", tags=["notifications"])

# Pydantic models for API
class NotificationBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    body: str = Field(..., min_length=1, max_length=1000)
    type: str = Field(..., description="Type of notification")
    priority: str = Field("medium", description="Priority level")
    action_url: Optional[str] = None
    action_route: Optional[str] = None
    action_text: Optional[str] = None
    image_url: Optional[str] = None
    data: Optional[Dict[str, Any]] = None

class NotificationCreate(NotificationBase):
    user_id: Optional[str] = None  # If None, send to current user
    scheduled_at: Optional[datetime] = None

class NotificationResponse(NotificationBase):
    id: str
    user_id: str
    is_read: bool
    created_at: datetime
    read_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class NotificationSettings(BaseModel):
    enable_push_notifications: bool = True
    enable_policy_notifications: bool = True
    enable_payment_reminders: bool = True
    enable_claim_updates: bool = True
    enable_renewal_notices: bool = True
    enable_marketing_notifications: bool = False
    enable_sound: bool = True
    enable_vibration: bool = True
    show_badge: bool = True
    quiet_hours_enabled: bool = False
    quiet_hours_start: Optional[str] = None  # HH:MM format
    quiet_hours_end: Optional[str] = None    # HH:MM format
    enabled_topics: List[str] = Field(default_factory=lambda: ["general", "policies", "payments"])

class NotificationStatistics(BaseModel):
    total_notifications: int
    unread_count: int
    read_count: int
    notifications_by_type: Dict[str, int]
    notifications_by_priority: Dict[str, int]
    recent_activity: List[Dict[str, Any]]

@router.get("/", response_model=List[NotificationResponse])
async def get_notifications(
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    type_filter: Optional[str] = None,
    priority_filter: Optional[str] = None,
    is_read: Optional[bool] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user notifications with filtering and pagination"""
    try:
        notification_service = NotificationService(db)

        notifications = await notification_service.get_user_notifications(
            user_id=current_user.user_id,
            page=page,
            limit=limit,
            type_filter=type_filter,
            priority_filter=priority_filter,
            is_read=is_read,
            start_date=start_date,
            end_date=end_date
        )

        return notifications
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch notifications: {str(e)}")

@router.get("/{notification_id}", response_model=NotificationResponse)
async def get_notification(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific notification"""
    try:
        notification_service = NotificationService(db)

        notification = await notification_service.get_notification_by_id(
            notification_id=notification_id,
            user_id=current_user.user_id
        )

        if not notification:
            raise HTTPException(status_code=404, detail="Notification not found")

        return notification
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch notification: {str(e)}")

@router.patch("/{notification_id}/read")
async def mark_notification_read(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a notification as read"""
    try:
        notification_service = NotificationService(db)

        success = await notification_service.mark_notification_read(
            notification_id=notification_id,
            user_id=current_user.user_id
        )

        if not success:
            raise HTTPException(status_code=404, detail="Notification not found")

        return {"message": "Notification marked as read"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to mark notification as read: {str(e)}")

@router.patch("/read")
async def mark_notifications_read(
    notification_ids: List[str],
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark multiple notifications as read"""
    try:
        notification_service = NotificationService(db)

        success_count = await notification_service.mark_notifications_read(
            notification_ids=notification_ids,
            user_id=current_user.user_id
        )

        return {
            "message": f"Marked {success_count} notifications as read",
            "success_count": success_count
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to mark notifications as read: {str(e)}")

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a notification"""
    try:
        notification_service = NotificationService(db)

        success = await notification_service.delete_notification(
            notification_id=notification_id,
            user_id=current_user.user_id
        )

        if not success:
            raise HTTPException(status_code=404, detail="Notification not found")

        return {"message": "Notification deleted"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete notification: {str(e)}")

@router.post("/", response_model=NotificationResponse)
async def create_notification(
    notification: NotificationCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new notification (admin only)"""
    # TODO: Add admin role check
    try:
        notification_service = NotificationService(db)

        target_user_id = notification.user_id or current_user.user_id

        created_notification = await notification_service.create_notification(
            user_id=target_user_id,
            title=notification.title,
            body=notification.body,
            type=notification.type,
            priority=notification.priority,
            action_url=notification.action_url,
            action_route=notification.action_route,
            action_text=notification.action_text,
            image_url=notification.image_url,
            data=notification.data,
            scheduled_at=notification.scheduled_at
        )

        # Send push notification in background
        if not notification.scheduled_at:
            background_tasks.add_task(
                notification_service.send_push_notification,
                created_notification
            )

        return created_notification
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create notification: {str(e)}")

@router.post("/bulk")
async def create_bulk_notifications(
    notifications: List[NotificationCreate],
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create multiple notifications (admin only)"""
    # TODO: Add admin role check
    try:
        notification_service = NotificationService(db)

        created_notifications = []
        for notification in notifications:
            target_user_id = notification.user_id or current_user.user_id

            created = await notification_service.create_notification(
                user_id=target_user_id,
                title=notification.title,
                body=notification.body,
                type=notification.type,
                priority=notification.priority,
                action_url=notification.action_url,
                action_route=notification.action_route,
                action_text=notification.action_text,
                image_url=notification.image_url,
                data=notification.data,
                scheduled_at=notification.scheduled_at
            )
            created_notifications.append(created)

        # Send push notifications in background
        immediate_notifications = [n for n in created_notifications if n.get('scheduled_at') is None]
        if immediate_notifications:
            background_tasks.add_task(
                notification_service.send_bulk_push_notifications,
                immediate_notifications
            )

        return {
            "message": f"Created {len(created_notifications)} notifications",
            "notifications": created_notifications
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create notifications: {str(e)}")

@router.get("/statistics", response_model=NotificationStatistics)
async def get_notification_statistics(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get notification statistics for the current user"""
    try:
        notification_service = NotificationService(db)

        stats = await notification_service.get_user_notification_statistics(
            user_id=current_user.user_id,
            start_date=start_date,
            end_date=end_date
        )

        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get notification statistics: {str(e)}")

@router.post("/test")
async def send_test_notification(
    title: str = "Test Notification",
    body: str = "This is a test notification",
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Send a test notification to the current user"""
    try:
        notification_service = NotificationService(db)

        notification = await notification_service.create_notification(
            user_id=current_user.user_id,
            title=title,
            body=body,
            type="system",
            priority="low"
        )

        # Send push notification
        await notification_service.send_push_notification(notification)

        return {"message": "Test notification sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send test notification: {str(e)}")

# Settings endpoints
@router.get("/settings", response_model=NotificationSettings)
async def get_notification_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user notification settings"""
    try:
        notification_service = NotificationService(db)

        settings = await notification_service.get_user_notification_settings(
            user_id=current_user.user_id
        )

        return settings
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get notification settings: {str(e)}")

@router.put("/settings")
async def update_notification_settings(
    settings: NotificationSettings,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user notification settings"""
    try:
        notification_service = NotificationService(db)

        success = await notification_service.update_user_notification_settings(
            user_id=current_user.user_id,
            settings=settings.dict()
        )

        if not success:
            raise HTTPException(status_code=500, detail="Failed to update notification settings")

        return {"message": "Notification settings updated"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update notification settings: {str(e)}")

# FCM token management
@router.post("/device-token")
async def register_device_token(
    token: str,
    device_type: str = Query(..., description="Device type (ios/android)"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Register FCM device token for push notifications"""
    try:
        notification_service = NotificationService(db)

        success = await notification_service.register_device_token(
            user_id=current_user.user_id,
            token=token,
            device_type=device_type
        )

        if not success:
            raise HTTPException(status_code=500, detail="Failed to register device token")

        return {"message": "Device token registered"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to register device token: {str(e)}")
