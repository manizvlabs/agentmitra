import 'package:flutter/material.dart';

/// Claims Status Widget
/// Shows customer's claims history and status
class ClaimsStatusWidget extends StatelessWidget {
  final List<dynamic> claims;
  final Function(dynamic) onClaimTap;

  const ClaimsStatusWidget({
    super.key,
    required this.claims,
    required this.onClaimTap,
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
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Claims & Support',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _fileNewClaim(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('File Claim'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Claims Summary
          Row(
            children: [
              Expanded(
                child: _buildClaimSummaryCard(
                  context,
                  'Active Claims',
                  claims.where((c) => c['status'] == 'pending' || c['status'] == 'processing').length,
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClaimSummaryCard(
                  context,
                  'Approved',
                  claims.where((c) => c['status'] == 'approved').length,
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClaimSummaryCard(
                  context,
                  'Total Claims',
                  claims.length,
                  Icons.assignment_turned_in,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Claims List
          Text(
            'Recent Claims',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildClaimsList(context),
        ],
      ),
    );
  }

  Widget _buildClaimSummaryCard(BuildContext context, String title, int count,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClaimsList(BuildContext context) {
    if (claims.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No claims filed yet',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _fileNewClaim(),
              child: const Text('File Your First Claim'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: claims.take(3).map<Widget>((claim) {
        final claimNumber = claim['claim_number'] ?? 'Unknown';
        final policyNumber = claim['policy_number'] ?? 'Unknown';
        final claimAmount = claim['claim_amount'] ?? 0;
        final status = claim['status'] ?? 'pending';
        final submittedDate = claim['submitted_date'] ?? '';
        final claimType = claim['claim_type'] ?? 'General';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () => onClaimTap(claim),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                claimNumber,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Policy: $policyNumber',
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
                            color: _getClaimStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatStatus(status),
                            style: TextStyle(
                              color: _getClaimStatusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          _getClaimTypeIcon(claimType),
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          claimType,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${_formatCurrency(claimAmount)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Submitted: $submittedDate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        if (status == 'approved' || status == 'processing')
                          TextButton(
                            onPressed: () => _trackClaim(claim),
                            child: const Text(
                              'Track Status',
                              style: TextStyle(fontSize: 12),
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
      }).toList(),
    );
  }

  void _fileNewClaim() {
    // Navigate to file new claim page
  }

  void _trackClaim(dynamic claim) {
    // Navigate to claim tracking page
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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'processing':
        return 'PROCESSING';
      case 'approved':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      case 'paid':
        return 'PAID';
      default:
        return status.toUpperCase();
    }
  }

  Color _getClaimStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getClaimTypeIcon(String claimType) {
    switch (claimType.toLowerCase()) {
      case 'health':
        return Icons.local_hospital;
      case 'accident':
        return Icons.personal_injury;
      case 'vehicle':
        return Icons.directions_car;
      case 'property':
        return Icons.home;
      case 'life':
        return Icons.favorite;
      default:
        return Icons.assignment;
    }
  }
}
