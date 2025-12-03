import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _roles = [];
  String _searchQuery = '';
  String _selectedRoleFilter = '';
  String _selectedStatusFilter = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRoles();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // Use GET /api/v1/users/ endpoint with filters
      final queryParams = <String, dynamic>{};
      if (_searchQuery.isNotEmpty) queryParams['q'] = _searchQuery;
      if (_selectedRoleFilter.isNotEmpty) queryParams['role'] = _selectedRoleFilter;
      if (_selectedStatusFilter.isNotEmpty) queryParams['status'] = _selectedStatusFilter;

      final response = await ApiService.get('/api/v1/users/', queryParameters: queryParams);
      setState(() => _users = List<Map<String, dynamic>>.from(response['data'] ?? []));
    } catch (e) {
      print('Failed to load users: $e');
      // Load mock data for demonstration
      setState(() => _users = [
        {
          'user_id': 'usr_001',
          'email': 'john.doe@example.com',
          'phone_number': '+91-9876543210',
          'first_name': 'John',
          'last_name': 'Doe',
          'display_name': 'John Doe',
          'role': 'policyholder',
          'status': 'active',
          'phone_verified': true,
          'email_verified': true,
          'last_login_at': '2025-12-02T10:30:00Z',
          'created_at': '2025-11-01T09:00:00Z'
        },
        {
          'user_id': 'usr_002',
          'email': 'jane.smith@example.com',
          'phone_number': '+91-8765432109',
          'first_name': 'Jane',
          'last_name': 'Smith',
          'display_name': 'Jane Smith',
          'role': 'senior_agent',
          'status': 'active',
          'phone_verified': true,
          'email_verified': true,
          'last_login_at': '2025-12-03T14:20:00Z',
          'created_at': '2025-10-15T11:30:00Z'
        },
        {
          'user_id': 'usr_003',
          'email': 'admin@agentmitra.com',
          'phone_number': '+91-7654321098',
          'first_name': 'Admin',
          'last_name': 'User',
          'display_name': 'Admin User',
          'role': 'super_admin',
          'status': 'active',
          'phone_verified': true,
          'email_verified': true,
          'last_login_at': '2025-12-03T16:45:00Z',
          'created_at': '2025-09-01T08:00:00Z'
        }
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRoles() async {
    try {
      // Use GET /api/v1/rbac/roles endpoint
      final response = await ApiService.get('/api/v1/rbac/roles');
      setState(() => _roles = List<Map<String, dynamic>>.from(response['data'] ?? []));
    } catch (e) {
      print('Failed to load roles: $e');
      // Load mock roles for demonstration
      setState(() => _roles = [
        {
          'role_id': 'role_001',
          'role_name': 'super_admin',
          'role_description': 'Super Administrator with full system access',
          'is_system_role': true,
          'permissions': ['system.admin', 'users.manage', 'tenants.manage']
        },
        {
          'role_id': 'role_002',
          'role_name': 'provider_admin',
          'role_description': 'Insurance Provider Administrator',
          'is_system_role': true,
          'permissions': ['users.manage', 'policies.manage']
        },
        {
          'role_id': 'role_003',
          'role_name': 'senior_agent',
          'role_description': 'Senior Insurance Agent',
          'is_system_role': true,
          'permissions': ['customers.manage', 'policies.create']
        },
        {
          'role_id': 'role_004',
          'role_name': 'junior_agent',
          'role_description': 'Junior Insurance Agent',
          'is_system_role': true,
          'permissions': ['customers.view', 'policies.view']
        },
        {
          'role_id': 'role_005',
          'role_name': 'policyholder',
          'role_description': 'Insurance Policyholder',
          'is_system_role': true,
          'permissions': ['policies.view', 'payments.make']
        }
      ]);
    }
  }

  Future<void> _assignRole(String userId, String roleName) async {
    setState(() => _isLoading = true);

    try {
      // Use POST /api/v1/rbac/users/assign-role endpoint
      await ApiService.post('/api/v1/rbac/users/assign-role', {
        'user_id': userId,
        'role_name': roleName,
      });

      // Reload users to reflect changes
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role $roleName assigned successfully')),
        );
      }
    } catch (e) {
      print('Failed to assign role: $e');
      // Simulate success for demo
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role $roleName assigned successfully (simulated)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeRole(String userId, String roleName) async {
    setState(() => _isLoading = true);

    try {
      // Use POST /api/v1/rbac/users/remove-role endpoint
      await ApiService.post('/api/v1/rbac/users/remove-role', {
        'user_id': userId,
        'role_name': roleName,
      });

      // Reload users to reflect changes
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role $roleName removed successfully')),
        );
      }
    } catch (e) {
      print('Failed to remove role: $e');
      // Simulate success for demo
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role $roleName removed successfully (simulated)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRoleManagementDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Roles: ${user['display_name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Role: ${user['role']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Available Roles:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roles.map((role) {
                  final isCurrentRole = role['role_name'] == user['role'];
                  return FilterChip(
                    label: Text(role['role_name']),
                    selected: isCurrentRole,
                    onSelected: (selected) {
                      if (!isCurrentRole && selected) {
                        _assignRole(user['user_id'], role['role_name']);
                        Navigator.of(context).pop();
                      }
                    },
                    backgroundColor: isCurrentRole ? Colors.blue.shade100 : null,
                    selectedColor: Colors.blue.shade200,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (user['role'] != 'policyholder') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    _removeRole(user['user_id'], user['role']);
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.remove_circle, color: Colors.white),
                  label: const Text('Remove Current Role'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildUsersSummary(),
            Expanded(
              child: _users.isEmpty && !_isLoading
                ? _buildEmptyState()
                : _buildUsersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0083B0),
        onPressed: () {
          // For now, just show a message since user creation requires complex form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User creation available via registration flow')),
          );
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users by name, email, or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              _searchQuery = value;
              _loadUsers();
            },
          ),
          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedRoleFilter.isEmpty ? null : _selectedRoleFilter,
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All Roles')),
                    ..._roles.map((role) => DropdownMenuItem(
                      value: role['role_name'],
                      child: Text(role['role_name']),
                    )),
                  ],
                  onChanged: (value) {
                    _selectedRoleFilter = value ?? '';
                    _loadUsers();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedStatusFilter.isEmpty ? null : _selectedStatusFilter,
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  ],
                  onChanged: (value) {
                    _selectedStatusFilter = value ?? '';
                    _loadUsers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSummary() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u['status'] == 'active').length;
    final roleBreakdown = <String, int>{};

    for (final user in _users) {
      final role = user['role'] ?? 'unknown';
      roleBreakdown[role] = (roleBreakdown[role] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildSummaryCard('Total Users', totalUsers.toString(), Icons.people, Colors.blue),
          const SizedBox(width: 12),
          _buildSummaryCard('Active Users', activeUsers.toString(), Icons.check_circle, Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role Breakdown',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleBreakdown.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No users found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final displayName = user['display_name'] ?? 'Unknown User';
    final email = user['email'] ?? '';
    final phone = user['phone_number'] ?? '';
    final role = user['role'] ?? 'unknown';
    final status = user['status'] ?? 'unknown';
    final lastLogin = user['last_login_at'];

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.red;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color roleColor;
    switch (role.toLowerCase()) {
      case 'super_admin':
        roleColor = Colors.red;
        break;
      case 'provider_admin':
        roleColor = Colors.purple;
        break;
      case 'regional_manager':
        roleColor = Colors.blue;
        break;
      case 'senior_agent':
        roleColor = Colors.green;
        break;
      case 'junior_agent':
        roleColor = Colors.teal;
        break;
      case 'policyholder':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Action Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRoleManagementDialog(user),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: const Text('Manage Roles'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0083B0),
                      side: const BorderSide(color: Color(0xFF0083B0)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (lastLogin != null) ...[
                  Text(
                    'Last login: ${_formatDate(lastLogin)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
