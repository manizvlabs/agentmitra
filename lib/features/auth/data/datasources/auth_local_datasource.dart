/// Local data source for authentication (Secure Storage + SharedPreferences)
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/services/storage_service.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Secure storage instance for sensitive data
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Save authentication tokens (tokens go to secure storage)
  Future<void> saveAuthTokens(AuthResponse authResponse) async {
    // Store sensitive tokens in secure storage
    await _secureStorage.write(key: _keyAccessToken, value: authResponse.accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: authResponse.refreshToken);

    // Store login status in regular storage (not sensitive)
    await StorageService.setBool(_keyIsLoggedIn, true);
    
    if (authResponse.user != null) {
      await saveUser(authResponse.user!);
    }
  }

  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Get refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  /// Check if user is logged in
  /// Returns true only if login flag is set AND access token exists
  Future<bool> isLoggedIn() async {
    final loginFlag = StorageService.getBool(_keyIsLoggedIn) ?? false;
    if (!loginFlag) {
      return false;
    }
    
    // Also verify that access token exists
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    // Store user data in regular storage (not sensitive)
    await StorageService.setString('${_keyUser}_id', user.userId);
    await StorageService.setString('${_keyUser}_phone', user.phoneNumber);
    if (user.fullName != null) {
      await StorageService.setString('${_keyUser}_name', user.fullName!);
    }
    if (user.role != null) {
      await StorageService.setString('${_keyUser}_role', user.role!);
    }
    // Store roles and permissions as JSON strings
    await StorageService.setString('${_keyUser}_roles', user.roles.join(','));
    await StorageService.setString('${_keyUser}_permissions', user.permissions.join(','));
  }

  /// Get user data
  UserModel? getUser() {
    final userId = StorageService.getString('${_keyUser}_id');
    final phoneNumber = StorageService.getString('${_keyUser}_phone');
    
    if (userId == null || phoneNumber == null) {
      return null;
    }

    // Parse roles and permissions from stored strings
    final rolesString = StorageService.getString('${_keyUser}_roles');
    final permissionsString = StorageService.getString('${_keyUser}_permissions');

    final roles = rolesString != null && rolesString.isNotEmpty
        ? rolesString.split(',').where((r) => r.isNotEmpty).toList()
        : <String>[];

    final permissions = permissionsString != null && permissionsString.isNotEmpty
        ? permissionsString.split(',').where((p) => p.isNotEmpty).toList()
        : <String>[];

    return UserModel(
      userId: userId,
      phoneNumber: phoneNumber,
      fullName: StorageService.getString('${_keyUser}_name'),
      role: StorageService.getString('${_keyUser}_role'),
      roles: roles,
      permissions: permissions,
    );
  }

  /// Clear authentication data
  Future<void> clearAuth() async {
    // Clear secure storage (tokens)
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);

    // Clear regular storage (user data and login status)
    await StorageService.remove(_keyIsLoggedIn);
    await StorageService.remove('${_keyUser}_id');
    await StorageService.remove('${_keyUser}_phone');
    await StorageService.remove('${_keyUser}_name');
    await StorageService.remove('${_keyUser}_role');
    await StorageService.remove('${_keyUser}_roles');
    await StorageService.remove('${_keyUser}_permissions');
  }
}

