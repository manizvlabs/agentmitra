import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../data/repositories/policy_repository.dart';
import '../../data/datasources/policy_remote_datasource.dart';
import '../../data/models/policy_model.dart';

class PoliciesViewModel extends ChangeNotifier {
  final PolicyRepository _policyRepository;

  PoliciesViewModel([PolicyRepository? policyRepository])
      : _policyRepository = policyRepository ?? PolicyRepository(PolicyRemoteDataSourceImpl(Dio()), PolicyLocalDataSourceImpl()) {
    // Initialize with mock data for Phase 5 testing
    _initializeMockData();
  }

  // State
  List<Policy> _policies = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _selectedStatus;
  String? _searchQuery;

  // Getters
  List<Policy> get policies => _policies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  String? get selectedStatus => _selectedStatus;
  String? get searchQuery => _searchQuery;

  // Computed properties
  List<Policy> get activePolicies =>
      _policies.where((policy) => policy.status == 'active').toList();

  List<Policy> get pendingPolicies =>
      _policies.where((policy) => policy.status == 'pending_approval').toList();

  List<Policy> get lapsedPolicies =>
      _policies.where((policy) => policy.status == 'lapsed').toList();

  // Actions
  Future<void> loadPolicies({
    bool refresh = false,
    String? status,
    String? search,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;

    if (refresh) {
      _currentPage = 1;
      _policies.clear();
    }

    _selectedStatus = status;
    _searchQuery = search;

    notifyListeners();

    try {
      final result = await _policyRepository.getPolicies(
        page: _currentPage,
        limit: 20,
        status: status,
        search: search,
        forceRefresh: refresh,
      );

      result.fold(
        (error) {
          _error = error.toString();
        },
        (newPolicies) {
          if (refresh || _currentPage == 1) {
            _policies = newPolicies;
          } else {
            _policies.addAll(newPolicies);
          }

          _hasMorePages = newPolicies.length == 20;
          if (_hasMorePages) _currentPage++;
        },
      );
    } catch (e) {
      _error = 'Failed to load policies: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePolicies() async {
    if (!_hasMorePages || _isLoading) return;

    await loadPolicies();
  }

  Future<void> refreshPolicies() async {
    await loadPolicies(refresh: true, status: _selectedStatus, search: _searchQuery);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    loadPolicies(refresh: true, status: status, search: _searchQuery);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadPolicies(refresh: true, status: _selectedStatus, search: query);
  }

  void clearFilters() {
    _selectedStatus = null;
    _searchQuery = null;
    loadPolicies(refresh: true);
  }

  void _initializeMockData() {
    // Mock policies data for Phase 5 testing
    _policies = [
      Policy(
        policyId: 'POL001',
        policyNumber: 'LIFE001234567',
        providerPolicyId: 'LIC001234567',
        policyholderId: 'PH001',
        agentId: 'agent_123',
        providerId: 'LIC',
        policyType: 'Life Insurance',
        planName: 'Life Secure Plus',
        planCode: 'LIFE_SECURE_PLUS',
        category: 'Life Insurance',
        sumAssured: 500000.0,
        premiumAmount: 2500.0,
        premiumFrequency: 'Monthly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 370)),
        startDate: DateTime.now().subtract(const Duration(days: 365)),
        status: 'active',
      ),
      Policy(
        policyId: 'POL002',
        policyNumber: 'HEALTH001234568',
        providerPolicyId: 'HDFC001234568',
        policyholderId: 'PH002',
        agentId: 'agent_123',
        providerId: 'HDFC',
        policyType: 'Health Insurance',
        planName: 'Health Shield',
        planCode: 'HEALTH_SHIELD',
        category: 'Health Insurance',
        sumAssured: 300000.0,
        premiumAmount: 1800.0,
        premiumFrequency: 'Monthly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 185)),
        startDate: DateTime.now().subtract(const Duration(days: 180)),
        status: 'active',
      ),
      Policy(
        policyId: 'POL003',
        policyNumber: 'MOTOR001234569',
        providerPolicyId: 'BAJAJ001234569',
        policyholderId: 'PH003',
        agentId: 'agent_123',
        providerId: 'BAJAJ',
        policyType: 'Motor Insurance',
        planName: 'Motor Shield',
        planCode: 'MOTOR_SHIELD',
        category: 'Motor Insurance',
        sumAssured: 800000.0,
        premiumAmount: 3200.0,
        premiumFrequency: 'Yearly',
        premiumMode: 'Online',
        applicationDate: DateTime.now().subtract(const Duration(days: 335)),
        startDate: DateTime.now().subtract(const Duration(days: 330)),
        status: 'active',
      ),
    ];
    _totalPolicies = _policies.length;
  }
}
