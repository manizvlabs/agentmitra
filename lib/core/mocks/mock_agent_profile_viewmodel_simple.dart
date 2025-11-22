import 'package:flutter/material.dart';
import '../../features/agent/data/models/agent_model.dart';
import 'mock_data.dart';

/// Production-grade Mock AgentProfileViewModel for web compatibility
class MockAgentProfileViewModel extends ChangeNotifier {
  AgentProfile? _profile;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _error;

  AgentProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get error => _error;

  MockAgentProfileViewModel() {
    _profile = MockData.mockAgentProfile;
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Profile is already loaded in constructor
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void startEditing() {
    _isEditing = true;
    notifyListeners();
  }

  void cancelEditing() {
    _isEditing = false;
    notifyListeners();
  }

  Future<void> updateProfile(AgentProfile updatedProfile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _profile = updatedProfile;
      _isEditing = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _profile = _profile?.copyWith(profileImageUrl: imagePath);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile image: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to change password: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    await loadProfile();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
