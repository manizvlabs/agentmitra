import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PolicyDetailsScreen extends StatelessWidget {
  final String? policyId;

  const PolicyDetailsScreen({
    super.key,
    this.policyId,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual data from ViewModel
    final maturityDate = DateTime(2040, 1, 1);
    final nextPaymentDate = DateTime.now().add(const Duration(days: 3));
    final daysUntilMaturity = maturityDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Policy Details',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF1a237e)),
            onPressed: () => _downloadDocuments(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1a237e)),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Header Card
            _buildPolicyHeaderCard(),
            const SizedBox(height: 24),

            // Premium & Payment Section
            _buildPremiumSection(nextPaymentDate),
            const SizedBox(height: 24),

            // Payment History Timeline
            _buildPaymentHistorySection(),
            const SizedBox(height: 24),

            // Coverage & Benefits
            _buildCoverageSection(maturityDate, daysUntilMaturity),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  '📄 Policy No: 123456789',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '📋 Plan: LIC Jeevan Anand (Plan 149)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text(
                'Start Date: 01/01/2020',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(DateTime nextPaymentDate) {
    final isDueSoon = nextPaymentDate.difference(DateTime.now()).inDays <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💰 Premium & Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Annual Premium', '₹25,000', null),
              const Divider(height: 24),
              _buildInfoRow(
                'Next Due Date',
                '${nextPaymentDate.day}/${nextPaymentDate.month}/${nextPaymentDate.year}',
                isDueSoon ? Colors.red : null,
              ),
              const Divider(height: 24),
              _buildInfoRow('Payment Frequency', 'Annual', null),
              const Divider(height: 24),
              _buildInfoRow('Payment Method', 'Auto Debit', Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistorySection() {
    // Mock payment history
    final payments = [
      {
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'amount': 25000.0,
        'status': 'success',
        'transactionId': 'TXN123456',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 60)),
        'amount': 25000.0,
        'status': 'success',
        'transactionId': 'TXN123455',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 90)),
        'amount': 25000.0,
        'status': 'success',
        'transactionId': 'TXN123454',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📊 Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full payment history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              final isLast = index == payments.length - 1;

              return Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${payment['amount'].toString()}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Paid',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(payment['date'] as DateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'TXN: ${payment['transactionId']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageSection(DateTime maturityDate, int daysUntilMaturity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👥 Coverage & Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow('Sum Assured', '₹10,00,000', Colors.green),
              const Divider(height: 24),
              _buildInfoRow('Bonus Accumulated', '₹1,25,000', Colors.green),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Maturity Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(maturityDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a237e),
                        ),
                      ),
                      Text(
                        '${(daysUntilMaturity / 365).toStringAsFixed(1)} years remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Pay Premium',
                Icons.payment,
                Colors.blue,
                () => context.push('/premium-payment', extra: {
                  'policyId': policyId,
                  'amount': 25000.0,
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Contact Agent',
                Icons.phone,
                Colors.green,
                () => context.push('/whatsapp-integration'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'File Claim',
                Icons.assignment,
                Colors.orange,
                () => context.push('/new-claim'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Download Docs',
                Icons.download,
                Colors.purple,
                () => _downloadDocuments(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1a237e),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _downloadDocuments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading policy documents...'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Implement document download
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Policy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print Policy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement print
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Policy Information'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show policy info
              },
            ),
          ],
        ),
      ),
    );
  }
}
