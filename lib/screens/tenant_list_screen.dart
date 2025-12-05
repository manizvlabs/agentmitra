import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({super.key});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _tenants = [];
  Map<String, dynamic>? _selectedTenantDetails;
  bool _showTenantDetails = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() => _isLoading = true);

    try {
      // Use the verified GET /api/v1/tenants/ endpoint from project plan
      final response = await ApiService.get('/api/v1/tenants/');
      // API returns direct array of tenants, not wrapped in 'data' key
      final tenantList = response as List<dynamic>? ?? [];
      setState(() => _tenants = List<Map<String, dynamic>>.from(tenantList));
    } catch (e) {
      // Production-grade code: Show proper error instead of mock data
      print('Failed to load tenants: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load tenants. Please check your authentication and try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadTenants,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTenantDetails(String tenantId) async {
    setState(() => _isLoading = true);

    try {
      // Use GET /api/v1/tenants/{tenant_id} endpoint for detailed tenant info
      final response = await ApiService.get('/api/v1/tenants/$tenantId');
      setState(() {
        _selectedTenantDetails = response['data'];
        _showTenantDetails = true;
      });
    } catch (e) {
      print('Failed to load tenant details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load tenant details. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _loadTenantDetails(tenantId),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTenantStatus(String tenantId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    final endpoint = newStatus == 'active' ? 'reactivate' : 'deactivate';

    setState(() => _isLoading = true);

    try {
      // Use PUT /api/v1/tenants/{tenant_id}/deactivate or reactivate endpoints
      await ApiService.put('/api/v1/tenants/$tenantId/$endpoint', {});

      // Update local state
      setState(() {
        final tenantIndex = _tenants.indexWhere((t) => t['tenant_id'] == tenantId);
        if (tenantIndex != -1) {
          _tenants[tenantIndex]['status'] = newStatus;
        }
        if (_selectedTenantDetails != null && _selectedTenantDetails!['tenant_id'] == tenantId) {
          _selectedTenantDetails!['status'] = newStatus;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tenant ${newStatus == 'active' ? 'activated' : 'deactivated'} successfully')),
        );
      }
    } catch (e) {
      print('Failed to toggle tenant status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update tenant status. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _toggleTenantStatus(tenantId, currentStatus == 'active' ? 'inactive' : 'active'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateTenantConfig(String tenantId, Map<String, dynamic> config) async {
    setState(() => _isLoading = true);

    try {
      // Use POST /api/v1/tenants/{tenant_id}/config endpoint
      await ApiService.post('/api/v1/tenants/$tenantId/config', config);

      // Update local state
      setState(() {
        final tenantIndex = _tenants.indexWhere((t) => t['tenant_id'] == tenantId);
        if (tenantIndex != -1) {
          _tenants[tenantIndex].addAll(config);
        }
        if (_selectedTenantDetails != null && _selectedTenantDetails!['tenant_id'] == tenantId) {
          _selectedTenantDetails!.addAll(config);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant configuration updated successfully')),
        );
      }
    } catch (e) {
      print('Failed to update tenant config: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update tenant configuration. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showTenantConfigDialog(String tenantId) {
    final tenant = _tenants.firstWhere((t) => t['tenant_id'] == tenantId);
    final maxUsersController = TextEditingController(text: tenant['max_users']?.toString() ?? '100');
    final storageController = TextEditingController(text: tenant['storage_limit_gb']?.toString() ?? '5');
    final apiRateController = TextEditingController(text: tenant['api_rate_limit']?.toString() ?? '1000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${tenant['tenant_name']}'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextFormField(
                  controller: maxUsersController,
                  decoration: const InputDecoration(
                    labelText: 'Max Users',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: storageController,
                  decoration: const InputDecoration(
                    labelText: 'Storage Limit (GB)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apiRateController,
                  decoration: const InputDecoration(
                    labelText: 'API Rate Limit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final maxUsers = int.tryParse(maxUsersController.text);
              final storageLimit = int.tryParse(storageController.text);
              final apiRateLimit = int.tryParse(apiRateController.text);

              final config = <String, dynamic>{};
              if (maxUsers != null && maxUsers != tenant['max_users']) {
                config['max_users'] = maxUsers;
              }
              if (storageLimit != null && storageLimit != tenant['storage_limit_gb']) {
                config['storage_limit_gb'] = storageLimit;
              }
              if (apiRateLimit != null && apiRateLimit != tenant['api_rate_limit']) {
                config['api_rate_limit'] = apiRateLimit;
              }

              if (config.isNotEmpty) {
                _updateTenantConfig(tenantId, config);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No changes to update')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showTenantDetails ? (_selectedTenantDetails?['tenant_name'] ?? 'Tenant Details') : 'Tenants Management',
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _showTenantDetails ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() => _showTenantDetails = false),
        ) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTenants,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _showTenantDetails
          ? _buildTenantDetailsView()
          : (_tenants.isEmpty && !_isLoading
            ? _buildEmptyState()
            : _buildTenantsGrid()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0083B0),
        onPressed: () {
          // For now, just show a message since tenant creation endpoint exists
          // but requires complex form implementation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tenant creation available via API: POST /api/v1/tenants/')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tenants found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tenants will appear here when available',
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

  Widget _buildTenantsGrid() {
    return RefreshIndicator(
      onRefresh: _loadTenants,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _tenants.length,
        itemBuilder: (context, index) {
          final tenant = _tenants[index];
          return _buildTenantCard(tenant);
        },
      ),
    );
  }

  Widget _buildTenantCard(Map<String, dynamic> tenant) {
    final tenantName = tenant['tenant_name'] ?? 'Unknown Tenant';
    final tenantCode = tenant['tenant_code'] ?? 'N/A';
    final status = tenant['status'] ?? 'unknown';
    final tenantType = tenant['tenant_type'] ?? 'unknown';
    final subscriptionPlan = tenant['subscription_plan'] ?? 'trial';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _loadTenantDetails(tenant['tenant_id']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and actions
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      switch (action) {
                        case 'activate':
                          _toggleTenantStatus(tenant['tenant_id'], 'inactive');
                          break;
                        case 'deactivate':
                          _toggleTenantStatus(tenant['tenant_id'], 'active');
                          break;
                        case 'configure':
                          _showTenantConfigDialog(tenant['tenant_id']);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (status == 'inactive')
                        const PopupMenuItem(value: 'activate', child: Text('Activate')),
                      if (status == 'active')
                        const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
                      const PopupMenuItem(value: 'configure', child: Text('Configure')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tenant info
              Text(
                tenantName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                'Code: $tenantCode',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              // Tenant type and plan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0083B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${tenantType.replaceAll('_', ' ').toUpperCase()} • ${subscriptionPlan.toUpperCase()}',
                  style: const TextStyle(
                    color: Color(0xFF0083B0),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(),

              // Metrics
              Row(
                children: [
                  _buildMetricChip(
                    '${tenant['max_users'] ?? 0}',
                    'Users',
                    Icons.people,
                  ),
                  const SizedBox(width: 8),
                  _buildMetricChip(
                    '${tenant['storage_limit_gb'] ?? 0}GB',
                    'Storage',
                    Icons.storage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantDetailsView() {
    if (_selectedTenantDetails == null) return const SizedBox.shrink();

    final tenant = _selectedTenantDetails!;
    final status = tenant['status'] ?? 'unknown';

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant['tenant_name'] ?? 'Unknown Tenant',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${tenant['tenant_code'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      if (status == 'inactive')
                        ElevatedButton.icon(
                          onPressed: () => _toggleTenantStatus(tenant['tenant_id'], 'inactive'),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Activate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      if (status == 'active')
                        ElevatedButton.icon(
                          onPressed: () => _toggleTenantStatus(tenant['tenant_id'], 'active'),
                          icon: const Icon(Icons.pause),
                          label: const Text('Deactivate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showTenantConfigDialog(tenant['tenant_id']),
                        icon: const Icon(Icons.settings),
                        label: const Text('Configure'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0083B0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details Grid
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildDetailCard('Tenant Type', tenant['tenant_type']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'N/A'),
              _buildDetailCard('Subscription Plan', tenant['subscription_plan']?.toString().toUpperCase() ?? 'N/A'),
              _buildDetailCard('Max Users', tenant['max_users']?.toString() ?? 'N/A'),
              _buildDetailCard('Storage Limit', '${tenant['storage_limit_gb'] ?? 0} GB'),
              _buildDetailCard('API Rate Limit', tenant['api_rate_limit']?.toString() ?? 'N/A'),
              _buildDetailCard('Created', _formatDate(tenant['created_at'] ?? '')),
            ],
          ),

          const SizedBox(height: 16),

          // Contact Information
          if (tenant['contact_email'] != null || tenant['contact_phone'] != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (tenant['contact_email'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(tenant['contact_email']),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (tenant['contact_phone'] != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(tenant['contact_phone']),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Business Address
          if (tenant['business_address'] != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${tenant['business_address']['street'] ?? ''}\n'
                      '${tenant['business_address']['city'] ?? ''}, ${tenant['business_address']['state'] ?? ''}\n'
                      '${tenant['business_address']['pincode'] ?? ''}',
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Compliance & Regulatory
          if (tenant['compliance_status'] != null || tenant['regulatory_approvals'] != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compliance & Regulatory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (tenant['compliance_status'] != null) ...[
                      const Text(
                        'Compliance Status:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: (tenant['compliance_status'] as Map<String, dynamic>).entries.map<Widget>((entry) {
                          return Chip(
                            label: Text('${entry.key.toUpperCase()}: ${entry.value}'),
                            backgroundColor: entry.value == 'verified' ? Colors.green.shade100 : Colors.orange.shade100,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (tenant['regulatory_approvals'] != null) ...[
                      const Text(
                        'Regulatory Approvals:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: (tenant['regulatory_approvals'] as List<dynamic>).map<Widget>((approval) {
                          return Chip(
                            label: Text(approval),
                            backgroundColor: Colors.blue.shade100,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
