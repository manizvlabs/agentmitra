import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rbac_service.dart';
import '../services/logger_service.dart';

/// Permission-based widget that conditionally renders content
class PermissionWidget extends StatefulWidget {
  final String permission;
  final Widget Function() builder;
  final Widget Function()? fallbackBuilder;
  final Widget Function()? loadingBuilder;
  final String? userId;

  const PermissionWidget({
    Key? key,
    required this.permission,
    required this.builder,
    this.fallbackBuilder,
    this.loadingBuilder,
    this.userId,
  }) : super(key: key);

  @override
  State<PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<PermissionWidget> {
  bool? _hasPermission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-check permission if widget parameters change
    if (widget.permission != _lastCheckedPermission) {
      _checkPermission();
    }
  }

  String? _lastCheckedPermission;

  Future<void> _checkPermission() async {
    _lastCheckedPermission = widget.permission;
    setState(() => _isLoading = true);

    try {
      // TODO: Get RBAC service from provider
      // For now, we'll use a placeholder implementation
      _hasPermission = await _checkPermissionFromService();
    } catch (e) {
      LoggerService().error('Failed to check permission: ${widget.permission}', error: e);
      _hasPermission = false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkPermissionFromService() async {
    try {
      final rbacService = Provider.of<RbacService>(context, listen: false);
      return await rbacService.hasPermission(widget.permission, userId: widget.userId);
    } catch (e) {
      LoggerService().error('Failed to check permission via RBAC service', error: e);
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
            child: CircularProgressIndicator(strokeWidth: 2),
          );
    }

    if (_hasPermission == true) {
      return widget.builder();
    } else {
      return widget.fallbackBuilder?.call() ??
          const SizedBox.shrink(); // Hidden when no permission
    }
  }
}

/// Feature flag-based widget that conditionally renders content
class FeatureFlagWidget extends StatefulWidget {
  final String flagName;
  final Widget Function() builder;
  final Widget Function()? fallbackBuilder;
  final Widget Function()? loadingBuilder;
  final String? tenantId;

  const FeatureFlagWidget({
    Key? key,
    required this.flagName,
    required this.builder,
    this.fallbackBuilder,
    this.loadingBuilder,
    this.tenantId,
  }) : super(key: key);

  @override
  State<FeatureFlagWidget> createState() => _FeatureFlagWidgetState();
}

class _FeatureFlagWidgetState extends State<FeatureFlagWidget> {
  bool? _isEnabled;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFeatureFlag();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.flagName != _lastCheckedFlag) {
      _checkFeatureFlag();
    }
  }

  String? _lastCheckedFlag;

  Future<void> _checkFeatureFlag() async {
    _lastCheckedFlag = widget.flagName;
    setState(() => _isLoading = true);

    try {
      // TODO: Get RBAC service from provider
      _isEnabled = await _checkFeatureFlagFromService();
    } catch (e) {
      LoggerService().error('Failed to check feature flag: ${widget.flagName}', error: e);
      _isEnabled = false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkFeatureFlagFromService() async {
    try {
      final rbacService = Provider.of<RbacService>(context, listen: false);
      return await rbacService.isFeatureEnabled(widget.flagName, tenantId: widget.tenantId);
    } catch (e) {
      LoggerService().error('Failed to check feature flag via RBAC service', error: e);
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
            child: CircularProgressIndicator(strokeWidth: 2),
          );
    }

    if (_isEnabled == true) {
      return widget.builder();
    } else {
      return widget.fallbackBuilder?.call() ??
          const SizedBox.shrink(); // Hidden when feature disabled
    }
  }
}

/// Role-based widget that conditionally renders content
class RoleWidget extends StatefulWidget {
  final List<UserRole> allowedRoles;
  final Widget Function() builder;
  final Widget Function()? fallbackBuilder;
  final Widget Function()? loadingBuilder;

