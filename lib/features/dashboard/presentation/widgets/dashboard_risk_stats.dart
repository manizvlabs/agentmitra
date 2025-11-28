import 'package:flutter/material.dart';

/// Risk Statistics Widget
/// Displays key metrics and KPIs for at-risk customers management
class RiskStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> riskData;
  final String riskLevel;
  final String priority;

  const RiskStatisticsWidget({
    super.key,
    required this.riskData,
    required this.riskLevel,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final stats = riskData['statistics'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'At-Risk Customers Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stats['total_at_risk'] ?? 0} At Risk',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // KPI Cards Row
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                'Churn Risk',
                '${stats['churn_risk_percentage']?.toStringAsFixed(1) ?? '0'}%',
                Icons.trending_down,
                Colors.red,
                stats['churn_trend'] ?? 'stable',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                'Retention Rate',
                '${stats['retention_rate']?.toStringAsFixed(1) ?? '0'}%',
                Icons.shield,
                Colors.green,
                stats['retention_trend'] ?? 'stable',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                'Revenue at Risk',
                '₹${stats['revenue_at_risk']?.toStringAsFixed(0) ?? '0'}',
                Icons.currency_rupee,
                Colors.orange,
                stats['revenue_trend'] ?? 'stable',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                'Avg. Risk Score',
                '${stats['avg_risk_score']?.toStringAsFixed(0) ?? '0'}/100',
                Icons.score,
                Colors.purple,
                stats['score_trend'] ?? 'stable',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Risk Trend Analysis
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
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
                'Risk Trend Analysis',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRiskTrendIndicator(
                context,
                '30-Day Trend',
                stats['thirty_day_trend'] ?? 'stable',
                stats['thirty_day_change'] ?? 0,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildRiskTrendIndicator(
                context,
                '90-Day Trend',
                stats['ninety_day_trend'] ?? 'stable',
                stats['ninety_day_change'] ?? 0,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildRiskTrendIndicator(
                context,
                '1-Year Trend',
                stats['year_trend'] ?? 'stable',
                stats['year_change'] ?? 0,
                Colors.green,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Risk Prevention Metrics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
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
                'Prevention & Recovery',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPreventionMetric(
                      context,
                      'Prevented Churn',
                      stats['prevented_churn'] ?? 0,
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPreventionMetric(
                      context,
                      'Recovered',
                      stats['recovered_customers'] ?? 0,
                      Icons.refresh,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPreventionMetric(
                      context,
                      'Active Interventions',
                      stats['active_interventions'] ?? 0,
                      Icons.campaign,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Filter Summary
        if (riskLevel != 'all' || priority != 'all') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${riskLevel != 'all' ? riskLevel : 'all risk levels'} customers with ${priority != 'all' ? priority : 'all priorities'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Reset filters - would need callback
                  },
                  child: const Text('Clear Filters'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value,
      IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Icon(
                _getTrendIcon(trend),
                color: _getTrendColor(trend),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTrendIndicator(BuildContext context, String period, String trend,
      int change, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _getTrendIcon(trend),
                    size: 16,
                    color: _getTrendColor(trend),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${change > 0 ? '+' : ''}$change customers',
                    style: TextStyle(
                      color: _getTrendColor(trend),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _getTrendStrength(trend),
            child: Container(
              decoration: BoxDecoration(
                color: _getTrendColor(trend),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreventionMetric(BuildContext context, String title, int value,
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
            value.toString(),
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

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
        return Icons.trending_up;
      case 'down':
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
        return Colors.red; // Red for increasing risk
      case 'down':
      case 'decreasing':
        return Colors.green; // Green for decreasing risk
      default:
        return Colors.grey;
    }
  }

  double _getTrendStrength(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
        return 0.8; // Strong trend
      case 'down':
      case 'decreasing':
        return 0.6; // Moderate improvement
      default:
        return 0.4; // Stable
    }
  }
}
