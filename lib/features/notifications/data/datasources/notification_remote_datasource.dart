import '../../../../core/services/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../models/notification_model.dart';

/// Remote datasource for notification operations
class NotificationRemoteDataSource {
  final LoggerService _logger;

  NotificationRemoteDataSource(this._logger);

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

      final response = await ApiService.get(
        '/api/v1/notifications',
        queryParameters: queryParams,
      );

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      _logger.info('Fetched ${notifications.length} notifications from backend');
      return notifications;
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch notifications from backend', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await ApiService.patch('/api/v1/notifications/$notificationId/read', {});
      _logger.info('Marked notification $notificationId as read');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notification as read', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Mark multiple notifications as read
  Future<bool> markNotificationsAsRead(List<String> notificationIds) async {
    try {
      await ApiService.patch('/api/v1/notifications/read', {
        'notification_ids': notificationIds,
      });
      _logger.info('Marked ${notificationIds.length} notifications as read');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notifications as read', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await ApiService.delete('/api/v1/notifications/$notificationId');
      _logger.info('Deleted notification $notificationId');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to delete notification', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final settingsJson = settings.toJson();
      await ApiService.put('/api/v1/users/notification-settings', settingsJson);
      _logger.info('Updated notification settings');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to update notification settings', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Get notification settings
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final response = await ApiService.get('/api/v1/users/notification-settings');
      final settings = NotificationSettings.fromJson(response['data']);
      _logger.info('Fetched notification settings');
      return settings;
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification settings', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Register device token
  Future<bool> registerDeviceToken(String token, String deviceType) async {
    try {
      await ApiService.post('/api/v1/users/device-token', {
        'token': token,
        'device_type': deviceType,
      });
      _logger.info('Registered device token');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Failed to register device token', error: e, stackTrace: stackTrace);
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

      final response = await ApiService.get(
        '/api/v1/notifications/statistics',
        queryParameters: queryParams,
      );

      _logger.info('Fetched notification statistics');
      return response['data'];
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification statistics', error: e, stackTrace: stackTrace);
      return {};
    }
  }
}

/// Local datasource for caching notifications
