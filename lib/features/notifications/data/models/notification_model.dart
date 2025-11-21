import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Notification model for push notifications and in-app notifications
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String body,
    required DateTime timestamp,
    required NotificationType type,
    required NotificationPriority priority,
    @Default(false) bool isRead,
    String? actionUrl,
    String? actionRoute,
    String? actionText,
    String? imageUrl,
    Map<String, dynamic>? data,
    String? senderId,
    String? category,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  const NotificationModel._();

  /// Computed properties
  Color get typeColor => type.color;
  IconData get typeIcon => type.icon;

  /// Check if notification is recent (within last 24 hours)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;

  /// Check if notification has action
  bool get hasAction => actionUrl != null || actionRoute != null;

  /// Get display timestamp
  String get displayTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Notification types with associated icons and colors
enum NotificationType {
  policy('Policy Updates', Icons.assignment, Colors.blue),
  payment('Payment Reminders', Icons.payment, Colors.green),
  claim('Claim Status', Icons.healing, Colors.orange),
  renewal('Renewal Notices', Icons.refresh, Colors.purple),
  general('General', Icons.notifications, Colors.grey),
  marketing('Marketing', Icons.campaign, Colors.teal),
  system('System', Icons.settings, Colors.red);

  const NotificationType(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}

/// Notification priority levels
enum NotificationPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const NotificationPriority(this.displayName);

  final String displayName;

  /// Get priority color
  Color get color {
    switch (this) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.critical:
        return Colors.red;
    }
  }

  /// Get priority icon
  IconData get icon {
    switch (this) {
      case NotificationPriority.low:
        return Icons.info_outline;
      case NotificationPriority.medium:
        return Icons.info;
      case NotificationPriority.high:
        return Icons.warning;
      case NotificationPriority.critical:
        return Icons.error;
    }
  }
}

/// Notification settings model
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    @Default(true) bool enablePushNotifications,
    @Default(true) bool enablePolicyNotifications,
    @Default(true) bool enablePaymentReminders,
    @Default(true) bool enableClaimUpdates,
    @Default(true) bool enableRenewalNotices,
    @Default(false) bool enableMarketingNotifications,
    @Default(true) bool enableSound,
    @Default(true) bool enableVibration,
    @Default(true) bool showBadge,
    @Default(false) bool quietHoursEnabled,
    String? quietHoursStart, // HH:MM format
    String? quietHoursEnd,   // HH:MM format
    @Default(['en']) List<String> enabledTopics,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  const NotificationSettings._();

  /// Check if notifications should be shown at current time
  bool shouldShowNotification() {
    if (!quietHoursEnabled || quietHoursStart == null || quietHoursEnd == null) {
      return true;
    }

    final now = TimeOfDay.now();
    return !_isTimeInRange(now, quietHoursStart!, quietHoursEnd!);
  }

  /// Check if time is within quiet hours range
  bool _isTimeInRange(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // Same day range
      return timeMinutes >= startMinutes && timeMinutes <= endMinutes;
    } else {
      // Overnight range
      return timeMinutes >= startMinutes || timeMinutes <= endMinutes;
    }
  }
}

/// Notification history model
@freezed
class NotificationHistory with _$NotificationHistory {
  const factory NotificationHistory({
    required List<NotificationModel> notifications,
    required DateTime lastSync,
    @Default(0) int totalCount,
    @Default(0) int unreadCount,
  }) = _NotificationHistory;

  factory NotificationHistory.fromJson(Map<String, dynamic> json) =>
      _$NotificationHistoryFromJson(json);

  const NotificationHistory._();

  /// Get notifications sorted by timestamp (newest first)
  List<NotificationModel> get sortedNotifications =>
      notifications..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  /// Get recent notifications (last 7 days)
  List<NotificationModel> get recentNotifications =>
      notifications.where((n) => n.isRecent).toList();

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();
}
