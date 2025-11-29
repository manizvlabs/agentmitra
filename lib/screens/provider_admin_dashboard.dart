import 'package:flutter/material.dart';
import 'package:provider/Provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../core/services/navigation_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/models/dashboard_models.dart';
import '../core/widgets/context_aware_back_button.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class ProviderAdminDashboard extends StatefulWidget {
  const ProviderAdminDashboard({super.key});

  @override
  State<ProviderAdminDashboard> createState() => _ProviderAdminDashboardState();
}

class _ProviderAdminDashboardState extends State<ProviderAdminDashboard> {
  final DashboardService _dashboardService = DashboardService();
  ProviderOverviewData? _providerData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    try {
      final data = await _dashboardService.getProviderOverview();
      if (mounted) {
        setState(() {
          _providerData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading provider data: $e');
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

    // Initialize breadcrumb for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().addNavigationItem('Provider Admin Dashboard', '/provider-admin-dashboard');
    });

    return Scaffold(
      appBar: ContextAwareAppBar(
        title: 'Provider Admin Dashboard',
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        showBreadcrumbs: true,
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
              onRefresh: _loadProviderData,
              child: SingleChildScrollView(
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
                                Icon(Icons.business,
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

                    // Provider Overview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Provider Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadProviderData,
                          tooltip: 'Refresh data',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Agents',
                            _providerData?.totalAgents.toString() ?? '0',
                            Icons.business,
                            Colors.indigo,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Agents',
                            _providerData?.activeAgents.toString() ?? '0',
                            Icons.business_center,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Policies',
                            _providerData?.totalPolicies.toString() ?? '0',
                            Icons.policy,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Monthly Revenue',
                            '₹${(_providerData?.monthlyRevenue ?? 0).toStringAsFixed(0)}',
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
                            'Pending Verifications',
                            _providerData?.pendingVerifications.toString() ?? '0',
                            Icons.pending_actions,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Recent Policies',
                            _providerData?.recentPolicies.length.toString() ?? '0',
                            Icons.receipt,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    // Top Performing Agents Section
                    if (_providerData?.topPerformingAgents.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Top Performing Agents',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ..._providerData!.topPerformingAgents.map((agent) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                              style: TextStyle(color: Colors.indigo.shade700),
                            ),
                          ),
                          title: Text(agent.name),
                          subtitle: Text('${agent.policiesSold} policies sold'),
                          trailing: Text(
                            '₹${agent.totalPremium.toStringAsFixed(0)}',
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
            onTap: () => context.navigateWithBreadcrumb('/user-management', 'Agent Management'),
          ),
          ListTile(
            leading: const Icon(Icons.contacts, color: Colors.green),
            title: const Text('Customer Data'),
            onTap: () => context.navigateWithBreadcrumb('/customer-data-management', 'Customer Data'),
          ),
          const Divider(),

          // Agent Portal (Limited Access)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Agent Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings_applications, color: Colors.grey[400], size: 20),
            title: const Text('Agent Config Dashboard', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/agent-config-dashboard'),
          ),
          ListTile(
            leading: Icon(Icons.campaign, color: Colors.grey[400], size: 20),
            title: const Text('Campaign Builder', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/campaign-builder'),
          ),
          ListTile(
            leading: Icon(Icons.people_alt, color: Colors.grey[400], size: 20),
            title: const Text('Customers', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/customers'),
          ),

          const Divider(),

          // Customer Portal (Limited Access)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Customer Support',
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
          ListTile(
            leading: Icon(Icons.chat, color: Colors.grey[400], size: 20),
            title: const Text('WhatsApp Integration', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/whatsapp-integration'),
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

          // Admin Portal (Limited Access)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Admin Portal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.business, color: Colors.grey[400], size: 20),
            title: const Text('Tenant Onboarding', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/tenant-onboarding'),
          ),
          ListTile(
            leading: Icon(Icons.gavel, color: Colors.grey[400], size: 20),
            title: const Text('Compliance Reports', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/compliance-reports'),
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
