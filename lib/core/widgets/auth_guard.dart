import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/rbac_service.dart';
import 'error_pages/unauthorized_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

/// Auth Guard for route protection
/// Checks authentication before allowing route access
class AuthGuard {
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final authService = AuthService();
    return await authService.isAuthenticated();
  }

  /// Redirect to login if not authenticated
  static Widget redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.go('/login');
      }
    });
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Check RBAC permissions
  static Future<bool> hasPermission(
    RbacService rbacService,
    String permission,
  ) async {
    return await rbacService.hasPermission(permission);
  }

  /// Check if user has any of the required roles
  static bool hasAnyRole(
    RbacService rbacService,
    List<UserRole> requiredRoles,
  ) {
    final currentRole = rbacService.getCurrentUserRole();
    if (currentRole == null) return false;
    return requiredRoles.contains(currentRole);
  }
}

