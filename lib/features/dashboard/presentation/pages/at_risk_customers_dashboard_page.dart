import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_risk_customer_cards.dart';
import '../widgets/dashboard_risk_filters.dart';
import '../widgets/dashboard_risk_stats.dart';
import '../widgets/dashboard_retention_actions.dart';

/// At-Risk Customers Dashboard Page
/// Comprehensive dashboard for managing customers at risk of churning
class AtRiskCustomersDashboardPage extends StatefulWidget {
  const AtRiskCustomersDashboardPage({super.key});

  @override
  State<AtRiskCustomersDashboardPage> createState() => _AtRiskCustomersDashboardPageState();
}

class _AtRiskCustomersDashboardPageState extends State<AtRiskCustomersDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRiskLevel = 'all';
  String _selectedPriority = 'all';

  final List<String> _riskLevels = ['all', 'high', 'medium', 'low'];
  final List<String> _priorities = ['all', 'urgent', 'high', 'medium', 'low'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAtRiskCustomersData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAtRiskCustomersData() async {
    final viewModel = context.read<DashboardViewModel>();
    await viewModel.loadAtRiskCustomersData(riskLevel: _selectedRiskLevel, priority: _selectedPriority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('At-Risk Customers'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(),
            tooltip: 'Filter Customers',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAtRiskCustomersData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'At-Risk', icon: Icon(Icons.warning)),
            Tab(text: 'Retention', icon: Icon(Icons.handshake)),
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
                  Text('Analyzing at-risk customers...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildAtRiskTab(viewModel),
              _buildRetentionTab(viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBulkRetentionDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.campaign, color: Colors.white),
        tooltip: 'Bulk Retention Actions',
      ),
    );
  }

  Widget _buildOverviewTab(DashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: _loadAtRiskCustomersData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Risk Statistics
              RiskStatisticsWidget(
                riskData: viewModel.riskCustomersData ?? {},
                riskLevel: _selectedRiskLevel,
                priority: _selectedPriority,
              ),

              const SizedBox(height: 24),

              // Risk Level Distribution
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
                      'Risk Level Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRiskLevelDistribution(viewModel.riskCustomersData ?? {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Retention Success Rate
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
                      'Retention Performance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRetentionPerformance(viewModel.riskCustomersData ?? {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Risk Factors Analysis
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
                      'Common Risk Factors',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRiskFactorsAnalysis(viewModel.riskCustomersData ?? {}),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtRiskTab(DashboardViewModel viewModel) {
    return Column(
      children: [
        // Filters Row
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Risk Level',
                  _selectedRiskLevel,
                  _riskLevels,
                  (value) {
                    setState(() => _selectedRiskLevel = value!);
                    _loadAtRiskCustomersData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Priority',
                  _selectedPriority,
                  _priorities,
                  (value) {
                    setState(() => _selectedPriority = value!);
                    _loadAtRiskCustomersData();
                  },
                ),
              ),
            ],
          ),
        ),

        // Customers List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadAtRiskCustomersData,
            child: RiskCustomerCardsWidget(
              customers: viewModel.riskCustomersData?['customers'] ?? [],
              onCustomerTap: _onCustomerTap,
              onActionTap: _onCustomerAction,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetentionTab(DashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Retention Actions Summary
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
                  'Retention Actions Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRetentionActionsSummary(viewModel.riskCustomersData ?? {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active Retention Plans
          RetentionActionsWidget(
            retentionActions: viewModel.riskCustomersData?['retention_actions'] ?? [],
            onActionComplete: _onRetentionActionComplete,
            onActionUpdate: _onRetentionActionUpdate,
          ),

          const SizedBox(height: 24),

          // Retention Strategies
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
                  'Retention Strategies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRetentionStrategies(viewModel.riskCustomersData ?? {}),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items,
      void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLevelDistribution(Map<String, dynamic> riskData) {
    final distribution = riskData['risk_distribution'] ?? {};
    final total = distribution.values.fold(0, (sum, value) => sum + (value as int));

    return Column(
      children: [
        _buildRiskBar('High Risk', distribution['high'] ?? 0, total, Colors.red),
        const SizedBox(height: 8),
        _buildRiskBar('Medium Risk', distribution['medium'] ?? 0, total, Colors.orange),
        const SizedBox(height: 8),
        _buildRiskBar('Low Risk', distribution['low'] ?? 0, total, Colors.yellow),
      ],
    );
  }

  Widget _buildRiskBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRetentionPerformance(Map<String, dynamic> riskData) {
    final performance = riskData['retention_performance'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildPerformanceMetric(
            context,
            'Success Rate',
            '${performance['success_rate']?.toStringAsFixed(1) ?? '0'}%',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPerformanceMetric(
            context,
            'Avg. Response',
            '${performance['avg_response_days'] ?? 0} days',
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildPerformanceMetric(
            context,
            'Revenue Saved',
            '₹${performance['revenue_saved']?.toStringAsFixed(0) ?? '0'}',
            Icons.currency_rupee,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetric(BuildContext context, String title, String value,
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
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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

  Widget _buildRiskFactorsAnalysis(Map<String, dynamic> riskData) {
    final factors = riskData['common_risk_factors'] ?? [];

    if (factors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No risk factors data available'),
        ),
      );
    }

    return Column(
      children: factors.map<Widget>((factor) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getRiskFactorIcon(factor['type']),
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  factor['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${factor['percentage']?.toStringAsFixed(0) ?? 0}%',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRetentionActionsSummary(Map<String, dynamic> riskData) {
    final summary = riskData['retention_actions_summary'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildActionSummaryCard(
            context,
            'Pending',
            summary['pending'] ?? 0,
            Icons.schedule,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionSummaryCard(
            context,
            'In Progress',
            summary['in_progress'] ?? 0,
            Icons.play_arrow,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionSummaryCard(
            context,
            'Completed',
            summary['completed'] ?? 0,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionSummaryCard(
            context,
            'Successful',
            summary['successful'] ?? 0,
            Icons.thumb_up,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSummaryCard(BuildContext context, String title, int count,
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
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
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

  Widget _buildRetentionStrategies(Map<String, dynamic> riskData) {
    final strategies = riskData['retention_strategies'] ?? [];

    if (strategies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No retention strategies available'),
        ),
      );
    }

    return Column(
      children: strategies.map<Widget>((strategy) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 16,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy['title'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      strategy['description'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${strategy['success_rate']?.toStringAsFixed(0) ?? 0}%',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter At-Risk Customers'),
        content: RiskFiltersWidget(
          selectedRiskLevel: _selectedRiskLevel,
          selectedPriority: _selectedPriority,
          onRiskLevelChanged: (value) => setState(() => _selectedRiskLevel = value),
          onPriorityChanged: (value) => setState(() => _selectedPriority = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadAtRiskCustomersData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showBulkRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Retention Actions'),
        content: const Text('Select retention actions to apply to multiple at-risk customers'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply Actions'),
          ),
        ],
      ),
    );
  }

  void _onCustomerTap(dynamic customer) {
    // Navigate to customer detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening customer: ${customer['customer_name']}')),
    );
  }

  void _onCustomerAction(dynamic customer, String action) {
    // Handle customer actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for customer: ${customer['customer_name']}')),
    );
  }

  void _onRetentionActionComplete(dynamic action) {
    // Handle retention action completion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retention action completed!')),
    );
  }

  void _onRetentionActionUpdate(dynamic action) {
    // Handle retention action updates
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Retention action updated!')),
    );
  }

  IconData _getRiskFactorIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'engagement':
        return Icons.remove_red_eye;
      case 'support':
        return Icons.support_agent;
      case 'policy_age':
        return Icons.calendar_today;
      default:
        return Icons.warning;
    }
  }
}
