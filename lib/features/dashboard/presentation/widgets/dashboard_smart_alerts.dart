import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Smart Alerts Widget for Agent Dashboard
/// Displays important alerts and notifications
class DashboardSmartAlerts extends StatelessWidget {
  const DashboardSmartAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final analytics = viewModel.analytics;
        final unreadCount = viewModel.unreadNotificationsCount;
        final priorities = viewModel.getTopPriorities();

        if (analytics == null && priorities.isEmpty && unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Smart Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/notifications');
                    },
                    child: Text('$unreadCount unread'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Column(
                children: [
                  // High Priority Alerts
                  if (priorities.isNotEmpty)
                    ...priorities.where((p) => p['priority'] == 'high').map((alert) => _buildAlertItem(
                      context,
                      icon: alert['icon'] as IconData,
                      title: alert['title'] as String,
                      message: alert['message'] as String,
                      color: alert['color'] as Color,
                      type: alert['type'] as String,
                    )),
                  // Medium Priority Alerts
                  if (priorities.isNotEmpty)
                    ...priorities.where((p) => p['priority'] == 'medium').map((alert) => _buildAlertItem(
                      context,
                      icon: alert['icon'] as IconData,
                      title: alert['title'] as String,
                      message: alert['message'] as String,
                      color: alert['color'] as Color,
                      type: alert['type'] as String,
                    )),
                  // Low Priority / Info Alerts
                  if (analytics != null) ...[
                    if (analytics.activeClaims > 0)
                      _buildAlertItem(
                        context,
                        icon: Icons.assignment,
                        title: '${analytics.activeClaims} Active Claims',
                        message: 'Claims currently being processed',
                        color: Colors.blue,
                        type: 'info',
                      ),
                    if (analytics.newCustomers > 0)
                      _buildAlertItem(
                        context,
                        icon: Icons.people_outline,
                        title: '${analytics.newCustomers} New Customers',
                        message: 'New customers added this month',
                        color: Colors.green,
                        type: 'info',
                      ),
                  ],
                  if (priorities.isEmpty && analytics == null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No alerts at this time',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required Color color,
    required String type,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (type == 'high')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Urgent',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

