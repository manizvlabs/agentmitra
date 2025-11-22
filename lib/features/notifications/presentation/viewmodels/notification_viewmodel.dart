import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/offline_queue_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/datasources/notification_local_datasource.dart';
import '../../data/models/notification_model.dart';

/// ViewModel for notification management
class NotificationViewModel extends BaseViewModel {
  final NotificationRepository _repository;
  // final OfflineQueueService _offlineQueueService;
  final LoggerService _logger;

  NotificationViewModel([
    NotificationRepository? repository,
    OfflineQueueService? offlineQueueService,
    LoggerService? logger,
  ])  : _repository = repository ?? NotificationRepository(
          NotificationRemoteDataSource(logger ?? LoggerService()),
          NotificationLocalDataSource(LoggerService(), Connectivity()),
          Connectivity(),
          OfflineQueueService(LoggerService(), Connectivity()),
          SyncService(LoggerService(), Connectivity()),
          LoggerService(),
        ),
        // _offlineQueueService = offlineQueueService ?? OfflineQueueService(LoggerService(), Connectivity()),
        _logger = logger ?? LoggerService() {
    // Initialize with mock data for Phase 5 testing
    _initializeMockData();
  }

  // Notification data
  List<NotificationModel> _notifications = [];
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  NotificationSettings? get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  // Computed properties
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get totalCount => _notifications.length;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  List<NotificationModel> get recentNotifications =>
      _notifications.where((n) => n.isRecent).toList();

  // Search and filter
  String _searchQuery = '';
  NotificationType? _selectedType;
  bool? _showOnlyUnread;

  String get searchQuery => _searchQuery;
  NotificationType? get selectedType => _selectedType;
  bool? get showOnlyUnread => _showOnlyUnread;

