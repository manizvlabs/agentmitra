import 'package:flutter/material.dart';
import '../../data/models/policy_models.dart';

/// Policy card widget matching the wireframe design
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
      margin: const EdgeInsets.only(bottom: 12),
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
                children: [
                  // Policy icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.policy,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Policy info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          policy.policyNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          policy.planName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(policy.status),
                ],
              ),
              const SizedBox(height: 12),
              // Policy details in grid
              Row(
                children: [
                  // Premium
                  Expanded(
                    child: _buildDetailItem(
                      'Premium',
                      '₹${policy.premiumAmount.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                    ),
                  ),
                  // Coverage
                  Expanded(
                    child: _buildDetailItem(
                      'Coverage',
                      '₹${policy.sumAssured.toStringAsFixed(0)}',
                      Icons.shield,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Frequency
                  Expanded(
                    child: _buildDetailItem(
                      'Frequency',
                      policy.premiumFrequency,
                      Icons.schedule,
                    ),
                  ),
                  // Next Due
                  Expanded(
                    child: _buildDetailItem(
                      'Next Due',
                      policy.nextPaymentDate != null
                          ? '${policy.nextPaymentDate!.day}/${policy.nextPaymentDate!.month}/${policy.nextPaymentDate!.year}'
                          : 'N/A',
                      Icons.calendar_today,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to premium payment
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Premium payment coming soon')),
                        );
                      },
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Pay Premium'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to WhatsApp integration
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WhatsApp integration coming soon')),
                        );
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
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
      case 'pending':
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
        border: Border.all(color: color, width: 1),
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

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


