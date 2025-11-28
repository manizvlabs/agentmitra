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
  late UserManagementViewModel _viewModel;

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
  void initState() {
    super.initState();
    print('🔍 UserManagementPage: initState called');
    _viewModel = context.read<UserManagementViewModel>();
    print('🔍 UserManagementPage: ViewModel obtained: $_viewModel');
    _viewModel.initialize();
    print('🔍 UserManagementPage: ViewModel initialized');
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _viewModel.search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 UserManagementPage: build called');
    return Consumer<UserManagementViewModel>(
      builder: (context, viewModel, child) {
        print('🔍 UserManagementPage: Consumer builder called with users: ${viewModel.users.length}, isLoading: ${viewModel.isLoading}, error: ${viewModel.errorMessage}');
        return Scaffold(
          appBar: AppBar(title: const Text('User Management Debug')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Users loaded: ${viewModel.users.length}'),
                Text('Loading: ${viewModel.isLoading}'),
                Text('Error: ${viewModel.errorMessage ?? 'None'}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => viewModel.refresh(),
                  child: const Text('Refresh Users'),
                ),
                const SizedBox(height: 20),
                if (viewModel.users.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.users.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.users[index];
                        return ListTile(
                          title: Text(user['display_name'] ?? user['email'] ?? 'Unknown'),
                          subtitle: Text(user['email'] ?? ''),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
