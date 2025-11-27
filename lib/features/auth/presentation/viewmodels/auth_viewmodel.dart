/// Authentication ViewModel
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../../core/services/rbac_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth_response.dart';
import '../../data/models/user_model.dart';

class AuthViewModel extends BaseViewModel {
  final AuthRepository _authRepository;
  final RbacService _rbacService;

  AuthViewModel({
    AuthRepository? authRepository,
    RbacService? rbacService,
  }) : _authRepository = authRepository ?? AuthRepository(),
       _rbacService = rbacService ?? RbacService(ApiService(), LoggerService());

  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> initialize() async {
    await super.initialize();
    setLoading(true);
    try {
      _isAuthenticated = await _authRepository.isLoggedIn();
      if (_isAuthenticated) {
        // Verify token exists and is valid
        final storedToken = await _authRepository.getStoredToken();
        if (storedToken == null || storedToken.isEmpty) {
          // Token missing, user is not authenticated
          _isAuthenticated = false;
          _currentUser = null;
          return;
        }

        // Check if token is expired
        if (JwtDecoder.isTokenExpired(storedToken)) {
          // Token expired, user is not authenticated
          _isAuthenticated = false;
          _currentUser = null;
          await _authRepository.logout(); // Clear expired tokens
          return;
        }

        _currentUser = await _authRepository.getCurrentUser();

        // Initialize RBAC with stored JWT token
        await _rbacService.initializeWithJwtToken(storedToken);

        // Update user model with roles and permissions from stored JWT
        _currentUser = _currentUser?.copyWith(
          roles: JwtDecoder.extractRoles(storedToken),
          permissions: JwtDecoder.extractPermissions(storedToken),
        );
      } else {
        // Not logged in, clear any stale data
        _currentUser = null;
      }
    } catch (e) {
      setError('Failed to initialize authentication: $e');
      _isAuthenticated = false;
      _currentUser = null;
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

      // Initialize RBAC with JWT token data
      if (authResponse.accessToken != null) {
        await _rbacService.initializeWithJwtToken(authResponse.accessToken!);

        // Update user model with roles and permissions from JWT
        _currentUser = _currentUser?.copyWith(
          roles: JwtDecoder.extractRoles(authResponse.accessToken!),
          permissions: JwtDecoder.extractPermissions(authResponse.accessToken!),
        );
      }
      
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

      // Initialize RBAC with JWT token data
      if (authResponse.accessToken != null) {
        await _rbacService.initializeWithJwtToken(authResponse.accessToken!);

        // Update user model with roles and permissions from JWT
        _currentUser = _currentUser?.copyWith(
          roles: JwtDecoder.extractRoles(authResponse.accessToken!),
          permissions: JwtDecoder.extractPermissions(authResponse.accessToken!),
        );
      }
      
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

