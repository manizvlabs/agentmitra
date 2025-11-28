import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_roi_score_card.dart';
import '../widgets/dashboard_revenue_performance.dart';
import '../widgets/dashboard_conversion_funnel.dart';
import '../widgets/dashboard_action_items.dart';
import '../widgets/dashboard_predictive_insights.dart';

/// ROI Executive Dashboard Page
/// Comprehensive dashboard showing ROI metrics, revenue performance,
/// conversion funnel, action items, and predictive insights
class ROIDashboardPage extends StatefulWidget {
  const ROIDashboardPage({super.key});

  @override
  State<ROIDashboardPage> createState() => _ROIDashboardPageState();
}

class _ROIDashboardPageState extends State<ROIDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = '30d';

  final List<String> _timeframes = ['7d', '30d', '90d', '1y'];
  final List<String> _timeframeLabels = ['7 Days', '30 Days', '90 Days', '1 Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadROIData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadROIData() async {
    final viewModel = context.read<DashboardViewModel>();
    await viewModel.loadROIDashboardData(_selectedTimeframe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('ROI Executive Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Timeframe selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedTimeframe,
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: List.generate(
                _timeframes.length,
                (index) => DropdownMenuItem(
                  value: _timeframes[index],
                  child: Text(
                    _timeframeLabels[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTimeframe = value);
                  _loadROIData();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadROIData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Revenue', icon: Icon(Icons.trending_up)),
            Tab(text: 'Conversion', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'Actions', icon: Icon(Icons.task_alt)),
          ],
        ),
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading ROI Analytics...'),
                ],
              ),
            );
          }

          if (viewModel.roiData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Unable to load ROI data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadROIData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildRevenueTab(viewModel),
              _buildConversionTab(viewModel),
              _buildActionsTab(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(DashboardViewModel viewModel) {
    final roiData = viewModel.roiData!;

    return RefreshIndicator(
      onRefresh: _loadROIData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall ROI Score
            ROIScoreCard(roiData: roiData),

            const SizedBox(height: 24),

            // Key Metrics Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Revenue',
                    '₹${roiData['total_revenue']?.toStringAsFixed(0) ?? '0'}',
                    Icons.currency_rupee,
                    Colors.green,
                    '+${roiData['revenue_growth']?.toStringAsFixed(1) ?? '0'}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'New Policies',
                    '${roiData['new_policies'] ?? 0}',
                    Icons.assignment,
                    Colors.blue,
                    'This period',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Conversion Funnel Preview
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
                  Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conversion Funnel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConversionFunnelWidget(roiData: roiData),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Items Preview
            ActionItemsWidget(
              actionItems: roiData['action_items'] ?? [],
              showAll: false,
            ),

            const SizedBox(height: 24),

            // Predictive Insights Preview
            PredictiveInsightsWidget(
              insights: roiData['predictive_insights'] ?? [],
              showAll: false,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTab(DashboardViewModel viewModel) {
    return RevenuePerformanceWidget(
      roiData: viewModel.roiData!,
      timeframe: _selectedTimeframe,
    );
  }

  Widget _buildConversionTab(DashboardViewModel viewModel) {
    return ConversionFunnelWidget(
      roiData: viewModel.roiData!,
      showDetails: true,
    );
  }

  Widget _buildActionsTab(DashboardViewModel viewModel) {
    final roiData = viewModel.roiData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionItemsWidget(
            actionItems: roiData['action_items'] ?? [],
            showAll: true,
          ),
          const SizedBox(height: 24),
          PredictiveInsightsWidget(
            insights: roiData['predictive_insights'] ?? [],
            showAll: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
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
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
