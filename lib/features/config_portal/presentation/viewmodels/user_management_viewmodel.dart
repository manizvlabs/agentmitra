import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../data/repositories/config_portal_repository.dart';

/// ViewModel for User Management
class UserManagementViewModel extends BaseViewModel {
  final ConfigPortalRepository _repository;

  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';
  int _currentPage = 0;
  int _pageSize = 20;
  int _totalCount = 0;
  bool _hasMore = true;

  UserManagementViewModel({
    ConfigPortalRepository? repository,
  }) : _repository = repository ?? ConfigPortalRepository();

  List<Map<String, dynamic>> get users => _users;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => isLoading && _users.isNotEmpty;

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadUsers();
  }

  /// Load users with pagination
  Future<void> loadUsers({bool append = false}) async {
    await executeAsync(
      () async {
        final offset = append ? _users.length : 0;
        if (!append) {
          _currentPage = 0;
        }

        final response = await _repository.getUsers(
          search: _searchQuery.isEmpty ? null : _searchQuery,
          role: _selectedFilter == 'all' ? null : _selectedFilter,
          limit: _pageSize,
          offset: offset,
        );

        if (append) {
          _users.addAll(response['items'] as List<Map<String, dynamic>>);
        } else {
          _users = response['items'] as List<Map<String, dynamic>>;
        }

        _totalCount = response['total'] as int? ?? 0;
        _hasMore = response['hasMore'] as bool? ?? false;
        _currentPage++;

        notifyListeners();
      },
      errorMessage: 'Failed to load users',
    );
  }

  /// Load more users (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || isLoadingMore) return;
    await loadUsers(append: true);
  }

  /// Search users
  Future<void> search(String query) async {
    _searchQuery = query;
    await loadUsers();
  }

  /// Set filter
  Future<void> setFilter(String filter) async {
    _selectedFilter = filter;
    await loadUsers();
  }

  /// Create user
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    return await executeAsync(
      () async {
        final result = await _repository.createUser(userData: userData);
        // Reload users
        await loadUsers();
        return result;
      },
      errorMessage: 'Failed to create user',
    );
  }

  /// Update user
  Future<Map<String, dynamic>?> updateUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    return await executeAsync(
      () async {
        final result = await _repository.updateUser(
          userId: userId,
          userData: userData,
        );
        // Reload users
        await loadUsers();
        return result;
      },
      errorMessage: 'Failed to update user',
    );
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await executeAsync(
      () async {
        await _repository.deleteUser(userId);
        // Reload users
        await loadUsers();
      },
      errorMessage: 'Failed to delete user',
    );
  }

  /// Get user details
  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await executeAsync(
      () async {
        return await _repository.getUser(userId);
      },
      errorMessage: 'Failed to fetch user details',
    );
  }

  /// Update user permissions
  Future<Map<String, dynamic>?> updateUserPermissions({
    required String userId,
    required List<String> permissions,
  }) async {
    return await executeAsync(
      () async {
        final result = await _repository.updateUserPermissions(
          userId: userId,
          permissions: permissions,
        );
        // Reload users to reflect permission changes
        await loadUsers();
        return result;
      },
      errorMessage: 'Failed to update permissions',
    );
  }

  /// Get user activity log
  Future<List<Map<String, dynamic>>> getUserActivity(String userId) async {
    return await executeAsync(
      () async {
        return await _repository.getUserActivity(userId: userId);
      },
      errorMessage: 'Failed to fetch user activity',
    ) ?? [];
  }

  /// Refresh users
  Future<void> refresh() async {
    await loadUsers();
  }
}

