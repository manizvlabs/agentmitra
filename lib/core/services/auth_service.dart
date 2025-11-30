import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/data/models/user_model.dart';

/// Authentication Service
/// Provides a simple interface for authentication operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get AuthViewModel from Provider context
  AuthViewModel? _getAuthViewModel(BuildContext? context) {
    if (context != null) {
      try {
        return Provider.of<AuthViewModel>(context, listen: false);
      } catch (e) {
        // Provider not available, fallback to service locator
      }
    }
    // Fallback to service locator
    try {
      return ServiceLocator.authViewModel;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated([BuildContext? context]) async {
    final authViewModel = _getAuthViewModel(context);
    if (authViewModel == null) {
      return false;
    }

    try {
      // Don't re-initialize if already authenticated, just check current state
      if (authViewModel.isAuthenticated) {
        return true;
      }

      // Only initialize if not already authenticated
      await authViewModel.initialize();
      return authViewModel.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get current user (synchronous)
  UserModel? get currentUser {
    try {
      return ServiceLocator.authViewModel.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser([BuildContext? context]) async {
    final authViewModel = _getAuthViewModel(context);
    if (authViewModel == null) {
      return null;
    }

    try {
      await authViewModel.initialize();
      return authViewModel.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout([BuildContext? context]) async {
    final authViewModel = _getAuthViewModel(context);
    if (authViewModel != null) {
      await authViewModel.logout();
    }
  }
}

