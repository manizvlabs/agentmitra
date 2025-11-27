/// RBAC (Role-Based Access Control) Service
/// Implements comprehensive role-based permissions and feature flag management
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'logger_service.dart';
import '../utils/jwt_decoder.dart';

/// User roles defined in the RBAC system
enum UserRole {
  superAdmin('super_admin', 'Super Admin', 'Full system access with complete control'),
  providerAdmin('insurance_provider_admin', 'Provider Admin', 'Insurance provider management and tenant administration'),
  regionalManager('regional_manager', 'Regional Manager', 'Regional operations and team management'),
  seniorAgent('senior_agent', 'Senior Agent', 'Advanced agent operations and marketing capabilities'),
  juniorAgent('junior_agent', 'Junior Agent', 'Basic agent operations and customer management'),
  policyholder('policyholder', 'Policyholder', 'Customer access to policies and services'),
  supportStaff('support_staff', 'Support Staff', 'Customer service and technical support'),
  guestUser('guest_user', 'Guest User', 'Trial/Prospective user access');

  const UserRole(this.value, this.displayName, this.description);
  final String value;
  final String displayName;
  final String description;

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.guestUser,
    );
  }
}

/// Permission categories and actions
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

  // Feature Flag Management
  static const String featureFlagsRead = 'feature_flags.read';
  static const String featureFlagsUpdate = 'feature_flags.update';

  // Campaign Management
  static const String campaignsCreate = 'campaigns.create';
  static const String campaignsRead = 'campaigns.read';
  static const String campaignsUpdate = 'campaigns.update';
  static const String campaignsDelete = 'campaigns.delete';

  // Data Import & Templates
  static const String dataImportCreate = 'data_import.create';
  static const String dataImportRead = 'data_import.read';
  static const String dataImportUpdate = 'data_import.update';
  static const String dataImportDelete = 'data_import.delete';
  static const String templatesRead = 'templates.read';
  static const String templatesCreate = 'templates.create';
  static const String templatesUpdate = 'templates.update';
  static const String templatesDelete = 'templates.delete';

  // Reporting
  static const String reportsGenerate = 'reports.generate';
  static const String reportsSchedule = 'reports.schedule';
}

/// Feature flags for dynamic UI rendering
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

