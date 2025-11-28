import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_policy_overview.dart';
import '../widgets/dashboard_premium_payment.dart';
import '../widgets/dashboard_claims_status.dart';
import '../widgets/dashboard_customer_profile.dart';
import '../widgets/dashboard_quick_actions.dart';

/// Customer Policyholder Dashboard Page
/// Comprehensive dashboard for policyholders to manage their policies and account
class CustomerPolicyholderDashboardPage extends StatefulWidget {
  const CustomerPolicyholderDashboardPage({super.key});

  @override
  State<CustomerPolicyholderDashboardPage> createState() => _CustomerPolicyholderDashboardPageState();
}

class _CustomerPolicyholderDashboardPageState extends State<CustomerPolicyholderDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final viewModel = context.read<DashboardViewModel>();
    await viewModel.loadCustomerPolicyholderData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Account'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => _contactSupport(),
            tooltip: 'Contact Support',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomerData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your account information...'),
                ],
              ),
            );
          }

          if (viewModel.customerData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Unable to load account data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCustomerData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final customerData = viewModel.customerData!;

          return RefreshIndicator(
            onRefresh: _loadCustomerData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(customerData),

                    const SizedBox(height: 24),

                    // Quick Stats Row
                    _buildQuickStatsRow(customerData),

                    const SizedBox(height: 24),

                    // Active Policies Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.policy,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'My Policies',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          PolicyOverviewWidget(
                            policies: customerData['policies'] ?? [],
                            onPolicyTap: _onPolicyTap,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Premium Payment Section
                    PremiumPaymentWidget(
                      premiumData: customerData['premium_data'] ?? {},
                      onPaymentTap: _onPaymentTap,
                    ),

                    const SizedBox(height: 24),

                    // Claims Section
                    ClaimsStatusWidget(
                      claims: customerData['claims'] ?? [],
                      onClaimTap: _onClaimTap,
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    QuickActionsWidget(
                      actions: customerData['quick_actions'] ?? [],
                      onActionTap: _onActionTap,
                    ),

                    const SizedBox(height: 24),

                    // Recent Activity
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activity',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRecentActivity(customerData['recent_activity'] ?? []),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(Map<String, dynamic> customerData) {
    final customerName = customerData['customer_name'] ?? 'Valued Customer';
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  customerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Policyholder ID: ${customerData['policyholder_id'] ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(Map<String, dynamic> customerData) {
    final stats = customerData['quick_stats'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            context,
            'Active Policies',
            '${stats['active_policies'] ?? 0}',
            Icons.policy,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            context,
            'Total Coverage',
            '₹${stats['total_coverage'] ?? 0}',
            Icons.shield,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            context,
            'Pending Claims',
            '${stats['pending_claims'] ?? 0}',
            Icons.assignment,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<dynamic> activities) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No recent activity'),
        ),
      );
    }

    return Column(
      children: activities.take(5).map<Widget>((activity) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getActivityIcon(activity['type']),
                size: 16,
                color: _getActivityColor(activity['type']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['description'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      activity['date'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showNotifications() {
    // Show notifications dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('Notifications feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    // Contact support functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Support contact options will be shown here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onPolicyTap(dynamic policy) {
    // Navigate to policy details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening policy: ${policy['policy_number']}')),
    );
  }

  void _onPaymentTap(String action) {
    // Handle payment actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment action: $action')),
    );
  }

  void _onClaimTap(dynamic claim) {
    // Navigate to claim details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening claim: ${claim['claim_number']}')),
    );
  }

  void _onActionTap(String action) {
    // Handle quick actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action: $action')),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'claim':
        return Icons.assignment;
      case 'policy':
        return Icons.policy;
      case 'support':
        return Icons.support_agent;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'claim':
        return Colors.orange;
      case 'policy':
        return Colors.blue;
      case 'support':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
