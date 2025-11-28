import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Forecast Chart Widget
/// Displays revenue projections over time with scenario comparisons
class ForecastChartWidget extends StatelessWidget {
  final Map<String, dynamic> forecastData;
  final String selectedScenario;
  final String period;

  const ForecastChartWidget({
    super.key,
    required this.forecastData,
    required this.selectedScenario,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Revenue Projection Trend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getScenarioColor(selectedScenario).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getScenarioColor(selectedScenario),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getScenarioLabel(selectedScenario),
                    style: TextStyle(
                      color: _getScenarioColor(selectedScenario),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250,
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
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatCurrency(value),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _getMonthLabel(value.toInt()),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Historical data (past months)
                LineChartBarData(
                  spots: _generateHistoricalSpots(),
                  isCurved: true,
                  color: Colors.grey.shade400,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.grey.shade200.withOpacity(0.3),
                  ),
                ),
                // Forecast data (future months)
                LineChartBarData(
                  spots: _generateForecastSpots(),
                  isCurved: true,
                  color: _getScenarioColor(selectedScenario),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: _getScenarioColor(selectedScenario),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _getScenarioColor(selectedScenario).withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isHistorical = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isHistorical ? 'Historical' : 'Forecast'}: ${_formatCurrency(spot.y)}',
                        TextStyle(
                          color: isHistorical ? Colors.grey.shade600 : _getScenarioColor(selectedScenario),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Historical', Colors.grey.shade400),
            const SizedBox(width: 24),
            _buildLegendItem(_getScenarioLabel(selectedScenario), _getScenarioColor(selectedScenario)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
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
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<FlSpot> _generateHistoricalSpots() {
    // Generate historical data for the past 6 months
    final spots = <FlSpot>[];
    final baseRevenue = (forecastData['current_revenue'] ?? 200000) / 30; // Daily average

    for (int i = 0; i < 6; i++) {
      // Simulate some historical trend
      final monthMultiplier = 0.85 + (i * 0.03); // Slight upward trend
      final seasonalMultiplier = 1 + 0.1 * (i % 4 == 3 ? 1 : 0); // Q4 boost
      final revenue = baseRevenue * 30 * monthMultiplier * seasonalMultiplier;

      spots.add(FlSpot(i.toDouble(), revenue));
    }

    return spots;
  }

  List<FlSpot> _generateForecastSpots() {
    // Generate forecast data based on selected scenario
    final spots = <FlSpot>[];
    final baseRevenue = forecastData['projected_revenue'] ?? 300000;
    final growthRate = _getScenarioGrowthRate();

    // Start from month 6 (continuation of historical)
    for (int i = 0; i < _getForecastMonths(); i++) {
      final monthIndex = 6 + i;
      final growthMultiplier = 1 + (growthRate * (i + 1));
      final seasonalMultiplier = 1 + 0.08 * ((monthIndex % 12) ~/ 3 == 3 ? 1 : 0); // Q4 boost
      final revenue = baseRevenue * growthMultiplier * seasonalMultiplier;

      spots.add(FlSpot(monthIndex.toDouble(), revenue));
    }

    return spots;
  }

  double _getScenarioGrowthRate() {
    switch (selectedScenario) {
      case 'best_case':
        return 0.15; // 15% monthly growth
      case 'base_case':
        return 0.08; // 8% monthly growth
      case 'worst_case':
        return 0.02; // 2% monthly growth
      default:
        return 0.08;
    }
  }

  int _getForecastMonths() {
    switch (period) {
      case '1m': return 1;
      case '3m': return 3;
      case '6m': return 6;
      case '1y': return 12;
      default: return 3;
    }
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else {
      return '₹${(value / 1000).toStringAsFixed(0)}K';
    }
  }

  String _getMonthLabel(int monthIndex) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[monthIndex % 12];
  }

  String _getScenarioLabel(String scenario) {
    switch (scenario) {
      case 'best_case': return 'Best Case';
      case 'base_case': return 'Base Case';
      case 'worst_case': return 'Worst Case';
      default: return scenario;
    }
  }

  Color _getScenarioColor(String scenario) {
    switch (scenario) {
      case 'best_case': return Colors.green;
      case 'base_case': return Colors.blue;
      case 'worst_case': return Colors.red;
      default: return Colors.grey;
    }
  }
}
