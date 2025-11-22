import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Agent Performance Dashboard Widget
class DashboardAgentPerformance extends StatelessWidget {
  const DashboardAgentPerformance({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Agent Performance Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Key Metrics Cards
              _buildKeyMetricsGrid(context, viewModel),

              const SizedBox(height: 32),

              // Performance Charts
              _buildPerformanceCharts(context, viewModel),

              const SizedBox(height: 32),

              // Commission Breakdown
              _buildCommissionBreakdown(context, viewModel),

              const SizedBox(height: 32),

              // Monthly Trends
              _buildMonthlyTrends(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyMetricsGrid(BuildContext context, DashboardViewModel viewModel) {
    final performance = viewModel.agentPerformance;

    if (performance == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildMetricCard(
          context,
          title: 'Total Commission',
          value: viewModel.formatCurrency(performance.totalCommission),
          subtitle: 'This month',
          icon: Icons.currency_rupee,
          color: Colors.green,
          trend: '+12.5% from last month', // TODO: Calculate from API data
          trendColor: Colors.green,
        ),
        _buildMetricCard(
          context,
          title: 'Policies Sold',
          value: performance.policiesSold.toString(),
          subtitle: 'This month',
          icon: Icons.policy,
          color: Colors.blue,
          trend: '+8.2% from last month', // TODO: Calculate from API data
          trendColor: Colors.green,
        ),
        _buildMetricCard(
          context,
          title: 'Customer Acquisition',
          value: performance.customersAcquired.toString(),
          subtitle: 'New customers',
          icon: Icons.people,
          color: Colors.purple,
          trend: '+15.3% from last month', // TODO: Calculate from API data
          trendColor: Colors.green,
        ),
        _buildMetricCard(
          context,
          title: 'Conversion Rate',
          value: '${performance.conversionRate.toStringAsFixed(1)}%',
          subtitle: 'Lead to sale',
          icon: Icons.trending_up,
          color: Colors.orange,
          trend: '+5.1% from last month', // TODO: Calculate from API data
          trendColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                trend.contains('+') ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: trendColor,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCharts(BuildContext context, DashboardViewModel viewModel) {
    final biData = viewModel.businessIntelligence;

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
          Text(
            'Performance Trends',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          if (biData != null && biData.revenueTrends.isNotEmpty)
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (biData.revenueTrends.map((t) => t.revenue).reduce((a, b) => a > b ? a : b) / 5).roundToDouble(),
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
                          if (value.toInt() >= 0 && value.toInt() < biData.revenueTrends.length) {
                            final date = biData.revenueTrends[value.toInt()].date;
                            return Text(
                              '${date.month}/${date.day}',
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
                    // Actual Revenue
                    LineChartBarData(
                      spots: biData.revenueTrends.asMap().entries.map((entry) {
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
                    // Target Revenue
                    LineChartBarData(
                      spots: biData.revenueTrends.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.target);
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
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend('Actual Revenue', Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              _buildChartLegend('Target Revenue', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionBreakdown(BuildContext context, DashboardViewModel viewModel) {
    final biData = viewModel.businessIntelligence;

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
          Text(
            'Commission by Product Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          if (biData != null && biData.productPerformance.isNotEmpty)
            Column(
              children: [
                // Pie Chart
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(biData.productPerformance),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: _buildProductLegend(biData.productPerformance, viewModel),
                ),
              ],
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> productPerformance) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    final total = productPerformance.values.fold<int>(0, (sum, value) => sum + value);

    return productPerformance.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
      final colorIndex = productPerformance.keys.toList().indexOf(entry.key) % colors.length;

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n$percentage%',
        color: colors[colorIndex],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildProductLegend(Map<String, int> productPerformance, DashboardViewModel viewModel) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
    final performance = viewModel.agentPerformance;

    return productPerformance.entries.map((entry) {
      final colorIndex = productPerformance.keys.toList().indexOf(entry.key) % colors.length;
      final commission = performance != null && performance.commissionByProduct.containsKey(entry.key)
          ? viewModel.formatCurrency(performance.commissionByProduct[entry.key]!)
          : '₹0';

      return _buildLegendItem(entry.key, colors[colorIndex], commission);
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color, String amount) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $amount',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMonthlyTrends(BuildContext context, DashboardViewModel viewModel) {
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
          Text(
            'Monthly Performance Comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 35,
                        color: Colors.blue,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 28,
                        color: Colors.green,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 42,
                        color: Colors.orange,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 38,
                        color: Colors.purple,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Policies', 'Customers', 'Revenue', 'Commission'];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(fontSize: 10),
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
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartLegend('Policies Sold', Colors.blue),
              _buildChartLegend('New Customers', Colors.green),
              _buildChartLegend('Revenue (₹K)', Colors.orange),
              _buildChartLegend('Commission (₹K)', Colors.purple),
            ],
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
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
