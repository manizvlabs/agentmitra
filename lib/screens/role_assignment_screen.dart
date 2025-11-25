import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../core/services/feature_flag_service.dart';
import '../shared/theme/app_theme.dart';
import '../shared/constants/app_constants.dart';

class RoleAssignmentScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const RoleAssignmentScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<RoleAssignmentScreen> createState() => _RoleAssignmentScreenState();
}

class _RoleAssignmentScreenState extends State<RoleAssignmentScreen> {
  final ApiService _apiService = ApiService();
  final FeatureFlagService _featureFlagService = FeatureFlagService(ApiService());

  List<Map<String, dynamic>> _availableRoles = [];
  List<String> _userRoles = [];
  List<String> _userPermissions = [];
  bool _isLoading = true;
  bool _isAssigningRole = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load available roles
      final rolesResponse = await _apiService.get('/rbac/roles') as List<dynamic>;
      _availableRoles = rolesResponse.map((role) => role as Map<String, dynamic>).toList();

      // Load user roles and permissions
      final userRolesResponse = await _apiService.get('/rbac/users/${widget.userId}/roles') as Map<String, dynamic>;
      _userRoles = List<String>.from(userRolesResponse['roles'] as List);
      _userPermissions = List<String>.from(userRolesResponse['permissions'] as List);

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignRole(String roleName) async {
    setState(() => _isAssigningRole = true);

    try {
      await _apiService.post('/rbac/users/assign-role', body: {
        'user_id': widget.userId,
        'role_name': roleName,
      });

      _successMessage = 'Role "$roleName" assigned successfully';
      _errorMessage = null;

      // Reload data to show updated roles
      await _loadData();

    } catch (e) {
      _errorMessage = 'Failed to assign role: ${e.toString()}';
      _successMessage = null;
    } finally {
      setState(() => _isAssigningRole = false);
    }
  }

  Future<void> _removeRole(String roleName) async {
    setState(() => _isAssigningRole = true);

    try {
      await _apiService.post('/rbac/users/remove-role', body: {
        'user_id': widget.userId,
        'role_name': roleName,
      });

      _successMessage = 'Role "$roleName" removed successfully';
      _errorMessage = null;

      // Reload data to show updated roles
      await _loadData();

    } catch (e) {
      _errorMessage = 'Failed to remove role: ${e.toString()}';
      _successMessage = null;
    } finally {
      setState(() => _isAssigningRole = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Assignment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Information Card
                  _buildUserInfoCard(),

                  const SizedBox(height: 24),

                  // Messages
                  if (_errorMessage != null) _buildErrorMessage(),
                  if (_successMessage != null) _buildSuccessMessage(),

                  const SizedBox(height: 24),

                  // Current Roles Section
                  _buildCurrentRolesSection(),

                  const SizedBox(height: 24),

                  // Available Roles Section
                  _buildAvailableRolesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'User ID: ${widget.userId}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade800),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.green),
            onPressed: () => setState(() => _successMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentRolesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Roles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_userRoles.isEmpty)
              const Text(
                'No roles assigned',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _userRoles.map((role) => Chip(
                  label: Text(role),
                  backgroundColor: _getRoleColor(role),
                  deleteIcon: const Icon(Icons.remove_circle),
                  onDeleted: () => _showRemoveRoleDialog(role),
                )).toList(),
              ),
            const SizedBox(height: 16),
            const Text(
              'Effective Permissions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _userPermissions.map((permission) => Chip(
                label: Text(
                  permission,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRolesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Roles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Click on a role to assign it to this user',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableRoles.length,
              itemBuilder: (context, index) {
                final role = _availableRoles[index];
                final roleName = role['role_name'] as String;
                final isAssigned = _userRoles.contains(roleName);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      roleName.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(roleName),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role['role_description'] ?? ''),
                        const SizedBox(height: 4),
                        Text(
                          '${(role['permissions'] as List).length} permissions',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: isAssigned
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: _isAssigningRole
                                ? null
                                : () => _assignRole(roleName),
                          ),
                    onTap: isAssigned
                        ? () => _showRoleDetails(role)
                        : (_isAssigningRole ? null : () => _assignRole(roleName)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveRoleDialog(String roleName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Role'),
        content: Text('Are you sure you want to remove the "$roleName" role from ${widget.userName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeRole(roleName);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRoleDetails(Map<String, dynamic> role) {
    final permissions = role['permissions'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(role['role_name'].toString().replaceAll('_', ' ').toUpperCase()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                role['role_description'] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: permissions.map<Widget>((permission) => Chip(
                  label: Text(
                    permission.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.grey.shade200,
                )).toList(),
              ),
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

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'super_admin':
        return Colors.red;
      case 'insurance_provider_admin':
        return Colors.purple;
      case 'regional_manager':
        return Colors.orange;
      case 'senior_agent':
        return Colors.blue;
      case 'junior_agent':
        return Colors.green;
      case 'policyholder':
        return Colors.teal;
      case 'support_staff':
        return Colors.amber;
      case 'compliance_officer':
        return Colors.indigo;
      case 'customer_support_lead':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
