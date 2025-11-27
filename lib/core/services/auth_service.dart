import '../di/service_locator.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/auth/data/models/user_model.dart';

/// Authentication Service
/// Provides a simple interface for authentication operations
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  AuthViewModel get _authViewModel => ServiceLocator.authViewModel;

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await _authViewModel.initialize();
      return _authViewModel.isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      await _authViewModel.initialize();
      return _authViewModel.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authViewModel.logout();
  }
}

