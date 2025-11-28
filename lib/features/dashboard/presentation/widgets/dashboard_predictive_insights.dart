import 'package:flutter/material.dart';

/// Predictive Insights Widget
/// Displays AI-powered insights and recommendations
class PredictiveInsightsWidget extends StatelessWidget {
  final List<dynamic> insights;
  final bool showAll;

  const PredictiveInsightsWidget({
    super.key,
    required this.insights,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayInsights = showAll ? insights : insights.take(3).toList();

    if (displayInsights.isEmpty) {
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
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'No Predictive Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Insights will appear as data becomes available',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
                Icons.lightbulb,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Predictive Insights',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'AI-powered recommendations and trends',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!showAll && insights.length > 3)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${insights.length - 3} more',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ...displayInsights.map((insight) => _buildInsightItem(context, insight)),
          if (!showAll && insights.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to full insights view
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PredictiveInsightsWidget(
                          insights: insights,
                          showAll: true,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.expand_more),
                  label: const Text('View All Insights'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, dynamic insight) {
    final type = insight['type'] ?? 'general';
    final confidence = insight['confidence'] ?? 0;
    final impact = insight['impact'] ?? 'medium';
    final potentialValue = insight['potential_value'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getInsightBackgroundColor(type),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInsightBorderColor(type),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getInsightIconColor(type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getInsightIcon(type),
                  color: _getInsightIconColor(type),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            insight['title'] ?? 'Insight',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getInsightTextColor(type),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(confidence),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${confidence.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight['description'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getInsightTextColor(type).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (potentialValue != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.currency_rupee,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Potential value: ₹${potentialValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getImpactColor(impact).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getImpactColor(impact).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    impact.toUpperCase(),
                    style: TextStyle(
                      color: _getImpactColor(impact),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleInsightAction(context, insight, 'view_details'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _getInsightIconColor(type)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: _getInsightIconColor(type),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleInsightAction(context, insight, 'take_action'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getInsightIconColor(type),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Take Action',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getInsightBackgroundColor(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return Colors.green.withOpacity(0.1);
      case 'warning':
        return Colors.orange.withOpacity(0.1);
      case 'trend':
        return Colors.blue.withOpacity(0.1);
      case 'recommendation':
        return Colors.purple.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getInsightBorderColor(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return Colors.green.withOpacity(0.3);
      case 'warning':
        return Colors.orange.withOpacity(0.3);
      case 'trend':
        return Colors.blue.withOpacity(0.3);
      case 'recommendation':
        return Colors.purple.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getInsightIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'trend':
        return Colors.blue;
      case 'recommendation':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getInsightTextColor(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return Colors.green.shade800;
      case 'warning':
        return Colors.orange.shade800;
      case 'trend':
        return Colors.blue.shade800;
      case 'recommendation':
        return Colors.purple.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'opportunity':
        return Icons.trending_up;
      case 'warning':
        return Icons.warning;
      case 'trend':
        return Icons.show_chart;
      case 'recommendation':
        return Icons.recommend;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleInsightAction(BuildContext context, dynamic insight, String action) {
    if (action == 'view_details') {
      // Show insight details dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(insight['title'] ?? 'Insight Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(insight['description'] ?? ''),
                const SizedBox(height: 12),
                if (insight['recommended_actions'] != null) ...[
                  const Text(
                    'Recommended Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...(insight['recommended_actions'] as List<dynamic>? ?? [])
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• '),
                                Expanded(child: Text(action.toString())),
                              ],
                            ),
                          )),
                ],
                if (insight['deadline'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Deadline: ${insight['deadline']}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Here you would navigate to take the recommended action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Action initiated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Take Action'),
            ),
          ],
        ),
      );
    } else if (action == 'take_action') {
      // Directly take action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Taking action on: ${insight['title']}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
