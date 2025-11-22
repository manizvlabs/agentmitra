import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Priority Alerts Widget for dashboard critical notifications
class DashboardPriorityAlerts extends StatelessWidget {
  const DashboardPriorityAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final priorities = viewModel.getTopPriorities();

        if (priorities.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Priority Alerts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Priority Alerts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: priorities.length,
              itemBuilder: (context, index) {
                final priority = priorities[index];
                return _buildPriorityAlertCard(context, priority);
              },
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPriorityAlertCard(BuildContext context, Map<String, dynamic> priority) {
    final priorityType = priority['type'] as String;
    final title = priority['title'] as String;
    final message = priority['message'] as String;
    final priorityLevel = priority['priority'] as String;
    final icon = priority['icon'] as IconData;
    final color = priority['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
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

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priorityLevel).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        priorityLevel.toUpperCase(),
                        style: TextStyle(
                          color: _getPriorityColor(priorityLevel),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Action Button
          TextButton(
            onPressed: () => _handlePriorityAction(context, priorityType),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handlePriorityAction(BuildContext context, String priorityType) {
    switch (priorityType) {
      case 'overdue_payments':
        // TODO: Navigate to payments page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payments page coming soon')),
        );
        break;
      case 'expiring_policies':
        // TODO: Navigate to policies page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Policies page coming soon')),
        );
        break;
      case 'active_claims':
        // TODO: Navigate to claims page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claims page coming soon')),
        );
        break;
      default:
        // Generic navigation for other types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigating to $priorityType section'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
    }
  }
}