/// Role hierarchy and permission mappings
class RolePermissions {
  static const Map<UserRole, List<String>> rolePermissions = {
    UserRole.superAdmin: [
      // All permissions
      Permissions.usersCreate, Permissions.usersRead, Permissions.usersUpdate, Permissions.usersDelete, Permissions.usersSearch,
      Permissions.agentsCreate, Permissions.agentsRead, Permissions.agentsUpdate, Permissions.agentsApprove,
      Permissions.policiesCreate, Permissions.policiesRead, Permissions.policiesUpdate, Permissions.policiesApprove,
      Permissions.customersCreate, Permissions.customersRead, Permissions.customersUpdate,
      Permissions.reportsRead, Permissions.analyticsRead,
      Permissions.tenantsCreate, Permissions.tenantsRead, Permissions.tenantsUpdate, Permissions.tenantsDelete,
      Permissions.systemAdmin, Permissions.auditRead,
      Permissions.featureFlagsRead, Permissions.featureFlagsUpdate,
      Permissions.campaignsCreate, Permissions.campaignsRead, Permissions.campaignsUpdate, Permissions.campaignsDelete,
    ],
    UserRole.providerAdmin: [
      Permissions.usersRead, Permissions.usersUpdate, Permissions.usersSearch,
      Permissions.agentsCreate, Permissions.agentsRead, Permissions.agentsUpdate, Permissions.agentsApprove,
      Permissions.policiesCreate, Permissions.policiesRead, Permissions.policiesUpdate, Permissions.policiesApprove,
      Permissions.customersCreate, Permissions.customersRead, Permissions.customersUpdate,
      Permissions.reportsRead, Permissions.reportsGenerate, Permissions.reportsSchedule, Permissions.analyticsRead,
      Permissions.tenantsRead, Permissions.tenantsUpdate,
      Permissions.auditRead,
      Permissions.featureFlagsRead, Permissions.featureFlagsUpdate,
      Permissions.campaignsCreate, Permissions.campaignsRead, Permissions.campaignsUpdate, Permissions.campaignsDelete,
      Permissions.dataImportCreate, Permissions.dataImportRead, Permissions.dataImportUpdate,
      Permissions.templatesRead, Permissions.templatesCreate, Permissions.templatesUpdate,
    ],
    UserRole.regionalManager: [
      Permissions.agentsRead, Permissions.agentsUpdate,
      Permissions.customersRead, Permissions.customersUpdate,
      Permissions.reportsRead, Permissions.reportsGenerate, Permissions.analyticsRead,
      Permissions.campaignsCreate, Permissions.campaignsRead, Permissions.campaignsUpdate,
      Permissions.dataImportRead,
      Permissions.templatesRead,
    ],
    UserRole.seniorAgent: [
      Permissions.customersCreate, Permissions.customersRead, Permissions.customersUpdate,
      Permissions.policiesCreate, Permissions.policiesRead, Permissions.policiesUpdate,
      Permissions.reportsRead, Permissions.analyticsRead,
      Permissions.campaignsCreate, Permissions.campaignsRead, Permissions.campaignsUpdate,
    ],
    UserRole.juniorAgent: [
      Permissions.customersCreate, Permissions.customersRead, Permissions.customersUpdate,
      Permissions.policiesCreate, Permissions.policiesRead,
      Permissions.reportsRead,
    ],
    UserRole.policyholder: [
      Permissions.policiesRead,
      Permissions.customersRead,
    ],
    UserRole.supportStaff: [
      Permissions.customersRead,
      Permissions.policiesRead,
      Permissions.reportsRead,
    ],
    UserRole.guestUser: [
      // Limited permissions for trial users
    ],
  };

  static List<String> getPermissionsForRole(UserRole role) {
    return rolePermissions[role] ?? [];
  }
}

/// RBAC Service for managing role-based access control
class RbacService {
  final ApiService _apiService;
  final LoggerService _logger;

  // Cache for permissions and feature flags
  final Map<String, bool> _permissionCache = {};
  final Map<String, bool> _featureFlagCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  UserRole? _currentUserRole;
  List<String> _currentUserPermissions = [];
  List<String> _currentUserRoles = [];

  RbacService(this._apiService, this._logger);

  /// Initialize RBAC service with JWT token data
  Future<void> initializeWithJwtToken(String jwtToken) async {
    try {
      // Extract data from JWT token
      final roles = JwtDecoder.extractRoles(jwtToken);
      final permissions = JwtDecoder.extractPermissions(jwtToken);
      final userId = JwtDecoder.extractUserId(jwtToken);
      final legacyRole = JwtDecoder.extractRole(jwtToken);

      // Set current user data
      _currentUserRoles = roles ?? [];
      _currentUserPermissions = permissions ?? [];
      _currentUserRole = _determinePrimaryRole(_currentUserRoles);

      // Only use static permissions if no permissions came from JWT
      if ((_currentUserPermissions?.isEmpty ?? true) && _currentUserRole != null) {
        _currentUserPermissions = RolePermissions.getPermissionsForRole(_currentUserRole!);
      }

      // If no roles in JWT, try to use legacy role field
      if ((_currentUserRoles?.isEmpty ?? true) && _currentUserRole == UserRole.guestUser && legacyRole != null) {
        final parsedRole = UserRole.fromString(legacyRole);
        if (parsedRole != null) {
          _currentUserRole = parsedRole;
          _currentUserRoles = [_currentUserRole!.value];
          // Only set static permissions if we still don't have any
          if (_currentUserPermissions?.isEmpty ?? true) {
            _currentUserPermissions = RolePermissions.getPermissionsForRole(_currentUserRole!);
          }
        }
      }

      _logger.info('RBAC service initialized from JWT for user: $userId, role: ${_currentUserRole?.displayName}, permissions: ${permissions.length}');

    } catch (e) {
      _logger.error('Failed to initialize RBAC service from JWT', error: e);
      // Fallback to guest user permissions
      _currentUserRole = UserRole.guestUser;
      _currentUserPermissions = RolePermissions.getPermissionsForRole(UserRole.guestUser);
      _currentUserRoles = [];
    }
  }

