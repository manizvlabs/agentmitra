import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'dart:async';
import 'api_service.dart';
import 'pioneer_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

/// Feature Flag Service for dynamic UI rendering based on permissions
class FeatureFlagService {
  final Map<String, bool> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  WebSocketChannel? _webSocketChannel;
  final StreamController<Map<String, dynamic>> _updateController =
      StreamController.broadcast();
  bool _isWebSocketConnected = false;
  Timer? _reconnectTimer;

  FeatureFlagService() {
    // Defer WebSocket initialization until user is authenticated
    // WebSocket will be initialized when needed via initializeWebSocketForUser()
  }

  /// Stream of real-time feature flag updates
  Stream<Map<String, dynamic>> get flagUpdates => _updateController.stream;

  /// Check if WebSocket is connected
  bool get isWebSocketConnected => _isWebSocketConnected;

  /// Initialize the service (async for future use)
  Future<void> initialize() async {
    // WebSocket initialization is deferred until user authentication
  }

  /// Initialize WebSocket connection for authenticated user
  Future<void> initializeWebSocketForUser() async {
    if (_isWebSocketConnected) return; // Already connected

    await _initializeWebSocket();
  }

  /// Initialize WebSocket connection for real-time updates
  Future<void> _initializeWebSocket() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser?.id == null) {
        debugPrint('Cannot initialize WebSocket: No authenticated user');
        // Don't initialize WebSocket until user is authenticated
        return;
      }

      final wsUrl = '${AppConfig().wsBaseUrl}/api/v1/feature-flags/ws/${currentUser!.id}';
      debugPrint('Connecting to WebSocket: $wsUrl');

      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isWebSocketConnected = true;

      _webSocketChannel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            if (data['type'] == 'feature_flag_update') {
              // Update cache with new value
              final flagName = data['feature_key'] as String;
              final newValue = data['new_value'] as bool;

              _cache[_getCacheKey(flagName, currentUser.id, null)] = newValue;
              _cacheTimestamps[_getCacheKey(flagName, currentUser.id, null)] = DateTime.now();

              // Broadcast update to listeners
              _updateController.add(data);
              debugPrint('Feature flag updated via WebSocket: $flagName = $newValue');
            }
          } catch (e) {
            debugPrint('Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _isWebSocketConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _isWebSocketConnected = false;
          _scheduleReconnect();
        },
      );

      // Send periodic ping to keep connection alive
      Timer.periodic(const Duration(minutes: 5), (timer) {
        if (_isWebSocketConnected && _webSocketChannel != null) {
          try {
            _webSocketChannel!.sink.add(jsonEncode({'type': 'ping'}));
          } catch (e) {
            debugPrint('Error sending ping: $e');
          }
        }
      });

    } catch (e) {
      debugPrint('Failed to initialize WebSocket: $e');
      _scheduleReconnect();
    }
  }

  /// Schedule WebSocket reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 30), () {
      debugPrint('Attempting WebSocket reconnection...');
      _initializeWebSocket();
    });
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    _reconnectTimer?.cancel();
    _webSocketChannel?.sink.close(status.goingAway);
    _webSocketChannel = null;
    _isWebSocketConnected = false;
  }

  /// Dispose of resources
  void dispose() {
    disconnectWebSocket();
    _updateController.close();
  }

  /// Synchronous check for feature flag (checks cache first, then Pioneer)
  bool isFeatureEnabledSync(String flagName, {String? userId, String? tenantId}) {
    final cacheKey = _getCacheKey(flagName, userId, tenantId);
    if (_cache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamps[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheDuration) {
        return _cache[cacheKey]!;
      }
    }

    try {
      // Get from Pioneer (will throw exception if not available)
      final result = PioneerService.isFeatureEnabledSync(flagName);

      // Cache the result
      _cache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return result;
    } catch (e) {
      debugPrint('Error checking feature flag sync $flagName: $e');
      // Return default value for known flags
      final defaultValue = _getDefaultValueForFlag(flagName);
      debugPrint('Using default value $defaultValue for feature flag $flagName (sync)');

      // Cache the default result
      _cache[cacheKey] = defaultValue;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return defaultValue;
    }
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagName, {String? userId, String? tenantId}) async {
    final effectiveUserId = userId ?? AuthService().currentUser?.id;

    // Initialize WebSocket for authenticated users (only once)
    if (effectiveUserId != null && !_isWebSocketConnected) {
      initializeWebSocketForUser();
    }

    // Check cache first
    final cacheKey = _getCacheKey(flagName, effectiveUserId, tenantId);
    if (_cache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamps[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheDuration) {
        return _cache[cacheKey]!;
      }
    }

    try {
      // Try Pioneer first (will throw exception if not available)
      final result = await PioneerService.isFeatureEnabled(flagName);
      return result;
    } catch (e) {
      debugPrint('Pioneer service not available for $flagName, trying backend APIs: $e');
    }

    try {
      // Try the enhanced backend feature flag API with user-specific flags
      if (effectiveUserId != null) {
        try {
          final response = await ApiService.get(
            '/api/v1/feature-flags/user/$effectiveUserId',
            queryParameters: {
              if (tenantId != null) 'tenant_id': tenantId,
            },
          );

          // The response should be a map of flag names to boolean values
          final flags = response as Map<String, dynamic>;
          final isEnabled = flags[flagName] as bool? ?? false;

          // Cache the result
          _cache[cacheKey] = isEnabled;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return isEnabled;
        } catch (e) {
          debugPrint('Error with user-specific feature flags API: $e');
          // Check if it's a JSON parsing error (HTML response)
          if (e.toString().contains('FormatException') || e.toString().contains('Unexpected token')) {
            debugPrint('Received HTML error page instead of JSON for user-specific feature flags API');
          }
          // Fall through to legacy API
        }
      }

      // Fall back to legacy backend feature flag API
      try {
        final response = await ApiService.get(
          '/rbac/feature-flags',
          queryParameters: {
            if (tenantId != null) 'tenant_id': tenantId,
          },
        );

        // Handle different response formats
        if (response is List) {
          // Legacy API returns list of flags
          final flags = response as List<dynamic>;
          final flag = flags.firstWhere(
            (f) => f is Map && f['flag_name'] == flagName,
            orElse: () => null,
          );
          final isEnabled = flag != null ? (flag['is_enabled'] as bool? ?? false) : false;

          // Cache the result
          _cache[cacheKey] = isEnabled;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return isEnabled;
        } else if (response is Map) {
          // Assume it's a map format
          final flags = response as Map<String, dynamic>;
          final isEnabled = flags[flagName] as bool? ?? false;

          // Cache the result
          _cache[cacheKey] = isEnabled;
          _cacheTimestamps[cacheKey] = DateTime.now();

          return isEnabled;
        } else {
          // Unknown format, return default
          final defaultValue = _getDefaultValueForFlag(flagName);
          _cache[cacheKey] = defaultValue;
          _cacheTimestamps[cacheKey] = DateTime.now();
          return defaultValue;
        }
      } catch (e) {
        debugPrint('Error with legacy feature flags API: $e');
        // Check if it's a JSON parsing error (HTML response)
        if (e.toString().contains('FormatException') || e.toString().contains('Unexpected token')) {
          debugPrint('Received HTML error page instead of JSON for legacy feature flags API');
        }
        // Fall through to default
      }
    } catch (e) {
      debugPrint('Error checking feature flag $flagName: $e');
      // Fall through to default
    }

    // If all APIs fail, return default values for known flags
    final defaultValue = _getDefaultValueForFlag(flagName);
    debugPrint('Using default value $defaultValue for feature flag $flagName');

    // Cache the default result to avoid repeated API calls
    _cache[cacheKey] = defaultValue;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return defaultValue;
  }

  /// Get default values for known feature flags
  bool _getDefaultValueForFlag(String flagName) {
    // Define default values for known feature flags
    const Map<String, bool> defaults = {
      'dashboard_enabled': true,
      'login_enabled': true,
      'registration_enabled': true,
      'otp_verification_enabled': true,
      'feature_flag_control_enabled': false,
      'analytics_enabled': true,
      'notifications_enabled': true,
      'chat_enabled': true,
      'policies_enabled': true,
      'claims_enabled': true,
      'reports_enabled': true,
    };

    return defaults[flagName] ?? false; // Default to false for unknown flags
  }

  /// Check if user has a specific permission
  Future<bool> hasPermission(String permission, {String? userId}) async {
    try {
      final response = await ApiService.get(
        '/rbac/check-permission',
        queryParameters: {
          'permission': permission,
          if (userId != null) 'user_id': userId,
        },
      );

      return response['has_permission'] as bool? ?? false;
    } catch (e) {
      debugPrint('Error checking permission $permission: $e');
      return false;
    }
  }

  /// Get user permissions
  Future<List<String>> getUserPermissions({String? userId}) async {
    try {
      final response = await ApiService.get('/rbac/user-permissions');

      return List<String>.from(response['permissions'] as List? ?? []);
    } catch (e) {
      debugPrint('Error getting user permissions: $e');
      return [];
    }
  }

  /// Get user roles
  Future<List<String>> getUserRoles({String? userId}) async {
    try {
      final response = await ApiService.get('/rbac/users/${userId ?? 'current'}/roles');

      return List<String>.from(response['roles'] as List? ?? []);
    } catch (e) {
      debugPrint('Error getting user roles: $e');
      return [];
    }
  }

  /// Clear cache for a specific flag or all flags
  void clearCache({String? flagName, String? userId, String? tenantId}) {
    if (flagName != null) {
      final cacheKey = _getCacheKey(flagName, userId, tenantId);
      _cache.remove(cacheKey);
      _cacheTimestamps.remove(cacheKey);
    } else {
      _cache.clear();
      _cacheTimestamps.clear();
    }
  }

  String _getCacheKey(String flagName, String? userId, String? tenantId) {
    return '$flagName:${userId ?? 'current'}:${tenantId ?? 'global'}';
  }

  /// Feature flag builder widget for conditional rendering
  static Widget buildWithFeatureFlag({
    required String flagName,
    required Widget Function() enabledBuilder,
    Widget Function()? disabledBuilder,
    Widget Function()? loadingBuilder,
    String? userId,
    String? tenantId,
  }) {
    return FeatureFlagBuilder(
      flagName: flagName,
      enabledBuilder: enabledBuilder,
      disabledBuilder: disabledBuilder,
      loadingBuilder: loadingBuilder,
      userId: userId,
      tenantId: tenantId,
    );
  }

  /// Permission-based builder widget
  static Widget buildWithPermission({
    required String permission,
    required Widget Function() enabledBuilder,
    Widget Function()? disabledBuilder,
    Widget Function()? loadingBuilder,
    String? userId,
  }) {
    return PermissionBuilder(
      permission: permission,
      enabledBuilder: enabledBuilder,
      disabledBuilder: disabledBuilder,
      loadingBuilder: loadingBuilder,
      userId: userId,
    );
  }
}

