/// Local data source for authentication (SharedPreferences)
import '../../../../core/services/storage_service.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  /// Save authentication tokens
  Future<void> saveAuthTokens(AuthResponse authResponse) async {
    await StorageService.setString(_keyAccessToken, authResponse.accessToken);
    await StorageService.setString(_keyRefreshToken, authResponse.refreshToken);
    await StorageService.setBool(_keyIsLoggedIn, true);
    
    if (authResponse.user != null) {
      await saveUser(authResponse.user!);
    }
  }

  /// Get access token
  String? getAccessToken() {
    return StorageService.getString(_keyAccessToken);
  }

  /// Get refresh token
  String? getRefreshToken() {
    return StorageService.getString(_keyRefreshToken);
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return StorageService.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    // In a real app, you'd serialize to JSON
    // For now, storing key fields
    await StorageService.setString('${_keyUser}_id', user.userId);
    await StorageService.setString('${_keyUser}_phone', user.phoneNumber);
    if (user.fullName != null) {
      await StorageService.setString('${_keyUser}_name', user.fullName!);
    }
    if (user.role != null) {
      await StorageService.setString('${_keyUser}_role', user.role!);
    }
  }

  /// Get user data
  UserModel? getUser() {
    final userId = StorageService.getString('${_keyUser}_id');
    final phoneNumber = StorageService.getString('${_keyUser}_phone');
    
    if (userId == null || phoneNumber == null) {
      return null;
    }

    return UserModel(
      userId: userId,
      phoneNumber: phoneNumber,
      fullName: StorageService.getString('${_keyUser}_name'),
      role: StorageService.getString('${_keyUser}_role'),
    );
  }

  /// Clear authentication data
  Future<void> clearAuth() async {
    await StorageService.remove(_keyAccessToken);
    await StorageService.remove(_keyRefreshToken);
    await StorageService.remove(_keyIsLoggedIn);
    await StorageService.remove('${_keyUser}_id');
    await StorageService.remove('${_keyUser}_phone');
    await StorageService.remove('${_keyUser}_name');
    await StorageService.remove('${_keyUser}_role');
  }
}

