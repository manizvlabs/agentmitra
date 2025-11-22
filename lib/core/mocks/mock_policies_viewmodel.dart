import 'package:flutter/material.dart';
import '../../features/payments/data/models/policy_model.dart';

/// Mock PoliciesViewModel for web compatibility
class MockPoliciesViewModel extends ChangeNotifier {
  List<Policy> _policies = [];
  Policy? _selectedPolicy;
  bool _isLoading = false;
  String? _error;

  List<Policy> get policies => _policies;
  Policy? get selectedPolicy => _selectedPolicy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Policy> get activePolicies => _policies.where((p) => p.status == 'active').toList();
  List<Policy> get expiredPolicies => _policies.where((p) => p.status == 'expired').toList();
  List<Policy> get expiringSoonPolicies => _policies.where((p) =>
    p.renewalDate != null &&
    p.renewalDate!.difference(DateTime.now()).inDays <= 30
  ).toList();

  MockPoliciesViewModel() {
    _initializeMockPolicies();
  }

  void _initializeMockPolicies() {
    _policies = [
      Policy(
        policyId: 'POL001',
        policyNumber: 'LI2023001',
        providerPolicyId: 'LIC001',
        policyholderId: 'PH001',
        agentId: 'agent_123',
        providerId: 'LIC',
        policyType: 'Life Insurance',
        planName: 'Life Secure Plus',
        planCode: 'LIFE_SECURE',
        category: 'Life Insurance',
        sumAssured: 500000.0,
        premiumAmount: 5000.0,
        premiumFrequency: 'Monthly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 370)),
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        status: 'active',
      ),
      Policy(
        policyId: 'POL002',
        policyNumber: 'HI2023002',
        providerPolicyId: 'HDFC002',
        policyholderId: 'PH002',
        agentId: 'agent_123',
        providerId: 'HDFC',
        policyType: 'Health Insurance',
        planName: 'Health Shield',
        planCode: 'HEALTH_SHIELD',
        category: 'Health Insurance',
        sumAssured: 300000.0,
        premiumAmount: 3000.0,
        premiumFrequency: 'Quarterly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 205)),
        startDate: DateTime.now().subtract(const Duration(days: 200)),
        status: 'active',
      ),
      Policy(
        policyId: 'POL003',
        policyNumber: 'VI2023003',
        providerPolicyId: 'BAJAJ003',
        policyholderId: 'PH003',
        agentId: 'agent_123',
        providerId: 'BAJAJ',
        policyType: 'Vehicle Insurance',
        planName: 'Vehicle Shield',
        planCode: 'VEHICLE_SHIELD',
        category: 'Motor Insurance',
        sumAssured: 800000.0,
        premiumAmount: 8000.0,
        premiumFrequency: 'Yearly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 105)),
        startDate: DateTime.now().subtract(const Duration(days: 100)),
        status: 'active',
      ),
    ];
  }

  Future<void> loadPolicies({String? status, int? limit, int? offset}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Filter policies if status is provided
    if (status != null) {
      _policies = _policies.where((p) => p.status == status).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPolicyDetails(String policyId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _selectedPolicy = _policies.firstWhere((p) => p.policyId == policyId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPolicy(Policy policy) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Add the new policy to the list
    _policies.insert(0, policy.copyWith(
      policyId: 'POL${(_policies.length + 1).toString().padLeft(3, '0')}',
      status: 'active',
    ));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePolicy(String policyId, Policy updatedPolicy) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _policies.indexWhere((p) => p.policyId == policyId);
    if (index != -1) {
      _policies[index] = updatedPolicy;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> renewPolicy(String policyId, DateTime newEndDate) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _policies.indexWhere((p) => p.policyId == policyId);
    if (index != -1) {
      _policies[index] = _policies[index].copyWith(renewalDate: newEndDate);
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectPolicy(Policy policy) {
    _selectedPolicy = policy;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPolicy = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    await loadPolicies();
  }
}
