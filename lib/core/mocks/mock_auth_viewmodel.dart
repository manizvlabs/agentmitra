import 'package:flutter/material.dart';
import '../../features/auth/data/models/user_model.dart';

/// Mock AuthViewModel for web compatibility
class MockAuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> login(String phoneNumber, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock login delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful login
    _currentUser = UserModel(
      id: 'user_123',
      phoneNumber: phoneNumber,
      name: 'John Doe',
      email: 'john@example.com',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'user_123',
      phoneNumber: phoneNumber,
      name: 'John Doe',
      email: 'john@example.com',
      isVerified: true,
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    // Mock initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
