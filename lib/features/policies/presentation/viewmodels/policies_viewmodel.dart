import 'package:flutter/foundation.dart';
import '../../data/models/policy_models.dart';
import '../../data/repositories/policy_repository.dart';

/// State class for policies screen
class PoliciesState {
  final List<Policy> policies;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PolicyFilters filters;
  final bool hasMoreData;
  final int currentPage;

  const PoliciesState({
    this.policies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filters = const PolicyFilters(),
    this.hasMoreData = true,
    this.currentPage = 1,
  });

  PoliciesState copyWith({
    List<Policy>? policies,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PolicyFilters? filters,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return PoliciesState(
      policies: policies ?? this.policies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filters: filters ?? this.filters,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// ViewModel for policies screen
class PoliciesViewModel extends ChangeNotifier {
  final PolicyRepository _repository;
  PoliciesState _state = const PoliciesState();

  PoliciesViewModel(this._repository) {
    loadPolicies();
  }

  PoliciesState get state => _state;

  void _updateState(PoliciesState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load policies with current filters
  Future<void> loadPolicies() async {
    if (_state.isLoading) return;

    _updateState(_state.copyWith(isLoading: true, error: null));

    try {
      final response = await _repository.getPolicies(filters: _state.filters);

      _updateState(_state.copyWith(
        policies: response.policies,
        isLoading: false,
        hasMoreData: response.hasNextPage,
        currentPage: response.page,
        error: null,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Load more policies (pagination)
  Future<void> loadMorePolicies() async {
    if (_state.isLoadingMore || !_state.hasMoreData) return;

    _updateState(_state.copyWith(isLoadingMore: true));

    try {
      final nextFilters = _state.filters.copyWith(
        page: _state.currentPage + 1,
      );

      final response = await _repository.getPolicies(filters: nextFilters);

      _updateState(_state.copyWith(
        policies: [..._state.policies, ...response.policies],
        isLoadingMore: false,
        hasMoreData: response.hasNextPage,
        currentPage: response.page,
      ));
    } catch (e) {
      _updateState(_state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      ));
    }
  }

  /// Search policies
  Future<void> searchPolicies(String query) async {
    final newFilters = _state.filters.copyWith(
      searchQuery: query.isEmpty ? null : query,
      page: 1,
    );

    _updateState(_state.copyWith(filters: newFilters));
    await loadPolicies();
  }

  /// Update status filter
  void setStatusFilter(String? status) {
    final statusEnum = status != null ? PolicyStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => PolicyStatus.active,
    ) : null;
    final newFilters = _state.filters.copyWith(status: statusEnum, page: 1);
    _updateState(_state.copyWith(filters: newFilters));
    loadPolicies();
  }

  /// Update policy type filter
  void setPolicyTypeFilter(String? policyType) {
    final policyTypeEnum = policyType != null ? PolicyType.values.firstWhere(
      (e) => e.toString().split('.').last == policyType,
      orElse: () => PolicyType.termLife,
    ) : null;
    final newFilters = _state.filters.copyWith(policyType: policyTypeEnum, page: 1);
    _updateState(_state.copyWith(filters: newFilters));
    loadPolicies();
  }

  /// Update provider filter
  void setProviderFilter(String? providerId) {
    final newFilters = _state.filters.copyWith(providerId: providerId, page: 1);
    _updateState(_state.copyWith(filters: newFilters));
    loadPolicies();
  }

  /// Clear all filters
  void clearFilters() {
    _updateState(_state.copyWith(
      filters: const PolicyFilters(),
      currentPage: 1,
    ));
    loadPolicies();
  }

  /// Refresh policies
  Future<void> refresh() async {
    _updateState(_state.copyWith(
      currentPage: 1,
      filters: _state.filters.copyWith(page: 1),
    ));
    await loadPolicies();
  }

  /// Get filtered policies (for display)
  List<Policy> getFilteredPolicies() {
    // Additional client-side filtering if needed
    return _state.policies;
  }

  /// Get policy by ID
  Policy? getPolicyById(String policyId) {
    try {
      return _state.policies.firstWhere((policy) => policy.policyId == policyId);
    } catch (e) {
      return null;
    }
  }

  // Compatibility methods for screens
  String? get selectedStatus => _state.filters.status?.toString().split('.').last;
  String? get selectedProviderId => _state.filters.providerId;
  String? get selectedPolicyType => _state.filters.policyType?.toString().split('.').last;

  void setSearchQuery(String? query) {
    final newFilters = _state.filters.copyWith(searchQuery: query, page: 1);
    _updateState(_state.copyWith(filters: newFilters));
    loadPolicies();
  }
}

