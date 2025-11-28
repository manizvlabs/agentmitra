import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Revenue Performance Widget
/// Shows detailed revenue metrics, trends, and breakdowns
class RevenuePerformanceWidget extends StatelessWidget {
  final Map<String, dynamic> roiData;
  final String timeframe;

  const RevenuePerformanceWidget({
    super.key,
    required this.roiData,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Performance',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Detailed revenue metrics and trends',
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

          // Revenue Metrics Cards
          Row(
            children: [
              Expanded(
                child: _buildRevenueMetricCard(
                  context,
                  'Total Revenue',
                  '₹${roiData['total_revenue']?.toStringAsFixed(0) ?? '0'}',
                  Icons.currency_rupee,
                  Colors.green,
                  '+${roiData['revenue_growth']?.toStringAsFixed(1) ?? '0'}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueMetricCard(
                  context,
                  'New Policies',
                  '${roiData['new_policies'] ?? 0}',
                  Icons.assignment,
                  Colors.blue,
                  'This period',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildRevenueMetricCard(
                  context,
                  'Avg. Premium',
                  '₹${roiData['average_premium']?.toStringAsFixed(0) ?? '0'}',
                  Icons.trending_up,
                  Colors.orange,
                  'Per policy',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRevenueMetricCard(
                  context,
                  'Collection Rate',
                  '${roiData['collection_rate']?.toStringAsFixed(1) ?? '0'}%',
                  Icons.check_circle,
                  Colors.purple,
                  'Payment efficiency',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Revenue Trend Chart
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
                Row(
                  children: [
                    Text(
                      'Revenue Trend',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${roiData['revenue_growth']?.toStringAsFixed(1) ?? '0'}%',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 50000,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).round()}K',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              // Mock data points for the chart
                              const days = ['1', '5', '10', '15', '20', '25', '30'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 10),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateRevenueSpots(),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Revenue Breakdown
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
                  'Revenue Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRevenueBreakdownItem(
                  context,
                  'New Policy Sales',
                  0.65,
                  '₹${((roiData['total_revenue'] ?? 0) * 0.65).toStringAsFixed(0)}',
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildRevenueBreakdownItem(
                  context,
                  'Policy Renewals',
                  0.25,
                  '₹${((roiData['total_revenue'] ?? 0) * 0.25).toStringAsFixed(0)}',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildRevenueBreakdownItem(
                  context,
                  'Premium Increases',
                  0.08,
                  '₹${((roiData['total_revenue'] ?? 0) * 0.08).toStringAsFixed(0)}',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildRevenueBreakdownItem(
                  context,
                  'Other Income',
                  0.02,
                  '₹${((roiData['total_revenue'] ?? 0) * 0.02).toStringAsFixed(0)}',
                  Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
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
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBreakdownItem(BuildContext context, String category,
      double percentage, String amount, Color color) {
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
          child: Text(
            category,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          '${(percentage * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateRevenueSpots() {
    // Generate mock revenue trend data
    final totalRevenue = roiData['total_revenue'] ?? 200000;
    final baseValue = totalRevenue / 30; // Daily average

    return List.generate(7, (index) {
      final day = index + 1;
      // Simulate a growth trend
      final multiplier = 0.8 + (day * 0.05) + ((day % 3) * 0.02);
      return FlSpot(day.toDouble(), baseValue * multiplier * (7 - day + 1) / 7);
    });
  }
}
