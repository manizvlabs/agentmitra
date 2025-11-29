import 'package:flutter/material.dart';

/// Dashboard Quick Actions Widget
/// Shows common actions customers can take
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Icon(
            Icons.flash_on,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Common actions will be available here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Quick Actions Widget
/// Shows common actions customers can take
class QuickActionsWidget extends StatelessWidget {
  final List<dynamic> actions;
  final Function(String) onActionTap;

  const QuickActionsWidget({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _getDefaultActions().map((action) {
              return _buildActionCard(context, action);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    return InkWell(
      onTap: () => onActionTap(action['id']),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: action['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: action['color'].withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              action['icon'],
              color: action['color'],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              action['title'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: action['color'],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              action['subtitle'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: action['color'].withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDefaultActions() {
    return [
      {
        'id': 'pay_premium',
        'title': 'Pay Premium',
        'subtitle': 'Make payment',
        'icon': Icons.payment,
        'color': Colors.green,
      },
      {
        'id': 'file_claim',
        'title': 'File Claim',
        'subtitle': 'Submit new claim',
        'icon': Icons.assignment,
        'color': Colors.orange,
      },
      {
        'id': 'download_docs',
        'title': 'Documents',
        'subtitle': 'Policy docs',
        'icon': Icons.download,
        'color': Colors.blue,
      },
      {
        'id': 'contact_agent',
        'title': 'Contact Agent',
        'subtitle': 'Get help',
        'icon': Icons.support_agent,
        'color': Colors.purple,
      },
      {
        'id': 'update_profile',
        'title': 'Update Profile',
        'subtitle': 'Edit details',
        'icon': Icons.person,
        'color': Colors.teal,
      },
      {
        'id': 'view_history',
        'title': 'Payment History',
        'subtitle': 'View records',
        'icon': Icons.history,
        'color': Colors.indigo,
      },
    ];
  }
}