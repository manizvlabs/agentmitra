import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';
import 'api_service.dart';

/// Service for handling push notifications with Firebase and local notifications
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final LoggerService _logger = LoggerService();

  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationSettingsKey = 'notification_settings';

  // Stream controllers for notification events
  final StreamController<RemoteMessage> _onMessageController = StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _onMessageOpenedAppController = StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _onTokenRefreshController = StreamController<String>.broadcast();

  // Streams
  Stream<RemoteMessage> get onMessage => _onMessageController.stream;
  Stream<RemoteMessage> get onMessageOpenedApp => _onMessageOpenedAppController.stream;
  Stream<String> get onTokenRefresh => _onTokenRefreshController.stream;

  // Notification settings
  NotificationSettings? _notificationSettings;

  /// Initialize Firebase and local notifications
  Future<void> initialize() async {
    try {
      await _initializeFirebase();
      await _initializeLocalNotifications();
      await _setupMessageHandlers();
      await _loadNotificationSettings();

      _logger.info('Push notification service initialized successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize push notification service', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Initialize Firebase
  Future<void> _initializeFirebase() async {
    // Firebase should already be initialized in main.dart
    // But let's ensure it's done here as well
    await Firebase.initializeApp();

    // Request permission for notifications
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    _notificationSettings = settings;
    _logger.info('Firebase messaging permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'agent_mitra_channel',
        'Agent Mitra Notifications',
        description: 'Notifications for Agent Mitra app',
        importance: Importance.high,
        playSound: true,
        showBadge: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Setup Firebase message handlers
  Future<void> _setupMessageHandlers() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.info('Received foreground message: ${message.messageId}');
      _onMessageController.add(message);
      _showLocalNotification(message);
    });

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.info('Message opened app: ${message.messageId}');
      _onMessageOpenedAppController.add(message);
    });

    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _logger.info('FCM token refreshed');
      _onTokenRefreshController.add(token);
      _saveFcmToken(token);
      _registerTokenWithBackend(token);
    });
  }

  /// Get FCM token
  Future<String?> getFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
        await _registerTokenWithBackend(token);
      }
      return token;
    } catch (e, stackTrace) {
      _logger.error('Failed to get FCM token', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Save FCM token locally
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
    _logger.info('FCM token saved locally');
  }

  /// Get saved FCM token
  Future<String?> getSavedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  /// Register FCM token with backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await ApiService.post('/api/v1/notifications/device-token', {
        'fcm_token': token,
        'device_type': Platform.isIOS ? 'ios' : 'android',
      });
      _logger.info('FCM token registered with backend');
    } catch (e, stackTrace) {
      _logger.error('Failed to register FCM token with backend', error: e, stackTrace: stackTrace);
      // Don't rethrow - this shouldn't break the app
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'agent_mitra_channel',
      'Agent Mitra Notifications',
      channelDescription: 'Notifications for Agent Mitra app',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      notification.title ?? 'Agent Mitra',
      notification.body ?? '',
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  /// Handle notification tap when app is in foreground
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationPayload(payload);
    }
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // This will be handled when the app is brought to foreground
      LoggerService().info('Background notification tapped: $payload');
    }
  }

  /// Handle notification payload
  void _handleNotificationPayload(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final action = data['action'] as String?;
      final route = data['route'] as String?;

      if (route != null) {
        // Navigate to specific route
        _logger.info('Notification action: navigate to $route');
        // Navigation will be handled by the app router
      }

      if (action != null) {
        _logger.info('Notification action: $action');
        // Handle specific actions like opening URLs, etc.
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to handle notification payload', error: e, stackTrace: stackTrace);
    }
  }

  /// Load notification settings
  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_notificationSettingsKey);
    if (settingsJson != null) {
      try {
        // Load user preferences
        _logger.info('Notification settings loaded');
      } catch (e, stackTrace) {
        _logger.error('Failed to load notification settings', error: e, stackTrace: stackTrace);
      }
    }
  }

  /// Save notification settings
  Future<void> saveNotificationSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, jsonEncode(settings));
    _logger.info('Notification settings saved');
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_notificationSettingsKey);
    if (settingsJson != null) {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    }
    return {};
  }

  /// Check if notifications are enabled
  bool get areNotificationsEnabled {
    return _notificationSettings?.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.info('Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      _logger.error('Failed to subscribe to topic: $topic', error: e, stackTrace: stackTrace);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.info('Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      _logger.error('Failed to unsubscribe from topic: $topic', error: e, stackTrace: stackTrace);
    }
  }

  /// Delete FCM token
  Future<void> deleteFcmToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      _logger.info('FCM token deleted');
    } catch (e, stackTrace) {
      _logger.error('Failed to delete FCM token', error: e, stackTrace: stackTrace);
    }
  }

  /// Dispose of resources
  void dispose() {
    _onMessageController.close();
    _onMessageOpenedAppController.close();
    _onTokenRefreshController.close();
    _logger.info('Push notification service disposed');
  }
}
