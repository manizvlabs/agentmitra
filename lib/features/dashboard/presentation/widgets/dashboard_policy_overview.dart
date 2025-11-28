import 'package:flutter/material.dart';

/// Policy Overview Widget
/// Displays customer's active policies with key information and actions
class PolicyOverviewWidget extends StatelessWidget {
  final List<dynamic> policies;
  final Function(dynamic) onPolicyTap;

  const PolicyOverviewWidget({
    super.key,
    required this.policies,
    required this.onPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    if (policies.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.policy_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No active policies found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: policies.map((policy) => _buildPolicyCard(context, policy)).toList(),
    );
  }

  Widget _buildPolicyCard(BuildContext context, dynamic policy) {
    final policyNumber = policy['policy_number'] ?? 'Unknown';
    final policyType = policy['policy_type'] ?? 'General Insurance';
    final coverageAmount = policy['coverage_amount'] ?? 0;
    final premiumAmount = policy['premium_amount'] ?? 0;
    final expiryDate = policy['expiry_date'] ?? '';
    final status = policy['status'] ?? 'active';
    final daysUntilExpiry = _calculateDaysUntilExpiry(expiryDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => onPolicyTap(policy),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getPolicyTypeColor(policyType).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPolicyTypeIcon(policyType),
                        color: _getPolicyTypeColor(policyType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policyNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatPolicyType(policyType),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  ],
                ),

                const SizedBox(height: 16),

                // Coverage and Premium
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coverage',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_formatCurrency(coverageAmount)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Premium',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_formatCurrency(premiumAmount)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Expiry Information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getExpiryColor(daysUntilExpiry).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getExpiryColor(daysUntilExpiry).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getExpiryIcon(daysUntilExpiry),
                        color: _getExpiryColor(daysUntilExpiry),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expires: $expiryDate',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _getExpiryMessage(daysUntilExpiry),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getExpiryColor(daysUntilExpiry),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (daysUntilExpiry <= 30)
                        TextButton(
                          onPressed: () => _renewPolicy(policy),
                          child: const Text(
                            'Renew Now',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewPolicyDetails(policy),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadPolicy(policy),
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _renewPolicy(dynamic policy) {
    // Handle policy renewal
  }

  void _viewPolicyDetails(dynamic policy) {
    // Navigate to policy details page
  }

  void _downloadPolicy(dynamic policy) {
    // Handle policy document download
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

  String _formatPolicyType(String type) {
    switch (type.toLowerCase()) {
      case 'term_life':
        return 'Term Life Insurance';
      case 'health':
        return 'Health Insurance';
      case 'ulip':
        return 'Unit Linked Insurance Plan';
      case 'comprehensive':
        return 'Comprehensive Insurance';
      case 'two_wheeler':
        return 'Two Wheeler Insurance';
      case 'four_wheeler':
        return 'Four Wheeler Insurance';
      default:
        return type.toUpperCase();
    }
  }

  IconData _getPolicyTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'term_life':
      case 'health':
        return Icons.favorite;
      case 'ulip':
        return Icons.trending_up;
      case 'comprehensive':
        return Icons.security;
      case 'two_wheeler':
        return Icons.motorcycle;
      case 'four_wheeler':
        return Icons.directions_car;
      default:
        return Icons.policy;
    }
  }

  Color _getPolicyTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'term_life':
        return Colors.red;
      case 'health':
        return Colors.green;
      case 'ulip':
        return Colors.purple;
      case 'comprehensive':
        return Colors.blue;
      case 'two_wheeler':
        return Colors.orange;
      case 'four_wheeler':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  int _calculateDaysUntilExpiry(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.difference(DateTime.now()).inDays;
    } catch (e) {
      return 999; // Far future if parsing fails
    }
  }

  Color _getExpiryColor(int days) {
    if (days < 0) return Colors.red; // Expired
    if (days <= 7) return Colors.red; // Critical
    if (days <= 30) return Colors.orange; // Warning
    return Colors.green; // Good
  }

  IconData _getExpiryIcon(int days) {
    if (days < 0) return Icons.warning; // Expired
    if (days <= 7) return Icons.warning; // Critical
    if (days <= 30) return Icons.schedule; // Warning
    return Icons.check_circle; // Good
  }

  String _getExpiryMessage(int days) {
    if (days < 0) return 'Policy has expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return 'Expires in 1 day';
    if (days <= 7) return 'Expires in $days days - Renew soon!';
    if (days <= 30) return 'Expires in $days days';
    return 'Valid for $days more days';
  }
}
