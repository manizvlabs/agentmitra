import 'package:flutter/material.dart';
import '../../data/models/agent_model.dart';

class PerformanceCard extends StatelessWidget {
  final AgentPerformance performance;

  const PerformanceCard({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                size: 20,
                color: Color(0xFF1a237e),
              ),
              const SizedBox(width: 8),
              const Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1a237e),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getGradeColor().withOpacity(0.3)),
                ),
                child: Text(
                  performance.performanceGrade ?? 'N/A',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getGradeColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key Metrics
          Row(
            children: [
              _buildMetricItem(
                'Policies Sold',
                performance.policiesSold?.toString() ?? '0',
                Icons.policy,
                Colors.blue,
              ),
              _buildMetricItem(
                'Commission',
                '₹${performance.commissionEarned?.toStringAsFixed(0) ?? '0'}',
                Icons.currency_rupee,
                Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildMetricItem(
                'Customers',
                performance.customersAcquired?.toString() ?? '0',
                Icons.people,
                Colors.orange,
              ),
              _buildMetricItem(
                'Claims',
                performance.claimsProcessed?.toString() ?? '0',
                Icons.assignment,
                Colors.purple,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Period
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reporting Period',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_formatDate(performance.periodStart)} - ${_formatDate(performance.periodEnd)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
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
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor() {
    final grade = performance.performanceGrade?.toUpperCase() ?? '';
    switch (grade) {
      case 'A':
      case 'EXCELLENT':
        return Colors.green;
      case 'B':
      case 'GOOD':
        return Colors.blue;
      case 'C':
      case 'AVERAGE':
        return Colors.orange;
      case 'D':
      case 'BELOW_AVERAGE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
