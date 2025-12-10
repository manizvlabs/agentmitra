import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _dashboardOverview = {};
  List<Map<String, dynamic>> _topAgents = [];
  List<Map<String, dynamic>> _revenueTrends = [];
  List<Map<String, dynamic>> _policyTrends = [];
  Map<String, dynamic> _comprehensiveAnalytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    print('🔄 Starting analytics data loading...');

    try {
      // Load all analytics data in parallel
      await Future.wait([
        _loadDashboardOverview(),
        _loadTopAgents(),
        _loadRevenueTrends(),
        _loadPolicyTrends(),
        _loadComprehensiveAnalytics(),
      ]);
      print('✅ All analytics data loaded successfully');
    } catch (e) {
      print('❌ Failed to load analytics data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load analytics data. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('🏁 Analytics loading completed, isLoading = false');
      }
    }
  }

  Future<void> _loadDashboardOverview() async {
    try {
      print('📊 Loading dashboard overview...');
      final response = await ApiService.get('/api/v1/analytics/dashboard/overview');
      print('📊 Dashboard response: $response');
      // API returns direct object, not wrapped in 'data' key
      final data = response as Map<String, dynamic>? ?? {};
      print('📊 Dashboard parsed data: $data');
      setState(() => _dashboardOverview = data);
      print('📊 Dashboard overview loaded: ${_dashboardOverview.length} keys');
    } catch (e) {
      print('❌ Dashboard overview API failed: $e');
    }
  }

  Future<void> _loadTopAgents() async {
    try {
      print('👥 Loading top agents...');
      final response = await ApiService.get('/api/v1/analytics/dashboard/top-agents');
      print('👥 Top agents response: $response');
      // API returns direct array of agents, not wrapped in 'data' key
      final agentList = response as List<dynamic>? ?? [];
      print('👥 Top agents parsed: ${agentList.length} agents');
      setState(() => _topAgents = List<Map<String, dynamic>>.from(agentList));
      print('👥 Top agents state updated: ${_topAgents.length} agents');
    } catch (e) {
      print('❌ Top agents API failed: $e');
      setState(() => _topAgents = []);
    }
  }

  Future<void> _loadRevenueTrends() async {
    try {
      print('💰 Loading revenue trends...');
      final response = await ApiService.get('/api/v1/analytics/dashboard/charts/revenue-trends');
      print('💰 Revenue trends response: $response');
      // API returns direct array of revenue data, not wrapped in 'data' key
      final revenueList = response as List<dynamic>? ?? [];
      print('💰 Revenue trends parsed: ${revenueList.length} data points');
      setState(() => _revenueTrends = List<Map<String, dynamic>>.from(revenueList));
      print('💰 Revenue trends state updated: ${_revenueTrends.length} data points');
    } catch (e) {
      print('❌ Revenue trends API failed: $e');
      setState(() => _revenueTrends = []);
    }
  }

  Future<void> _loadPolicyTrends() async {
    try {
      print('📈 Loading policy trends...');
      final response = await ApiService.get('/api/v1/analytics/dashboard/charts/policy-trends');
      print('📈 Policy trends response: $response');
      // API returns direct array of policy data, not wrapped in 'data' key
      final policyList = response as List<dynamic>? ?? [];
      print('📈 Policy trends parsed: ${policyList.length} data points');
      setState(() => _policyTrends = List<Map<String, dynamic>>.from(policyList));
      print('📈 Policy trends state updated: ${_policyTrends.length} data points');
    } catch (e) {
      print('❌ Policy trends API failed: $e');
      setState(() => _policyTrends = []);
    }
  }

  Future<void> _loadComprehensiveAnalytics() async {
    try {
      print('📊 Loading comprehensive analytics...');
      final response = await ApiService.get('/api/v1/analytics/comprehensive/dashboard');
      print('📊 Comprehensive response: $response');
      // API returns data wrapped in 'data' key
      final analyticsData = response['data'] as Map<String, dynamic>? ?? {};
      print('📊 Comprehensive parsed data: ${analyticsData.length} keys');
      setState(() => _comprehensiveAnalytics = analyticsData);
      print('📊 Comprehensive analytics loaded: ${_comprehensiveAnalytics.length} metrics');
    } catch (e) {
      print('❌ Comprehensive analytics API failed: $e');
    }
  }

  Widget _buildKPIsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key Performance Indicators',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildKPICard(
                  'Total Revenue',
                  '₹${(_dashboardOverview['total_premium_collected'] ?? 0).toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                  '₹${(_dashboardOverview['monthly_premium_collected'] ?? 0).toStringAsFixed(0)} this month',
                ),
                _buildKPICard(
                  'Total Policies',
                  '${_dashboardOverview['total_policies'] ?? 0}',
                  Icons.policy,
                  Colors.blue,
                  '${_dashboardOverview['active_policies'] ?? 0} active',
                ),
                _buildKPICard(
                  'Total Customers',
                  '${_dashboardOverview['total_customers'] ?? 0}',
                  Icons.people,
                  Colors.orange,
                  '${_dashboardOverview['new_customers_this_month'] ?? 0} new this month',
                ),
                _buildKPICard(
                  'Conversion Rate',
                  '${(_dashboardOverview['conversion_rate'] as num? ?? 0).toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                  'Lead to policy',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFF0083B0), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Revenue Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTrendChart(_revenueTrends, Colors.green),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.policy, color: Color(0xFF0083B0), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Policy Trends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTrendChart(_policyTrends, Colors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(List<Map<String, dynamic>> data, Color color) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: Text('No trend data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final maxValue = data.map((d) => d['value'] ?? 0).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((d) => d['value'] ?? 0).reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((point) {
          final value = point['value'] ?? 0;
          final height = maxValue > minValue ? ((value - minValue) / (maxValue - minValue)) * 100 : 50.0;
          final month = point['label'] ?? point['date'] ?? '';

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  height: height.clamp(20.0, 100.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      value is double ? value.toStringAsFixed(0) : value.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopPerformersSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF0083B0), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Top Performing Agents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_topAgents.length} Top Performers',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _topAgents.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No performance data available', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topAgents.length,
                  itemBuilder: (context, index) {
                    final agent = _topAgents[index];
                    return _buildTopAgentCard(agent, index + 1);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAgentCard(Map<String, dynamic> agent, int rank) {
    final rankColors = [
      Colors.amber,
      Colors.grey.shade400,
      Colors.brown.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
      Colors.indigo.shade400
    ];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: rankColors[(rank - 1) % rankColors.length].withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: rankColors[(rank - 1) % rankColors.length],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent['name'] ?? 'Unknown Agent',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Rank #${agent['rank'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '₹${(agent['value'] ?? 0).toStringAsFixed(0)} premium',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0083B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: const Border.fromBorderSide(BorderSide(color: Color(0xFF0083B0), width: 0.5)),
              ),
              child: Text(
                '₹${(agent['value'] ?? 0).toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF0083B0),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPerformanceSection() {
    final products = _comprehensiveAnalytics['productPerformance'] as List<dynamic>? ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            products.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No product performance data available', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index] as Map<String, dynamic>;
                    return _buildProductCard(product);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final products = _comprehensiveAnalytics['productPerformance'] as List<dynamic>? ?? [];
    final totalRevenue = products.fold<double>(0, (sum, p) => sum + (p['revenue'] as double? ?? 0));
    final percentage = totalRevenue > 0 ? ((product['revenue'] as double? ?? 0) / totalRevenue * 100) : 0;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['product'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['policies'] ?? 0} policies • ${percentage.toStringAsFixed(1)}% of total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '₹${(product['revenue'] as double? ?? 0).toStringAsFixed(0)}',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicInsightsSection() {
    final distribution = _comprehensiveAnalytics['geographicDistribution'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geographic Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            distribution.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No geographic data available', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: distribution.entries.map<Widget>((entry) {
                    final percentage = entry.value as int;
                    return _buildGeographicChip(entry.key, percentage);
                  }).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicChip(String city, int percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0083B0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: const Border.fromBorderSide(BorderSide(color: Color(0xFF0083B0), width: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF0083B0),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF0083B0).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0083B0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get products => _comprehensiveAnalytics['productPerformance'] as List<Map<String, dynamic>>? ?? [];

  @override
  Widget build(BuildContext context) {
    print('🔄 Building analytics screen...');
    print('📊 Dashboard overview: ${_dashboardOverview.length} keys');
    print('👥 Top agents: ${_topAgents.length} agents');
    print('💰 Revenue trends: ${_revenueTrends.length} data points');
    print('📈 Policy trends: ${_policyTrends.length} data points');
    print('📊 Comprehensive: ${_comprehensiveAnalytics.length} metrics');
    print('⏳ Is loading: $_isLoading');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0),
        foregroundColor: Colors.white,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _dashboardOverview.isEmpty && _topAgents.isEmpty && _revenueTrends.isEmpty
            ? const Center(
                child: Text('Analytics data unavailable - requires backend API integration'),
              )
            : _buildComprehensiveAnalyticsContent(),
      ),
    );
  }


  Widget _buildComprehensiveAnalyticsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Performance Indicators
          if (_dashboardOverview.isNotEmpty) ...[
            _buildKPIsSection(),
            const SizedBox(height: 24),
          ],

          // Trends Section (Revenue and Policy)
          if (_revenueTrends.isNotEmpty || _policyTrends.isNotEmpty) ...[
            _buildTrendsSection(),
            const SizedBox(height: 24),
          ],

          // Top Performing Agents
          if (_topAgents.isNotEmpty) ...[
            _buildTopPerformersSection(),
            const SizedBox(height: 24),
          ],

          // Product Performance (from comprehensive analytics)
          if (_comprehensiveAnalytics.isNotEmpty) ...[
            _buildProductPerformanceSection(),
            const SizedBox(height: 24),
            _buildGeographicInsightsSection(),
          ],
        ],
      ),
    );
  }

}
