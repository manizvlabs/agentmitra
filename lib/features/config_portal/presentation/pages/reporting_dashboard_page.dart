import 'package:flutter/material.dart';

/// Reporting Dashboard Page
/// Section 5.5: Report generation, filters, export options, and scheduled reports
class ReportingDashboardPage extends StatefulWidget {
  const ReportingDashboardPage({super.key});

  @override
  State<ReportingDashboardPage> createState() => _ReportingDashboardPageState();
}

class _ReportingDashboardPageState extends State<ReportingDashboardPage> {
  String _selectedReportType = 'customer';
  DateTimeRange? _dateRange;
  String _selectedFormat = 'pdf';

  final List<Map<String, dynamic>> _reportTemplates = [
    {
      'id': '1',
      'name': 'Customer Report',
      'type': 'customer',
      'icon': Icons.people,
      'description': 'Customer data and statistics',
    },
    {
      'id': '2',
      'name': 'Policy Report',
      'type': 'policy',
      'icon': Icons.policy,
      'description': 'Policy details and premiums',
    },
    {
      'id': '3',
      'name': 'Agent Performance',
      'type': 'agent',
      'icon': Icons.trending_up,
      'description': 'Agent sales and performance',
    },
    {
      'id': '4',
      'name': 'Financial Report',
      'type': 'financial',
      'icon': Icons.account_balance,
      'description': 'Revenue and financial data',
    },
  ];

  final List<Map<String, dynamic>> _scheduledReports = [
    {
      'id': '1',
      'name': 'Weekly Customer Report',
      'type': 'customer',
      'schedule': 'Every Monday',
      'format': 'PDF',
      'recipients': ['admin@example.com'],
      'status': 'active',
    },
    {
      'id': '2',
      'name': 'Monthly Financial Summary',
      'type': 'financial',
      'schedule': '1st of every month',
      'format': 'Excel',
      'recipients': ['finance@example.com'],
      'status': 'active',
    },
  ];

  final List<Map<String, dynamic>> _reportHistory = [
    {
      'id': '1',
      'name': 'Customer Report',
      'generated': '2024-01-15 10:30',
      'format': 'PDF',
      'size': '2.5 MB',
    },
    {
      'id': '2',
      'name': 'Policy Report',
      'generated': '2024-01-14 14:20',
      'format': 'Excel',
      'size': '1.8 MB',
    },
  ];

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
          'Reporting Dashboard',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Generation Section
            _buildReportGenerationSection(),
            const SizedBox(height: 24),

            // Scheduled Reports
            _buildScheduledReportsSection(),
            const SizedBox(height: 24),

            // Report History
            _buildReportHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportGenerationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generate Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 16),

            // Report Type Selection
            const Text(
              'Report Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reportTemplates.map((template) {
                final isSelected = _selectedReportType == template['type'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(template['icon'] as IconData, size: 18),
                      const SizedBox(width: 4),
                      Text(template['name'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReportType = template['type'] as String;
                    });
                  },
                  selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Date Range Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date Range',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (range != null) {
                            setState(() {
                              _dateRange = range;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _dateRange == null
                              ? 'Select Date Range'
                              : '${_dateRange!.start.toString().split(' ')[0]} - ${_dateRange!.end.toString().split(' ')[0]}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Format',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedFormat,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: ['PDF', 'Excel', 'CSV'].map((format) {
                          return DropdownMenuItem(
                            value: format.toLowerCase(),
                            child: Text(format),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFormat = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Additional Filters
            ExpansionTile(
              title: const Text('Additional Filters'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Filter by Agent',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _generateReport();
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a237e),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Scheduled Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                _showScheduleReportDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Schedule New'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._scheduledReports.map((report) => _buildScheduledReportCard(report)),
      ],
    );
  }

  Widget _buildScheduledReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.schedule, color: Colors.blue),
        ),
        title: Text(
          report['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Schedule: ${report['schedule']}'),
            Text('Format: ${report['format']}'),
            Text('Recipients: ${(report['recipients'] as List).join(', ')}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: report['status'] == 'active',
              onChanged: (value) {
                // Toggle schedule
              },
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildReportHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Report History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        ..._reportHistory.map((report) => _buildReportHistoryCard(report)),
      ],
    );
  }

  Widget _buildReportHistoryCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            report['format'] == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
            color: Colors.green,
          ),
        ),
        title: Text(
          report['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Generated: ${report['generated']}'),
            Text('Size: ${report['size']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Download report
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Delete report
              },
            ),
          ],
        ),
      ),
    );
  }

  void _generateReport() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating report...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report generated successfully'),
          action: SnackBarAction(
            label: 'Download',
            onPressed: () {
              // Download report
            },
          ),
        ),
      );
    });
  }

  void _showScheduleReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Report'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Report Name'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Schedule (e.g., Every Monday)'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Recipients (comma-separated emails)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report scheduled successfully')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}