  // Filtered notifications
  List<NotificationModel> get filteredNotifications {
    var filtered = _notifications;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((notification) {
        return notification.title.toLowerCase().contains(query) ||
               notification.body.toLowerCase().contains(query) ||
               (notification.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((n) => n.type == _selectedType).toList();
    }

    // Apply read status filter
    if (_showOnlyUnread == true) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadNotifications();
    await loadNotificationSettings();
  }

  /// Load notifications from repository
  Future<void> loadNotifications({bool forceRefresh = false}) async {
    if (!forceRefresh) _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(forceRefresh: forceRefresh);
      _logger.info('Loaded ${_notifications.length} notifications');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      _logger.error('Failed to load notifications', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await loadNotifications(forceRefresh: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Load notification settings
  Future<void> loadNotificationSettings() async {
    try {
      _notificationSettings = await _repository.getNotificationSettings();
      _logger.info('Loaded notification settings');
    } catch (e, stackTrace) {
      _logger.error('Failed to load notification settings', error: e, stackTrace: stackTrace);
      // Use default settings if loading fails
      _notificationSettings ??= const NotificationSettings();
    }
    notifyListeners();
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    final previousSettings = _notificationSettings;

    // Optimistically update UI
    _notificationSettings = settings;
    notifyListeners();

    try {
      final success = await _repository.updateNotificationSettings(settings);
      if (success) {
        _logger.info('Updated notification settings successfully');
        return true;
      } else {
        // Revert on failure
        _notificationSettings = previousSettings;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      // Revert on failure
      _notificationSettings = previousSettings;
      notifyListeners();
      _logger.error('Failed to update notification settings', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        // Optimistically update UI
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();

        final success = await _repository.markNotificationAsRead(notificationId);
        if (!success) {
          // Revert on failure
          _notifications[index] = _notifications[index].copyWith(isRead: false);
          notifyListeners();
          _logger.warning('Failed to mark notification as read on server');
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to mark notification as read', error: e, stackTrace: stackTrace);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final unreadIds = _notifications
          .where((n) => !n.isRead)
          .map((n) => n.id)
          .toList();

      if (unreadIds.isEmpty) return;

      // Optimistically update UI
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();

      final success = await _repository.markNotificationsAsRead(unreadIds);
      if (!success) {
        // Revert on failure
        for (var i = 0; i < _notifications.length; i++) {
          if (unreadIds.contains(_notifications[i].id)) {
            _notifications[i] = _notifications[i].copyWith(isRead: false);
          }
        }
        notifyListeners();
        _logger.warning('Failed to mark all notifications as read on server');
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to mark all notifications as read', error: e, stackTrace: stackTrace);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notificationToDelete = _notifications[index];

        // Optimistically remove from UI
        _notifications.removeAt(index);
        notifyListeners();

        final success = await _repository.deleteNotification(notificationId);
        if (!success) {
          // Add back on failure
          _notifications.insert(index, notificationToDelete);
          notifyListeners();
          _logger.warning('Failed to delete notification from server');
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to delete notification', error: e, stackTrace: stackTrace);
    }
  }

  /// Add new notification (from push notification)
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _repository.addNotification(notification);

      // Add to local list if not already present
      final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
      if (existingIndex == -1) {
        _notifications.add(notification);
        notifyListeners();
      }

      _logger.info('Added new notification: ${notification.id}');
    } catch (e, stackTrace) {
      _logger.error('Failed to add notification', error: e, stackTrace: stackTrace);
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update type filter
  void updateTypeFilter(NotificationType? type) {
    _selectedType = type;
    notifyListeners();
  }

  /// Update read status filter
  void updateReadFilter(bool? showOnlyUnread) {
    _showOnlyUnread = showOnlyUnread;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _showOnlyUnread = null;
    notifyListeners();
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _repository.getNotificationStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e, stackTrace) {
      _logger.error('Failed to get notification statistics', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Get notifications by date range
  List<NotificationModel> getNotificationsByDateRange(DateTime start, DateTime end) {
    return _notifications.where((n) {
      return n.timestamp.isAfter(start) && n.timestamp.isBefore(end);
    }).toList();
  }

  /// Handle notification action
  void handleNotificationAction(NotificationModel notification) {
    if (notification.actionUrl != null) {
      // Handle URL action
      _logger.info('Handling URL action: ${notification.actionUrl}');
      // TODO: Launch URL
    } else if (notification.actionRoute != null) {
      // Handle route navigation
      _logger.info('Handling route action: ${notification.actionRoute}');
      // TODO: Navigate to route
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get notification groups by date
  Map<String, List<NotificationModel>> getNotificationsGroupedByDate() {
    final groups = <String, List<NotificationModel>>{};
    final now = DateTime.now();

    for (final notification in filteredNotifications) {
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

  /// Sync notifications
  Future<void> syncNotifications() async {
    try {
      await _repository.syncNotifications();
      // Refresh local data after sync
      await loadNotifications(forceRefresh: true);
    } catch (e, stackTrace) {
      _logger.error('Failed to sync notifications', error: e, stackTrace: stackTrace);
      _errorMessage = 'Failed to sync notifications: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      return await _repository.getSyncStatistics();
    } catch (e, stackTrace) {
      _logger.error('Failed to get sync statistics', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  /// Force sync with conflict resolution
  Future<void> forceSync() async {
    await syncNotifications();
  }

  void _initializeMockData() {
    // Mock notifications data for Phase 5 testing
    _notifications = [
      NotificationModel(
        id: 'notif_001',
        title: 'Policy Renewal Due',
        body: 'Your policy LIC123456789 is due for renewal in 7 days.',
        type: NotificationType.renewal,
        priority: NotificationPriority.high,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionRoute: '/policies',
        data: {'policyId': 'POL001'},
      ),
      NotificationModel(
        id: 'notif_002',
        title: 'Claim Approved',
        body: 'Your claim CLM001 for ₹45,000 has been approved.',
        type: NotificationType.claim,
        priority: NotificationPriority.high,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        actionRoute: '/claims',
        data: {'claimId': 'CLM001'},
      ),
      NotificationModel(
        id: 'notif_003',
        title: 'Payment Reminder',
        body: 'Premium payment of ₹2,500 is due in 3 days.',
        type: NotificationType.payment,
        priority: NotificationPriority.medium,
        isRead: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionRoute: '/policies',
        data: {'policyId': 'POL001'},
      ),
      NotificationModel(
        id: 'notif_004',
        title: 'New Feature Available',
        body: 'Try our new claims filing feature with AI assistance.',
        type: NotificationType.marketing,
        priority: NotificationPriority.low,
        isRead: false,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        actionRoute: '/claims',
        data: {},
      ),
    ];

    // Notification counts are computed properties
  }
}
