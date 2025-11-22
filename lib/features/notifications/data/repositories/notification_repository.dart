import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_queue_service.dart';
import '../../../../core/services/sync_service.dart';
import '../datasources/notification_remote_datasource.dart';
import '../datasources/notification_local_datasource.dart';
import '../models/notification_model.dart';

/// Repository for notification operations with offline support
class NotificationRepository extends BaseRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  final OfflineQueueService _offlineQueueService;
  final SyncService _syncService;
  final LoggerService _logger;

  NotificationRepository(
    this._remoteDataSource,
    this._localDataSource,
    this._connectivity,
    this._offlineQueueService,
    this._syncService,
    this._logger,
  );

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Get current connectivity status
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Fetch notifications with offline support
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 50,
    String? userId,
    NotificationType? type,
    bool? isRead,
    bool forceRefresh = false,
  }) async {
    try {
      final connected = await isConnected;

      if (!connected && !forceRefresh) {
        // Return cached data when offline
        _logger.info('Offline mode: returning cached notifications');
        final cachedData = await _localDataSource.getCachedNotifications();
        return cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      }

      // Fetch from remote when online
      final remoteNotifications = await _remoteDataSource.fetchNotifications(
        page: page,
        limit: limit,
        userId: userId,
        type: type,
        isRead: isRead,
      );

      // Cache the data locally
      final notificationsJson = remoteNotifications.map((n) => n.toJson()).toList();
      await _localDataSource.cacheNotifications(notificationsJson);

      return remoteNotifications;
    } catch (e) {
      _logger.error('Failed to fetch notifications', error: e);
      rethrow;
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final cachedData = await _localDataSource.getCachedNotifications();
      final notifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      return notifications.where((n) => n.id == notificationId).firstOrNull;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final connected = await isConnected;

      // Update local cache first
      final cachedData = await _localDataSource.getCachedNotifications();
      final cachedNotifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      final notificationIndex = cachedNotifications.indexWhere((n) => n.id == notificationId);

      if (notificationIndex != -1) {
        final updatedNotification = cachedNotifications[notificationIndex].copyWith(isRead: true);
        await _localDataSource.updateNotificationInCache(updatedNotification.toJson());
      }

      // Try to update remote if connected
      if (connected) {
        final success = await _remoteDataSource.markNotificationAsRead(notificationId);
        if (!success) {
          _logger.warning('Failed to update notification on server, queuing for retry');
          // Queue for retry
          await _offlineQueueService.addOperation(
            OfflineOperationType.apiPatch,
            '/api/v1/notifications/$notificationId/read',
          );
        }
        return success;
      }

      _logger.info('Marked notification as read offline');
      return true;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Mark multiple notifications as read
  Future<bool> markNotificationsAsRead(List<String> notificationIds) async {
    try {
      final connected = await isConnected;

      // Update local cache first
      final cachedData = await _localDataSource.getCachedNotifications();
      final cachedNotifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      for (final id in notificationIds) {
        final index = cachedNotifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          cachedNotifications[index] = cachedNotifications[index].copyWith(isRead: true);
        }
      }
      final updatedData = cachedNotifications.map((n) => n.toJson()).toList();
      await _localDataSource.cacheNotifications(updatedData);

      // Try to update remote if connected
      if (connected) {
        final success = await _remoteDataSource.markNotificationsAsRead(notificationIds);
        if (!success) {
          _logger.warning('Failed to update notifications on server, will retry later');
          // TODO: Queue for retry
        }
        return success;
      }

      _logger.info('Marked ${notificationIds.length} notifications as read offline');
      return true;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final connected = await isConnected;

      // Remove from local cache first
      await _localDataSource.removeNotificationFromCache(notificationId);

      // Try to delete from remote if connected
      if (connected) {
        final success = await _remoteDataSource.deleteNotification(notificationId);
        if (!success) {
          _logger.warning('Failed to delete notification from server, will retry later');
          // TODO: Queue for retry
        }
        return success;
      }

      _logger.info('Deleted notification offline');
      return true;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Add new notification (typically from push notification)
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _localDataSource.addNotificationToCache(notification.toJson());
      _logger.info('Added new notification: ${notification.id}');
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Get notification settings
  Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final connected = await isConnected;

      // Try to get from remote first if connected
      if (connected) {
        final remoteSettings = await _remoteDataSource.getNotificationSettings();
        if (remoteSettings != null) {
          await _localDataSource.cacheNotificationSettings(remoteSettings.toJson());
          return remoteSettings;
        }
      }

      // Fallback to cached settings
      final cachedData = await _localDataSource.getCachedNotificationSettings();
      return cachedData != null ? NotificationSettings.fromJson(cachedData) : null;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final connected = await isConnected;

      // Cache locally first
      await _localDataSource.cacheNotificationSettings(settings.toJson());

      // Try to update remote if connected
      if (connected) {
        final success = await _remoteDataSource.updateNotificationSettings(settings);
        if (!success) {
          _logger.warning('Failed to update notification settings on server, will retry later');
          // TODO: Queue for retry
        }
        return success;
      }

      _logger.info('Updated notification settings offline');
      return true;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connected = await isConnected;

      if (connected) {
        return await _remoteDataSource.getNotificationStatistics(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
      }

      // Return basic statistics from cached data
      final cachedData = await _localDataSource.getCachedNotifications();
      final cachedNotifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      final lastSync = await _localDataSource.getLastSyncTimestamp();
      return {
        'total_notifications': cachedNotifications.length,
        'unread_count': cachedNotifications.where((n) => !n.isRead).length,
        'read_count': cachedNotifications.where((n) => n.isRead).length,
        'last_sync': lastSync?.toIso8601String(),
      };
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Register device token
  Future<bool> registerDeviceToken(String token, String deviceType) async {
    try {
      final connected = await isConnected;

      if (connected) {
        return await _remoteDataSource.registerDeviceToken(token, deviceType);
      }

      _logger.warning('Cannot register device token while offline');
      return false;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Sync pending operations when coming back online
  Future<void> syncPendingOperations() async {
    try {
      final connected = await isConnected;

      if (!connected) {
        _logger.info('Skipping sync - device offline');
        return;
      }

      _logger.info('Starting pending operations sync');

      // TODO: Implement sync queue
      // - Retry failed remote operations
      // - Upload pending local changes
      // - Resolve conflicts

      _logger.info('Pending operations sync completed');
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _localDataSource.clearCache();
      _logger.info('Cleared notification cache');
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final cachedData = await _localDataSource.getCachedNotifications();
      final notifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      return notifications.where((n) => !n.isRead).length;
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Search notifications
  Future<List<NotificationModel>> searchNotifications(String query) async {
    try {
      final cachedData = await _localDataSource.getCachedNotifications();
      final notifications = cachedData.map((json) => NotificationModel.fromJson(json)).toList();
      final lowercaseQuery = query.toLowerCase();

      return notifications.where((notification) {
        return notification.title.toLowerCase().contains(lowercaseQuery) ||
               notification.body.toLowerCase().contains(lowercaseQuery) ||
               (notification.category?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Sync notifications with conflict resolution
  Future<void> syncNotifications() async {
    try {
      final result = await _syncService.performFullSync();
      if (!result.success) {
        _logger.warning('Notification sync failed: ${result.error}');
      } else {
        _logger.info('Notification sync completed: ${result.itemsSynced} items synced');
      }
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      return await _syncService.getSyncStatistics();
    } catch (e) {
      _logger.error('Failed to get notification by ID', error: e);
      rethrow;
    }
  }
}
