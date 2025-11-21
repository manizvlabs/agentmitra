import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/services/logger_service.dart';

/// Local data source for notifications
class NotificationLocalDataSource {
  final LoggerService _logger;
  final Connectivity _connectivity;

  static const String _notificationsKey = 'notifications';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _lastSyncKey = 'notifications_last_sync';

  NotificationLocalDataSource(this._logger, this._connectivity);

  /// Get stored notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson == null) return [];

      final notifications = jsonDecode(notificationsJson) as List;
      return notifications.cast<Map<String, dynamic>>();
    } catch (e) {
      _logger.error('Failed to get stored notifications', e);
      return [];
    }
  }

  /// Save notifications locally
  Future<void> saveNotifications(List<Map<String, dynamic>> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationsKey, jsonEncode(notifications));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      _logger.error('Failed to save notifications locally', e);
    }
  }

  /// Add single notification
  Future<void> addNotification(Map<String, dynamic> notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification); // Add to beginning
    await saveNotifications(notifications);
  }

  /// Update notification
  Future<void> updateNotification(String notificationId, Map<String, dynamic> updates) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n['id'] == notificationId);

    if (index != -1) {
      notifications[index] = {...notifications[index], ...updates};
      await saveNotifications(notifications);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n['id'] == notificationId);
    await saveNotifications(notifications);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await updateNotification(notificationId, {'isRead': true, 'readAt': DateTime.now().toIso8601String()});
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !(n['isRead'] ?? false)).length;
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_lastSyncKey);
    return timestampStr != null ? DateTime.parse(timestampStr) : null;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
