import '../../core/architecture/base/base_viewmodel.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/models/auth_response.dart';
import 'mock_data.dart';

/// Production-grade Mock AuthViewModel for web compatibility
class MockAuthViewModel extends BaseViewModel {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    setLoading(true);
    try {
      // Mock initialization - check for existing session
      await Future.delayed(const Duration(milliseconds: 500));
      // For demo purposes, start logged out
      _isAuthenticated = false;
    } catch (e) {
      setError('Failed to initialize authentication: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Login with phone number and password/agent code
  Future<AuthResponse?> login({
    required String phoneNumber,
    String? password,
    String? agentCode,
  }) async {
    setLoading(true);
    clearError();

    try {
      // Mock login delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock successful login
      _currentUser = MockData.mockUser;
      _isAuthenticated = true;

      return AuthResponse(
        user: _currentUser!,
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
        tokenType: 'bearer',
        expiresIn: 1800,
      );
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    setLoading(true);
    clearError();

    try {
      await Future.delayed(const Duration(seconds: 1));

      // Mock OTP verification
      if (otp == '123456') {
        _currentUser = MockData.mockUser;
        _isAuthenticated = true;
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      setError('OTP verification failed: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> sendOtp(String phoneNumber) async {
    setLoading(true);
    clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock OTP sent
    } catch (e) {
      setError('Failed to send OTP: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    clearError();
    notifyListeners();
  }
}
