/// Authentication repository - combines remote and local data sources
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthRepository extends BaseRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepository({
    AuthRemoteDataSource? remoteDataSource,
    AuthLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
        _localDataSource = localDataSource ?? AuthLocalDataSource();

  /// Login with phone number and password/agent code
  Future<AuthResponse> login({
    required String phoneNumber,
    String? password,
    String? agentCode,
  }) async {
    try {
      final authResponse = await _remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
        agentCode: agentCode,
      );
      
      // Save tokens locally
      await _localDataSource.saveAuthTokens(authResponse);
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    return await _remoteDataSource.sendOtp(phoneNumber);
  }

  /// Verify OTP and get tokens
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final authResponse = await _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      
      // Save tokens locally
      await _localDataSource.saveAuthTokens(authResponse);
      
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken() async {
    final refreshToken = await _localDataSource.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final authResponse = await _remoteDataSource.refreshToken(refreshToken);
    await _localDataSource.saveAuthTokens(authResponse);
    
    return authResponse;
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    }
    await _localDataSource.clearAuth();
  }

  /// Get current user
  Future<UserModel> getCurrentUser() async {
    // Try to get from local first
    final localUser = _localDataSource.getUser();
    if (localUser != null) {
      return localUser;
    }
    
    // Fetch from remote
    final user = await _remoteDataSource.getCurrentUser();
    await _localDataSource.saveUser(user);
    
    return user;
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _localDataSource.isLoggedIn();
  }

  /// Get stored access token
  Future<String?> getStoredToken() async {
    return await _localDataSource.getAccessToken();
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _localDataSource.getAccessToken();
  }
}

