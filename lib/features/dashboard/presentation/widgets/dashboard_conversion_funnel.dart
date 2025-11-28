import 'package:flutter/material.dart';

/// Conversion Funnel Widget
/// Visual representation of the lead-to-customer conversion process
class ConversionFunnelWidget extends StatelessWidget {
  final Map<String, dynamic> roiData;
  final bool showDetails;

  const ConversionFunnelWidget({
    super.key,
    required this.roiData,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalLeads = roiData['total_leads'] ?? 0;
    final contactedLeads = roiData['contacted_leads'] ?? 0;
    final totalQuotes = roiData['total_quotes'] ?? 0;
    final totalPolicies = roiData['total_policies'] ?? 0;

    final contactRate = roiData['contact_rate'] ?? 0.0;
    final quoteRate = roiData['quote_rate'] ?? 0.0;
    final conversionRate = roiData['conversion_rate'] ?? 0.0;

    if (showDetails) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Funnel Analysis',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track lead-to-customer conversion rates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Funnel Visualization
            Container(
              height: 300,
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
              child: CustomPaint(
                painter: FunnelPainter(
                  totalLeads: totalLeads,
                  contactedLeads: contactedLeads,
                  quotes: totalQuotes,
                  policies: totalPolicies,
                ),
                child: Container(),
              ),
            ),

            const SizedBox(height: 24),

            // Detailed Metrics
            Container(
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
                  Text(
                    'Conversion Metrics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildConversionMetric(
                    context,
                    'Lead Contact Rate',
                    '${contactRate.toStringAsFixed(1)}%',
                    contactedLeads,
                    totalLeads,
                    Colors.blue,
                    'Leads contacted out of total leads',
                  ),
                  const SizedBox(height: 16),
                  _buildConversionMetric(
                    context,
                    'Quote Generation Rate',
                    '${quoteRate.toStringAsFixed(1)}%',
                    totalQuotes,
                    contactedLeads,
                    Colors.orange,
                    'Quotes generated from contacted leads',
                  ),
                  const SizedBox(height: 16),
                  _buildConversionMetric(
                    context,
                    'Policy Conversion Rate',
                    '${conversionRate.toStringAsFixed(1)}%',
                    totalPolicies,
                    totalQuotes,
                    Colors.green,
                    'Policies issued from quotes',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Funnel Stage Details
            _buildFunnelStageDetails(context),

            const SizedBox(height: 24),

            // Improvement Recommendations
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conversion Optimization Tips',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildOptimizationTip(
                    context,
                    'Improve Contact Rate',
                    contactRate < 70
                        ? 'Focus on faster response times and follow-up automation'
                        : 'Contact rate is good, maintain current practices',
                    contactRate < 70 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildOptimizationTip(
                    context,
                    'Enhance Quote Process',
                    quoteRate < 50
                        ? 'Streamline quote generation and improve presentation quality'
                        : 'Quote generation is effective',
                    quoteRate < 50 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildOptimizationTip(
                    context,
                    'Close More Policies',
                    conversionRate < 30
                        ? 'Provide better customer education and address objections'
                        : 'Policy conversion is strong',
                    conversionRate < 30 ? Colors.orange : Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Compact version for overview tab
    return Container(
      height: 200,
      child: Row(
        children: [
          // Funnel visualization
          Expanded(
            flex: 2,
            child: CustomPaint(
              painter: FunnelPainter(
                totalLeads: totalLeads,
                contactedLeads: contactedLeads,
                quotes: totalQuotes,
                policies: totalPolicies,
                compact: true,
              ),
              child: Container(),
            ),
          ),
          const SizedBox(width: 16),
          // Metrics summary
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactMetric(
                  context,
                  'Leads',
                  totalLeads.toString(),
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildCompactMetric(
                  context,
                  'Contacted',
                  contactedLeads.toString(),
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                _buildCompactMetric(
                  context,
                  'Quotes',
                  totalQuotes.toString(),
                  Colors.purple,
                ),
                const SizedBox(height: 8),
                _buildCompactMetric(
                  context,
                  'Policies',
                  totalPolicies.toString(),
                  Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversionMetric(BuildContext context, String title, String percentage,
      int actual, int total, Color color, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$actual of $total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total > 0 ? actual / total : 0,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildFunnelStageDetails(BuildContext context) {
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
          Text(
            'Funnel Stage Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStageDetail(
            context,
            'Leads Generated',
            'Initial lead capture through marketing campaigns',
            Colors.blue,
            'Focus on lead quality over quantity',
          ),
          const SizedBox(height: 12),
          _buildStageDetail(
            context,
            'Lead Contact',
            'Initial contact and qualification',
            Colors.orange,
            'Respond within 2 hours for best results',
          ),
          const SizedBox(height: 12),
          _buildStageDetail(
            context,
            'Quote Generation',
            'Detailed proposal and pricing',
            Colors.purple,
            'Personalize quotes based on customer needs',
          ),
          const SizedBox(height: 12),
          _buildStageDetail(
            context,
            'Policy Issuance',
            'Final conversion to active policy',
            Colors.green,
            'Address objections and build trust',
          ),
        ],
      ),
    );
  }

  Widget _buildStageDetail(BuildContext context, String stage, String description,
      Color color, String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
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
              Text(
                stage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '💡 $tip',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationTip(BuildContext context, String title, String tip, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.arrow_right,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                tip,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMetric(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the conversion funnel visualization
class FunnelPainter extends CustomPainter {
  final int totalLeads;
  final int contactedLeads;
  final int quotes;
  final int policies;
  final bool compact;

  FunnelPainter({
    required this.totalLeads,
    required this.contactedLeads,
    required this.quotes,
    required this.policies,
    this.compact = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate funnel stages
    final stages = [
      {'count': totalLeads, 'color': Colors.blue, 'label': 'Leads'},
      {'count': contactedLeads, 'color': Colors.orange, 'label': 'Contacted'},
      {'count': quotes, 'color': Colors.purple, 'label': 'Quotes'},
      {'count': policies, 'color': Colors.green, 'label': 'Policies'},
    ];

    final maxCount = stages.map((s) => s['count'] as int).reduce((a, b) => a > b ? a : b);
    final stageHeight = size.height / stages.length;

    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final count = stage['count'] as int;
      final color = stage['color'] as Color;

      // Calculate width based on count (minimum 20% width)
      final widthRatio = count / maxCount;
      final minWidth = compact ? 0.3 : 0.2;
      final width = size.width * (minWidth + (widthRatio * (1 - minWidth)));

      final y = i * stageHeight;
      final rect = Rect.fromLTWH(
        (size.width - width) / 2,
        y,
        width,
        stageHeight * 0.8,
      );

      // Draw funnel stage
      paint.color = color.withOpacity(0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );

      // Draw label if not compact
      if (!compact) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${stage['label']}: $count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            rect.center.dx - textPainter.width / 2,
            rect.center.dy - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
