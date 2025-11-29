import 'package:flutter/material.dart';
import 'package:provider/Provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class ProviderAdminDashboard extends StatelessWidget {
  const ProviderAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = provider.Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Admin Dashboard'),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/welcome');
              }
            },
          ),
        ],
      ),
      drawer: _buildNavigationDrawer(context),
      body: const Center(
        child: Text(
          'Provider Admin Dashboard\n\nInsurance Provider Management',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNavigationDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo.shade700,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business,
                      size: 30, color: Colors.indigo),
                ),
                SizedBox(height: 10),
                Text(
                  'Provider Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Insurance Provider Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.indigo),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Agent Management'),
            onTap: () => Navigator.of(context).pushNamed('/user-management'),
          ),
          ListTile(
            leading: const Icon(Icons.contacts, color: Colors.green),
            title: const Text('Customer Data'),
            onTap: () => Navigator.of(context).pushNamed('/customer-data-management'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () => _showSettingsDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text('Logout'),
            onTap: () async {
              final authViewModel =
                  provider.Provider.of<AuthViewModel>(context, listen: false);
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/welcome');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Provider Settings'),
        content: const Text('Provider settings panel coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
