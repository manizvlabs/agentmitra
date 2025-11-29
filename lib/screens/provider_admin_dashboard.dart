import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              elevation: 4,
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_center,
                            size: 32, color: Colors.indigo.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${currentUser?.name ?? 'Provider Admin'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo.shade700,
                                    ),
                              ),
                              Text(
                                'Insurance Provider Management',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.indigo.shade600),
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
              'Insurance Management',
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
                  'Data Import',
                  'Import customer & policy data',
                  Icons.upload_file,
                  Colors.blue,
                  () => Navigator.of(context).pushNamed('/data-import-dashboard'),
                ),
                _buildActionCard(
                  context,
                  'Agent Management',
                  'Manage insurance agents',
                  Icons.people,
                  Colors.green,
                  () => Navigator.of(context).pushNamed('/user-management'),
                ),
                _buildActionCard(
                  context,
                  'Customer Data',
                  'View & manage customer records',
                  Icons.contacts,
                  Colors.orange,
                  () => Navigator.of(context).pushNamed('/customer-data-management'),
                ),
                _buildActionCard(
                  context,
                  'Templates',
                  'Manage import templates',
                  Icons.description,
                  Colors.purple,
                  () => Navigator.of(context).pushNamed('/excel-template-config'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Provider Analytics
            Text(
              'Provider Analytics',
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
                    'Active Agents',
                    '1,234',
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Policies',
                    '45,678',
                    Icons.policy,
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
                    'Data Imports',
                    '156',
                    Icons.upload,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Import Success',
                    '94.2%',
                    Icons.check_circle,
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
              color: Colors.indigo.shade700,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business_center,
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

          // Provider Management
          _buildSectionHeader('Provider Management'),
          _buildDrawerItem(
            context,
            'Dashboard',
            Icons.dashboard,
            () => Navigator.of(context).pop(),
            selected: true,
          ),
          _buildDrawerItem(
            context,
            'Data Import',
            Icons.upload_file,
            () => Navigator.of(context).pushNamed('/data-import-dashboard'),
          ),
          _buildDrawerItem(
            context,
            'Agent Management',
            Icons.people,
            () => Navigator.of(context).pushNamed('/user-management'),
          ),
          _buildDrawerItem(
            context,
            'Customer Data',
            Icons.contacts,
            () => Navigator.of(context).pushNamed('/customer-data-management'),
          ),
          _buildDrawerItem(
            context,
            'Templates',
            Icons.description,
            () => Navigator.of(context).pushNamed('/excel-template-config'),
          ),
          _buildDrawerItem(
            context,
            'Reports',
            Icons.report,
            () => Navigator.of(context).pushNamed('/reporting-dashboard'),
          ),

          const Divider(),

          // Agent Portal Access
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
            () => Navigator.of(context).pushNamed('/role-assignment/1'),
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
          color: selected ? Colors.indigo.shade700 : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.indigo.shade700 : Colors.black,
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
