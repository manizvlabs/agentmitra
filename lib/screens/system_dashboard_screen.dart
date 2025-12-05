import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class SystemDashboardScreen extends StatefulWidget {
  const SystemDashboardScreen({super.key});

  @override
  State<SystemDashboardScreen> createState() => _SystemDashboardScreenState();
}

class _SystemDashboardScreenState extends State<SystemDashboardScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _systemOverview = {};
  Map<String, dynamic> _systemHealth = {};
  Map<String, dynamic> _databaseHealth = {};
  Map<String, dynamic> _metrics = {};
  
  // Metrics history for charts
  List<double> _cpuHistory = [];
  List<double> _memoryHistory = [];
  List<double> _diskHistory = [];
  DateTime? _lastMetricsUpdate;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
    // Auto-refresh metrics every 30 seconds
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadSystemHealth();
        _loadMetrics();
        _startAutoRefresh(); // Schedule next refresh
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSystemData() async {
    setState(() => _isLoading = true);

    try {
      // Load system overview data
      await _loadSystemOverview();

      // Load system health data
      await _loadSystemHealth();

      // Load database health data
      await _loadDatabaseHealth();

      // Load metrics data
      await _loadMetrics();
    } catch (e) {
      print('Failed to load system data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load system data. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSystemOverview() async {
    try {
      final response = await ApiService.get('/api/v1/dashboard/system-overview');
      // API returns direct object, not wrapped in 'data' key
      setState(() => _systemOverview = response as Map<String, dynamic>? ?? {});
    } catch (e) {
      print('System overview API failed: $e');
    }
  }

  Future<void> _loadSystemHealth() async {
    try {
      final response = await ApiService.get('/api/v1/health/system');
      // API returns direct object with nested structure
      final healthData = response as Map<String, dynamic>? ?? {};
      
      setState(() {
        _systemHealth = healthData;
        
        // Extract metrics for charts
        if (healthData['system'] != null) {
          final system = healthData['system'] as Map<String, dynamic>;
          final cpu = system['cpu'] as Map<String, dynamic>?;
          final memory = system['memory'] as Map<String, dynamic>?;
          final disk = system['disk'] as Map<String, dynamic>?;
          
          // Add to history (keep last 20 data points)
          if (cpu != null) {
            _cpuHistory.add(cpu['usage_percent']?.toDouble() ?? 0.0);
            if (_cpuHistory.length > 20) _cpuHistory.removeAt(0);
          }
          if (memory != null) {
            _memoryHistory.add(memory['usage_percent']?.toDouble() ?? 0.0);
            if (_memoryHistory.length > 20) _memoryHistory.removeAt(0);
          }
          if (disk != null) {
            _diskHistory.add(disk['usage_percent']?.toDouble() ?? 0.0);
            if (_diskHistory.length > 20) _diskHistory.removeAt(0);
          }
        }
        
        _lastMetricsUpdate = DateTime.now();
      });
    } catch (e) {
      print('System health API failed: $e');
    }
  }

  Future<void> _loadDatabaseHealth() async {
    try {
      final response = await ApiService.get('/api/v1/health/database');
      // API returns direct object, not wrapped in 'data' key
      setState(() => _databaseHealth = response as Map<String, dynamic>? ?? {});
    } catch (e) {
      print('Database health API failed: $e');
    }
  }

  Future<void> _loadMetrics() async {
    try {
      // Metrics endpoint returns Prometheus format plain text, not JSON
      final metricsText = await ApiService.getText('/api/v1/metrics');
      setState(() => _metrics = {'raw': metricsText});
    } catch (e) {
      print('Metrics API failed: $e');
      // Silently fail - metrics are optional, we already have system health data
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSystemData,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _systemOverview.isEmpty && _systemHealth.isEmpty && _databaseHealth.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadSystemData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSystemOverviewSection(),
                    const SizedBox(height: 24),
                    _buildSystemHealthSection(),
                    const SizedBox(height: 24),
                    _buildDatabaseHealthSection(),
                    const SizedBox(height: 24),
                    _buildMetricsSection(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.computer,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'System data unavailable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'System monitoring data will appear here when available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverviewSection() {
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
                const Icon(Icons.dashboard, color: Color(0xFF0083B0), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_systemOverview['systemHealth'] ?? 0) > 90
                        ? Colors.green.shade100
                        : (_systemOverview['systemHealth'] ?? 0) > 70
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Health: ${(_systemOverview['systemHealth'] ?? 0).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: (_systemOverview['systemHealth'] ?? 0) > 90
                          ? Colors.green.shade800
                          : (_systemOverview['systemHealth'] ?? 0) > 70
                            ? Colors.orange.shade800
                            : Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOverviewMetric(
                  'Users',
                  '${_systemOverview['totalUsers'] ?? 0}',
                  '${_systemOverview['activeUsers'] ?? 0} active',
                  Icons.people,
                  Colors.blue,
                ),
                _buildOverviewMetric(
                  'Agents',
                  '${_systemOverview['totalAgents'] ?? 0}',
                  '${_systemOverview['activeAgents'] ?? 0} active',
                  Icons.business,
                  Colors.green,
                ),
                _buildOverviewMetric(
                  'Policies',
                  '${_systemOverview['totalPolicies'] ?? 0}',
                  '${_systemOverview['activePolicies'] ?? 0} active',
                  Icons.policy,
                  Colors.orange,
                ),
                _buildOverviewMetric(
                  'Revenue',
                  '₹${(_systemOverview['monthlyRevenue'] ?? 0).toStringAsFixed(0)}',
                  'Monthly',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStat(
                    'Active Sessions',
                    '${_systemOverview['activeSessions'] ?? 0}',
                    Icons.computer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStat(
                    'API Calls (24h)',
                    '${_systemOverview['apiCalls24h'] ?? 0}',
                    Icons.api,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickStat(
                    'Pending Approvals',
                    '${_systemOverview['pendingApprovals'] ?? 0}',
                    Icons.pending,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetric(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthSection() {
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
                const Icon(Icons.health_and_safety, color: Color(0xFF0083B0), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'System Health',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_systemHealth['status'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_systemHealth['status'] == 'healthy')
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (_systemHealth['status'] ?? 'unknown').toUpperCase(),
                      style: TextStyle(
                        color: (_systemHealth['status'] == 'healthy')
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'UNKNOWN',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_systemHealth['system'] != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildHealthMetric(
                      'CPU Usage',
                      '${(_systemHealth['system']['cpu']?['usage_percent'] ?? 0).toStringAsFixed(1)}%',
                      _getHealthColor((_systemHealth['system']['cpu']?['usage_percent'] ?? 0).toDouble()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthMetric(
                      'Memory Usage',
                      '${(_systemHealth['system']['memory']?['usage_percent'] ?? 0).toStringAsFixed(1)}%',
                      _getHealthColor((_systemHealth['system']['memory']?['usage_percent'] ?? 0).toDouble()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHealthMetric(
                      'Disk Usage',
                      '${(_systemHealth['system']['disk']?['usage_percent'] ?? 0).toStringAsFixed(1)}%',
                      _getHealthColor((_systemHealth['system']['disk']?['usage_percent'] ?? 0).toDouble()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CPU Cores: ${_systemHealth['system']['cpu']?['cores'] ?? 'N/A'} | '
                      'Memory: ${(_systemHealth['system']['memory']?['used_gb'] ?? 0).toStringAsFixed(1)}GB / ${(_systemHealth['system']['memory']?['total_gb'] ?? 0).toStringAsFixed(1)}GB',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'System health data not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage < 60) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDatabaseHealthSection() {
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
                const Icon(Icons.storage, color: Color(0xFF0083B0), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Database Health',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_databaseHealth['status'] == 'healthy')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (_databaseHealth['status'] ?? 'unknown').toUpperCase(),
                    style: TextStyle(
                      color: (_databaseHealth['status'] == 'healthy')
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_databaseHealth['database'] != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDatabaseMetric(
                      'Response Time',
                      '${_databaseHealth['database']['connection']['response_time_ms'] ?? 0}ms',
                      Icons.speed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatabaseMetric(
                      'Pool Size',
                      '${_databaseHealth['database']['connection']['pool_size'] ?? 0}',
                      Icons.pool,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatabaseMetric(
                      'Schema',
                      _databaseHealth['database']['schema'] ?? 'unknown',
                      Icons.schema,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Connection Pool Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPoolStat(
                      'Checked In',
                      '${_databaseHealth['database']['pool_stats']['connections_checked_in'] ?? 0}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPoolStat(
                      'Checked Out',
                      '${_databaseHealth['database']['pool_stats']['connections_checked_out'] ?? 0}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPoolStat(
                      'Overflow',
                      '${_databaseHealth['database']['pool_stats']['overflow_connections'] ?? 0}',
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Database health data not available',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPoolStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
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
                const Icon(Icons.analytics, color: Color(0xFF0083B0), size: 28),
                const SizedBox(width: 12),
                const Text(
                  'System Metrics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showMetricsDialog(),
                  icon: const Icon(Icons.visibility),
                  tooltip: 'View Raw Metrics',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_cpuHistory.isNotEmpty || _memoryHistory.isNotEmpty || _diskHistory.isNotEmpty) ...[
              Container(
                height: 250,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildMetricsChart(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricChip(
                    'CPU: ${_systemHealth['system']?['cpu']?['usage_percent']?.toStringAsFixed(1) ?? '0.0'}%',
                    Colors.blue,
                  ),
                  _buildMetricChip(
                    'Memory: ${_systemHealth['system']?['memory']?['usage_percent']?.toStringAsFixed(1) ?? '0.0'}%',
                    Colors.green,
                  ),
                  _buildMetricChip(
                    'Disk: ${_systemHealth['system']?['disk']?['usage_percent']?.toStringAsFixed(1) ?? '0.0'}%',
                    Colors.orange,
                  ),
                ],
              ),
              if (_lastMetricsUpdate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last updated: ${_formatTime(_lastMetricsUpdate!)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    'Metrics data will appear here once system health data is loaded',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showMetricsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raw System Metrics'),
        content: SingleChildScrollView(
          child: Text(
            _metrics['raw'] ?? 'No metrics data available',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsChart() {
    if (_cpuHistory.isEmpty && _memoryHistory.isEmpty && _diskHistory.isEmpty) {
      return const Center(
        child: Text('No metrics data available'),
      );
    }

    final maxValue = [
      ..._cpuHistory,
      ..._memoryHistory,
      ..._diskHistory,
    ].fold<double>(0.0, (max, value) => value > max ? value : max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 5 : 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _cpuHistory.length > 10 ? 5 : 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxValue > 0 ? maxValue / 5 : 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: (_cpuHistory.length > 0 ? _cpuHistory.length : 20).toDouble() - 1,
        minY: 0,
        maxY: maxValue > 0 ? (maxValue * 1.1).ceilToDouble() : 100,
        lineBarsData: [
          if (_cpuHistory.isNotEmpty)
            LineChartBarData(
              spots: _cpuHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          if (_memoryHistory.isNotEmpty)
            LineChartBarData(
              spots: _memoryHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          if (_diskHistory.isNotEmpty)
            LineChartBarData(
              spots: _diskHistory.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                String label = '';
                if (touchedSpot.barIndex == 0 && _cpuHistory.isNotEmpty) {
                  label = 'CPU';
                } else if (touchedSpot.barIndex == (_cpuHistory.isNotEmpty ? 1 : 0) && _memoryHistory.isNotEmpty) {
                  label = 'Memory';
                } else if (_diskHistory.isNotEmpty) {
                  label = 'Disk';
                }
                return LineTooltipItem(
                  '$label: ${touchedSpot.y.toStringAsFixed(1)}%',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
    }
  }
}
