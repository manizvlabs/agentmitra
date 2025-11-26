import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Action Items Widget for Agent Dashboard
/// Displays priority actions that need agent attention
class DashboardActionItems extends StatelessWidget {
  const DashboardActionItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final priorities = viewModel.getTopPriorities();
        final overduePayments = viewModel.overduePayments;
        final expiringPolicies = viewModel.expiringPolicies;

        if (priorities.isEmpty && overduePayments.isEmpty && expiringPolicies.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Action Items',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (priorities.length > 3)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to full action items page
                    },
                    child: const Text('View All'),
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
                  // Overdue Payments
                  if (overduePayments.isNotEmpty)
                    ...overduePayments.take(3).map((payment) => _buildActionItem(
                      context,
                      icon: Icons.payment,
                      title: 'Overdue Payment',
                      subtitle: '${payment.customerName} - ${payment.policyNumber}',
                      amount: payment.amount,
                      priority: 'high',
                      onTap: () {
                        // TODO: Navigate to payment details
                      },
                    )),
                  // Expiring Policies
                  if (expiringPolicies.isNotEmpty)
                    ...expiringPolicies.take(3).map((policy) => _buildActionItem(
                      context,
                      icon: Icons.schedule,
                      title: 'Policy Expiring Soon',
                      subtitle: '${policy.customerName} - ${policy.policyNumber}',
                      amount: policy.premium,
                      priority: 'medium',
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/policy-details',
                          arguments: {'policyId': policy.id},
                        );
                      },
                    )),
                  // Other priorities
                  if (priorities.isNotEmpty)
                    ...priorities.take(3).map((priority) => _buildActionItem(
                      context,
                      icon: priority['icon'] as IconData,
                      title: priority['title'] as String,
                      subtitle: priority['message'] as String,
                      priority: priority['priority'] as String,
                      onTap: () {
                        // TODO: Handle priority action
                      },
                    )),
                  if (priorities.isEmpty && overduePayments.isEmpty && expiringPolicies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No action items at this time',
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

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    double? amount,
    required String priority,
    required VoidCallback onTap,
  }) {
    Color priorityColor;
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: priorityColor,
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
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (amount != null)
              Text(
                '\u{20B9}${amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}

