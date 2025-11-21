import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// Notification list widget with pull-to-refresh support
class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Future<void> Function()? onRefresh;
  final bool isRefreshing;
  final String emptyMessage;
  final Function(String)? onMarkAsRead;
  final Function(String)? onDelete;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onRefresh,
    this.isRefreshing = false,
    this.emptyMessage = 'No notifications',
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    final groupedNotifications = _groupNotificationsByDate(notifications);

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final entry = groupedNotifications.entries.elementAt(index);
          return _buildNotificationGroup(context, entry.key, entry.value);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(
    BuildContext context,
    String dateLabel,
    List<NotificationModel> groupNotifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Notifications in this group
        ...groupNotifications.map(
          (notification) => NotificationListItem(
            notification: notification,
            onMarkAsRead: onMarkAsRead,
            onDelete: onDelete,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final groups = <String, List<NotificationModel>>{};
    final now = DateTime.now();

    for (final notification in notifications) {
      final difference = now.difference(notification.timestamp);
      String groupKey;

      if (difference.inDays == 0) {
        groupKey = 'Today';
      } else if (difference.inDays == 1) {
        groupKey = 'Yesterday';
      } else if (difference.inDays < 7) {
        groupKey = '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        groupKey = '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else {
        groupKey = '${notification.timestamp.month}/${notification.timestamp.year}';
      }

      groups.putIfAbsent(groupKey, () => []).add(notification);
    }

    return groups;
  }
}

/// Individual notification list item
class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final Function(String)? onMarkAsRead;
  final Function(String)? onDelete;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call(notification.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // TODO: Implement undo functionality
                },
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: notification.isRead ? 0 : 2,
        child: InkWell(
          onTap: () => _handleNotificationTap(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: notification.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    notification.typeIcon,
                    color: notification.typeColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),

                          // Unread indicator
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        notification.body,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            notification.displayTimestamp,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),

                          if (notification.hasAction) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                notification.actionText ?? 'Action',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action indicator
                if (notification.hasAction)
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context) {
    // Mark as read if not already
    if (!notification.isRead) {
      onMarkAsRead?.call(notification.id);
    }

    // Handle action if available
    if (notification.actionRoute != null) {
      // Navigate to route
      Navigator.of(context).pushNamed(notification.actionRoute!);
    } else if (notification.actionUrl != null) {
      // Handle URL (could use url_launcher)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening: ${notification.actionUrl}')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
