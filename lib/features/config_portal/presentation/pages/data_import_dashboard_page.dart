import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/loading/empty_state_card.dart';

/// Data Import Dashboard Page
/// Section 5.2: Quick actions, statistics, recent imports, and bulk actions
class DataImportDashboardPage extends StatefulWidget {
  const DataImportDashboardPage({super.key});

  @override
  State<DataImportDashboardPage> createState() => _DataImportDashboardPageState();
}

class _DataImportDashboardPageState extends State<DataImportDashboardPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, completed, processing, failed

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Data Import',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1a237e)),
            onPressed: () {
              // Refresh imports
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Statistics Cards
              _buildStatisticsCards(),
              const SizedBox(height: 24),

              // Filter Chips
              _buildFilterChips(),
              const SizedBox(height: 16),

              // Recent Imports List
              _buildRecentImportsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/excel-template-config');
        },
        backgroundColor: const Color(0xFF1a237e),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Import',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.upload_file,
                title: 'Excel Import',
                subtitle: 'Import from Excel',
                color: Colors.blue,
                onTap: () {
                  context.push('/excel-template-config');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.sync,
                title: 'LIC API Sync',
                subtitle: 'Sync with LIC API',
                color: Colors.green,
                onTap: () {
                  _showSyncDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.update,
                title: 'Bulk Update',
                subtitle: 'Update multiple records',
                color: Colors.orange,
                onTap: () {
                  _showBulkUpdateDialog();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Import Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Records',
                value: '125,430',
                icon: Icons.description,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Success Rate',
                value: '98.7%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Active Jobs',
                value: '3',
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Templates',
                value: '12',
                icon: Icons.folder_special,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a237e),
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
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Completed', 'completed'),
          const SizedBox(width: 8),
          _buildFilterChip('Processing', 'processing'),
          const SizedBox(width: 8),
          _buildFilterChip('Failed', 'failed'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1a237e),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1a237e) : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildRecentImportsList() {
    final imports = _getFilteredImports();

    if (imports.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.upload_file,
        title: 'No Imports Found',
        message: 'Start by creating a new import',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Imports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            TextButton(
              onPressed: () {
                // View all imports
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...imports.map((import) => _buildImportCard(import)),
      ],
    );
  }

  Widget _buildImportCard(Map<String, dynamic> import) {
    final status = import['status'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor, size: 24),
        ),
        title: Text(
          import['fileName'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${import['records']} records • ${import['date']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'retry',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text('Retry'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredImports() {
    final allImports = [
      {
        'id': '1',
        'fileName': 'customers_q1_2024.xlsx',
        'status': 'completed',
        'records': 245,
        'date': '2024-01-15',
      },
      {
        'id': '2',
        'fileName': 'agent_data_mar2024.csv',
        'status': 'processing',
        'records': 156,
        'date': '2024-01-14',
      },
      {
        'id': '3',
        'fileName': 'policy_updates_feb.xlsx',
        'status': 'failed',
        'records': 0,
        'date': '2024-01-13',
      },
    ];

    if (_selectedFilter == 'all') {
      return allImports;
    }

    return allImports.where((import) => import['status'] == _selectedFilter).toList();
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('LIC API Sync'),
        content: const Text('This will sync data from LIC API. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start sync
            },
            child: const Text('Sync'),
          ),
        ],
      ),
    );
  }

  void _showBulkUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Update'),
        content: const Text('Select records to update in bulk.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Open bulk update page
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

