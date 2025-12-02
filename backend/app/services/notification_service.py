from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import json
import uuid
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_, desc

from ..models.notification import Notification, NotificationSettings, DeviceToken
from ..core.logger import logger

class NotificationService:
    def __init__(self, db: Session):
        self.db = db

    async def get_user_notifications(
        self,
        user_id: str,
        tenant_id: Optional[str] = None,
        page: int = 1,
        limit: int = 50,
        type_filter: Optional[str] = None,
        priority_filter: Optional[str] = None,
        is_read: Optional[bool] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> List[Dict[str, Any]]:
        """Get user notifications with filtering and pagination"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            query = self.db.query(Notification).filter(
                Notification.user_id == user_id,
                Notification.tenant_id == tenant_filter
            )

            # Apply filters
            if type_filter:
                query = query.filter(Notification.type == type_filter)

            if priority_filter:
                query = query.filter(Notification.priority == priority_filter)

            if is_read is not None:
                query = query.filter(Notification.is_read == is_read)

            if start_date:
                query = query.filter(Notification.created_at >= start_date)

            if end_date:
                query = query.filter(Notification.created_at <= end_date)

            # Order by creation date (newest first)
            query = query.order_by(desc(Notification.created_at))

            # Apply pagination
            offset = (page - 1) * limit
            notifications = query.offset(offset).limit(limit).all()

            # Convert to dict format
            result = []
            for notification in notifications:
                result.append({
                    "id": str(notification.id),
                    "user_id": str(notification.user_id),
                    "title": notification.title,
                    "body": notification.body,
                    "type": notification.type,
                    "priority": notification.priority,
                    "is_read": notification.is_read,
                    "action_url": notification.action_url,
                    "action_route": notification.action_route,
                    "action_text": notification.action_text,
                    "image_url": notification.image_url,
                    "data": notification.data,
                    "created_at": notification.created_at,
                    "read_at": notification.read_at,
                })

            logger.info(f"Retrieved {len(result)} notifications for user {user_id}")
            return result

        except Exception as e:
            logger.error(f"Failed to get user notifications: {str(e)}")
            raise

    async def get_notification_by_id(self, notification_id: str, user_id: str, tenant_id: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Get a specific notification by ID"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            notification = self.db.query(Notification).filter(
                and_(
                    Notification.id == notification_id,
                    Notification.user_id == user_id,
                    Notification.tenant_id == tenant_filter
                )
            ).first()

            if not notification:
                return None

            return {
                "id": str(notification.id),
                "user_id": str(notification.user_id),
                "title": notification.title,
                "body": notification.body,
                "type": notification.type,
                "priority": notification.priority,
                "is_read": notification.is_read,
                "action_url": notification.action_url,
                "action_route": notification.action_route,
                "action_text": notification.action_text,
                "image_url": notification.image_url,
                "data": notification.data,
                "created_at": notification.created_at,
                "read_at": notification.read_at,
            }

        except Exception as e:
            logger.error(f"Failed to get notification by ID: {str(e)}")
            raise

    async def create_notification(
        self,
        user_id: str,
        title: str,
        body: str,
        type: str,
        priority: str = "medium",
        tenant_id: Optional[str] = None,
        action_url: Optional[str] = None,
        action_route: Optional[str] = None,
        action_text: Optional[str] = None,
        image_url: Optional[str] = None,
        data: Optional[Dict[str, Any]] = None,
        scheduled_at: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """Create a new notification"""
        try:
            notification_id = str(uuid.uuid4())

            notification = Notification(
                id=notification_id,
                user_id=user_id,
                title=title,
                body=body,
                type=type,
                priority=priority,
                tenant_id=tenant_id or '00000000-0000-0000-0000-000000000000',  # Default tenant
                is_read=False,
                action_url=action_url,
                action_route=action_route,
                action_text=action_text,
                image_url=image_url,
                data=data or {},
                created_at=datetime.utcnow(),
                scheduled_at=scheduled_at
            )

            self.db.add(notification)
            self.db.commit()
            self.db.refresh(notification)

            result = {
                "id": str(notification.id),
                "user_id": str(notification.user_id),
                "title": notification.title,
                "body": notification.body,
                "type": notification.type,
                "priority": notification.priority,
                "is_read": notification.is_read,
                "action_url": notification.action_url,
                "action_route": notification.action_route,
                "action_text": notification.action_text,
                "image_url": notification.image_url,
                "data": notification.data,
                "created_at": notification.created_at,
                "scheduled_at": notification.scheduled_at,
            }

            logger.info(f"Created notification {notification_id} for user {user_id}")
            return result

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to create notification: {str(e)}")
            raise

    async def mark_notification_read(self, notification_id: str, user_id: str, tenant_id: Optional[str] = None) -> bool:
        """Mark a notification as read"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            notification = self.db.query(Notification).filter(
                and_(
                    Notification.id == notification_id,
                    Notification.user_id == user_id,
                    Notification.tenant_id == tenant_filter
                )
            ).first()

            if not notification:
                return False

            if not notification.is_read:
                notification.is_read = True
                notification.read_at = datetime.utcnow()
                self.db.commit()

            logger.info(f"Marked notification {notification_id} as read for user {user_id}")
            return True

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to mark notification as read: {str(e)}")
            raise

    async def mark_notifications_read(self, notification_ids: List[str], user_id: str, tenant_id: Optional[str] = None) -> int:
        """Mark multiple notifications as read"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            updated_count = self.db.query(Notification).filter(
                and_(
                    Notification.id.in_(notification_ids),
                    Notification.user_id == user_id,
                    Notification.tenant_id == tenant_filter,
                    Notification.is_read == False
                )
            ).update({
                "is_read": True,
                "read_at": datetime.utcnow()
            })

            self.db.commit()

            logger.info(f"Marked {updated_count} notifications as read for user {user_id}")
            return updated_count

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to mark notifications as read: {str(e)}")
            raise

    async def delete_notification(self, notification_id: str, user_id: str, tenant_id: Optional[str] = None) -> bool:
        """Delete a notification"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            deleted_count = self.db.query(Notification).filter(
                and_(
                    Notification.id == notification_id,
                    Notification.user_id == user_id,
                    Notification.tenant_id == tenant_filter
                )
            ).delete()

            self.db.commit()

            success = deleted_count > 0
            if success:
                logger.info(f"Deleted notification {notification_id} for user {user_id}")

            return success

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to delete notification: {str(e)}")
            raise

    async def get_user_notification_statistics(
        self,
        user_id: str,
        tenant_id: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> Dict[str, Any]:
        """Get notification statistics for a user"""
        try:
            tenant_filter = tenant_id if tenant_id else '00000000-0000-0000-0000-000000000000'
            query = self.db.query(Notification).filter(
                Notification.user_id == user_id,
                Notification.tenant_id == tenant_filter
            )

            if start_date:
                query = query.filter(Notification.created_at >= start_date)

            if end_date:
                query = query.filter(Notification.created_at <= end_date)

            # Get basic counts
            total_notifications = query.count()
            unread_count = query.filter(Notification.is_read == False).count()
            read_count = total_notifications - unread_count

            # Get notifications by type
            type_stats = self.db.query(
                Notification.type,
                func.count(Notification.id)
            ).filter(Notification.user_id == user_id).group_by(Notification.type).all()

            notifications_by_type = {type_name: count for type_name, count in type_stats}

            # Get notifications by priority
            priority_stats = self.db.query(
                Notification.priority,
                func.count(Notification.id)
            ).filter(Notification.user_id == user_id).group_by(Notification.priority).all()

            notifications_by_priority = {priority: count for priority, count in priority_stats}

            # Get recent activity (last 10 notifications)
            recent_notifications = self.db.query(Notification).filter(
                Notification.user_id == user_id
            ).order_by(desc(Notification.created_at)).limit(10).all()

            recent_activity = []
            for notification in recent_notifications:
                recent_activity.append({
                    "id": str(notification.id),
                    "title": notification.title,
                    "type": notification.type,
                    "is_read": notification.is_read,
                    "created_at": notification.created_at,
                })

            return {
                "total_notifications": total_notifications,
                "unread_count": unread_count,
                "read_count": read_count,
                "notifications_by_type": notifications_by_type,
                "notifications_by_priority": notifications_by_priority,
                "recent_activity": recent_activity,
            }

        except Exception as e:
            logger.error(f"Failed to get notification statistics: {str(e)}")
            raise

    async def get_user_notification_settings(self, user_id: str, tenant_id: Optional[str] = None) -> Dict[str, Any]:
        """Get user notification settings"""
        try:
            settings = self.db.query(NotificationSettings).filter(
                NotificationSettings.user_id == user_id
            ).first()

            if not settings:
                # Return default settings
                return {
                    "enable_push_notifications": True,
                    "enable_policy_notifications": True,
                    "enable_payment_reminders": True,
                    "enable_claim_updates": True,
                    "enable_renewal_notices": True,
                    "enable_marketing_notifications": False,
                    "enable_sound": True,
                    "enable_vibration": True,
                    "show_badge": True,
                    "quiet_hours_enabled": False,
                    "quiet_hours_start": None,
                    "quiet_hours_end": None,
                    "enabled_topics": ["general", "policies", "payments"],
                }

            return {
                "enable_push_notifications": settings.enable_push_notifications,
                "enable_policy_notifications": settings.enable_policy_notifications,
                "enable_payment_reminders": settings.enable_payment_reminders,
                "enable_claim_updates": settings.enable_claim_updates,
                "enable_renewal_notices": settings.enable_renewal_notices,
                "enable_marketing_notifications": settings.enable_marketing_notifications,
                "enable_sound": settings.enable_sound,
                "enable_vibration": settings.enable_vibration,
                "show_badge": settings.show_badge,
                "quiet_hours_enabled": settings.quiet_hours_enabled,
                "quiet_hours_start": settings.quiet_hours_start,
                "quiet_hours_end": settings.quiet_hours_end,
                "enabled_topics": settings.enabled_topics or [],
            }

        except Exception as e:
            logger.error(f"Failed to get notification settings: {str(e)}")
            raise

    async def update_user_notification_settings(self, user_id: str, settings: Dict[str, Any]) -> bool:
        """Update user notification settings"""
        try:
            existing_settings = self.db.query(NotificationSettings).filter(
                NotificationSettings.user_id == user_id
            ).first()

            if existing_settings:
                # Update existing settings
                for key, value in settings.items():
                    if hasattr(existing_settings, key):
                        setattr(existing_settings, key, value)
            else:
                # Create new settings
                new_settings = NotificationSettings(
                    user_id=user_id,
                    enable_push_notifications=settings.get("enable_push_notifications", True),
                    enable_policy_notifications=settings.get("enable_policy_notifications", True),
                    enable_payment_reminders=settings.get("enable_payment_reminders", True),
                    enable_claim_updates=settings.get("enable_claim_updates", True),
                    enable_renewal_notices=settings.get("enable_renewal_notices", True),
                    enable_marketing_notifications=settings.get("enable_marketing_notifications", False),
                    enable_sound=settings.get("enable_sound", True),
                    enable_vibration=settings.get("enable_vibration", True),
                    show_badge=settings.get("show_badge", True),
                    quiet_hours_enabled=settings.get("quiet_hours_enabled", False),
                    quiet_hours_start=settings.get("quiet_hours_start"),
                    quiet_hours_end=settings.get("quiet_hours_end"),
                    enabled_topics=settings.get("enabled_topics", ["general", "policies", "payments"]),
                )
                self.db.add(new_settings)

            self.db.commit()
            logger.info(f"Updated notification settings for user {user_id}")
            return True

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to update notification settings: {str(e)}")
            raise

    async def register_device_token(self, user_id: str, token: str, device_type: str) -> bool:
        """Register FCM device token"""
        try:
            # Check if token already exists
            existing_token = self.db.query(DeviceToken).filter(
                and_(DeviceToken.token == token, DeviceToken.user_id == user_id)
            ).first()

            if existing_token:
                # Update last used timestamp
                existing_token.last_used_at = datetime.utcnow()
            else:
                # Create new token
                device_token = DeviceToken(
                    user_id=user_id,
                    token=token,
                    device_type=device_type,
                    created_at=datetime.utcnow(),
                    last_used_at=datetime.utcnow(),
                )
                self.db.add(device_token)

            self.db.commit()
            logger.info(f"Registered device token for user {user_id}")
            return True

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to register device token: {str(e)}")
            raise

    async def send_push_notification(self, notification: Dict[str, Any]) -> bool:
        """Send push notification via FCM"""
        try:
            # Get user device tokens
            device_tokens = self.db.query(DeviceToken).filter(
                DeviceToken.user_id == notification["user_id"]
            ).all()

            if not device_tokens:
                logger.warning(f"No device tokens found for user {notification['user_id']}")
                return False

            # TODO: Implement actual FCM sending logic
            # For now, just log the notification
            logger.info(f"Would send push notification to {len(device_tokens)} devices: {notification['title']}")

            # Placeholder for FCM integration
            # This would use firebase-admin SDK or similar to send to FCM

            return True

        except Exception as e:
            logger.error(f"Failed to send push notification: {str(e)}")
            return False

    async def send_bulk_push_notifications(self, notifications: List[Dict[str, Any]]) -> bool:
        """Send multiple push notifications"""
        try:
            success_count = 0
            for notification in notifications:
                if await self.send_push_notification(notification):
                    success_count += 1

            logger.info(f"Sent {success_count}/{len(notifications)} bulk push notifications")
            return success_count > 0

        except Exception as e:
            logger.error(f"Failed to send bulk push notifications: {str(e)}")
            return False

    async def cleanup_old_notifications(self, days_old: int = 30) -> int:
        """Clean up old read notifications"""
        try:
            cutoff_date = datetime.utcnow() - timedelta(days=days_old)

            deleted_count = self.db.query(Notification).filter(
                and_(
                    Notification.is_read == True,
                    Notification.created_at < cutoff_date
                )
            ).delete()

            self.db.commit()

            logger.info(f"Cleaned up {deleted_count} old notifications")
            return deleted_count

        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to cleanup old notifications: {str(e)}")
            raise
