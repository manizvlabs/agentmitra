import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SuperAdminDashboard extends StatelessWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = provider.Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        backgroundColor: Colors.red.shade700,
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
          'Super Admin Dashboard\n\nFull System Access Available',
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
              color: Colors.red.shade700,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings,
                      size: 30, color: Colors.red),
                ),
                SizedBox(height: 10),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Full System Access',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.red),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('User Management'),
            onTap: () => Navigator.of(context).pushNamed('/user-management'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.green),
            title: const Text('System Analytics'),
            onTap: () => Navigator.of(context).pushNamed('/reporting-dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.orange),
            title: const Text('Feature Flags'),
            onTap: () => Navigator.of(context).pushNamed('/pioneer-demo'),
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
        title: const Text('System Settings'),
        content: const Text('System settings panel coming soon...'),
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