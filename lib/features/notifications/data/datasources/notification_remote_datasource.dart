import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../models/notification_model.dart';

/// Remote datasource for notification operations
class NotificationRemoteDataSource {
  final ApiService _apiService;
  final LoggerService _logger;

  static const String _notificationsKey = 'cached_notifications';
  static const String _lastSyncKey = 'notifications_last_sync';

  NotificationRemoteDataSource(this._apiService, this._logger);

  /// Fetch notifications from backend
  Future<List<NotificationModel>> fetchNotifications({
    int page = 1,
    int limit = 50,
    String? userId,
    NotificationType? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['user_id'] = userId;
      if (type != null) queryParams['type'] = type.name;
      if (isRead != null) queryParams['is_read'] = isRead.toString();

      final response = await _apiService.get(
        '/api/v1/notifications',
        queryParameters: queryParams,
      );

      final notifications = (response['data'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      _logger.info('Fetched ${notifications.length} notifications from backend');
      return notifications;
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch notifications from backend', e, stackTrace);
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.patch('/api/v1/notifications/$notificationId/read');
      _logger.info('Marked notification $notificationId as read');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notification as read', e, stackTrace);
      return false;
    }
  }

  /// Mark multiple notifications as read
  Future<bool> markNotificationsAsRead(List<String> notificationIds) async {
    try {
      await _apiService.patch('/api/v1/notifications/read', {
        'notification_ids': notificationIds,
      });
      _logger.info('Marked ${notificationIds.length} notifications as read');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notifications as read', e, stackTrace);
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _apiService.delete('/api/v1/notifications/$notificationId');
      _logger.info('Deleted notification $notificationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete notification', e, stackTrace);
      return false;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final settingsJson = settings.toJson();
      await _apiService.put('/api/v1/users/notification-settings', settingsJson);
      _logger.info('Updated notification settings');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update notification settings', e, stackTrace);
      return false;
    }
  }

  /// Get notification settings
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final response = await _apiService.get('/api/v1/users/notification-settings');
      final settings = NotificationSettings.fromJson(response['data']);
      _logger.info('Fetched notification settings');
      return settings;
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification settings', e, stackTrace);
      return null;
    }
  }

  /// Register device token
  Future<bool> registerDeviceToken(String token, String deviceType) async {
    try {
      await _apiService.post('/api/v1/users/device-token', {
        'token': token,
        'device_type': deviceType,
      });
      _logger.info('Registered device token');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to register device token', e, stackTrace);
      return false;
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (userId != null) queryParams['user_id'] = userId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/api/v1/notifications/statistics',
        queryParameters: queryParams,
      );

      _logger.info('Fetched notification statistics');
      return response['data'];
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification statistics', e, stackTrace);
      return {};
    }
  }
}

/// Local datasource for caching notifications
class NotificationLocalDataSource {
  final LoggerService _logger;

  static const String _notificationsKey = 'cached_notifications';
  static const String _settingsKey = 'notification_settings';
  static const String _lastSyncKey = 'notifications_last_sync';

  NotificationLocalDataSource(this._logger);

  /// Cache notifications locally
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(notificationsJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      _logger.info('Cached ${notifications.length} notifications locally');
    } catch (e, stackTrace) {
      _logger.error('Failed to cache notifications', e, stackTrace);
    }
  }

  /// Get cached notifications
  Future<List<NotificationModel>> getCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_notificationsKey);
      if (notificationsJson != null) {
        final notifications = (jsonDecode(notificationsJson) as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        _logger.info('Retrieved ${notifications.length} cached notifications');
        return notifications;
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to get cached notifications', e, stackTrace);
    }
    return [];
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_lastSyncKey);
      if (timestampStr != null) {
        return DateTime.parse(timestampStr);
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to get last sync timestamp', e, stackTrace);
    }
    return null;
  }

  /// Cache notification settings
  Future<void> cacheNotificationSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
      _logger.info('Cached notification settings locally');
    } catch (e, stackTrace) {
      _logger.error('Failed to cache notification settings', e, stackTrace);
    }
  }

  /// Get cached notification settings
  Future<NotificationSettings?> getCachedNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final settings = NotificationSettings.fromJson(jsonDecode(settingsJson));
        _logger.info('Retrieved cached notification settings');
        return settings;
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to get cached notification settings', e, stackTrace);
    }
    return null;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);
      await prefs.remove(_settingsKey);
      await prefs.remove(_lastSyncKey);
      _logger.info('Cleared notification cache');
    } catch (e, stackTrace) {
      _logger.error('Failed to clear notification cache', e, stackTrace);
    }
  }

  /// Add single notification to cache
  Future<void> addNotificationToCache(NotificationModel notification) async {
    try {
      final cached = await getCachedNotifications();
      cached.removeWhere((n) => n.id == notification.id); // Remove if exists
      cached.add(notification);
      await cacheNotifications(cached);
      _logger.info('Added notification ${notification.id} to cache');
    } catch (e, stackTrace) {
      _logger.error('Failed to add notification to cache', e, stackTrace);
    }
  }

  /// Update notification in cache
  Future<void> updateNotificationInCache(NotificationModel notification) async {
    try {
      final cached = await getCachedNotifications();
      final index = cached.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        cached[index] = notification;
        await cacheNotifications(cached);
        _logger.info('Updated notification ${notification.id} in cache');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to update notification in cache', e, stackTrace);
    }
  }

  /// Remove notification from cache
  Future<void> removeNotificationFromCache(String notificationId) async {
    try {
      final cached = await getCachedNotifications();
      cached.removeWhere((n) => n.id == notificationId);
      await cacheNotifications(cached);
      _logger.info('Removed notification $notificationId from cache');
    } catch (e, stackTrace) {
      _logger.error('Failed to remove notification from cache', e, stackTrace);
    }
  }
}