  /// Initialize RBAC service with user context (fallback method)
  Future<void> initializeWithUser(String userId) async {
    try {
      await _loadUserRolesAndPermissions(userId);
      _logger.info('RBAC service initialized for user: $userId');
    } catch (e) {
      _logger.error('Failed to initialize RBAC service', error: e);
      // Fallback to guest user permissions
      _currentUserRole = UserRole.guestUser;
      _currentUserPermissions = RolePermissions.getPermissionsForRole(UserRole.guestUser);
    }
  }

  /// Load user roles and permissions from backend
  Future<void> _loadUserRolesAndPermissions(String userId) async {
    try {
      final response = await ApiService.get('/rbac/users/$userId/roles');
      _currentUserRoles = List<String>.from(response['roles'] ?? []);
      _currentUserPermissions = List<String>.from(response['permissions'] ?? []);

      // Determine primary role (first role in hierarchy)
      _currentUserRole = _determinePrimaryRole(_currentUserRoles);

    } catch (e) {
      _logger.error('Failed to load user roles and permissions', error: e);
      throw e;
    }
  }

  /// Determine primary role from list of roles
  UserRole _determinePrimaryRole(List<String> roles) {
    // Role hierarchy (highest to lowest priority)
    final roleHierarchy = [
      UserRole.superAdmin,
      UserRole.providerAdmin,
      UserRole.regionalManager,
      UserRole.seniorAgent,
      UserRole.juniorAgent,
      UserRole.supportStaff,
      UserRole.policyholder,
      UserRole.guestUser,
    ];

    for (final role in roleHierarchy) {
      if (roles.contains(role.value)) {
        return role;
      }
    }

    return UserRole.guestUser;
  }

