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
      setState(() => _tenants = List<Map<String, dynamic>>.from(response['data'] ?? []));
    } catch (e) {
      // For testing purposes, show mock data when API fails due to authentication
      // TODO: Remove this when authentication is properly implemented
      print('API call failed ($e), using mock tenant data for testing');
      setState(() => _tenants = [
        {
          'tenant_id': 'bf0b6627-c595-4fd8-93c2-cb0e9cdc86bc',
          'tenant_code': 'LIC',
          'tenant_name': 'Life Insurance Corporation of India',
          'status': 'active',
          'created_at': '2025-11-21T13:00:53.717908Z'
        },
        {
          'tenant_id': '00000000-0000-0000-0000-000000000000',
          'tenant_code': 'DEFAULT',
          'tenant_name': 'Default Tenant',
          'status': 'active',
          'created_at': '2025-11-28T22:05:11.329831Z'
        }
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Showing mock tenant data (authentication pending)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants Management', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTenants,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _tenants.isEmpty && !_isLoading
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadTenants,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tenants.length,
                itemBuilder: (context, index) {
                  final tenant = _tenants[index];
                  return _buildTenantCard(tenant);
                },
              ),
            ),
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

  Widget _buildTenantCard(Map<String, dynamic> tenant) {
    final tenantName = tenant['tenant_name'] ?? 'Unknown Tenant';
    final tenantCode = tenant['tenant_code'] ?? 'N/A';
    final status = tenant['status'] ?? 'unknown';
    final createdAt = tenant['created_at'];

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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        tenantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: $tenantCode',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatDate(createdAt)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
