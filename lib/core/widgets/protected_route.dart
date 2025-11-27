import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/rbac_service.dart';
import '../services/auth_service.dart';
import '../di/service_locator.dart';
import 'error_pages/unauthorized_page.dart';

/// Protected Route Widget
/// Wraps routes with authentication and permission checks
class ProtectedRoute extends StatefulWidget {
  final Widget child;
  final List<UserRole>? requiredRoles;
  final List<String>? requiredPermissions; // Format: "resource.action"
  final String? redirectTo;

  const ProtectedRoute({
    super.key,
    required this.child,
    this.requiredRoles,
    this.requiredPermissions,
    this.redirectTo,
  });

  @override
  State<ProtectedRoute> createState() => _ProtectedRouteState();
}

class _ProtectedRouteState extends State<ProtectedRoute> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _hasAccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check authentication
      final authService = AuthService();
      _isAuthenticated = await authService.isAuthenticated(context);

      if (!_isAuthenticated) {
        setState(() {
          _isLoading = false;
          _hasAccess = false;
        });
        return;
      }

      // Get RBAC service from provider or service locator
      RbacService? rbacService;
      try {
        rbacService = Provider.of<RbacService>(context, listen: false);
      } catch (e) {
        // If not in provider, get from service locator
        try {
          rbacService = ServiceLocator.rbacService;
        } catch (e2) {
          // If still not available, create a new instance (shouldn't happen)
          setState(() {
            _isLoading = false;
            _hasAccess = false;
            _errorMessage = 'RBAC service not available. Please ensure RbacService is initialized.';
          });
          return;
        }
      }

      // Check role requirements
      if (widget.requiredRoles != null && widget.requiredRoles!.isNotEmpty) {
        final currentRole = rbacService.getCurrentUserRole();
        print('ProtectedRoute: Required roles: ${widget.requiredRoles}');
        print('ProtectedRoute: Current user role: $currentRole');
        print('ProtectedRoute: Route: ${ModalRoute.of(context)?.settings.name}');

        // Super admin has access to everything
        final isSuperAdmin = currentRole?.value == 'super_admin';
        final hasRequiredRole = currentRole != null && widget.requiredRoles!.contains(currentRole);

        if (!isSuperAdmin && !hasRequiredRole) {
          print('ProtectedRoute: Access denied - role check failed');
          setState(() {
            _isLoading = false;
            _hasAccess = false;
            _errorMessage = 'You do not have the required role to access this page.';
          });
          return;
        }
        print('ProtectedRoute: Role check passed (super_admin: $isSuperAdmin)');
      }

      // Check permission requirements
      if (widget.requiredPermissions != null && widget.requiredPermissions!.isNotEmpty) {
        bool hasAllPermissions = true;
        for (final permission in widget.requiredPermissions!) {
          final parts = permission.split('.');
          if (parts.length != 2) {
            hasAllPermissions = false;
            break;
          }
          final resource = parts[0];
          final action = parts[1];
          
          // Check permission using resource.action format
          final hasPermission = await rbacService.hasPermission(
            '$resource.$action',
          );
          
          if (!hasPermission) {
            hasAllPermissions = false;
            break;
          }
        }

        if (!hasAllPermissions) {
          setState(() {
            _isLoading = false;
            _hasAccess = false;
            _errorMessage = 'You do not have the required permissions to access this page.';
          });
          return;
        }
      }

      setState(() {
        _isLoading = false;
        _hasAccess = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasAccess = false;
        _errorMessage = 'Error checking access: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      // Redirect to login using Navigator (MaterialApp routing)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_hasAccess) {
      return UnauthorizedPage(
        message: _errorMessage,
      );
    }

    return widget.child;
  }
}

