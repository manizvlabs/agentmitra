import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../core/config/app_config.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/logger_service.dart';

/// Real-time dashboard updates service using WebSocket connections
class DashboardRealtimeService {
  static final DashboardRealtimeService _instance = DashboardRealtimeService._internal();
  factory DashboardRealtimeService() => _instance;
  DashboardRealtimeService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  final StreamController<DashboardUpdate> _updateController =
      StreamController<DashboardUpdate>.broadcast();

  final StreamController<ConnectionStatus> _connectionController =
      StreamController<ConnectionStatus>.broadcast();

  final Map<String, StreamSubscription> _widgetSubscriptions = {};

  /// Stream of dashboard updates
  Stream<DashboardUpdate> get updates => _updateController.stream;

  /// Stream of connection status changes
  Stream<ConnectionStatus> get connectionStatus => _connectionController.stream;

  /// Current connection status
  ConnectionStatus get currentStatus => _isConnected
      ? ConnectionStatus.connected
      : ConnectionStatus.disconnected;

  /// Initialize the WebSocket connection
  Future<void> initialize() async {
    if (_isConnected) return;

    try {
      // For now, use a placeholder WebSocket URL
      // In production, this should be configured based on environment
      final wsUrl = 'ws://localhost:8012/api/v1/dashboard/ws/test-user';
      LoggerService().info('Connecting to dashboard WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _connectionController.add(ConnectionStatus.connecting);

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      // Start heartbeat
      _startHeartbeat();

      _connectionController.add(ConnectionStatus.connected);

    } catch (e) {
      LoggerService().error('Failed to initialize dashboard WebSocket: $e');
      _connectionController.add(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  /// Subscribe to updates for a specific widget
  StreamSubscription subscribeToWidget(String widgetId, Function(DashboardUpdate) onUpdate) {
    final subscription = updates
        .where((update) => update.widgetId == widgetId || update.widgetId == 'all')
        .listen(onUpdate);

    _widgetSubscriptions[widgetId] = subscription;
    return subscription;
  }

  /// Unsubscribe from widget updates
  void unsubscribeFromWidget(String widgetId) {
    _widgetSubscriptions[widgetId]?.cancel();
    _widgetSubscriptions.remove(widgetId);
  }

  /// Send a message to request specific data updates
  void requestDataUpdate(String widgetId, {Map<String, dynamic>? params}) {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'data_request',
      'widgetId': widgetId,
      'params': params ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Send widget configuration update
  void updateWidgetConfig(String widgetId, Map<String, dynamic> config) {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'widget_config_update',
      'widgetId': widgetId,
      'config': config,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      switch (data['type']) {
        case 'dashboard_update':
          final update = DashboardUpdate.fromJson(data);
          _updateController.add(update);
          break;

        case 'bulk_update':
          final updates = (data['updates'] as List)
              .map((u) => DashboardUpdate.fromJson(u))
              .toList();
          for (final update in updates) {
            _updateController.add(update);
          }
          break;

        case 'heartbeat':
          // Handle heartbeat response
          break;

        case 'error':
          LoggerService().error('WebSocket error: ${data['message']}');
          break;

        default:
          LoggerService().info('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      LoggerService().error('Error handling WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(Object error) {
    LoggerService().error('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(ConnectionStatus.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    LoggerService().info('Dashboard WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(ConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({
            'type': 'heartbeat',
            'timestamp': DateTime.now().toIso8601String(),
          }));
        } catch (e) {
          LoggerService().error('Error sending heartbeat: $e');
        }
      }
    });
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      LoggerService().info('Attempting to reconnect dashboard WebSocket...');
      initialize();
    });
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;

    // Cancel all subscriptions
    for (final subscription in _widgetSubscriptions.values) {
      subscription.cancel();
    }
    _widgetSubscriptions.clear();

    _connectionController.add(ConnectionStatus.disconnected);
  }

  /// Check if WebSocket is connected
  bool get isConnected => _isConnected;
}

/// Dashboard update data model
class DashboardUpdate {
  final String type;
  final String widgetId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? source;

  const DashboardUpdate({
    required this.type,
    required this.widgetId,
    required this.data,
    required this.timestamp,
    this.source,
  });

  factory DashboardUpdate.fromJson(Map<String, dynamic> json) {
    return DashboardUpdate(
      type: json['type'] as String,
      widgetId: json['widgetId'] as String,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'widgetId': widgetId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'source': source,
  };
}

/// Connection status enum
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Real-time dashboard widget mixin
mixin RealtimeDashboardWidget on DashboardWidgetState {
  StreamSubscription<DashboardUpdate>? _updateSubscription;
  StreamSubscription<ConnectionStatus>? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    final realtimeService = DashboardRealtimeService();

    // Subscribe to widget-specific updates
    _updateSubscription = realtimeService.subscribeToWidget(
      (widget as DashboardWidget).id,
      _handleRealtimeUpdate,
    );

    // Subscribe to connection status changes
    _connectionSubscription = realtimeService.connectionStatus.listen(
      _handleConnectionStatusChange,
    );

    // Initialize WebSocket connection if not already connected
    if (!realtimeService.isConnected) {
      realtimeService.initialize();
    }
  }

  void _handleRealtimeUpdate(DashboardUpdate update) {
    // Handle different update types
    switch (update.type) {
      case 'data_update':
        _handleDataUpdate(update.data);
        break;
      case 'config_update':
        _handleConfigUpdate(update.data);
        break;
      case 'refresh_request':
        loadData();
        break;
    }
  }

  void _handleConnectionStatusChange(ConnectionStatus status) {
    // Update UI based on connection status
    switch (status) {
      case ConnectionStatus.connected:
        // Show connected indicator
        break;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        // Show disconnected indicator and retry option
        break;
      case ConnectionStatus.connecting:
        // Show connecting indicator
        break;
    }
  }

  /// Override this method to handle data updates
  void _handleDataUpdate(Map<String, dynamic> data) {
    // Default implementation - override in subclasses
  }

  /// Override this method to handle config updates
  void _handleConfigUpdate(Map<String, dynamic> data) {
    // Default implementation - override in subclasses
  }
}

/// Smart Alert System for real-time notifications
class SmartAlertSystem {
  static final SmartAlertSystem _instance = SmartAlertSystem._internal();
  factory SmartAlertSystem() => _instance;
  SmartAlertSystem._internal();

  final StreamController<SmartAlert> _alertController =
      StreamController<SmartAlert>.broadcast();

  final List<SmartAlert> _activeAlerts = [];
  final Map<String, AlertRule> _rules = {};

  /// Stream of smart alerts
  Stream<SmartAlert> get alerts => _alertController.stream;

  /// Active alerts list
  List<SmartAlert> get activeAlerts => List.unmodifiable(_activeAlerts);

  /// Initialize the alert system
  void initialize() {
    // Set up default alert rules
    _setupDefaultRules();

    // Start monitoring (would integrate with real-time data streams)
    _startMonitoring();
  }

  void _setupDefaultRules() {
    // Revenue drop alert
    addRule(AlertRule(
      id: 'revenue_drop',
      name: 'Revenue Drop Alert',
      description: 'Alert when revenue drops by more than 20% in 24 hours',
      condition: (data) {
        final revenue = data['revenue'] as num?;
        final previousRevenue = data['previousRevenue'] as num?;
        if (revenue == null || previousRevenue == null) return false;
        return (previousRevenue - revenue) / previousRevenue > 0.20;
      },
      severity: AlertSeverity.high,
      enabled: true,
    ));

    // Customer churn risk
    addRule(AlertRule(
      id: 'churn_risk',
      name: 'High Churn Risk',
      description: 'Alert when customer churn risk exceeds 70%',
      condition: (data) {
        final riskScore = data['churnRiskScore'] as num?;
        return riskScore != null && riskScore > 0.70;
      },
      severity: AlertSeverity.medium,
      enabled: true,
    ));

    // KPI target missed
    addRule(AlertRule(
      id: 'kpi_target_missed',
      name: 'KPI Target Missed',
      description: 'Alert when KPI targets are not met',
      condition: (data) {
        final actual = data['actual'] as num?;
        final target = data['target'] as num?;
        return actual != null && target != null && actual < target;
      },
      severity: AlertSeverity.medium,
      enabled: true,
    ));

    // System performance issue
    addRule(AlertRule(
      id: 'performance_issue',
      name: 'Performance Issue',
      description: 'Alert when system response time exceeds threshold',
      condition: (data) {
        final responseTime = data['responseTime'] as num?;
        return responseTime != null && responseTime > 5000; // 5 seconds
      },
      severity: AlertSeverity.low,
      enabled: true,
    ));
  }

  /// Add an alert rule
  void addRule(AlertRule rule) {
    _rules[rule.id] = rule;
  }

  /// Remove an alert rule
  void removeRule(String ruleId) {
    _rules.remove(ruleId);
  }

  /// Enable/disable a rule
  void toggleRule(String ruleId, bool enabled) {
    final rule = _rules[ruleId];
    if (rule != null) {
      _rules[ruleId] = rule.copyWith(enabled: enabled);
    }
  }

  /// Evaluate data against all rules and trigger alerts
  void evaluateData(Map<String, dynamic> data, {String? source}) {
    for (final rule in _rules.values) {
      if (!rule.enabled) continue;

      try {
        if (rule.condition(data)) {
          final alert = SmartAlert(
            id: '${rule.id}_${DateTime.now().millisecondsSinceEpoch}',
            ruleId: rule.id,
            title: rule.name,
            message: rule.description,
            severity: rule.severity,
            timestamp: DateTime.now(),
            data: data,
            source: source,
            acknowledged: false,
          );

          _triggerAlert(alert);
        }
      } catch (e) {
        LoggerService().error('Error evaluating alert rule ${rule.id}: $e');
      }
    }
  }

  void _triggerAlert(SmartAlert alert) {
    // Check if similar alert already exists
    final existingAlert = _activeAlerts.firstWhere(
      (a) => a.ruleId == alert.ruleId && !a.acknowledged,
      orElse: () => alert,
    );

    if (existingAlert.id != alert.id) {
      // Update existing alert instead of creating new one
      existingAlert.timestamp = alert.timestamp;
      existingAlert.data = alert.data;
      _alertController.add(existingAlert);
    } else {
      // Add new alert
      _activeAlerts.add(alert);
      _alertController.add(alert);
    }

    // Log the alert
    LoggerService().info('Smart alert triggered: ${alert.title}');
  }

  /// Acknowledge an alert
  void acknowledgeAlert(String alertId) {
    final alert = _activeAlerts.firstWhere(
      (a) => a.id == alertId,
      orElse: () => throw Exception('Alert not found'),
    );

    alert.acknowledged = true;
    alert.acknowledgedAt = DateTime.now();

    _alertController.add(alert);
  }

  /// Dismiss an alert
  void dismissAlert(String alertId) {
    _activeAlerts.removeWhere((a) => a.id == alertId);
  }

  /// Clear all alerts
  void clearAllAlerts() {
    _activeAlerts.clear();
  }

  void _startMonitoring() {
    // This would integrate with the real-time data streams
    // For now, it's a placeholder for future implementation
    LoggerService().info('Smart Alert System monitoring started');
  }

  /// Get alerts by severity
  List<SmartAlert> getAlertsBySeverity(AlertSeverity severity) {
    return _activeAlerts.where((alert) => alert.severity == severity).toList();
  }

  /// Get unacknowledged alerts
  List<SmartAlert> getUnacknowledgedAlerts() {
    return _activeAlerts.where((alert) => !alert.acknowledged).toList();
  }
}

/// Smart alert data model
class SmartAlert {
  final String id;
  final String ruleId;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String? source;
  bool acknowledged;
  DateTime? acknowledgedAt;

  SmartAlert({
    required this.id,
    required this.ruleId,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.data,
    this.source,
    this.acknowledged = false,
    this.acknowledgedAt,
  });

  IconData get icon {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info_outline;
      case AlertSeverity.medium:
        return Icons.warning_amber_outlined;
      case AlertSeverity.high:
        return Icons.error_outline;
      case AlertSeverity.critical:
        return Icons.dangerous_outlined;
    }
  }

  Color get color {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }
}

/// Alert rule data model
class AlertRule {
  final String id;
  final String name;
  final String description;
  final bool Function(Map<String, dynamic>) condition;
  final AlertSeverity severity;
  final bool enabled;
  final Map<String, dynamic>? config;

  const AlertRule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.severity,
    this.enabled = true,
    this.config,
  });

  AlertRule copyWith({
    String? name,
    String? description,
    bool? enabled,
    Map<String, dynamic>? config,
  }) {
    return AlertRule(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      condition: condition,
      severity: severity,
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
    );
  }
}

/// Alert severity levels
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// Extension methods for alert severity
extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red.shade900;
    }
  }
}
