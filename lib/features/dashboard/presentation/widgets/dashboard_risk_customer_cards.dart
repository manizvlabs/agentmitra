import 'package:flutter/material.dart';

/// Risk Customer Cards Widget
/// Displays customer cards with risk indicators and retention actions
class RiskCustomerCardsWidget extends StatelessWidget {
  final List<dynamic> customers;
  final Function(dynamic) onCustomerTap;
  final Function(dynamic, String) onActionTap;

  const RiskCustomerCardsWidget({
    super.key,
    required this.customers,
    required this.onCustomerTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No at-risk customers found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: RiskCustomerCard(
            customer: customer,
            onTap: () => onCustomerTap(customer),
            onActionTap: (action) => onActionTap(customer, action),
          ),
        );
      },
    );
  }
}

/// Individual Risk Customer Card
class RiskCustomerCard extends StatelessWidget {
  final dynamic customer;
  final VoidCallback onTap;
  final Function(String) onActionTap;

  const RiskCustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = customer['risk_level'] ?? 'medium';
    final riskScore = customer['risk_score'] ?? 0.0;
    final premiumValue = customer['premium_value'] ?? 0;
    final daysSinceContact = customer['days_since_contact'] ?? 0;
    final missedPayments = customer['missed_payments'] ?? 0;

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
              // Header with risk level and score
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['customer_name'] ?? 'Unknown Customer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.policy,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer['policy_number'] ?? 'POL000000',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$daysSinceContact days since contact',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRiskLevelBadge(riskLevel),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRiskColor(riskLevel),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${riskScore.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Risk factors indicators
              Row(
                children: [
                  if (missedPayments > 0) ...[
                    Icon(
                      Icons.payment,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$missedPayments missed payments',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    Icons.currency_rupee,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹${premiumValue.toStringAsFixed(0)} premium',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    customer['policy_type'] ?? 'Life Insurance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Risk factors list
              if (customer['risk_factors'] != null && customer['risk_factors'].isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Factors:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (customer['risk_factors'] as List<dynamic>).map((factor) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              factor.toString(),
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Retention plan preview
              if (customer['retention_plan'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.handshake,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Retention plan: ${customer['retention_plan']['next_action'] ?? 'Contact customer'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onActionTap('call'),
                      icon: const Icon(Icons.call, size: 16),
                      label: const Text('Call'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onActionTap('email'),
                      icon: const Icon(Icons.email, size: 16),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onActionTap('retain'),
                      icon: const Icon(Icons.handshake, size: 16),
                      label: const Text('Retain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),

              // Last retention action
              if (customer['last_retention_action'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last action: ${customer['last_retention_action']['description'] ?? 'Contact made'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Text(
                        customer['last_retention_action']['date'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 10,
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

  Widget _buildRiskLevelBadge(String riskLevel) {
    Color color;
    String text;
    IconData icon;

    switch (riskLevel.toLowerCase()) {
      case 'high':
        color = Colors.red;
        text = 'HIGH RISK';
        icon = Icons.warning;
        break;
      case 'medium':
        color = Colors.orange;
        text = 'MEDIUM RISK';
        icon = Icons.warning_amber;
        break;
      case 'low':
        color = Colors.yellow;
        text = 'LOW RISK';
        icon = Icons.info_outline;
        break;
      default:
        color = Colors.grey;
        text = 'UNKNOWN';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }
}
