import 'package:flutter/material.dart';

/// Lead Statistics Widget
/// Displays key metrics and KPIs for leads management
class LeadStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> leadsData;
  final String priority;
  final String source;

  const LeadStatisticsWidget({
    super.key,
    required this.leadsData,
    required this.priority,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final stats = leadsData['statistics'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Lead Performance Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stats['total_leads'] ?? 0} Total Leads',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
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
                'Conversion Rate',
                '${stats['conversion_rate']?.toStringAsFixed(1) ?? '0'}%',
                Icons.trending_up,
                Colors.green,
                stats['conversion_trend'] ?? 'stable',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                'Avg Response Time',
                '${stats['avg_response_time']?.toStringAsFixed(1) ?? '0'}h',
                Icons.timer,
                Colors.blue,
                stats['response_trend'] ?? 'stable',
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
                'Lead Quality Score',
                '${stats['avg_quality_score']?.toStringAsFixed(0) ?? '0'}/100',
                Icons.star,
                Colors.orange,
                stats['quality_trend'] ?? 'stable',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                context,
                'Potential Revenue',
                '₹${stats['total_potential_revenue']?.toStringAsFixed(0) ?? '0'}',
                Icons.currency_rupee,
                Colors.purple,
                stats['revenue_trend'] ?? 'stable',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Performance Indicators
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
                'Performance Indicators',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPerformanceIndicator(
                context,
                'Lead Generation',
                stats['lead_generation_performance'] ?? 75,
                'Target: 20 leads/week',
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildPerformanceIndicator(
                context,
                'Follow-up Efficiency',
                stats['followup_efficiency'] ?? 82,
                'Target: 85% follow-up rate',
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPerformanceIndicator(
                context,
                'Conversion Quality',
                stats['conversion_quality'] ?? 68,
                'Target: 75% qualified leads',
                Colors.orange,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Lead Pipeline Summary
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
                'Lead Pipeline Summary',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPipelineStage(
                context,
                'New Leads',
                stats['new_leads_count'] ?? 0,
                Colors.blue,
                'Fresh leads requiring initial contact',
              ),
              const SizedBox(height: 8),
              _buildPipelineStage(
                context,
                'In Progress',
                stats['in_progress_count'] ?? 0,
                Colors.orange,
                'Leads being actively worked on',
              ),
              const SizedBox(height: 8),
              _buildPipelineStage(
                context,
                'Qualified',
                stats['qualified_count'] ?? 0,
                Colors.purple,
                'Leads ready for proposal/quote',
              ),
              const SizedBox(height: 8),
              _buildPipelineStage(
                context,
                'Converted',
                stats['converted_count'] ?? 0,
                Colors.green,
                'Successfully converted to policies',
              ),
            ],
          ),
        ),

        // Filter Summary
        if (priority != 'all' || source != 'all') ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing ${priority != 'all' ? priority : 'all priorities'} leads from ${source != 'all' ? source.replaceAll('_', ' ') : 'all sources'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue,
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

  Widget _buildPerformanceIndicator(BuildContext context, String metric,
      int percentage, String target, Color color) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    metric,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 2),
              Text(
                target,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineStage(BuildContext context, String stage, int count,
      Color color, String description) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    stage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'improving':
        return Icons.trending_up;
      case 'down':
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'improving':
        return Colors.green;
      case 'down':
      case 'declining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
