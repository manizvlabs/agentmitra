import 'package:flutter/material.dart';

/// Retention Actions Widget
/// Displays and manages retention actions for at-risk customers
class RetentionActionsWidget extends StatelessWidget {
  final List<dynamic> retentionActions;
  final Function(dynamic) onActionComplete;
  final Function(dynamic) onActionUpdate;

  const RetentionActionsWidget({
    super.key,
    required this.retentionActions,
    required this.onActionComplete,
    required this.onActionUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (retentionActions.isEmpty) {
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
              Icons.handshake,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'No Retention Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Retention actions will appear as customers are identified',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
          Row(
            children: [
              Icon(
                Icons.handshake,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Retention Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${retentionActions.length} actions in progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...retentionActions.map((action) => _buildRetentionAction(context, action)),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Navigate to full retention actions view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View all retention actions')),
                );
              },
              icon: const Icon(Icons.expand_more),
              label: const Text('View All Actions'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetentionAction(BuildContext context, dynamic action) {
    final status = action['status'] ?? 'pending';
    final priority = action['priority'] ?? 'medium';
    final dueDate = action['due_date'] ?? '';
    final customerName = action['customer_name'] ?? 'Unknown Customer';
    final actionType = action['action_type'] ?? 'general';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and priority
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPriorityColor(priority).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  priority.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                dueDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isOverdue(dueDate) ? Colors.red : Colors.grey.shade600,
                  fontWeight: _isOverdue(dueDate) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Customer and action details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action['description'] ?? 'Retention action',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getActionTypeColor(actionType).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActionTypeIcon(actionType),
                  color: _getActionTypeColor(actionType),
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress and actions
          if (status == 'in_progress') ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: action['progress'] ?? 0.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(status),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],

          // Action buttons
          Row(
            children: [
              if (status == 'pending' || status == 'in_progress') ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onActionUpdate(action),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _getStatusColor(status)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      status == 'pending' ? 'Start Action' : 'Update Progress',
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onActionComplete(action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == 'completed' ? Colors.green : _getStatusColor(status),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    status == 'completed' ? 'View Details' : 'Mark Complete',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          // Success metrics (for completed actions)
          if (status == 'completed' && action['outcome'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      action['outcome']['description'] ?? 'Action completed successfully',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (action['outcome']['value'] != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '₹${action['outcome']['value']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'successful':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getActionTypeColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'call':
        return Colors.blue;
      case 'email':
        return Colors.purple;
      case 'meeting':
        return Colors.green;
      case 'discount':
        return Colors.orange;
      case 'personal_visit':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionTypeIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'call':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'meeting':
        return Icons.meeting_room;
      case 'discount':
        return Icons.discount;
      case 'personal_visit':
        return Icons.person;
      default:
        return Icons.handshake;
    }
  }

  bool _isOverdue(String dueDate) {
    if (dueDate.isEmpty) return false;
    try {
      final due = DateTime.parse(dueDate);
      return due.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }
}
