import 'package:flutter/material.dart';
import 'package:provider/Provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/models/dashboard_models.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class RegionalManagerDashboard extends StatefulWidget {
  const RegionalManagerDashboard({super.key});

  @override
  State<RegionalManagerDashboard> createState() => _RegionalManagerDashboardState();
}

class _RegionalManagerDashboardState extends State<RegionalManagerDashboard> {
  final DashboardService _dashboardService = DashboardService();
  RegionalOverviewData? _regionalData;
  bool _isLoading = true;
  String _region = 'Mumbai'; // Default region, could be derived from user data

  @override
  void initState() {
    super.initState();
    _loadRegionalData();
  }

  Future<void> _loadRegionalData() async {
    try {
      final data = await _dashboardService.getRegionalOverview(_region);
      if (mounted) {
        setState(() {
          _regionalData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading regional data: $e');
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
        title: const Text('Regional Manager Dashboard'),
        backgroundColor: Colors.teal.shade700,
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
              onRefresh: _loadRegionalData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Card(
                      elevation: 4,
                      color: Colors.teal.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 32, color: Colors.teal.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome, ${currentUser?.name ?? 'Regional Manager'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal.shade700,
                                            ),
                                      ),
                                      Text(
                                        'Regional Operations - $_region',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(color: Colors.teal.shade600),
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

                    // Regional Overview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Regional Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadRegionalData,
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
                            _regionalData?.totalAgents.toString() ?? '0',
                            Icons.business,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Agents',
                            _regionalData?.activeAgents.toString() ?? '0',
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
                            'Regional Revenue',
                            '₹${(_regionalData?.regionalRevenue ?? 0).toStringAsFixed(0)}',
                            Icons.currency_rupee,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Monthly Growth',
                            '${(_regionalData?.monthlyGrowth ?? 0).toStringAsFixed(1)}%',
                            Icons.trending_up,
                            (_regionalData?.monthlyGrowth ?? 0) >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    // Top Performers Section
                    if (_regionalData?.topPerformers.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Top Performers in $_region',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ..._regionalData!.topPerformers.map((performer) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Text(
                              performer.name.isNotEmpty ? performer.name[0].toUpperCase() : 'A',
                              style: TextStyle(color: Colors.teal.shade700),
                            ),
                          ),
                          title: Text(performer.name),
                          subtitle: Text('${performer.policiesSold} policies sold'),
                          trailing: Text(
                            '₹${performer.totalPremium.toStringAsFixed(0)}',
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
              color: Colors.teal.shade700,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.location_on,
                      size: 30, color: Colors.teal),
                ),
                SizedBox(height: 10),
                Text(
                  'Regional Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Regional Operations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.teal),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.green),
            title: const Text('Regional Analytics'),
            onTap: () => Navigator.of(context).pushNamed('/reporting-dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Agent Oversight'),
            onTap: () => Navigator.of(context).pushNamed('/user-management'),
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.orange),
            title: const Text('Campaign Management'),
            onTap: () => Navigator.of(context).pushNamed('/campaign-builder'),
          ),
          const Divider(),

          // Agent Portal (Regional Oversight)
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
            onTap: () => Navigator.of(context).pushNamed('/policy/create'),
          ),
          ListTile(
            leading: Icon(Icons.report_problem, color: Colors.grey[400], size: 20),
            title: const Text('New Claim', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/claims/new'),
          ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).pushNamed('/regional-manager-settings'),
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

}