  const RoleWidget({
    Key? key,
    required this.allowedRoles,
    required this.builder,
    this.fallbackBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  State<RoleWidget> createState() => _RoleWidgetState();
}

class _RoleWidgetState extends State<RoleWidget> {
  UserRole? _currentRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Get current user role from RBAC service
      _currentRole = await _getCurrentUserRole();
    } catch (e) {
      LoggerService().error('Failed to check user role', error: e);
      _currentRole = UserRole.guestUser;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserRole> _getCurrentUserRole() async {
    try {
      final rbacService = Provider.of<RbacService>(context, listen: false);
      return rbacService.getCurrentUserRole() ?? UserRole.guestUser;
    } catch (e) {
      LoggerService().error('Failed to get current user role via RBAC service', error: e);
      return UserRole.guestUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call() ??
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
    }

    if (_currentRole != null && widget.allowedRoles.contains(_currentRole)) {
      return widget.builder();
    } else {
      return widget.fallbackBuilder?.call() ??
          const SizedBox.shrink(); // Hidden when role not allowed
    }
  }
}

/// Permission guard that wraps widgets and shows access denied message
class PermissionGuard extends StatelessWidget {
  final String permission;
  final Widget child;
  final String? accessDeniedMessage;
  final Widget Function()? accessDeniedBuilder;

  const PermissionGuard({
    Key? key,
    required this.permission,
    required this.child,
    this.accessDeniedMessage,
    this.accessDeniedBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionWidget(
      permission: permission,
      builder: () => child,
      fallbackBuilder: accessDeniedBuilder ?? () => _buildAccessDenied(context),
    );
  }

  Widget _buildAccessDenied(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              accessDeniedMessage ?? 'You do not have permission to access this feature.',
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature flag guard that wraps widgets and shows feature disabled message
class FeatureFlagGuard extends StatelessWidget {
  final String flagName;
  final Widget child;
  final String? disabledMessage;
  final Widget Function()? disabledBuilder;

  const FeatureFlagGuard({
    Key? key,
    required this.flagName,
    required this.child,
    this.disabledMessage,
    this.disabledBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FeatureFlagWidget(
      flagName: flagName,
      builder: () => child,
      fallbackBuilder: disabledBuilder ?? () => _buildFeatureDisabled(context),
    );
  }

  Widget _buildFeatureDisabled(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility_off, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              disabledMessage ?? 'This feature is currently disabled.',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Role guard that wraps widgets and shows role access message
class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final String? accessDeniedMessage;
  final Widget Function()? accessDeniedBuilder;

  const RoleGuard({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.accessDeniedMessage,
    this.accessDeniedBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoleWidget(
      allowedRoles: allowedRoles,
      builder: () => child,
      fallbackBuilder: accessDeniedBuilder ?? () => _buildRoleAccessDenied(context),
    );
  }

  Widget _buildRoleAccessDenied(BuildContext context) {
    final roleNames = allowedRoles.map((role) => role.displayName).join(', ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.person_off, color: Colors.amber.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              accessDeniedMessage ?? 'This feature requires one of the following roles: $roleNames',
              style: TextStyle(color: Colors.amber.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension methods for easier RBAC widget usage
extension RbacWidgetExtensions on Widget {
  /// Wrap widget with permission check
  Widget withPermission(String permission, {String? accessDeniedMessage}) {
    return PermissionGuard(
      permission: permission,
      accessDeniedMessage: accessDeniedMessage,
      child: this,
    );
  }

  /// Wrap widget with feature flag check
  Widget withFeatureFlag(String flagName, {String? disabledMessage}) {
    return FeatureFlagGuard(
      flagName: flagName,
      disabledMessage: disabledMessage,
      child: this,
    );
  }

  /// Wrap widget with role check
  Widget withRoles(List<UserRole> allowedRoles, {String? accessDeniedMessage}) {
    return RoleGuard(
      allowedRoles: allowedRoles,
      accessDeniedMessage: accessDeniedMessage,
      child: this,
    );
  }
}
