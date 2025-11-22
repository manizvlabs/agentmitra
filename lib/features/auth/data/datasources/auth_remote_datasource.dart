/// Remote data source for authentication API calls
import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  /// Login with phone number and password/agent code
  Future<AuthResponse> login({
    required String phoneNumber,
    String? password,
    String? agentCode,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      {
        'phone_number': phoneNumber,
        if (password != null) 'password': password,
        if (agentCode != null) 'agent_code': agentCode,
      },
    );
    return AuthResponse.fromJson(response);
  }

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    return await ApiService.post(
      ApiConstants.sendOtp,
      {'phone_number': phoneNumber},
    );
  }

  /// Verify OTP and get tokens
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await ApiService.post(
      ApiConstants.verifyOtp,
      {
        'phone_number': phoneNumber,
        'otp': otp,
      },
    );
    return AuthResponse.fromJson(response);
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await ApiService.post(
      ApiConstants.refreshToken,
      {'refresh_token': refreshToken},
    );
    return AuthResponse.fromJson(response);
  }

  /// Logout
  Future<void> logout() async {
    await ApiService.post(ApiConstants.logout, {});
  }

  /// Get current user profile
  Future<UserModel> getCurrentUser() async {
    final response = await ApiService.get(
      ApiConstants.userProfile('me'),
    );
    return UserModel.fromJson(response);
  }
}

