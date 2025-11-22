import 'package:flutter/foundation.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/models/customer_model.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerViewModel([CustomerRepository? repository])
      : _repository = repository ??
            CustomerRepository(CustomerRemoteDataSourceImpl());

  // State
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String? _searchQuery;
  String? _statusFilter;

  // Getters
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  String? get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;

  // Actions
  Future<void> loadCustomers({
    bool refresh = false,
    String? search,
    String? status,
  }) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;

    if (refresh) {
      _currentPage = 1;
      _customers.clear();
    }

    _searchQuery = search;
    _statusFilter = status;

    notifyListeners();

    try {
      final result = await _repository.getCustomers(
        page: _currentPage,
        limit: 20,
        search: search,
        status: status,
      );

      result.fold(
        (error) {
          _error = error.toString();
        },
        (newCustomers) {
          if (refresh || _currentPage == 1) {
            _customers = newCustomers;
          } else {
            _customers.addAll(newCustomers);
          }

          _hasMorePages = newCustomers.length == 20;
          if (_hasMorePages) _currentPage++;
        },
      );
    } catch (e) {
      _error = 'Failed to load customers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCustomers() async {
    if (!_hasMorePages || _isLoading) return;
    await loadCustomers(search: _searchQuery, status: _statusFilter);
  }

  Future<void> refreshCustomers() async {
    await loadCustomers(
      refresh: true,
      search: _searchQuery,
      status: _statusFilter,
    );
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadCustomers(refresh: true, search: query, status: _statusFilter);
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadCustomers(refresh: true, search: _searchQuery, status: status);
  }

  void clearFilters() {
    _searchQuery = null;
    _statusFilter = null;
    loadCustomers(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

