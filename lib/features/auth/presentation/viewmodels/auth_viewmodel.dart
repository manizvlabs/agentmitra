/// Authentication ViewModel
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    setLoading(true);
    try {
      _isAuthenticated = _authRepository.isLoggedIn();
      if (_isAuthenticated) {
        _currentUser = await _authRepository.getCurrentUser();
      }
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
      final authResponse = await _authRepository.login(
        phoneNumber: phoneNumber,
        password: password,
        agentCode: agentCode,
      );
      
      _currentUser = authResponse.user;
      _isAuthenticated = true;
      
      return authResponse;
    } catch (e) {
      setError('Login failed: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    setLoading(true);
    clearError();
    
    try {
      await _authRepository.sendOtp(phoneNumber);
      return true;
    } catch (e) {
      setError('Failed to send OTP: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Verify OTP
  Future<AuthResponse?> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    setLoading(true);
    clearError();
    
    try {
      final authResponse = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      
      _currentUser = authResponse.user;
      _isAuthenticated = true;
      
      return authResponse;
    } catch (e) {
      setError('OTP verification failed: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Logout
  Future<void> logout() async {
    setLoading(true);
    clearError();
    
    try {
      await _authRepository.logout();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      setError('Logout failed: $e');
    } finally {
      setLoading(false);
    }
  }
}

