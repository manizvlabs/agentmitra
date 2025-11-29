import 'package:flutter/foundation.dart';
import '../../data/repositories/policy_repository.dart';
import '../../data/datasources/policy_remote_datasource.dart';
import '../../data/datasources/policy_local_datasource.dart';
import '../../data/models/policy_model.dart';

class PoliciesViewModel extends ChangeNotifier {
  final PolicyRepository _policyRepository;
  final PolicyLocalDataSourceImpl _localDataSource;

  PoliciesViewModel([PolicyRepository? policyRepository, PolicyLocalDataSourceImpl? localDataSource])
      : _localDataSource = localDataSource ?? PolicyLocalDataSourceImpl(),
        _policyRepository = policyRepository ?? PolicyRepository(PolicyRemoteDataSourceImpl(), localDataSource ?? PolicyLocalDataSourceImpl()) {
    // Initialize local datasource asynchronously (will be ensured before use)
    _localDataSource.init().catchError((e) {
      // Silently handle initialization errors - will use fallback storage
    });
  }

  // State
  List<Policy> _policies = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _selectedStatus;
  String? _selectedProviderId;
  String? _selectedPolicyType;
  String? _searchQuery;

  // Getters
  List<Policy> get policies => _policies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  String? get selectedStatus => _selectedStatus;
  String? get selectedProviderId => _selectedProviderId;
  String? get selectedPolicyType => _selectedPolicyType;
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
    String? providerId,
    String? policyType,
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
    _selectedProviderId = providerId;
    _selectedPolicyType = policyType;
    _searchQuery = search;

    notifyListeners();

    try {
      final result = await _policyRepository.getPolicies(
        page: _currentPage,
        limit: 20,
        status: status,
        providerId: providerId,
        policyType: policyType,
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
    await loadPolicies(
      refresh: true,
      status: _selectedStatus,
      providerId: _selectedProviderId,
      policyType: _selectedPolicyType,
      search: _searchQuery,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    loadPolicies(
      refresh: true,
      status: status,
      providerId: _selectedProviderId,
      policyType: _selectedPolicyType,
      search: _searchQuery,
    );
  }

  void setProviderFilter(String? providerId) {
    _selectedProviderId = providerId;
    loadPolicies(
      refresh: true,
      status: _selectedStatus,
      providerId: providerId,
      policyType: _selectedPolicyType,
      search: _searchQuery,
    );
  }

  void setPolicyTypeFilter(String? policyType) {
    _selectedPolicyType = policyType;
    loadPolicies(
      refresh: true,
      status: _selectedStatus,
      providerId: _selectedProviderId,
      policyType: policyType,
      search: _searchQuery,
    );
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadPolicies(
      refresh: true,
      status: _selectedStatus,
      providerId: _selectedProviderId,
      policyType: _selectedPolicyType,
      search: query,
    );
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedProviderId = null;
    _selectedPolicyType = null;
    _searchQuery = null;
    loadPolicies(refresh: true);
  }
}
