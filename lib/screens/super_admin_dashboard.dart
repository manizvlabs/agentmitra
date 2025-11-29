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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              elevation: 4,
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings,
                            size: 32, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${currentUser?.name ?? 'Super Admin'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                              ),
                              Text(
                                'Full System Administrator',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.red.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Grid
            Text(
              'System Administration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  'User Management',
                  'Manage system users, roles & permissions',
                  Icons.people,
                  Colors.blue,
                  () => Navigator.of(context).pushNamed('/user-management'),
                ),
                _buildActionCard(
                  context,
                  'System Analytics',
                  'View platform usage & performance metrics',
                  Icons.analytics,
                  Colors.green,
                  () => Navigator.of(context).pushNamed('/reporting-dashboard'),
                ),
                _buildActionCard(
                  context,
                  'Feature Flags',
                  'Control app features & functionality',
                  Icons.flag,
                  Colors.orange,
                  () => Navigator.of(context).pushNamed('/pioneer-demo'),
                ),
                _buildActionCard(
                  context,
                  'System Settings',
                  'Configure platform settings',
                  Icons.settings,
                  Colors.purple,
                  () => _showSettingsDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // System Overview
            Text(
              'System Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Users',
                    '1,247',
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active Sessions',
                    '89',
                    Icons.online_prediction,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'API Calls (24h)',
                    '45.2K',
                    Icons.api,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'System Health',
                    '98.5%',
                    Icons.health_and_safety,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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

          // System Administration
          _buildSectionHeader('System Administration'),
          _buildDrawerItem(
            context,
            'Dashboard',
            Icons.dashboard,
            () => Navigator.of(context).pop(),
            selected: true,
          ),
          _buildDrawerItem(
            context,
            'User Management',
            Icons.people,
            () => Navigator.of(context).pushNamed('/user-management'),
          ),
          _buildDrawerItem(
            context,
            'System Analytics',
            Icons.analytics,
            () => Navigator.of(context).pushNamed('/reporting-dashboard'),
          ),
          _buildDrawerItem(
            context,
            'Feature Flags',
            Icons.flag,
            () => Navigator.of(context).pushNamed('/pioneer-demo'),
          ),

          const Divider(),

          // Authentication & Onboarding
          _buildSectionHeader('Authentication & Onboarding'),
          _buildDrawerItem(
            context,
            'Welcome Screen',
            Icons.waving_hand,
            () => Navigator.of(context).pushNamed('/welcome'),
          ),
          _buildDrawerItem(
            context,
            'Phone Verification',
            Icons.phone,
            () => Navigator.of(context).pushNamed('/phone-verification'),
          ),
          _buildDrawerItem(
            context,
            'OTP Verification',
            Icons.lock,
            () => Navigator.of(context).pushNamed('/otp-verification'),
          ),
          _buildDrawerItem(
            context,
            'Login Page',
            Icons.login,
            () => Navigator.of(context).pushNamed('/login'),
          ),
          _buildDrawerItem(
            context,
            'Trial Setup',
            Icons.rocket_launch,
            () => Navigator.of(context).pushNamed('/trial-setup'),
          ),
          _buildDrawerItem(
            context,
            'Onboarding',
            Icons.school,
            () => Navigator.of(context).pushNamed('/onboarding'),
          ),
          _buildDrawerItem(
            context,
            'Trial Expiration',
            Icons.timer_off,
            () => Navigator.of(context).pushNamed('/trial-expiration'),
          ),

          const Divider(),

          // Customer Portal
          _buildSectionHeader('Customer Portal'),
          _buildDrawerItem(
            context,
            'Customer Dashboard',
            Icons.home,
            () => Navigator.of(context).pushNamed('/customer-dashboard'),
          ),
          _buildDrawerItem(
            context,
            'My Policies',
            Icons.policy,
            () => Navigator.of(context).pushNamed('/policies'),
          ),
          _buildDrawerItem(
            context,
            'Policy Details',
            Icons.description,
            () => Navigator.of(context).pushNamed('/policy-details'),
          ),
          _buildDrawerItem(
            context,
            'WhatsApp Integration',
            Icons.chat,
            () => Navigator.of(context).pushNamed('/whatsapp-integration'),
          ),
          _buildDrawerItem(
            context,
            'Smart Chatbot',
            Icons.smart_toy,
            () => Navigator.of(context).pushNamed('/smart-chatbot'),
          ),
          _buildDrawerItem(
            context,
            'Notifications',
            Icons.notifications,
            () => Navigator.of(context).pushNamed('/notifications'),
          ),
          _buildDrawerItem(
            context,
            'Learning Center',
            Icons.library_books,
            () => Navigator.of(context).pushNamed('/learning-center'),
          ),
          _buildDrawerItem(
            context,
            'Profile',
            Icons.person,
            () => Navigator.of(context).pushNamed('/profile'),
          ),

          const Divider(),

          // Agent Portal
          _buildSectionHeader('Agent Portal'),
          _buildDrawerItem(
            context,
            'Agent Config Dashboard',
            Icons.settings_applications,
            () => Navigator.of(context).pushNamed('/agent-config-dashboard'),
          ),
          _buildDrawerItem(
            context,
            'ROI Analytics',
            Icons.trending_up,
            () => Navigator.of(context).pushNamed('/roi-analytics'),
          ),
          _buildDrawerItem(
            context,
            'Campaign Builder',
            Icons.campaign,
            () => Navigator.of(context).pushNamed('/campaign-builder'),
          ),
          _buildDrawerItem(
            context,
            'Customers',
            Icons.people_alt,
            () => Navigator.of(context).pushNamed('/customers'),
          ),
          _buildDrawerItem(
            context,
            'Reports',
            Icons.report,
            () => Navigator.of(context).pushNamed('/reports'),
          ),

          const Divider(),

          // Policy Management
          _buildSectionHeader('Policy Management'),
          _buildDrawerItem(
            context,
            'New Policy',
            Icons.add_circle,
            () => Navigator.of(context).pushNamed('/new-policy'),
          ),
          _buildDrawerItem(
            context,
            'New Claim',
            Icons.report_problem,
            () => Navigator.of(context).pushNamed('/new-claim'),
          ),
          _buildDrawerItem(
            context,
            'Create Policy',
            Icons.create,
            () => Navigator.of(context).pushNamed('/policy/create'),
          ),

          const Divider(),

          // Admin Portal
          _buildSectionHeader('Admin Portal'),
          _buildDrawerItem(
            context,
            'Tenant Onboarding',
            Icons.business,
            () => Navigator.of(context).pushNamed('/tenant-onboarding'),
          ),
          _buildDrawerItem(
            context,
            'Role Assignment',
            Icons.assignment_ind,
            () => Navigator.of(context).pushNamed('/role-assignment/1'), // Example user ID
          ),
          _buildDrawerItem(
            context,
            'Compliance Reports',
            Icons.gavel,
            () => Navigator.of(context).pushNamed('/compliance-reports'),
          ),

          const Divider(),

          _buildDrawerItem(
            context,
            'Settings',
            Icons.settings,
            () => _showSettingsDialog(context),
          ),
          _buildDrawerItem(
            context,
            'Logout',
            Icons.logout,
            () async {
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ).copyWith(fontSize: 12),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon,
      VoidCallback onTap,
      {bool selected = false}) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? Colors.red.shade700 : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.red.shade700 : Colors.black,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      onTap: onTap,
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
