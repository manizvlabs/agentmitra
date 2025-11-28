import 'package:flutter/material.dart';

/// Premium Payment Widget
/// Shows premium payment status and payment options
class PremiumPaymentWidget extends StatelessWidget {
  final Map<String, dynamic> premiumData;
  final Function(String) onPaymentTap;

  const PremiumPaymentWidget({
    super.key,
    required this.premiumData,
    required this.onPaymentTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextDueDate = premiumData['next_due_date'] ?? '';
    final dueAmount = premiumData['due_amount'] ?? 0;
    final paymentStatus = premiumData['payment_status'] ?? 'paid';
    final paymentHistory = premiumData['payment_history'] ?? [];
    final autoPayEnabled = premiumData['auto_pay_enabled'] ?? false;

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
                Icons.payment,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Premium Payments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  paymentStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getPaymentStatusColor(paymentStatus),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Next Payment Due
          if (paymentStatus == 'pending' || paymentStatus == 'overdue')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getPaymentStatusColor(paymentStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPaymentStatusColor(paymentStatus).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentStatusIcon(paymentStatus),
                    color: _getPaymentStatusColor(paymentStatus),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Due',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${_formatCurrency(dueAmount)} due on $nextDueDate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onPaymentTap('pay_now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPaymentStatusColor(paymentStatus),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Payment Options
          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  context,
                  'Online Payment',
                  Icons.credit_card,
                  Colors.blue,
                  () => onPaymentTap('online'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  context,
                  'Auto Pay',
                  autoPayEnabled ? Icons.autorenew : Icons.autorenew_disabled,
                  autoPayEnabled ? Colors.green : Colors.grey,
                  () => onPaymentTap('auto_pay'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildPaymentOption(
                  context,
                  'Download Receipt',
                  Icons.download,
                  Colors.purple,
                  () => onPaymentTap('download'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentOption(
                  context,
                  'Payment History',
                  Icons.history,
                  Colors.orange,
                  () => onPaymentTap('history'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Recent Payments
          Text(
            'Recent Payments',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentHistory(paymentHistory),

          // Auto Pay Status
          if (autoPayEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto Pay Enabled',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          'Your premiums will be paid automatically',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(List<dynamic> history) {
    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No payment history available'),
        ),
      );
    }

    return Column(
      children: history.take(3).map<Widget>((payment) {
        final amount = payment['amount'] ?? 0;
        final date = payment['date'] ?? '';
        final status = payment['status'] ?? 'completed';
        final method = payment['method'] ?? 'Online';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status == 'completed' ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${_formatCurrency(amount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$method • $date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: status == 'completed' ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatCurrency(dynamic amount) {
    final num = amount is int ? amount : (amount is double ? amount : 0.0);
    if (num >= 10000000) {
      return '${(num / 10000000).toStringAsFixed(1)}Cr';
    } else if (num >= 100000) {
      return '${(num / 100000).toStringAsFixed(1)}L';
    } else {
      return num.toStringAsFixed(0);
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'overdue':
        return Icons.warning;
      case 'failed':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
