import 'package:flutter/material.dart';
import 'package:provider/Provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SeniorAgentDashboard extends StatelessWidget {
  const SeniorAgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = provider.Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Senior Agent Dashboard'),
        backgroundColor: Colors.deepPurple.shade700,
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
          'Senior Agent Dashboard\n\nBusiness Operations & Analytics',
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
              color: Colors.deepPurple.shade700,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business_center,
                      size: 30, color: Colors.deepPurple),
                ),
                SizedBox(height: 10),
                Text(
                  'Senior Agent',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Business Operations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.deepPurple),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Customers'),
            onTap: () => Navigator.of(context).pushNamed('/customers'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.green),
            title: const Text('Analytics'),
            onTap: () => Navigator.of(context).pushNamed('/roi-analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: const Text('Campaigns'),
            onTap: () => Navigator.of(context).pushNamed('/campaign-builder'),
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.red),
            title: const Text('Reports'),
            onTap: () => Navigator.of(context).pushNamed('/reports'),
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
        title: const Text('Agent Settings'),
        content: const Text('Agent settings panel coming soon...'),
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