/// Widget that conditionally renders based on feature flag status
class FeatureFlagBuilder extends StatefulWidget {
  final String flagName;
  final Widget Function() enabledBuilder;
  final Widget Function()? disabledBuilder;
  final Widget Function()? loadingBuilder;
  final String? userId;
  final String? tenantId;

  const FeatureFlagBuilder({
    Key? key,
    required this.flagName,
    required this.enabledBuilder,
    this.disabledBuilder,
    this.loadingBuilder,
    this.userId,
    this.tenantId,
  }) : super(key: key);

  @override
  State<FeatureFlagBuilder> createState() => _FeatureFlagBuilderState();
}

class _FeatureFlagBuilderState extends State<FeatureFlagBuilder> {
  bool? _isEnabled;
  bool _isLoading = true;
  StreamSubscription<Map<String, dynamic>>? _flagUpdateSubscription;
  FeatureFlagService? _service;

  @override
  void initState() {
    super.initState();
    _service = FeatureFlagService();
    _loadFeatureFlag();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _flagUpdateSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToUpdates() {
    _flagUpdateSubscription = _service?.flagUpdates.listen((update) {
      if (update['feature_key'] == widget.flagName) {
        if (mounted) {
          setState(() {
            _isEnabled = update['new_value'] as bool;
          });
        }
      }
    });
  }


  Future<void> _loadFeatureFlag() async {
    setState(() => _isLoading = true);

    try {
      // This would normally get the service from provider
      // For now, we'll use a placeholder
      _isEnabled = await _checkFeatureFlag();
    } catch (e) {
      debugPrint('Error loading feature flag: $e');
      _isEnabled = false; // Default to disabled on error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkFeatureFlag() async {
    // Use the feature flag service to check the flag
    final service = FeatureFlagService();
    return await service.isFeatureEnabled(widget.flagName,
        userId: widget.userId, tenantId: widget.tenantId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call() ??
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          );
    }

    if (_isEnabled == true) {
      return widget.enabledBuilder();
    } else {
      return widget.disabledBuilder?.call() ??
          const SizedBox.shrink(); // Hidden when disabled
    }
  }
}

/// Widget that conditionally renders based on permission status
class PermissionBuilder extends StatefulWidget {
  final String permission;
  final Widget Function() enabledBuilder;
  final Widget Function()? disabledBuilder;
  final Widget Function()? loadingBuilder;
  final String? userId;

