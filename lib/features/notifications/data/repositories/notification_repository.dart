import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_queue_service.dart';
import '../../../../core/services/sync_service.dart';
import '../datasources/notification_remote_datasource.dart';
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
    return executeAsync(() async {
      final connected = await isConnected;

      if (!connected && !forceRefresh) {
        // Return cached data when offline
        _logger.info('Offline mode: returning cached notifications');
        return await _localDataSource.getCachedNotifications();
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
      await _localDataSource.cacheNotifications(remoteNotifications);

      return remoteNotifications;
    });
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    return executeAsync(() async {
      final notifications = await _localDataSource.getCachedNotifications();
      return notifications.where((n) => n.id == notificationId).firstOrNull;
    });
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    return executeAsync(() async {
      final connected = await isConnected;

      // Update local cache first
      final cachedNotifications = await _localDataSource.getCachedNotifications();
      final notificationIndex = cachedNotifications.indexWhere((n) => n.id == notificationId);

      if (notificationIndex != -1) {
        final updatedNotification = cachedNotifications[notificationIndex].copyWith(isRead: true);
        await _localDataSource.updateNotificationInCache(updatedNotification);
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
    });
  }

  /// Mark multiple notifications as read
  Future<bool> markNotificationsAsRead(List<String> notificationIds) async {
    return executeAsync(() async {
      final connected = await isConnected;

      // Update local cache first
      final cachedNotifications = await _localDataSource.getCachedNotifications();
      for (final id in notificationIds) {
        final index = cachedNotifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          cachedNotifications[index] = cachedNotifications[index].copyWith(isRead: true);
        }
      }
      await _localDataSource.cacheNotifications(cachedNotifications);

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
    });
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    return executeAsync(() async {
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
    });
  }

  /// Add new notification (typically from push notification)
  Future<void> addNotification(NotificationModel notification) async {
    return executeAsync(() async {
      await _localDataSource.addNotificationToCache(notification);
      _logger.info('Added new notification: ${notification.id}');
    });
  }

  /// Get notification settings
  Future<NotificationSettings?> getNotificationSettings() async {
    return executeAsync(() async {
      final connected = await isConnected;

      // Try to get from remote first if connected
      if (connected) {
        final remoteSettings = await _remoteDataSource.getNotificationSettings();
        if (remoteSettings != null) {
          await _localDataSource.cacheNotificationSettings(remoteSettings);
          return remoteSettings;
        }
      }

      // Fallback to cached settings
      return await _localDataSource.getCachedNotificationSettings();
    });
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    return executeAsync(() async {
      final connected = await isConnected;

      // Cache locally first
      await _localDataSource.cacheNotificationSettings(settings);

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
    });
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return executeAsync(() async {
      final connected = await isConnected;

      if (connected) {
        return await _remoteDataSource.getNotificationStatistics(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
      }

      // Return basic statistics from cached data
      final cachedNotifications = await _localDataSource.getCachedNotifications();
      return {
        'total_notifications': cachedNotifications.length,
        'unread_count': cachedNotifications.where((n) => !n.isRead).length,
        'read_count': cachedNotifications.where((n) => n.isRead).length,
        'last_sync': await _localDataSource.getLastSyncTimestamp()?.toIso8601String(),
      };
    });
  }

  /// Register device token
  Future<bool> registerDeviceToken(String token, String deviceType) async {
    return executeAsync(() async {
      final connected = await isConnected;

      if (connected) {
        return await _remoteDataSource.registerDeviceToken(token, deviceType);
      }

      _logger.warning('Cannot register device token while offline');
      return false;
    });
  }

  /// Sync pending operations when coming back online
  Future<void> syncPendingOperations() async {
    return executeAsync(() async {
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
    });
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    return executeAsync(() async {
      await _localDataSource.clearCache();
      _logger.info('Cleared notification cache');
    });
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    return executeAsync(() async {
      final notifications = await _localDataSource.getCachedNotifications();
      return notifications.where((n) => !n.isRead).length;
    });
  }

  /// Search notifications
  Future<List<NotificationModel>> searchNotifications(String query) async {
    return executeAsync(() async {
      final notifications = await _localDataSource.getCachedNotifications();
      final lowercaseQuery = query.toLowerCase();

      return notifications.where((notification) {
        return notification.title.toLowerCase().contains(lowercaseQuery) ||
               notification.body.toLowerCase().contains(lowercaseQuery) ||
               (notification.category?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();
    });
  }

  /// Sync notifications with conflict resolution
  Future<void> syncNotifications() async {
    return executeAsync(() async {
      final result = await _syncService.performFullSync();
      if (!result.success) {
        _logger.warning('Notification sync failed: ${result.error}');
      } else {
        _logger.info('Notification sync completed: ${result.itemsSynced} items synced');
      }
    });
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    return executeAsync(() async {
      return await _syncService.getSyncStatistics();
    });
  }
}
