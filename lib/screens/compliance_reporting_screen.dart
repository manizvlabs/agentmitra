import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/services/api_service.dart';
import '../shared/theme/app_theme.dart';

class ComplianceReportingScreen extends StatefulWidget {
  const ComplianceReportingScreen({Key? key}) : super(key: key);

  @override
  State<ComplianceReportingScreen> createState() => _ComplianceReportingScreenState();
}

class _ComplianceReportingScreenState extends State<ComplianceReportingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _auditLogs = [];
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _permissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filters
  String? _selectedAction;
  String? _selectedUserId;
  DateTime? _startDate;
  DateTime? _endDate;
  int _limit = 50;

  final List<String> _actionTypes = [
    'role_assigned',
    'role_removed',
    'permission_checked',
    'feature_flag_changed',
    'data_created',
    'data_updated',
    'data_deleted',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load audit logs
      await _loadAuditLogs();

      // Load roles and permissions for reference
      final rolesResponse = await _apiService.get('/rbac/roles') as List<dynamic>;
      _roles = rolesResponse.map((role) => role as Map<String, dynamic>).toList();

      final permissionsResponse = await _apiService.get('/rbac/permissions') as List<dynamic>;
      _permissions = permissionsResponse.map((perm) => perm as Map<String, dynamic>).toList();

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAuditLogs() async {
    try {
      final queryParams = <String, dynamic>{
        'limit': _limit.toString(),
      };

      if (_selectedAction != null) queryParams['action'] = _selectedAction!;
      if (_selectedUserId != null) queryParams['user_id'] = _selectedUserId!;
      if (_startDate != null) queryParams['start_date'] = _startDate!.toIso8601String();
      if (_endDate != null) queryParams['end_date'] = _endDate!.toIso8601String();

      final response = await _apiService.get('/rbac/audit-log', queryParameters: queryParams) as List<dynamic>;
      _auditLogs = response.map((log) => log as Map<String, dynamic>).toList();

    } catch (e) {
      debugPrint('Error loading audit logs: $e');
      _auditLogs = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RBAC Compliance Reports'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Audit Logs', icon: Icon(Icons.history)),
            Tab(text: 'Role Reports', icon: Icon(Icons.assignment)),
            Tab(text: 'Access Summary', icon: Icon(Icons.analytics)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAuditLogsTab(),
                _buildRoleReportsTab(),
                _buildAccessSummaryTab(),
              ],
            ),
    );
  }

  Widget _buildAuditLogsTab() {
    return Column(
      children: [
        // Filters
        _buildFilters(),

        // Audit logs list
        Expanded(
          child: _auditLogs.isEmpty
              ? const Center(
                  child: Text('No audit logs found'),
                )
              : ListView.builder(
                  itemCount: _auditLogs.length,
                  itemBuilder: (context, index) {
                    final log = _auditLogs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: _getActionIcon(log['action'] as String),
                        title: Text(_getActionDescription(log)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User: ${log['user_id'] ?? 'System'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Time: ${_formatTimestamp(log['timestamp'])}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: log['success'] == true
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                            : const Icon(Icons.error, color: Colors.red, size: 20),
                        onTap: () => _showAuditLogDetails(log),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Action filter
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Action',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    value: _selectedAction,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Actions')),
                      ..._actionTypes.map((action) => DropdownMenuItem(
                            value: action,
                            child: Text(action.replaceAll('_', ' ')),
                          )),
                    ],
                    onChanged: (value) => setState(() => _selectedAction = value),
                  ),
                ),

                const SizedBox(width: 8),

                // User ID filter
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    onChanged: (value) => setState(() => _selectedUserId = value.isEmpty ? null : value),
                  ),
                ),

                const SizedBox(width: 8),

                // Date range
                ElevatedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: const Text('Date Range'),
                  onPressed: _showDateRangePicker,
                ),

                const SizedBox(width: 8),

                // Limit
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Limit',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    value: _limit,
                    items: [10, 25, 50, 100].map((limit) => DropdownMenuItem(
                          value: limit,
                          child: Text(limit.toString()),
                        )).toList(),
                    onChanged: (value) => setState(() => _limit = value ?? 50),
                  ),
                ),

                const SizedBox(width: 8),

                // Apply filters button
                ElevatedButton(
                  onPressed: _loadAuditLogs,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role Distribution Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Role summary cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (role['role_name'] as String).replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${role['permissions'].length} permissions',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      if (role['is_system_role'] == true)
                        const Chip(
                          label: Text('System', style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.blue.shade100,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          const Text(
            'Permissions Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Permissions by resource type
          _buildPermissionsByResourceType(),
        ],
      ),
    );
  }

  Widget _buildPermissionsByResourceType() {
    final resourceGroups = <String, List<Map<String, dynamic>>>{};

    for (final permission in _permissions) {
      final resourceType = permission['resource_type'] as String;
      resourceGroups.putIfAbsent(resourceType, () => []);
      resourceGroups[resourceType]!.add(permission);
    }

    return Column(
      children: resourceGroups.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key.toUpperCase()} Permissions',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: entry.value.map((permission) {
                    return Chip(
                      label: Text(
                        '${permission['action']} - ${permission['permission_name']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getResourceColor(entry.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Access Control Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Roles',
                  _roles.length.toString(),
                  Icons.group,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Permissions',
                  _permissions.length.toString(),
                  Icons.security,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Audit Entries',
                  _auditLogs.length.toString(),
                  Icons.history,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Active Sessions',
                  'N/A', // Would need to implement session tracking
                  Icons.online_prediction,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Recent audit entries
          ..._auditLogs.take(10).map((log) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: _getActionIcon(log['action']),
                  title: Text(_getActionDescription(log)),
                  subtitle: Text(_formatTimestamp(log['timestamp'])),
                  trailing: log['success'] == true
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : const Icon(Icons.error, color: Colors.red, size: 16),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showAuditLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Audit Log Details - ${log['action']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Action', log['action']),
              _buildDetailRow('User ID', log['user_id'] ?? 'System'),
              _buildDetailRow('Target User', log['target_user_id'] ?? 'N/A'),
              _buildDetailRow('Timestamp', _formatTimestamp(log['timestamp'])),
              _buildDetailRow('Success', log['success'].toString()),
              if (log['details'] != null) ...[
                const SizedBox(height: 16),
                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  log['details'].toString(),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Icon _getActionIcon(String action) {
    switch (action) {
      case 'role_assigned':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'role_removed':
        return const Icon(Icons.person_remove, color: Colors.orange);
      case 'permission_checked':
        return const Icon(Icons.visibility, color: Colors.green);
      case 'feature_flag_changed':
        return const Icon(Icons.flag, color: Colors.purple);
      case 'data_created':
        return const Icon(Icons.add_circle, color: Colors.teal);
      case 'data_updated':
        return const Icon(Icons.edit, color: Colors.amber);
      case 'data_deleted':
        return const Icon(Icons.delete, color: Colors.red);
      default:
        return const Icon(Icons.info, color: Colors.grey);
    }
  }

  String _getActionDescription(Map<String, dynamic> log) {
    final action = log['action'] as String;
    final details = log['details'] as Map<String, dynamic>?;

    switch (action) {
      case 'role_assigned':
        return 'Role "${details?['assigned_role']}" assigned';
      case 'role_removed':
        return 'Role "${details?['removed_role']}" removed';
      case 'permission_checked':
        return 'Permission checked: ${details?['permission'] ?? 'N/A'}';
      case 'feature_flag_changed':
        return 'Feature flag "${details?['flag_name']}" ${details?['enabled'] ? 'enabled' : 'disabled'}';
      case 'data_created':
        return 'Data created: ${details?['table'] ?? 'Unknown'}';
      case 'data_updated':
        return 'Data updated: ${details?['table'] ?? 'Unknown'}';
      case 'data_deleted':
        return 'Data deleted: ${details?['table'] ?? 'Unknown'}';
      default:
        return action.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM dd, yyyy HH:mm:ss').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  Color _getResourceColor(String resourceType) {
    switch (resourceType) {
      case 'user':
        return Colors.blue.shade100;
      case 'agent':
        return Colors.green.shade100;
      case 'policy':
        return Colors.orange.shade100;
      case 'customer':
        return Colors.purple.shade100;
      case 'payment':
        return Colors.teal.shade100;
      case 'report':
        return Colors.amber.shade100;
      case 'system':
        return Colors.red.shade100;
      case 'tenant':
        return Colors.indigo.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
