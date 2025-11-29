import 'package:flutter/material.dart';
import 'package:provider/Provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/models/dashboard_models.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SeniorAgentDashboard extends StatefulWidget {
  const SeniorAgentDashboard({super.key});

  @override
  State<SeniorAgentDashboard> createState() => _SeniorAgentDashboardState();
}

class _SeniorAgentDashboardState extends State<SeniorAgentDashboard> {
  final DashboardService _dashboardService = DashboardService();
  SeniorAgentOverviewData? _agentData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgentData();
  }

  Future<void> _loadAgentData() async {
    try {
      final data = await _dashboardService.getSeniorAgentOverview();
      if (mounted) {
        setState(() {
          _agentData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading agent data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAgentData,
              child: SingleChildScrollView(
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
                                Icon(Icons.business_center,
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
                                        'Business Operations & Analytics',
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

                    // Personal Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Performance',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadAgentData,
                          tooltip: 'Refresh data',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Policies Sold',
                            _agentData?.personalStats['totalPoliciesSold']?.toString() ?? '0',
                            Icons.policy,
                            Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Monthly Revenue',
                            '₹${(_agentData?.monthlyRevenue ?? 0).toStringAsFixed(0)}',
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
                            'Team Size',
                            _agentData?.teamStats['teamSize']?.toString() ?? '0',
                            Icons.group,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Pending Tasks',
                            _agentData?.pendingTasks.toString() ?? '0',
                            Icons.pending_actions,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),

                    // Top Customers Section
                    if (_agentData?.topCustomers.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Top Customers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ..._agentData!.topCustomers.map((customer) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                              style: TextStyle(color: Colors.deepPurple.shade700),
                            ),
                          ),
                          title: Text(customer.name),
                          subtitle: Text('${customer.policyCount} policies'),
                          trailing: Text(
                            '₹${customer.totalPremium.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      )),
                    ],

                    // Recent Activities Section
                    if (_agentData?.recentActivities.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Recent Activities',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ..._agentData!.recentActivities.take(5).map((activity) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.receipt,
                            color: Colors.deepPurple.shade600,
                          ),
                          title: Text(activity.description),
                          subtitle: Text(
                            activity.timestamp != null
                                ? 'Today'
                                : 'Recently',
                          ),
                          trailing: Text(
                            '₹${activity.amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ],
                ),
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
          // Customer Portal (Limited Access)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Customer Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.grey[400], size: 20),
            title: const Text('Customer Dashboard', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/customer-dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.policy, color: Colors.grey[400], size: 20),
            title: const Text('My Policies', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/policies'),
          ),
          ListTile(
            leading: Icon(Icons.description, color: Colors.grey[400], size: 20),
            title: const Text('Policy Details', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/policy-details'),
          ),

          const Divider(),

          // Communication
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Communication',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.chat, color: Colors.grey[400], size: 20),
            title: const Text('WhatsApp Integration', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/whatsapp-integration'),
          ),
          ListTile(
            leading: Icon(Icons.smart_toy, color: Colors.grey[400], size: 20),
            title: const Text('Smart Chatbot', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/smart-chatbot'),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.grey[400], size: 20),
            title: const Text('Notifications', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),

          const Divider(),

          // Policy Management
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Policy Management',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.add_circle, color: Colors.grey[400], size: 20),
            title: const Text('New Policy', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/new-policy'),
          ),
          ListTile(
            leading: Icon(Icons.report_problem, color: Colors.grey[400], size: 20),
            title: const Text('New Claim', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/new-claim'),
          ),
          ListTile(
            leading: Icon(Icons.create, color: Colors.grey[400], size: 20),
            title: const Text('Policy Create', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/policy/create'),
          ),

          const Divider(),

          // Learning & Support
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Learning & Support',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.library_books, color: Colors.grey[400], size: 20),
            title: const Text('Learning Center', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/learning-center'),
          ),
          ListTile(
            leading: Icon(Icons.report, color: Colors.grey[400], size: 20),
            title: const Text('Reports', style: TextStyle(fontSize: 14)),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
