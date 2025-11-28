import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/dashboard_lead_cards.dart';
import '../widgets/dashboard_lead_filters.dart';
import '../widgets/dashboard_lead_stats.dart';

/// Hot Leads & Opportunities Dashboard Page
/// Comprehensive dashboard for managing leads and opportunities
class HotLeadsDashboardPage extends StatefulWidget {
  const HotLeadsDashboardPage({super.key});

  @override
  State<HotLeadsDashboardPage> createState() => _HotLeadsDashboardPageState();
}

class _HotLeadsDashboardPageState extends State<HotLeadsDashboardPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPriority = 'all';
  String _selectedSource = 'all';

  final List<String> _priorities = ['all', 'high', 'medium', 'low'];
  final List<String> _sources = ['all', 'website', 'referral', 'whatsapp_campaign',
                                'email_campaign', 'social_media', 'cold_call'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeadsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeadsData() async {
    final viewModel = context.read<DashboardViewModel>();
    await viewModel.loadHotLeadsData(priority: _selectedPriority, source: _selectedSource);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hot Leads & Opportunities'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersDialog(),
            tooltip: 'Filter Leads',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeadsData,
            tooltip: 'Refresh Leads',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Active Leads', icon: Icon(Icons.people)),
            Tab(text: 'Conversion', icon: Icon(Icons.trending_up)),
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
                  Text('Loading hot leads...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildActiveLeadsTab(viewModel),
              _buildConversionTab(viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLeadDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Lead',
      ),
    );
  }

  Widget _buildOverviewTab(DashboardViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: _loadLeadsData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Statistics
              LeadStatisticsWidget(
                leadsData: viewModel.leadsData ?? {},
                priority: _selectedPriority,
                source: _selectedSource,
              ),

              const SizedBox(height: 24),

              // Priority Distribution
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
                      'Lead Priority Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPriorityDistribution(viewModel.leadsData ?? {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Top Performing Sources
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
                      'Top Lead Sources',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSourcePerformance(viewModel.leadsData ?? {}),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent Activity
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
                      'Recent Lead Activity',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivity(viewModel.leadsData ?? {}),
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

  Widget _buildActiveLeadsTab(DashboardViewModel viewModel) {
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
                  'Priority',
                  _selectedPriority,
                  _priorities,
                  (value) {
                    setState(() => _selectedPriority = value!);
                    _loadLeadsData();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Source',
                  _selectedSource,
                  _sources,
                  (value) {
                    setState(() => _selectedSource = value!);
                    _loadLeadsData();
                  },
                ),
              ),
            ],
          ),
        ),

        // Leads List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadLeadsData,
            child: LeadCardsWidget(
              leads: viewModel.leadsData?['leads'] ?? [],
              onLeadTap: _onLeadTap,
              onActionTap: _onLeadAction,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversionTab(DashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conversion Metrics
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
                  'Conversion Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildConversionMetrics(viewModel.leadsData ?? {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Conversion Funnel
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
                  'Lead Conversion Funnel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLeadConversionFunnel(viewModel.leadsData ?? {}),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Top Converting Leads
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
                  'High-Potential Leads',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTopConvertingLeads(viewModel.leadsData ?? {}),
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

  Widget _buildPriorityDistribution(Map<String, dynamic> leadsData) {
    final priorities = leadsData['priority_distribution'] ?? {};
    final total = priorities.values.fold(0, (sum, value) => sum + (value as int));

    return Column(
      children: [
        _buildPriorityBar('High Priority', priorities['high'] ?? 0, total, Colors.red),
        const SizedBox(height: 8),
        _buildPriorityBar('Medium Priority', priorities['medium'] ?? 0, total, Colors.orange),
        const SizedBox(height: 8),
        _buildPriorityBar('Low Priority', priorities['low'] ?? 0, total, Colors.green),
      ],
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
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

  Widget _buildSourcePerformance(Map<String, dynamic> leadsData) {
    final sources = leadsData['source_performance'] ?? {};

    return Column(
      children: sources.entries.map<Widget>((entry) {
        final source = entry.key;
        final performance = entry.value as Map<String, dynamic>;
        final conversionRate = performance['conversion_rate'] ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  source.replaceAll('_', ' ').toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${performance['count'] ?? 0} leads',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 12),
              Text(
                '${conversionRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: conversionRate > 20 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(Map<String, dynamic> leadsData) {
    final activities = leadsData['recent_activities'] ?? [];

    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No recent lead activities'),
        ),
      );
    }

    return Column(
      children: activities.take(5).map<Widget>((activity) {
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
                _getActivityIcon(activity['type']),
                size: 16,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  activity['description'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                activity['time'] ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConversionMetrics(Map<String, dynamic> leadsData) {
    final metrics = leadsData['conversion_metrics'] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Leads',
            '${metrics['total_leads'] ?? 0}',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Converted',
            '${metrics['converted'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Conversion Rate',
            '${metrics['conversion_rate']?.toStringAsFixed(1) ?? '0'}%',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadConversionFunnel(Map<String, dynamic> leadsData) {
    // Simplified funnel visualization
    return Container(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFunnelStage('Leads', leadsData['total_leads'] ?? 0, Colors.blue),
          _buildFunnelArrow(),
          _buildFunnelStage('Contacted', leadsData['contacted_leads'] ?? 0, Colors.orange),
          _buildFunnelArrow(),
          _buildFunnelStage('Qualified', leadsData['qualified_leads'] ?? 0, Colors.purple),
          _buildFunnelArrow(),
          _buildFunnelStage('Converted', leadsData['converted_leads'] ?? 0, Colors.green),
        ],
      ),
    );
  }

  Widget _buildFunnelStage(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFunnelArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildTopConvertingLeads(Map<String, dynamic> leadsData) {
    final topLeads = leadsData['top_converting_leads'] ?? [];

    if (topLeads.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No high-potential leads found'),
        ),
      );
    }

    return Column(
      children: topLeads.take(3).map<Widget>((lead) {
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
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Text(
                  lead['name']?.substring(0, 1) ?? 'L',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead['name'] ?? 'Unknown Lead',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Score: ${lead['score'] ?? 0}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call, size: 20),
                color: Colors.green,
                onPressed: () => _onLeadAction(lead, 'call'),
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
        title: const Text('Filter Leads'),
        content: LeadFiltersWidget(
          selectedPriority: _selectedPriority,
          selectedSource: _selectedSource,
          onPriorityChanged: (value) => setState(() => _selectedPriority = value),
          onSourceChanged: (value) => setState(() => _selectedSource = value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadLeadsData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddLeadDialog() {
    // Implementation for adding new lead
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lead'),
        content: const Text('Lead creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }

  void _onLeadTap(dynamic lead) {
    // Navigate to lead detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening lead: ${lead['customer_name']}')),
    );
  }

  void _onLeadAction(dynamic lead, String action) {
    // Handle lead actions (call, email, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action action for lead: ${lead['customer_name']}')),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'call':
        return Icons.call;
      case 'email':
        return Icons.email;
      case 'meeting':
        return Icons.meeting_room;
      default:
        return Icons.info;
    }
  }
}
