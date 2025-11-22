import 'package:flutter/material.dart';
import '../../features/agent/data/models/agent_profile_model.dart';

/// Mock AgentProfileViewModel for web compatibility
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
    _initializeMockProfile();
  }

  void _initializeMockProfile() {
    _profile = AgentProfile(
      agentId: 'agent_123',
      userId: 'user_123',
      agentCode: 'AGENT001',
      licenseNumber: 'LIC2023001',
      companyName: 'Agent Mitra',
      branchName: 'Mumbai Central',
      designation: 'Senior Insurance Agent',
      joiningDate: DateTime.now().subtract(const Duration(days: 365)),
      employmentStatus: 'active',
      contactDetails: {
        'phone': '+91 9876543210',
        'email': 'rajesh.kumar@agentmitra.com',
      },
      addressDetails: {
        'street': '123 MG Road',
        'city': 'Mumbai',
        'state': 'Maharashtra',
        'pincode': '400001',
        'country': 'India',
      },
      verificationStatus: 'verified',
      profileImageUrl: null,
    );
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
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
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _profile = updatedProfile;
    _isEditing = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Mock profile image update
    _profile = _profile?.copyWith(profileImageUrl: imagePath);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadProfile();
  }
}
