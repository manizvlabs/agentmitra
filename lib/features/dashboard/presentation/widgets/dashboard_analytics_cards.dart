import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mocks/mock_dashboard_viewmodel.dart';

/// Analytics Cards Widget for dashboard metrics
class DashboardAnalyticsCards extends StatelessWidget {
  const DashboardAnalyticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockDashboardViewModel>(
      builder: (context, viewModel, child) {
        final analytics = viewModel.analytics;

        if (analytics == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Analytics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildAnalyticsCard(
                  context,
                  title: 'Total Policies',
                  value: analytics.totalPolicies.toString(),
                  subtitle: 'Active policies',
                  icon: Icons.policy,
                  color: Colors.blue,
                  trend: '+${analytics.newCustomers} new this month',
                ),

                _buildAnalyticsCard(
                  context,
                  title: 'Total Premium',
                  value: viewModel.formatCurrency(analytics.totalPremium),
                  subtitle: 'Portfolio value',
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                  trend: '${viewModel.formatPercentage(analytics.growthRate)} growth',
                ),

                _buildAnalyticsCard(
                  context,
                  title: 'Monthly Revenue',
                  value: viewModel.formatCurrency(analytics.monthlyRevenue),
                  subtitle: 'This month',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                  trend: 'Target: ${viewModel.formatCurrency(analytics.monthlyRevenue * 1.2)}',
                ),

                _buildAnalyticsCard(
                  context,
                  title: 'Active Claims',
                  value: analytics.activeClaims.toString(),
                  subtitle: 'Under process',
                  icon: Icons.assignment,
                  color: Colors.orange,
                  trend: '${analytics.recentClaims.where((c) => c.status == 'approved').length} approved',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Activity Section
            _buildRecentActivitySection(context, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
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
          // Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          // Trend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trend,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, MockDashboardViewModel viewModel) {
    final analytics = viewModel.analytics;
    if (analytics == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        // Recent Policies
        if (analytics.recentPolicies.isNotEmpty) ...[
          _buildActivityCard(
            context,
            title: 'Recent Policies',
            items: analytics.recentPolicies.take(3).map((policy) {
              final isExpiring = policy.isExpiringSoon;
              final isExpired = policy.isExpired;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? Colors.red.withOpacity(0.1)
                        : isExpiring
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.policy,
                    color: isExpired
                        ? Colors.red
                        : isExpiring
                            ? Colors.orange
                            : Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  policy.policyNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${policy.customerName} • ${policy.policyType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Text(
                  viewModel.formatCurrency(policy.premium),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 16),

        // Upcoming Payments
        if (analytics.upcomingPayments.isNotEmpty) ...[
          _buildActivityCard(
            context,
            title: 'Upcoming Payments',
            items: analytics.upcomingPayments.take(3).map((payment) {
              final daysUntilDue = payment.daysUntilDue;
              final isOverdue = payment.isOverdue;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: isOverdue ? Colors.red : Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  payment.policyNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${payment.customerName} • Due ${isOverdue ? 'overdue' : 'in $daysUntilDue days'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverdue ? Colors.red : null,
                  ),
                ),
                trailing: Text(
                  viewModel.formatCurrency(payment.amount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
}
