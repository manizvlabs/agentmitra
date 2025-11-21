import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/dashboard_viewmodel.dart';

/// Business Intelligence Dashboard Widget
class DashboardBusinessIntelligence extends StatefulWidget {
  const DashboardBusinessIntelligence({super.key});

  @override
  State<DashboardBusinessIntelligence> createState() => _DashboardBusinessIntelligenceState();
}

class _DashboardBusinessIntelligenceState extends State<DashboardBusinessIntelligence> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedTimeRange = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Date Range Picker
              Row(
                children: [
                  Icon(
                    Icons.business_center,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Intelligence',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedTimeRange,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showDateRangePicker(context),
                    icon: const Icon(Icons.date_range),
                    tooltip: 'Select Date Range',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Key Business Metrics
              _buildBusinessMetricsGrid(context, viewModel),

              const SizedBox(height: 32),

              // Revenue Trends Chart
              _buildRevenueTrendsChart(context, viewModel),

              const SizedBox(height: 32),

              // Customer Engagement Metrics
              _buildCustomerEngagement(context, viewModel),

              const SizedBox(height: 32),

              // ROI Analysis
              _buildROIAnalysis(context, viewModel),

              const SizedBox(height: 32),

              // Geographic Distribution
              _buildGeographicDistribution(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessMetricsGrid(BuildContext context, DashboardViewModel viewModel) {
    final biData = viewModel.businessIntelligence;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Business Metrics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        if (biData != null)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildBusinessMetricCard(
                context,
                title: 'Marketing ROI',
                value: '${biData.roiMetrics.marketingROI.toStringAsFixed(0)}%',
                subtitle: 'Return on ad spend',
                icon: Icons.trending_up,
                color: Colors.green,
                trend: '+15.2% vs last period', // TODO: Calculate from trends
              ),
              _buildBusinessMetricCard(
                context,
                title: 'Customer LTV',
                value: viewModel.formatCurrency(biData.roiMetrics.lifetimeValue),
                subtitle: 'Lifetime value',
                icon: Icons.person,
                color: Colors.blue,
                trend: '+8.7% growth', // TODO: Calculate from trends
              ),
              _buildBusinessMetricCard(
                context,
                title: 'CAC',
                value: viewModel.formatCurrency(biData.roiMetrics.customerAcquisitionCost),
                subtitle: 'Customer acquisition cost',
                icon: Icons.attach_money,
                color: Colors.orange,
                trend: '-12.3% reduction', // TODO: Calculate from trends
              ),
              _buildBusinessMetricCard(
                context,
                title: 'Churn Rate',
                value: '${biData.roiMetrics.churnRate.toStringAsFixed(1)}%',
                subtitle: 'Monthly churn',
                icon: Icons.arrow_downward,
                color: Colors.red,
                trend: '-0.8% improvement', // TODO: Calculate from trends
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
    );
  }

  Widget _buildBusinessMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
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
                color: trend.contains('+') ? Colors.green : trend.contains('-') ? Colors.red : Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: trend.contains('+') ? Colors.green : trend.contains('-') ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendsChart(BuildContext context, DashboardViewModel viewModel) {
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
            children: [
              Text(
                'Revenue Trends & Targets',
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
                  '+12.5% vs Target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

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
                  // Actual Revenue
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 125000),
                      const FlSpot(1, 145000),
                      const FlSpot(2, 138000),
                      const FlSpot(3, 162000),
                      const FlSpot(4, 158000),
                      const FlSpot(5, 185000),
                      const FlSpot(6, 192000),
                    ],
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Target Revenue
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 130000),
                      const FlSpot(1, 135000),
                      const FlSpot(2, 145000),
                      const FlSpot(3, 155000),
                      const FlSpot(4, 165000),
                      const FlSpot(5, 175000),
                      const FlSpot(6, 180000),
                    ],
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

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCustomerEngagement(BuildContext context, DashboardViewModel viewModel) {
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
            'Customer Engagement Metrics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          if (biData != null && biData.customerEngagement.isNotEmpty)
            ...biData.customerEngagement.map((engagement) {
              IconData icon;
              Color color;
              String description;

              switch (engagement.metric) {
                case 'App Sessions':
                  icon = Icons.phone_android;
                  color = Colors.blue;
                  description = 'Daily active users increased by ${engagement.change}%';
                  break;
                case 'Policy Views':
                  icon = Icons.visibility;
                  color = Colors.green;
                  description = 'Customers viewing policy details';
                  break;
                case 'Support Queries':
                  icon = Icons.support_agent;
                  color = Colors.orange;
                  description = engagement.change < 0
                      ? 'Reduction in support ticket volume'
                      : 'Increase in customer support requests';
                  break;
                case 'Premium Payments':
                  icon = Icons.payment;
                  color = Colors.purple;
                  description = 'Successful online premium payments';
                  break;
                default:
                  icon = Icons.analytics;
                  color = Colors.grey;
                  description = engagement.metric;
              }

              return _buildEngagementMetric(
                context,
                engagement.metric,
                engagement.value.toString(),
                '${engagement.change > 0 ? '+' : ''}${engagement.change.toStringAsFixed(1)}%',
                description,
                icon,
                color,
              );
            })
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

  Widget _buildEngagementMetric(
    BuildContext context,
    String metric,
    String value,
    String change,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      metric,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        color: change.contains('+') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildROIAnalysis(BuildContext context, DashboardViewModel viewModel) {
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
            'ROI Analysis Dashboard',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // ROI Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildROISummaryCard(
                  context,
                  'Marketing ROI',
                  '245%',
                  'Excellent performance',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildROISummaryCard(
                  context,
                  'Customer LTV/CAC',
                  '14.7x',
                  'Strong unit economics',
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ROI Breakdown Chart
          Text(
            'Cost vs Revenue Analysis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 45,
                        color: Colors.red,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 125,
                        color: Colors.green,
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
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
                          '${value.toInt()}K',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Marketing Cost', 'Revenue Generated'];
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
        ],
      ),
    );
  }

  Widget _buildROISummaryCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicDistribution(BuildContext context, DashboardViewModel viewModel) {
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
            'Geographic Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Geographic Data List
          ...[
            _buildGeographicItem(context, 'Maharashtra', 'Mumbai', 12450, 2500000, 18.5),
            _buildGeographicItem(context, 'Karnataka', 'Bangalore', 9870, 1980000, 15.2),
            _buildGeographicItem(context, 'Tamil Nadu', 'Chennai', 8760, 1750000, 13.4),
            _buildGeographicItem(context, 'Delhi', 'Delhi', 7230, 1450000, 11.1),
            _buildGeographicItem(context, 'Gujarat', 'Ahmedabad', 6540, 1320000, 10.1),
          ],
        ],
      ),
    );
  }

  Widget _buildGeographicItem(
    BuildContext context,
    String state,
    String city,
    int customers,
    double revenue,
    double marketShare,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  state,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  customers.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'customers',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(revenue / 100000).round()}L',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'revenue',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${marketShare.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'market share',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedTimeRange = '${DateFormat('MMM d').format(_startDate)} - ${DateFormat('MMM d').format(_endDate)}';
      });
    }
  }
}
