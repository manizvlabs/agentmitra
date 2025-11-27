import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/customer_dashboard/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../features/customer_dashboard/data/models/customer_dashboard_data.dart';
import '../core/widgets/loading/loading_widgets.dart';
import '../core/widgets/loading/empty_state_card.dart';
import '../core/providers/global_providers.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(customerDashboardViewModelProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(customerDashboardViewModelProvider);
    final dashboardData = viewModel.dashboardData;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1a237e)),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text(
          'AGENT MITRA',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.search, color: Color(0xFF1a237e), size: 24),
              ],
            ),
            onPressed: () {
              // TODO: Implement global search
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              return IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: const Color(0xFF1a237e),
                  size: 24,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
                tooltip: themeMode == ThemeMode.dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Color(0xFF1a237e), size: 24),
                if (dashboardData != null && dashboardData.unreadNotificationsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child:                       Text(
                        '${dashboardData.unreadNotificationsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: viewModel.isLoading && dashboardData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dashboardData != null) ...[
                      _buildWelcomeHeader(viewModel, dashboardData),
                      const SizedBox(height: 24),
                      _buildQuickActions(viewModel),
                      const SizedBox(height: 24),
                      _buildPolicyOverview(dashboardData),
                      const SizedBox(height: 24),
                      if (dashboardData.criticalNotifications.isNotEmpty) ...[
                        _buildCriticalNotifications(dashboardData),
                        const SizedBox(height: 24),
                      ],
                      if (dashboardData.quickInsights.isNotEmpty) ...[
                        _buildQuickInsights(dashboardData),
                        const SizedBox(height: 24),
                      ],
                    ] else
                      const EmptyStateCard(
                        icon: Icons.dashboard,
                        title: 'No Data Available',
                        message: 'Unable to load dashboard data. Please try again.',
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1a237e),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/policies');
              break;
            case 2:
              context.push('/smart-chatbot');
              break;
            case 3:
              context.push('/learning-center');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Policies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(
    CustomerDashboardViewModel viewModel,
    CustomerDashboardData data,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👋 ${viewModel.greeting}, ${data.customerName}!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                viewModel.formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(CustomerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: viewModel.quickActions.map((action) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: action.id != viewModel.quickActions.last.id ? 12 : 0,
                ),
                child: _buildQuickActionCard(action),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(CustomerQuickAction action) {
    return InkWell(
      onTap: () {
        context.push(action.route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(action.icon, color: action.color, size: 28),
            const SizedBox(height: 8),
            Text(
              action.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: action.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              action.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: action.color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyOverview(CustomerDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Policy Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPolicyOverviewItem(
                    'Active',
                    data.activePolicies.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildPolicyOverviewItem(
                    'Maturing',
                    data.maturingPolicies.toString(),
                    Colors.orange,
                    Icons.schedule,
                  ),
                  _buildPolicyOverviewItem(
                    'Lapsed',
                    data.lapsedPolicies.toString(),
                    Colors.red,
                    Icons.warning,
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '💰 Next Payment',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '₹${data.nextPaymentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a237e),
                    ),
                  ),
                ],
              ),
              if (data.nextPaymentDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📅 Due Date',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${data.nextPaymentDate!.day}/${data.nextPaymentDate!.month}/${data.nextPaymentDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: data.nextPaymentDate!.difference(DateTime.now()).inDays <= 7
                            ? Colors.red
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📈 Total Coverage',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '₹${(data.totalCoverage / 100000).toStringAsFixed(1)}L',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyOverviewItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalNotifications(CustomerDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔔 Critical Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        ...data.criticalNotifications.map((notification) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: notification.actionRoute != null
                  ? () {
                      context.push(notification.actionRoute!);
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: notification.typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notification.typeColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(notification.typeIcon, color: notification.typeColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: notification.typeColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: notification.typeColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (notification.actionText != null)
                      TextButton(
                        onPressed: () {
                          if (notification.actionRoute != null) {
                            context.push(notification.actionRoute!);
                          }
                        },
                        child: Text(notification.actionText!),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuickInsights(CustomerDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Quick Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: data.quickInsights.map((insight) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: insight.id != data.quickInsights.last.id ? 12 : 0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(insight.icon, color: insight.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight.title,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        insight.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: insight.color,
                        ),
                      ),
                      if (insight.change != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          insight.change!,
                          style: TextStyle(
                            fontSize: 12,
                            color: insight.color.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer Portal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF1a237e)),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              // Already on dashboard
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Onboarding',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Color(0xFF1a237e)),
            title: const Text('Find Agent'),
            subtitle: const Text('Discover and connect with agents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/agent-discovery');
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user, color: Color(0xFF1a237e)),
            title: const Text('Agent Verification'),
            subtitle: const Text('Verify your agent details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/agent-verification');
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Color(0xFF1a237e)),
            title: const Text('Upload Documents'),
            subtitle: const Text('Upload KYC documents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/document-upload');
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: Color(0xFF1a237e)),
            title: const Text('KYC Verification'),
            subtitle: const Text('Complete KYC verification'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/kyc-verification');
            },
          ),
          ListTile(
            leading: const Icon(Icons.emergency, color: Color(0xFF1a237e)),
            title: const Text('Emergency Contact'),
            subtitle: const Text('Setup emergency contacts'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/emergency-contact');
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Communication',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Color(0xFF1a237e)),
            title: const Text('WhatsApp Integration'),
            subtitle: const Text('Chat with your agent'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/whatsapp-integration');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1a237e)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF1a237e)),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
    );
  }
}