  const PermissionBuilder({
    Key? key,
    required this.permission,
    required this.enabledBuilder,
    this.disabledBuilder,
    this.loadingBuilder,
    this.userId,
  }) : super(key: key);

  @override
  State<PermissionBuilder> createState() => _PermissionBuilderState();
}

class _PermissionBuilderState extends State<PermissionBuilder> {
  bool? _hasPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  Future<void> _loadPermission() async {
    setState(() => _isLoading = true);

    try {
      _hasPermission = await _checkPermission();
    } catch (e) {
      debugPrint('Error loading permission: $e');
      _hasPermission = false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkPermission() async {
    // Use the feature flag service to check permissions
    // For now, we'll use a placeholder service instance
    // In a real app, this would be injected via provider
    try {
      final service = FeatureFlagService();
      return await service.hasPermission(widget.permission, userId: widget.userId);
    } catch (e) {
      debugPrint('Error checking permission: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call() ??
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          );
    }

    if (_hasPermission == true) {
      return widget.enabledBuilder();
    } else {
      return widget.disabledBuilder?.call() ??
          const SizedBox.shrink();
    }
  }
}

/// Extension methods for easier feature flag usage
extension FeatureFlagExtensions on BuildContext {
  /// Check if a feature is enabled
  Future<bool> isFeatureEnabled(String flagName, {String? userId, String? tenantId}) async {
    // This would normally get the service from provider
    // For now, return true for demo
    return true;
  }

  /// Check if user has permission
  Future<bool> hasPermission(String permission, {String? userId}) async {
    // This would normally check actual permissions
    // For now, return true for demo
    return true;
  }
}

/// Common feature flags used throughout the app
class FeatureFlags {
  // Customer Portal Features
  static const String customerDashboardEnabled = 'customer_dashboard_enabled';
  static const String policyManagementEnabled = 'policy_management_enabled';
  static const String premiumPaymentsEnabled = 'premium_payments_enabled';
  static const String documentAccessEnabled = 'document_access_enabled';
  static const String communicationToolsEnabled = 'communication_tools_enabled';
  static const String learningCenterEnabled = 'learning_center_enabled';
  static const String profileManagementEnabled = 'profile_management_enabled';
  static const String whatsappIntegrationEnabled = 'whatsapp_integration_enabled';
  static const String chatbotAssistanceEnabled = 'chatbot_assistance_enabled';
  static const String videoTutorialsEnabled = 'video_tutorials_enabled';

  // Agent Portal Features
  static const String agentDashboardEnabled = 'agent_dashboard_enabled';
  static const String customerManagementEnabled = 'customer_management_enabled';
  static const String marketingCampaignsEnabled = 'marketing_campaigns_enabled';
  static const String contentManagementEnabled = 'content_management_enabled';
  static const String roiAnalyticsEnabled = 'roi_analytics_enabled';
  static const String commissionTrackingEnabled = 'commission_tracking_enabled';
  static const String leadManagementEnabled = 'lead_management_enabled';
  static const String advancedAnalyticsEnabled = 'advanced_analytics_enabled';
  static const String teamManagementEnabled = 'team_management_enabled';
  static const String regionalOversightEnabled = 'regional_oversight_enabled';

  // Administrative Features
  static const String userManagementEnabled = 'user_management_enabled';
  static const String featureFlagControlEnabled = 'feature_flag_control_enabled';
  static const String systemConfigurationEnabled = 'system_configuration_enabled';
  static const String auditComplianceEnabled = 'audit_compliance_enabled';
  static const String financialManagementEnabled = 'financial_management_enabled';
  static const String tenantManagementEnabled = 'tenant_management_enabled';
  static const String providerAdministrationEnabled = 'provider_administration_enabled';
}

/// Common permissions used throughout the app
class Permissions {
  // User Management
  static const String usersCreate = 'users.create';
  static const String usersRead = 'users.read';
  static const String usersUpdate = 'users.update';
  static const String usersDelete = 'users.delete';
  static const String usersSearch = 'users.search';

  // Agent Management
  static const String agentsCreate = 'agents.create';
  static const String agentsRead = 'agents.read';
  static const String agentsUpdate = 'agents.update';
  static const String agentsApprove = 'agents.approve';

  // Policy Management
  static const String policiesCreate = 'policies.create';
  static const String policiesRead = 'policies.read';
  static const String policiesUpdate = 'policies.update';
  static const String policiesApprove = 'policies.approve';

  // Customer Management
  static const String customersCreate = 'customers.create';
  static const String customersRead = 'customers.read';
  static const String customersUpdate = 'customers.update';

  // Reporting & Analytics
  static const String reportsRead = 'reports.read';
  static const String analyticsRead = 'analytics.read';

  // Tenant Management (Super Admin only)
  static const String tenantsCreate = 'tenants.create';
  static const String tenantsRead = 'tenants.read';
  static const String tenantsUpdate = 'tenants.update';
  static const String tenantsDelete = 'tenants.delete';

  // System Administration
  static const String systemAdmin = 'system.admin';
  static const String auditRead = 'audit.read';
}