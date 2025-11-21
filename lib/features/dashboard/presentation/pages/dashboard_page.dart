import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/global_providers.dart';
import '../../../../features/presentations/presentation/widgets/presentation_carousel.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_analytics_cards.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_notifications.dart';
import '../widgets/dashboard_priority_alerts.dart';

/// Enhanced Dashboard Page with real API integration and presentation carousel
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Load additional analytics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = provider.Provider.of<DashboardViewModel>(context, listen: false);
      viewModel.loadAgentPerformanceData();
      viewModel.loadBusinessIntelligenceData();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final viewModel = provider.Provider.of<DashboardViewModel>(context, listen: false);
            await viewModel.refreshDashboard();
          },
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Header
                    _buildWelcomeHeader(),

                    const SizedBox(height: 24),

                    // Presentation Carousel
                    const PresentationCarousel(),

                    const SizedBox(height: 24),

                    // Priority Alerts (if any)
                    const DashboardPriorityAlerts(),

                    // Analytics Cards
                    const DashboardAnalyticsCards(),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const DashboardQuickActions(),

                    const SizedBox(height: 24),

                    // Recent Activity / Notifications
                    const DashboardNotifications(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final titleSize = constraints.maxWidth < 350 ? 16.0 : 18.0;
          return Text(
            'AGENT MITRA',
            style: TextStyle(
              color: Theme.of(context).textTheme.headlineSmall?.color,
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          );
        },
      ),
      actions: [
        provider.Consumer<DashboardViewModel>(
          builder: (context, viewModel, child) {
            final unreadCount = viewModel.unreadNotificationsCount;
            return Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: 24,
                  ),
                  onPressed: () {
                    // TODO: Navigate to notifications screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications screen coming soon!')),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
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
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
            size: 24,
          ),
          onPressed: () {
            // TODO: Implement global search
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Global search coming soon!')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).iconTheme.color,
          ),
          onSelected: (value) async {
            switch (value) {
              case 'refresh':
                final viewModel = context.read<DashboardViewModel>();
                await viewModel.refreshDashboard();
                break;
              case 'settings':
                context.go('/settings');
                break;
              case 'logout':
                // TODO: Implement logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout functionality coming soon!')),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final greeting = viewModel.getGreeting();
        final summary = viewModel.getAnalyticsSummary();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, Agent!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.headlineSmall?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your business overview',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_center,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quick Stats Row
              Row(
                children: [
                  _buildStatItem(
                    'Policies',
                    summary['total_policies']?.toString() ?? '0',
                    Icons.policy,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    'Revenue',
                    viewModel.formatCurrency(summary['monthly_revenue'] ?? 0.0),
                    Icons.currency_rupee,
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    'Growth',
                    viewModel.formatPercentage(summary['growth_rate'] ?? 0.0),
                    Icons.trending_up,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
