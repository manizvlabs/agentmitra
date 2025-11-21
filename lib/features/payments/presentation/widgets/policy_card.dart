import 'package:flutter/material.dart';
import '../../data/models/policy_model.dart';

class PolicyCard extends StatelessWidget {
  final Policy policy;
  final VoidCallback? onTap;

  const PolicyCard({
    super.key,
    required this.policy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with policy number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      policy.policyNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a237e),
                      ),
                    ),
                  ),
                  _buildStatusBadge(policy.status),
                ],
              ),

              const SizedBox(height: 8),

              // Plan name
              Text(
                policy.planName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // Key details
              Row(
                children: [
                  _buildDetailItem(
                    Icons.account_balance,
                    policy.providerId,
                    'Provider',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.calendar_today,
                    _formatDate(policy.startDate),
                    'Start Date',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _buildDetailItem(
                    Icons.attach_money,
                    '₹${policy.premiumAmount.toStringAsFixed(0)}',
                    'Premium',
                  ),
                  const SizedBox(width: 16),
                  _buildDetailItem(
                    Icons.security,
                    '₹${policy.sumAssured.toStringAsFixed(0)}',
                    'Sum Assured',
                  ),
                ],
              ),

              // Show next payment due if applicable
              if (policy.nextPaymentDate != null &&
                  policy.status == 'active' &&
                  policy.outstandingAmount != null &&
                  policy.outstandingAmount! > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment due: ${_formatDate(policy.nextPaymentDate!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '₹${policy.outstandingAmount!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Active';
        break;
      case 'pending_approval':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'lapsed':
        color = Colors.red;
        text = 'Lapsed';
        break;
      case 'matured':
        color = Colors.blue;
        text = 'Matured';
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
