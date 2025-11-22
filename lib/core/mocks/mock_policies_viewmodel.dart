import 'package:flutter/material.dart';
import '../../features/payments/data/models/policy_model.dart';

/// Mock PoliciesViewModel for web compatibility
class MockPoliciesViewModel extends ChangeNotifier {
  List<PolicyModel> _policies = [];
  PolicyModel? _selectedPolicy;
  bool _isLoading = false;
  String? _error;

  List<PolicyModel> get policies => _policies;
  PolicyModel? get selectedPolicy => _selectedPolicy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PolicyModel> get activePolicies => _policies.where((p) => p.status == 'active').toList();
  List<PolicyModel> get expiredPolicies => _policies.where((p) => p.status == 'expired').toList();
  List<PolicyModel> get expiringSoonPolicies => _policies.where((p) => p.isExpiringSoon).toList();

  MockPoliciesViewModel() {
    _initializeMockPolicies();
  }

  void _initializeMockPolicies() {
    _policies = [
      PolicyModel(
        policyId: 'POL001',
        customerId: 'CUST001',
        customerName: 'John Doe',
        policyType: 'Life Insurance',
        policyNumber: 'LI2023001',
        premiumAmount: 5000.0,
        sumAssured: 500000.0,
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        endDate: DateTime.now().add(const Duration(days: 365)),
        status: 'active',
        agentId: 'agent_123',
        agentName: 'Rajesh Kumar',
        paymentFrequency: 'monthly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 30)),
        documents: ['policy_document.pdf', 'terms_conditions.pdf'],
      ),
      PolicyModel(
        policyId: 'POL002',
        customerId: 'CUST002',
        customerName: 'Jane Smith',
        policyType: 'Health Insurance',
        policyNumber: 'HI2023002',
        premiumAmount: 3000.0,
        sumAssured: 300000.0,
        startDate: DateTime.now().subtract(const Duration(days: 200)),
        endDate: DateTime.now().add(const Duration(days: 165)),
        status: 'active',
        agentId: 'agent_123',
        agentName: 'Rajesh Kumar',
        paymentFrequency: 'quarterly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 60)),
        documents: ['health_policy.pdf'],
      ),
      PolicyModel(
        policyId: 'POL003',
        customerId: 'CUST003',
        customerName: 'Bob Johnson',
        policyType: 'Vehicle Insurance',
        policyNumber: 'VI2023003',
        premiumAmount: 8000.0,
        sumAssured: 800000.0,
        startDate: DateTime.now().subtract(const Duration(days: 100)),
        endDate: DateTime.now().add(const Duration(days: 265)),
        status: 'active',
        agentId: 'agent_123',
        agentName: 'Rajesh Kumar',
        paymentFrequency: 'yearly',
        nextPaymentDate: DateTime.now().add(const Duration(days: 120)),
        documents: ['vehicle_policy.pdf', 'vehicle_details.pdf'],
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

  Future<void> createPolicy(PolicyModel policy) async {
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

  Future<void> updatePolicy(String policyId, PolicyModel updatedPolicy) async {
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
      _policies[index] = _policies[index].copyWith(endDate: newEndDate);
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectPolicy(PolicyModel policy) {
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
