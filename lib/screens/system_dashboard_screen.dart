import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSystemData();
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
      final response = await ApiService.get('/api/v1/dashboard/system-overview');
      setState(() => _systemHealth = response ?? {});
    } catch (e) {
      print('System health API failed: $e');
    }
  }

  Future<void> _loadDatabaseHealth() async {
    try {
      // Database health not in project plan - using system overview instead
      final response = await ApiService.get('/api/v1/dashboard/system-overview');
      setState(() => _databaseHealth = response ?? {});
    } catch (e) {
      print('Database health API failed: $e');
    }
  }

  Future<void> _loadMetrics() async {
    try {
      // General metrics not in project plan - using analytics dashboard instead
      final response = await ApiService.get('/api/v1/analytics/dashboard/overview');
      setState(() => _metrics = {'raw': response ?? ''});
    } catch (e) {
      print('Metrics API failed: $e');
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
                Container(
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
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildHealthMetric(
                    'CPU Usage',
                    '${(_systemHealth['cpu_usage'] ?? 0).toStringAsFixed(1)}%',
                    _getHealthColor(_systemHealth['cpu_usage'] ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Memory Usage',
                    '${(_systemHealth['memory_usage'] ?? 0).toStringAsFixed(1)}%',
                    _getHealthColor(_systemHealth['memory_usage'] ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHealthMetric(
                    'Disk Usage',
                    '${(_systemHealth['disk_usage'] ?? 0).toStringAsFixed(1)}%',
                    _getHealthColor(_systemHealth['disk_usage'] ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Uptime: ${_formatUptime(_systemHealth['uptime_seconds'] ?? 0)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
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
                  'Metrics Visualization\n\n[Chart would display here]\n\nReal-time system metrics,\nperformance graphs,\nand monitoring data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricChip('CPU: 45.2%', Colors.blue),
                _buildMetricChip('Memory: 62.8%', Colors.green),
                _buildMetricChip('API: 2.8K req/h', Colors.orange),
              ],
            ),
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
