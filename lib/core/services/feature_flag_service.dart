import 'package:flutter/material.dart';
import 'api_service.dart';
import 'pioneer_service.dart';

/// Feature Flag Service for dynamic UI rendering based on permissions
class FeatureFlagService {
  final Map<String, bool> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  FeatureFlagService();

  /// Initialize the service (async for future use)
  Future<void> initialize() async {
    // Placeholder for future initialization logic
    return;
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

    // Get from Pioneer (will throw exception if not available)
    final result = PioneerService.isFeatureEnabledSync(flagName);

    // Cache the result
    _cache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return result;
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagName, {String? userId, String? tenantId}) async {
    // Check cache first
    final cacheKey = _getCacheKey(flagName, userId, tenantId);
    if (_cache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamps[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheDuration) {
        return _cache[cacheKey]!;
      }
    }

    // Get from Pioneer (will throw exception if not available)
    final result = await PioneerService.isFeatureEnabled(flagName);

    // Cache the result
    _cache[cacheKey] = result;
    _cacheTimestamps[cacheKey] = DateTime.now();

    return result;
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

  @override
  void initState() {
    super.initState();
    // Get the service from provider or locator
    // For now, we'll assume it's available via context or a global instance
    _loadFeatureFlag();
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