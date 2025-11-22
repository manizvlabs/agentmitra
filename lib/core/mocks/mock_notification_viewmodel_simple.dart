import 'package:flutter/material.dart';
import '../../features/notifications/data/models/notification_model.dart';
import 'mock_data.dart';

/// Production-grade Mock NotificationViewModel for web compatibility
class MockNotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  String _searchQuery = '';
  NotificationType? _selectedType;
  bool _showOnlyUnread = false;

  List<NotificationModel> get notifications => _filteredNotifications;
  NotificationSettings? get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  String get searchQuery => _searchQuery;
  NotificationType? get selectedType => _selectedType;
  bool get showOnlyUnread => _showOnlyUnread;

  List<NotificationModel> get recentNotifications =>
      _notifications.where((n) => n.isRecent).toList();

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get _filteredNotifications {
    var filtered = _notifications;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.body.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Apply type filter
    if (_selectedType != null) {
      filtered = filtered.where((n) => n.type == _selectedType).toList();
    }

    // Apply unread filter
    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    return filtered;
  }

  MockNotificationViewModel() {
    _notifications = MockData.mockNotifications;
    _notificationSettings = MockData.mockNotificationSettings;
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Notifications are already loaded in constructor
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // In a real app, this would fetch fresh data from server
      _isRefreshing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to refresh notifications: ${e.toString()}';
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  Future<void> loadNotificationSettings() async {
    // Settings are already loaded in constructor
    notifyListeners();
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    _notificationSettings = settings;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateTypeFilter(NotificationType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void updateReadFilter(bool showOnlyUnread) {
    _showOnlyUnread = showOnlyUnread;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedType = null;
    _showOnlyUnread = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadNotifications();
    await loadNotificationSettings();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
