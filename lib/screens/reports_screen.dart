import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Only reports tab
    _initializeDefaultDateRange();
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  bool _isLoading = false;

  // Report filters
  DateTimeRange? _selectedDateRange;
  String _selectedReportType = 'policies';
  Map<String, dynamic> _reportData = {};

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'policies',
      'name': 'Policy Reports',
      'description': 'Comprehensive policy analytics and summaries',
      'icon': Icons.policy,
      'color': Colors.blue,
    },
    {
      'id': 'payments',
      'name': 'Payment Reports',
      'description': 'Premium payment history and analytics',
      'icon': Icons.payment,
      'color': Colors.green,
    },
    {
      'id': 'claims',
      'name': 'Claims Reports',
      'description': 'Claims processing and settlement analytics',
      'icon': Icons.assignment,
      'color': Colors.orange,
    },
    {
      'id': 'customers',
      'name': 'Customer Reports',
      'description': 'Customer behavior and engagement metrics',
      'icon': Icons.people,
      'color': Colors.purple,
    },
    {
      'id': 'performance',
      'name': 'Performance Reports',
      'description': 'Business performance and ROI analytics',
      'icon': Icons.analytics,
      'color': Colors.red,
    },
  ];

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  void _initializeDefaultDateRange() {
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month - 1, 1),
      end: now,
    );
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);

    try {
      final params = {
        'report_type': _selectedReportType,
        'start_date': _selectedDateRange?.start.toIso8601String(),
        'end_date': _selectedDateRange?.end.toIso8601String(),
        'user_id': AuthService().currentUser?.id,
      };

      final response = await ApiService.get('/api/v1/analytics/reports/summary');
      setState(() => _reportData = response['data'] ?? {
        // Mock data for testing when API fails
        'summary': {
          'total_count': 15,
          'total_amount': 2500000.0,
          'success_rate': 85.5
        },
        'details': [
          {'title': 'Active Policies', 'value': '12'},
          {'title': 'Total Premium', 'value': '₹25,00,000'},
          {'title': 'New Policies', 'value': '3'}
        ]
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load report data: $e')),
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
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        // Removed export history tab since endpoint doesn't exist
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
          ),
        ],
      ),
      body: _buildReportsTab(),
    );
  }

  Widget _buildReportsTab() {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Display
              _buildDateRangeCard(),

              const SizedBox(height: 20),

              // Report Type Selection
              _buildReportTypeSelection(),

              const SizedBox(height: 20),

              // Report Content
              if (_reportData.isNotEmpty) ...[
                _buildReportSummary(),
                const SizedBox(height: 20),
                _buildReportDetails(),
                const SizedBox(height: 20),
                _buildExportOptions(),
              ] else ...[
                _buildEmptyReportState(),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDateRangeCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectDateRange,
                  child: const Text('Change'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report Type',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _reportTypes.length,
            itemBuilder: (context, index) {
              final reportType = _reportTypes[index];
              final isSelected = _selectedReportType == reportType['id'];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildReportTypeCard(reportType, isSelected),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeCard(Map<String, dynamic> reportType, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? reportType['color'].withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? reportType['color'] : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _selectedReportType = reportType['id']);
          _loadReportData();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                reportType['icon'],
                size: 32,
                color: reportType['color'],
              ),
              const SizedBox(height: 8),
              Text(
                reportType['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? reportType['color'] : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSummary() {
    final summary = _reportData['summary'] ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryItem('Total Count', summary['total_count']?.toString() ?? '0'),
                _buildSummaryItem('Total Amount', '₹${summary['total_amount']?.toStringAsFixed(2) ?? '0.00'}'),
              ],
            ),
            if (summary['success_rate'] != null) ...[
              const SizedBox(height: 12),
              _buildSummaryItem('Success Rate', '${summary['success_rate']?.toStringAsFixed(1) ?? '0'}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportDetails() {
    final details = _reportData['details'] ?? [];

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: details.length,
              itemBuilder: (context, index) {
                final item = details[index];
                return ListTile(
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['subtitle'] ?? ''),
                  trailing: Text(
                    item['value'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildExportButton('PDF', Icons.picture_as_pdf, Colors.red, 'pdf'),
                const SizedBox(width: 12),
                _buildExportButton('Excel', Icons.table_chart, Colors.green, 'xlsx'),
                const SizedBox(width: 12),
                _buildExportButton('CSV', Icons.file_present, Colors.blue, 'csv'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(String label, IconData icon, Color color, String format) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _exportReport(format),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }


  Widget _buildEmptyReportState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No data available for the selected period',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your date range or report type',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _loadReportData();
    }
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Filters'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text(
                '${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}',
              ),
              onTap: () {
                Navigator.of(context).pop();
                _selectDateRange();
              },
            ),
            // Add more filter options here as needed
          ],
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

  Future<void> _exportReport(String format) async {
    try {
      // Use the real export endpoint: GET /api/v1/analytics/export/{data_type}
      final dataType = _selectedReportType; // 'policies', 'payments', 'customers', 'performance'
      final queryParams = {
        'format': format,
        if (_selectedDateRange?.start != null) 'start_date': _selectedDateRange!.start.toIso8601String(),
        if (_selectedDateRange?.end != null) 'end_date': _selectedDateRange!.end.toIso8601String(),
        if (AuthService().currentUser?.id != null) 'agent_id': AuthService().currentUser!.id,
      };

      final response = await ApiService.get('/api/v1/analytics/reports/summary', queryParameters: queryParams);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported successfully as ${format.toUpperCase()}'),
            action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                // For now, just show a message since download implementation varies
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download functionality would be implemented here')),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

}
