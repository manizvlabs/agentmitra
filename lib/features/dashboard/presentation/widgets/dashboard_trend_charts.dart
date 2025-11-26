import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Trend Charts Widget for Agent Dashboard
/// Displays Revenue and Customer Growth trends
class DashboardTrendCharts extends StatelessWidget {
  const DashboardTrendCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        final biData = viewModel.businessIntelligence;
        final analytics = viewModel.analytics;
        final performance = viewModel.agentPerformance;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Revenue Trend Chart
            _buildRevenueChart(context, biData, analytics),
            const SizedBox(height: 24),
            // Customer Growth Chart
            _buildCustomerGrowthChart(context, performance, analytics),
          ],
        );
      },
    );
  }

  Widget _buildRevenueChart(
    BuildContext context,
    dynamic biData,
    dynamic analytics,
  ) {
    // Generate mock data if not available
    final revenueData = biData?.revenueTrends ?? _generateMockRevenueData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Revenue Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '6 Months',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(revenueData),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
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
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            _formatChartValue(value),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < revenueData.length) {
                          final date = revenueData[index].date;
                          return Text(
                            '${date.month}/${date.day}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
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
                    spots: revenueData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.revenue);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                  if (revenueData.isNotEmpty && revenueData.first.target != null)
                    LineChartBarData(
                      spots: revenueData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.target ?? entry.value.revenue * 1.1);
                      }).toList(),
                      isCurved: true,
                      color: Colors.grey.withOpacity(0.5),
                      barWidth: 2,
                      dashArray: [5, 5],
                      dotData: FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Actual Revenue', Theme.of(context).primaryColor),
              if (revenueData.isNotEmpty && revenueData.first.target != null) ...[
                const SizedBox(width: 16),
                _buildChartLegend('Target Revenue', Colors.grey),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerGrowthChart(
    BuildContext context,
    dynamic performance,
    dynamic analytics,
  ) {
    // Generate mock customer growth data
    final growthData = _generateMockCustomerGrowthData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Growth',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '6 Months',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateBarInterval(growthData),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
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
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < growthData.length) {
                          final date = growthData[index].date;
                          return Text(
                            '${date.month}/${date.day}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
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
                barGroups: growthData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value.toDouble(),
                        color: Theme.of(context).primaryColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  List<dynamic> _generateMockRevenueData() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return _RevenueDataPoint(
        date: date,
        revenue: 100000 + (index * 15000) + (index % 2 == 0 ? 5000 : -3000),
        target: (100000 + (index * 15000)) * 1.1,
      );
    });
  }

  List<dynamic> _generateMockCustomerGrowthData() {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - (5 - index), 1);
      return _CustomerGrowthDataPoint(
        date: date,
        value: 300 + (index * 10) + (index % 2 == 0 ? 5 : -2),
      );
    });
  }

  double _calculateInterval(List<dynamic> data) {
    if (data.isEmpty) return 10000;
    final maxValue = data.map((d) => d.revenue).reduce((a, b) => a > b ? a : b);
    return (maxValue / 5).roundToDouble();
  }

  double _calculateBarInterval(List<dynamic> data) {
    if (data.isEmpty) return 50;
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    return (maxValue / 5).roundToDouble();
  }

  String _formatChartValue(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }
}

// Helper classes for mock data
class _RevenueDataPoint {
  final DateTime date;
  final double revenue;
  final double? target;

  _RevenueDataPoint({required this.date, required this.revenue, this.target});
}

class _CustomerGrowthDataPoint {
  final DateTime date;
  final int value;

  _CustomerGrowthDataPoint({required this.date, required this.value});
}

