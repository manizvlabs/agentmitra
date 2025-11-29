import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../core/services/rbac_service.dart';
import '../core/services/navigation_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/models/dashboard_models.dart';
import '../core/widgets/context_aware_back_button.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final DashboardService _dashboardService = DashboardService();
  SystemOverviewData? _systemData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
  }

  Future<void> _loadSystemData() async {
    try {
      final data = await _dashboardService.getSystemOverview();
      if (mounted) {
        setState(() {
          _systemData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading system data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _hasPermission(String permission) {
    final authViewModel = provider.Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;
    return user?.permissions.contains(permission) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = provider.Provider.of<AuthViewModel>(context);
    final currentUser = authViewModel.currentUser;

    // Initialize breadcrumb for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().addNavigationItem('Super Admin Dashboard', '/super-admin-dashboard');
    });

    return Scaffold(
      appBar: ContextAwareAppBar(
        title: 'Super Admin Dashboard',
        backgroundColor: Colors.red.shade700,
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
              onRefresh: _loadSystemData,
              child: SingleChildScrollView(
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

                    // System Overview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'System Overview',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadSystemData,
                          tooltip: 'Refresh data',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Users',
                            _systemData?.totalUsers.toString() ?? '0',
                            Icons.people_outline,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Users',
                            _systemData?.activeUsers.toString() ?? '0',
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
                            'Total Agents',
                            _systemData?.totalAgents.toString() ?? '0',
                            Icons.business,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Agents',
                            _systemData?.activeAgents.toString() ?? '0',
                            Icons.business_center,
                            Colors.indigo,
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
                            _systemData?.totalPolicies.toString() ?? '0',
                            Icons.policy,
                            Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Policies',
                            _systemData?.activePolicies.toString() ?? '0',
                            Icons.verified,
                            Colors.cyan,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Monthly Revenue',
                            '₹${(_systemData?.monthlyRevenue ?? 0).toStringAsFixed(0)}',
                            Icons.currency_rupee,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Active Sessions',
                            _systemData?.activeSessions.toString() ?? '0',
                            Icons.computer,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'System Health',
                            '${(_systemData?.systemHealth ?? 0).toStringAsFixed(1)}%',
                            Icons.health_and_safety,
                            (_systemData?.systemHealth ?? 0) >= 95 ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Pending Approvals',
                            _systemData?.pendingApprovals.toString() ?? '0',
                            Icons.pending_actions,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
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
          if (_hasPermission('users.read'))
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('User Management'),
            onTap: () => context.navigateWithBreadcrumb('/user-management', 'User Management'),
          ),
          if (_hasPermission('analytics.read'))
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.green),
              title: const Text('System Analytics'),
              onTap: () => context.navigateWithBreadcrumb('/reporting-dashboard', 'System Analytics'),
            ),
          // Feature flags only for Super Admin role
          ListTile(
            leading: const Icon(Icons.flag, color: Colors.orange),
            title: const Text('Feature Flags'),
            onTap: () => context.navigateWithBreadcrumb('/pioneer-demo', 'Feature Flags'),
          ),

          const Divider(),

          // Authentication & Onboarding
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Authentication & Onboarding',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.waving_hand, color: Colors.grey[400], size: 20),
            title: const Text('Welcome Screen', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/welcome'),
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.grey[400], size: 20),
            title: const Text('Phone Verification', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/phone-verification'),
          ),
          ListTile(
            leading: Icon(Icons.lock, color: Colors.grey[400], size: 20),
            title: const Text('OTP Verification', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/otp-verification'),
          ),
          ListTile(
            leading: Icon(Icons.login, color: Colors.grey[400], size: 20),
            title: const Text('Login Page', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/login'),
          ),
          ListTile(
            leading: Icon(Icons.rocket_launch, color: Colors.grey[400], size: 20),
            title: const Text('Trial Setup', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/trial-setup'),
          ),
          ListTile(
            leading: Icon(Icons.school, color: Colors.grey[400], size: 20),
            title: const Text('Onboarding', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/onboarding'),
          ),
          ListTile(
            leading: Icon(Icons.timer_off, color: Colors.grey[400], size: 20),
            title: const Text('Trial Expiration', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/trial-expiration'),
          ),

          const Divider(),

          // Customer Portal
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
          ListTile(
            leading: Icon(Icons.library_books, color: Colors.grey[400], size: 20),
            title: const Text('Learning Center', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/learning-center'),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.grey[400], size: 20),
            title: const Text('Profile', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),

          // Agent Portal
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
            leading: Icon(Icons.trending_up, color: Colors.grey[400], size: 20),
            title: const Text('ROI Analytics', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/roi-analytics'),
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
          ListTile(
            leading: Icon(Icons.report, color: Colors.grey[400], size: 20),
            title: const Text('Reports', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/reports'),
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

          // Admin Portal
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
            leading: Icon(Icons.assignment_ind, color: Colors.grey[400], size: 20),
            title: const Text('Role Assignment', style: TextStyle(fontSize: 14)),
            onTap: () => Navigator.of(context).pushNamed('/role-assignment/1'), // Example user ID
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