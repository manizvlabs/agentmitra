import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../data/repositories/config_portal_repository.dart';

/// ViewModel for Customer Data Management
class CustomerDataViewModel extends BaseViewModel {
  final ConfigPortalRepository _repository;

  List<Map<String, dynamic>> _customers = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';
  int _currentPage = 0;
  int _pageSize = 20;
  int _totalCount = 0;
  bool _hasMore = true;

  CustomerDataViewModel({
    ConfigPortalRepository? repository,
  }) : _repository = repository ?? ConfigPortalRepository();

  List<Map<String, dynamic>> get customers => _customers;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => isLoading && _customers.isNotEmpty;

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadCustomers();
  }

  /// Load customers with pagination
  Future<void> loadCustomers({bool append = false}) async {
    await executeAsync(
      () async {
        final offset = append ? _customers.length : 0;
        if (!append) {
          _currentPage = 0;
        }

        final response = await _repository.getCustomers(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          status: _selectedFilter == 'all' ? null : _selectedFilter,
          limit: _pageSize,
          offset: offset,
        );

        if (append) {
          _customers.addAll(response['items'] as List<Map<String, dynamic>>);
        } else {
          _customers = response['items'] as List<Map<String, dynamic>>;
        }

        _totalCount = response['total'] as int? ?? 0;
        _hasMore = response['hasMore'] as bool? ?? false;
        _currentPage++;

        notifyListeners();
      },
      errorMessage: 'Failed to load customers',
    );
  }

  /// Load more customers (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore) return;
    await loadCustomers(append: true);
  }

  /// Search customers
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadCustomers();
  }

  /// Set filter
  Future<void> setFilter(String filter) async {
    _selectedFilter = filter;
    await loadCustomers();
  }

  /// Create customer
  Future<Map<String, dynamic>?> createCustomer(Map<String, dynamic> customerData) async {
    return await executeAsync(
      () async {
        final result = await _repository.createCustomer(customerData: customerData);
        // Reload customers
        await loadCustomers();
        return result;
      },
      errorMessage: 'Failed to create customer',
    );
  }

  /// Update customer
  Future<Map<String, dynamic>?> updateCustomer({
    required String customerId,
    required Map<String, dynamic> customerData,
  }) async {
    return await executeAsync(
      () async {
        final result = await _repository.updateCustomer(
          customerId: customerId,
          customerData: customerData,
        );
        // Reload customers
        await loadCustomers();
        return result;
      },
      errorMessage: 'Failed to update customer',
    );
  }

  /// Delete customer
  Future<void> deleteCustomer(String customerId) async {
    await executeAsync(
      () async {
        await _repository.deleteCustomer(customerId);
        // Reload customers
        await loadCustomers();
      },
      errorMessage: 'Failed to delete customer',
    );
  }

  /// Get customer details
  Future<Map<String, dynamic>?> getCustomer(String customerId) async {
    return await executeAsync(
      () async {
        return await _repository.getCustomer(customerId);
      },
      errorMessage: 'Failed to fetch customer details',
    );
  }

  /// Refresh customers
  Future<void> refresh() async {
    await loadCustomers();
  }
}

