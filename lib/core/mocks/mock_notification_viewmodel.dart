import 'package:flutter/material.dart';
import '../../features/notifications/data/models/notification_model.dart';

/// Mock NotificationViewModel for web compatibility
class MockNotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  NotificationSettings? _notificationSettings;
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  NotificationSettings? get notificationSettings => _notificationSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  MockNotificationViewModel() {
    // Initialize with mock notifications
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Policy Renewal Reminder',
        message: 'Policy POL001 is due for renewal in 7 days',
        type: 'warning',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        actionUrl: '/policies',
      ),
      NotificationModel(
        id: '2',
        title: 'Claim Approved',
        message: 'Your claim CLM001 has been approved',
        type: 'success',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        actionUrl: '/claims',
      ),
    ];
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  Future<void> loadNotificationSettings() async {
    _notificationSettings = NotificationSettings(
      pushEnabled: true,
      emailEnabled: true,
      smsEnabled: false,
    );
    notifyListeners();
  }

  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    _notificationSettings = settings;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadNotifications();
    await loadNotificationSettings();
  }
}
