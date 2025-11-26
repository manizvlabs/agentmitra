import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Enhanced KPI Cards Widget for Agent Dashboard
/// Displays Monthly Revenue, Active Customers, Policies Sold, and Commission
class DashboardKPICards extends StatelessWidget {
  const DashboardKPICards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final analytics = viewModel.analytics;
        final performance = viewModel.agentPerformance;

        if (analytics == null && performance == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Performance Indicators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                // Monthly Revenue
                _buildKPICard(
                  context,
                  title: 'Monthly Revenue',
                  value: viewModel.formatCurrency(analytics?.monthlyRevenue ?? 0.0),
                  subtitle: 'This month',
                  icon: Icons.currency_rupee,
                  color: Colors.green,
                  trend: analytics != null
                      ? viewModel.formatPercentage(analytics.growthRate)
                      : '+0.0%',
                  trendColor: analytics != null && analytics.growthRate >= 0
                      ? Colors.green
                      : Colors.red,
                ),
                // Active Customers
                _buildKPICard(
                  context,
                  title: 'Active Customers',
                  value: (analytics?.totalPolicies ?? performance?.customersAcquired ?? 0).toString(),
                  subtitle: 'Total customers',
                  icon: Icons.people,
                  color: Colors.blue,
                  trend: analytics != null && analytics.newCustomers > 0
                      ? '+${analytics.newCustomers} new'
                      : '+0 new',
                  trendColor: Colors.green,
                ),
                // Policies Sold
                _buildKPICard(
                  context,
                  title: 'Policies Sold',
                  value: (performance?.policiesSold ?? analytics?.totalPolicies ?? 0).toString(),
                  subtitle: 'This month',
                  icon: Icons.policy,
                  color: Colors.purple,
                  trend: performance != null
                      ? '+${(performance.policiesSold * 0.1).round()} vs last month'
                      : '+0 vs last month',
                  trendColor: Colors.green,
                ),
                // Commission
                _buildKPICard(
                  context,
                  title: 'Commission',
                  value: viewModel.formatCurrency(performance?.totalCommission ?? 0.0),
                  subtitle: 'Total earned',
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                  trend: performance != null
                      ? viewModel.formatPercentage(12.5) // TODO: Calculate from API
                      : '+0.0%',
                  trendColor: Colors.green,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required Color trendColor,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Value
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineMedium?.color,
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

          const SizedBox(height: 12),

          // Trend indicator
          Row(
            children: [
              Icon(
                trendColor == Colors.green ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

