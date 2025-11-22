import 'package:flutter/material.dart';
import 'mock_data.dart';

/// Production-grade Mock PoliciesViewModel for web compatibility
class MockPoliciesViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _policies = [];
  Map<String, dynamic>? _selectedPolicy;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get policies => _policies;
  Map<String, dynamic>? get selectedPolicy => _selectedPolicy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get activePolicies => _policies.where((p) => p['status'] == 'active').toList();
  List<Map<String, dynamic>> get expiredPolicies => _policies.where((p) => p['status'] == 'expired').toList();
  List<Map<String, dynamic>> get expiringSoonPolicies => _policies.where((p) => _isExpiringSoon(p)).toList();

  bool _isExpiringSoon(Map<String, dynamic> policy) {
    final endDate = policy['endDate'] as DateTime?;
    if (endDate == null) return false;
    return endDate.difference(DateTime.now()).inDays <= 30;
  }

  MockPoliciesViewModel() {
    _initializeMockPolicies();
  }

  void _initializeMockPolicies() {
    _policies = [
      MockData.mockPolicyData,
      {
        'policyId': 'POL002',
        'customerId': 'CUST002',
        'customerName': 'Jane Smith',
        'policyType': 'Health Insurance',
        'policyNumber': 'HI2023002',
        'premiumAmount': 3000.0,
        'sumAssured': 300000.0,
        'startDate': DateTime.now().subtract(const Duration(days: 200)),
        'endDate': DateTime.now().add(const Duration(days: 165)),
        'status': 'active',
        'agentId': 'agent_123',
        'agentName': 'Rajesh Kumar',
        'paymentFrequency': 'quarterly',
        'nextPaymentDate': DateTime.now().add(const Duration(days: 60)),
        'documents': ['health_policy.pdf'],
      },
      {
        'policyId': 'POL003',
        'customerId': 'CUST003',
        'customerName': 'Bob Johnson',
        'policyType': 'Vehicle Insurance',
        'policyNumber': 'VI2023003',
        'premiumAmount': 8000.0,
        'sumAssured': 800000.0,
        'startDate': DateTime.now().subtract(const Duration(days: 100)),
        'endDate': DateTime.now().add(const Duration(days: 265)),
        'status': 'active',
        'agentId': 'agent_123',
        'agentName': 'Rajesh Kumar',
        'paymentFrequency': 'yearly',
        'nextPaymentDate': DateTime.now().add(const Duration(days: 120)),
        'documents': ['vehicle_policy.pdf', 'vehicle_details.pdf'],
      },
    ];
  }

  Future<void> loadPolicies({String? status, int? limit, int? offset}) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (status != null) {
      _policies = _policies.where((p) => p['status'] == status).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPolicyDetails(String policyId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _selectedPolicy = _policies.firstWhere((p) => p['policyId'] == policyId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPolicy(Map<String, dynamic> policy) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _policies.insert(0, {
      ...policy,
      'policyId': 'POL${(_policies.length + 1).toString().padLeft(3, '0')}',
      'status': 'active',
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePolicy(String policyId, Map<String, dynamic> updatedPolicy) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _policies.indexWhere((p) => p['policyId'] == policyId);
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

    final index = _policies.indexWhere((p) => p['policyId'] == policyId);
    if (index != -1) {
      _policies[index] = {..._policies[index], 'endDate': newEndDate};
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectPolicy(Map<String, dynamic> policy) {
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
