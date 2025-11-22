import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/agent_repository.dart';
import '../../data/datasources/agent_remote_datasource.dart';
import '../../data/datasources/agent_local_datasource.dart';
import '../../data/models/agent_model.dart';

class AgentProfileViewModel extends ChangeNotifier {
  final AgentRepository _agentRepository;
  final String agentId;

  AgentProfileViewModel([
    AgentRepository? agentRepository,
    String? agentId,
  ])  : _agentRepository = agentRepository ?? AgentRepository(AgentRemoteDataSourceImpl(Dio()), AgentLocalDataSourceImpl()),
        agentId = agentId ?? 'current-agent' {
    // Initialize with mock data for Phase 5 testing
    _initializeMockData();
  }

  // State
  AgentProfile? _profile;
  AgentPerformance? _performance;
  bool _isLoading = false;
  String? _error;

  // Form state for editing
  String _companyName = '';
  String _branchName = '';
  String _designation = '';
  String _licenseNumber = '';
  DateTime? _licenseExpiryDate;

  // Getters
  AgentProfile? get profile => _profile;
  AgentPerformance? get performance => _performance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Form getters
  String get companyName => _companyName;
  String get branchName => _branchName;
  String get designation => _designation;
  String get licenseNumber => _licenseNumber;
  DateTime? get licenseExpiryDate => _licenseExpiryDate;

  // Computed properties
  bool get isProfileComplete => _profile != null &&
      (_profile!.companyName?.isNotEmpty ?? false) &&
      (_profile!.licenseNumber?.isNotEmpty ?? false);

  bool get isLicenseExpiringSoon {
    if (_profile?.licenseExpiryDate == null) return false;
    final expiryDate = DateTime.parse(_profile!.licenseExpiryDate!);
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isLicenseExpired {
    if (_profile?.licenseExpiryDate == null) return false;
    final expiryDate = DateTime.parse(_profile!.licenseExpiryDate!);
    return expiryDate.isBefore(DateTime.now());
  }

  String get licenseStatus {
    if (isLicenseExpired) return 'Expired';
    if (isLicenseExpiringSoon) return 'Expiring Soon';
    return 'Valid';
  }

  // Actions
  Future<void> loadAgentProfile({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load profile
      final profileResult = await _agentRepository.getAgentProfile(agentId, forceRefresh: forceRefresh);
      profileResult.fold(
        (error) => _error = error.toString(),
        (profile) {
          _profile = profile;
          // Initialize form fields
          _companyName = profile.companyName ?? '';
          _branchName = profile.branchName ?? '';
          _designation = profile.designation ?? '';
          _licenseNumber = profile.licenseNumber ?? '';
          _licenseExpiryDate = profile.licenseExpiryDate;
        },
      );

      // Load performance data
      final performanceResult = await _agentRepository.getAgentPerformance(agentId);
      performanceResult.fold(
        (error) => _error = error.toString(),
        (performance) => _performance = performance,
      );
    } catch (e) {
      _error = 'Failed to load agent profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    await loadAgentProfile(forceRefresh: true);
  }

  // Form actions
  void updateCompanyName(String value) {
    _companyName = value;
    notifyListeners();
  }

  void updateBranchName(String value) {
    _branchName = value;
    notifyListeners();
  }

  void updateDesignation(String value) {
    _designation = value;
    notifyListeners();
  }

  void updateLicenseNumber(String value) {
    _licenseNumber = value;
    notifyListeners();
  }

  void updateLicenseExpiryDate(DateTime? date) {
    _licenseExpiryDate = date;
    notifyListeners();
  }

  // Profile update
  Future<Either<Exception, AgentProfile>> updateProfile() async {
    final profileData = {
      'company_name': _companyName,
      'branch_name': _branchName,
      'designation': _designation,
      'license_number': _licenseNumber,
      if (_licenseExpiryDate != null) 'license_expiry_date': _licenseExpiryDate!.toIso8601String(),
    };

    final result = await _agentRepository.updateAgentProfile(agentId, profileData);

    result.fold(
      (error) => _error = error.toString(),
      (updatedProfile) => _profile = updatedProfile,
    );

    notifyListeners();
    return result;
  }

  // File upload
  Future<Either<Exception, String>> uploadProfileImage(String imagePath) async {
    final result = await _agentRepository.uploadProfileImage(agentId, imagePath);

    result.fold(
      (error) => _error = error.toString(),
      (imageUrl) {
        // Update profile with new image URL
        if (_profile != null) {
          _profile = _profile!.copyWith(profileImageUrl: imageUrl);
        }
      },
    );

    notifyListeners();
    return result;
  }

  Future<Either<Exception, String>> uploadDocument(String documentPath, String documentType) async {
    final result = await _agentRepository.uploadDocument(agentId, documentPath, documentType);
    return result;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset form to current profile values
  void resetForm() {
    if (_profile != null) {
      _companyName = _profile!.companyName ?? '';
      _branchName = _profile!.branchName ?? '';
      _designation = _profile!.designation ?? '';
      _licenseNumber = _profile!.licenseNumber ?? '';
      _licenseExpiryDate = _profile!.licenseExpiryDate;
    }
    notifyListeners();
  }

  void _initializeMockData() {
    // Mock data for Phase 5 testing
    _profile = AgentProfile(
      agentId: 'agent_123',
      name: 'John Doe',
      email: 'john.doe@agentmitra.com',
      phone: '+91 9876543210',
      licenseNumber: 'LIC123456789',
      licenseExpiryDate: DateTime(2025, 12, 31),
      status: 'active',
      joinDate: DateTime.now().subtract(const Duration(days: 365)),
      profileImageUrl: null,
      address: '123 Agent Street, Mumbai, Maharashtra',
      panNumber: 'ABCDE1234F',
      aadhaarNumber: '123456789012',
    );

    _performance = AgentPerformance(
      agentId: 'agent_123',
      totalCommission: 45000.0,
      policiesSold: 42,
      customersAcquired: 38,
      conversionRate: 85.0,
      averagePolicyValue: 1250.0,
      monthlyData: [],
      commissionByProduct: {'Life Insurance': 25000.0, 'Health Insurance': 15000.0, 'Motor Insurance': 5000.0},
    );

    _licenseExpiryDate = DateTime(2025, 12, 31);
    _formattedLicenseExpiryDate = '31/12/2025';
  }
}
