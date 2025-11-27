import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/rbac_service.dart';
import '../services/auth_service.dart';
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
      _isAuthenticated = await authService.isAuthenticated();

      if (!_isAuthenticated) {
        setState(() {
          _isLoading = false;
          _hasAccess = false;
        });
        return;
      }

      // Get RBAC service from provider
      RbacService? rbacService;
      try {
        rbacService = Provider.of<RbacService>(context, listen: false);
      } catch (e) {
        // If RbacService is not provided, try to get it from service locator or create instance
        // For now, we'll use AuthService to check authentication only
        setState(() {
          _isLoading = false;
          _hasAccess = false;
          _errorMessage = 'RBAC service not available. Please ensure RbacService is provided in the widget tree.';
        });
        return;
      }

      // Check role requirements
      if (widget.requiredRoles != null && widget.requiredRoles!.isNotEmpty) {
        final currentRole = rbacService.getCurrentUserRole();
        if (currentRole == null || !widget.requiredRoles!.contains(currentRole)) {
          setState(() {
            _isLoading = false;
            _hasAccess = false;
            _errorMessage = 'You do not have the required role to access this page.';
          });
          return;
        }
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
      // Redirect to login using GoRouter
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
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

