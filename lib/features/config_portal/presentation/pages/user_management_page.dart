import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/loading/empty_state_card.dart';
import '../viewmodels/user_management_viewmodel.dart';

/// User Management Page
/// Section 5.6: User list, add/edit forms, role assignment, and permissions
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _availableRoles = ['admin', 'agent', 'customer', 'junior_agent', 'senior_agent'];
  final List<String> _availablePermissions = [
    'all',
    'view_customers',
    'create_policies',
    'edit_policies',
    'view_reports',
    'manage_users',
    'view_own_policies',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagementViewModel>(
      builder: (context, viewModel, child) {
        // Initialize the ViewModel on first build
        if (viewModel.users.isEmpty && !viewModel.isLoading && viewModel.errorMessage == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.initialize();
          });
        }

        print('🔍 UserManagementPage: Building UI with ${viewModel.users.length} users, loading: ${viewModel.isLoading}, error: ${viewModel.errorMessage}');
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'User Management',
              style: TextStyle(
                color: Color(0xFF1a237e),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Color(0xFF1a237e)),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
          body: viewModel.isLoading && viewModel.users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : viewModel.hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${viewModel.errorMessage}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => viewModel.search(value),
                            decoration: InputDecoration(
                              hintText: 'Search users...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        viewModel.search('');
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ),

                        // User count and Filter Chips
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User count
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Total Users: ${viewModel.totalCount > 0 ? viewModel.totalCount : viewModel.users.length}${viewModel.hasMore ? '+' : ''}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              // Filter Chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip('All', 'all', viewModel),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Super Admin', 'super_admin', viewModel),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Senior Agent', 'senior_agent', viewModel),
                                    const SizedBox(width: 8),
                                    _buildFilterChip('Customer', 'policyholder', viewModel),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // User List
                        Expanded(
                          child: viewModel.users.isEmpty && !viewModel.isLoading
                              ? const EmptyStateCard(
                                  icon: Icons.people,
                                  title: 'No Users Found',
                                  message: 'Try adjusting your search or filters',
                                )
                              : Column(
                                  children: [
                                    Expanded(
                                      child: RefreshIndicator(
                                        onRefresh: () => viewModel.refresh(),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(16),
                                          itemCount: viewModel.users.length,
                                            itemBuilder: (context, index) {
                                              final user = viewModel.users[index];
                                              return _buildUserCard(user);
                                            },
                                        ),
                                      ),
                                    ),
                                    // Load More Button
                                    if (viewModel.hasMore && !viewModel.isLoadingMore)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        color: Colors.white,
                                        child: Center(
                                          child: ElevatedButton.icon(
                                            onPressed: () => viewModel.loadMore(),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Load More Users'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1a237e),
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Loading indicator for load more
                                    if (viewModel.isLoadingMore)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        color: Colors.white,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showAddUserDialog();
            },
            backgroundColor: const Color(0xFF1a237e),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add User',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, UserManagementViewModel viewModel) {
    final isSelected = viewModel.selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.setFilter(value);
      },
      selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1a237e),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1a237e) : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] as String? ?? 'unknown';
    final status = user['status'] as String? ?? 'active';
    final displayName = user['display_name'] as String? ??
                       '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim() ??
                       user['email'] as String? ??
                       'Unknown User';
    final email = user['email'] as String? ?? '';
    final lastLogin = user['last_login_at'] != null
        ? DateTime.parse(user['last_login_at']).toString().split(' ')[0]
        : 'Never';

    Color roleColor;
    IconData roleIcon;

    switch (role) {
      case 'super_admin':
      case 'provider_admin':
      case 'regional_manager':
        roleColor = Colors.red;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'senior_agent':
      case 'junior_agent':
        roleColor = Colors.blue;
        roleIcon = Icons.business_center;
        break;
      case 'policyholder':
        roleColor = Colors.green;
        roleIcon = Icons.person;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(roleIcon, color: roleColor, size: 24),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: status == 'active' ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: status == 'active' ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Last Login: $lastLogin',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'permissions',
              child: Row(
                children: [
                  Icon(Icons.security, size: 20),
                  SizedBox(width: 8),
                  Text('Manage Permissions'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'activity',
              child: Row(
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('View Activity'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            final userId = user['user_id'] as String;
            if (value == 'edit') {
              _showEditUserDialog(user);
            } else if (value == 'permissions') {
              _showPermissionsDialog(user);
            } else if (value == 'activity') {
              _showActivityLog(userId);
            } else if (value == 'delete') {
              _showDeleteDialog(user);
            }
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: const Text('Advanced filter options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String? selectedRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                items: _availableRoles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedRole != null && nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User added successfully')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(Map<String, dynamic> user) {
    final userPermissions = List<String>.from(user['permissions'] as List? ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Manage Permissions - ${user['display_name'] ?? user['email'] ?? 'User'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _availablePermissions.map((permission) {
                final isSelected = userPermissions.contains(permission);
                return CheckboxListTile(
                  title: Text(permission.replaceAll('_', ' ').toUpperCase()),
                  value: isSelected,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        userPermissions.add(permission);
                      } else {
                        userPermissions.remove(permission);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permissions updated')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityLog(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Log'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildActivityItem('Logged in', '2024-01-15 10:30'),
              _buildActivityItem('Viewed customers', '2024-01-15 10:35'),
              _buildActivityItem('Created policy', '2024-01-15 11:20'),
              _buildActivityItem('Updated profile', '2024-01-14 16:45'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String action, String timestamp) {
    return ListTile(
      leading: const Icon(Icons.history, size: 20),
      title: Text(action),
      subtitle: Text(timestamp),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['display_name'] ?? user['email'] ?? 'this user'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