  /// Check if user has a specific permission
  Future<bool> hasPermission(String permission, {String? userId}) async {
    // Check cache first
    final cacheKey = 'perm_${userId ?? 'current'}_$permission';
    if (_permissionCache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamps[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheDuration) {
        return _permissionCache[cacheKey]!;
      }
    }

    try {
      // If checking for current user, use cached permissions
      if (userId == null) {
        final hasPerm = _currentUserPermissions.contains(permission);
        _permissionCache[cacheKey] = hasPerm;
        _cacheTimestamps[cacheKey] = DateTime.now();
        return hasPerm;
      }

      // For other users, check via API
      final response = await ApiService.get('/rbac/check-permission',
        queryParameters: {'permission': permission, 'user_id': userId}
      );
      final hasPerm = response['has_permission'] as bool;
      _permissionCache[cacheKey] = hasPerm;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return hasPerm;

    } catch (e) {
      _logger.error('Failed to check permission: $permission', error: e);
      return false; // Fail safe - deny permission on error
    }
  }

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagName, {String? tenantId}) async {
    // Check cache first
    final cacheKey = 'flag_${tenantId ?? 'global'}_$flagName';
    if (_featureFlagCache.containsKey(cacheKey)) {
      final cachedTime = _cacheTimestamps[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheDuration) {
        return _featureFlagCache[cacheKey]!;
      }
    }

    try {
      // For now, return true based on role permissions
      // In production, this would check feature flags from backend
      final isEnabled = await _checkFeatureFlagBasedOnRole(flagName);
      _featureFlagCache[cacheKey] = isEnabled;
      _cacheTimestamps[cacheKey] = DateTime.now();
      return isEnabled;

    } catch (e) {
      _logger.error('Failed to check feature flag: $flagName', error: e);
      return false; // Fail safe - disable feature on error
    }
  }

  /// Check feature flag based on current user's role
  Future<bool> _checkFeatureFlagBasedOnRole(String flagName) async {
    if (_currentUserRole == null) return false;

    // Feature flag access based on roles
    switch (flagName) {
      // Customer Portal Features
      case FeatureFlags.customerDashboardEnabled:
      case FeatureFlags.policyManagementEnabled:
      case FeatureFlags.premiumPaymentsEnabled:
      case FeatureFlags.documentAccessEnabled:
      case FeatureFlags.communicationToolsEnabled:
      case FeatureFlags.learningCenterEnabled:
      case FeatureFlags.profileManagementEnabled:
        return [
          UserRole.policyholder,
          UserRole.superAdmin,
          UserRole.providerAdmin,
          UserRole.regionalManager,
          UserRole.seniorAgent,
          UserRole.juniorAgent,
          UserRole.supportStaff,
        ].contains(_currentUserRole);

      // Agent Portal Features
      case FeatureFlags.agentDashboardEnabled:
      case FeatureFlags.customerManagementEnabled:
        return [
          UserRole.superAdmin,
          UserRole.providerAdmin,
          UserRole.regionalManager,
          UserRole.seniorAgent,
          UserRole.juniorAgent,
        ].contains(_currentUserRole);

      case FeatureFlags.marketingCampaignsEnabled:
      case FeatureFlags.roiAnalyticsEnabled:
      case FeatureFlags.commissionTrackingEnabled:
        return [
          UserRole.superAdmin,
          UserRole.providerAdmin,
          UserRole.regionalManager,
          UserRole.seniorAgent,
        ].contains(_currentUserRole);

      // Administrative Features
      case FeatureFlags.userManagementEnabled:
      case FeatureFlags.systemConfigurationEnabled:
      case FeatureFlags.auditComplianceEnabled:
      case FeatureFlags.tenantManagementEnabled:
        return [
          UserRole.superAdmin,
          UserRole.providerAdmin,
        ].contains(_currentUserRole);

      default:
        return true; // Default to enabled for unknown flags
    }
  }

  /// Get current user's role
  UserRole? getCurrentUserRole() => _currentUserRole;

  /// Get current user's permissions
  List<String> getCurrentUserPermissions() => _currentUserPermissions;

  /// Get current user's roles
  List<String> getCurrentUserRoles() => _currentUserRoles;

  /// Check if user can access a specific screen/feature
  Future<bool> canAccessFeature(String featureName) async {
    // Map feature names to required permissions
    final featurePermissions = {
      'dashboard': [Permissions.analyticsRead],
      'user_management': [Permissions.usersRead],
      'agent_management': [Permissions.agentsRead],
      'policy_management': [Permissions.policiesRead],
      'customer_management': [Permissions.customersRead],
      'campaign_management': [Permissions.campaignsRead],
      'reports': [Permissions.reportsRead],
      'analytics': [Permissions.analyticsRead],
      'settings': [Permissions.systemAdmin],
      'audit_logs': [Permissions.auditRead],
      'feature_flags': [Permissions.featureFlagsRead],
    };

    final requiredPermissions = featurePermissions[featureName] ?? [];
    if (requiredPermissions.isEmpty) return true;

    // Check if user has any of the required permissions
    for (final permission in requiredPermissions) {
      if (await hasPermission(permission)) {
        return true;
      }
    }

    return false;
  }

  /// Clear all caches
  void clearCache() {
    _permissionCache.clear();
    _featureFlagCache.clear();
    _cacheTimestamps.clear();
    _logger.info('RBAC cache cleared');
  }

  /// Refresh user permissions (call after role changes)
  Future<void> refreshUserPermissions(String userId) async {
    await _loadUserRolesAndPermissions(userId);
    clearCache();
    _logger.info('User permissions refreshed for: $userId');
  }
}

/// Extension methods for easier RBAC usage
// Note: Removed BuildContext extension as it's causing import issues
// RBAC service should be accessed via Provider in widgets
