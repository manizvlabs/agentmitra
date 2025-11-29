import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              elevation: 4,
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business,
                            size: 32, color: Colors.deepPurple.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${currentUser?.name ?? 'Senior Agent'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurple.shade700,
                                    ),
                              ),
                              Text(
                                'Advanced Agent Operations',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.deepPurple.shade600),
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
              'Business Operations',
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
                  'My Dashboard',
                  'View business analytics',
                  Icons.dashboard,
                  Colors.blue,
                  () => Navigator.of(context).pushNamed('/agent-dashboard'),
                ),
                _buildActionCard(
                  context,
                  'Customer Management',
                  'Manage client relationships',
                  Icons.people,
                  Colors.green,
                  () => Navigator.of(context).pushNamed('/customers'),
                ),
                _buildActionCard(
                  context,
                  'Marketing Campaigns',
                  'Create & manage campaigns',
                  Icons.campaign,
                  Colors.orange,
                  () => Navigator.of(context).pushNamed('/campaign-builder'),
                ),
                _buildActionCard(
                  context,
                  'Presentations',
                  'Create sales presentations',
                  Icons.slideshow,
                  Colors.purple,
                  () => Navigator.of(context).pushNamed('/presentations'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Business Overview
            Text(
              'Business Overview',
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
                    'Active Clients',
                    '127',
                    Icons.people_outline,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Monthly Revenue',
                    '₹4.2L',
                    Icons.currency_rupee,
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
                    'Policies Sold',
                    '45',
                    Icons.policy,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'ROI',
                    '18.5%',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityItem(
                      'Policy sold to Rajesh Kumar',
                      '₹50,000 LIC Jeevan Anand',
                      '2 hours ago',
                      Icons.policy,
                      Colors.green,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      'Campaign "Summer Savings" launched',
                      'Target: 200 prospects',
                      '5 hours ago',
                      Icons.campaign,
                      Colors.orange,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      'Customer follow-up completed',
                      '15 clients contacted',
                      '1 day ago',
                      Icons.phone,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Tasks
            Text(
              'Quick Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickTaskButton(context, 'Add Client', Icons.person_add),
                _buildQuickTaskButton(context, 'Create Quote', Icons.calculate),
                _buildQuickTaskButton(context, 'Schedule Call', Icons.schedule),
                _buildQuickTaskButton(context, 'Send Message', Icons.message),
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

  Widget _buildActivityItem(String title, String subtitle, String time,
      IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTaskButton(BuildContext context, String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _showTaskDialog(context, label),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade50,
        foregroundColor: Colors.deepPurple.shade700,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  child: Icon(Icons.business,
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
                  'Advanced Operations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Business Operations
          _buildSectionHeader('Business Operations'),
          _buildDrawerItem(
            context,
            'Dashboard',
            Icons.dashboard,
            () => Navigator.of(context).pop(),
            selected: true,
          ),
          _buildDrawerItem(
            context,
            'My Business',
            Icons.business,
            () => Navigator.of(context).pushNamed('/agent-dashboard'),
          ),
          _buildDrawerItem(
            context,
            'ROI Analytics',
            Icons.trending_up,
            () => Navigator.of(context).pushNamed('/roi-analytics'),
          ),

          const Divider(),

          // Customer Management
          _buildSectionHeader('Customer Management'),
          _buildDrawerItem(
            context,
            'Customers',
            Icons.people,
            () => Navigator.of(context).pushNamed('/customers'),
          ),
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

          const Divider(),

          // Marketing & Sales
          _buildSectionHeader('Marketing & Sales'),
          _buildDrawerItem(
            context,
            'Campaign Builder',
            Icons.campaign,
            () => Navigator.of(context).pushNamed('/campaign-builder'),
          ),
          _buildDrawerItem(
            context,
            'Presentations',
            Icons.slideshow,
            () => Navigator.of(context).pushNamed('/presentations'),
          ),
          _buildDrawerItem(
            context,
            'Daily Quotes',
            Icons.format_quote,
            () => Navigator.of(context).pushNamed('/daily-quotes'),
          ),

          const Divider(),

          // Communication
          _buildSectionHeader('Communication'),
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

          // Learning & Support
          _buildSectionHeader('Learning & Support'),
          _buildDrawerItem(
            context,
            'Learning Center',
            Icons.library_books,
            () => Navigator.of(context).pushNamed('/learning-center'),
          ),
          _buildDrawerItem(
            context,
            'Reports',
            Icons.report,
            () => Navigator.of(context).pushNamed('/reports'),
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
          color: selected ? Colors.deepPurple.shade700 : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.deepPurple.shade700 : Colors.black,
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

  void _showTaskDialog(BuildContext context, String taskType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$taskType - Coming Soon'),
        content: Text('The $taskType feature is under development.'),
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
