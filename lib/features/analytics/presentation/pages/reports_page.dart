import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/api_service.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'Sales Report';

  final List<String> _reportTypes = [
    'Sales Report',
    'Commission Report',
    'Policy Performance',
    'Claims Analysis',
    'Customer Analytics',
    'Revenue Report',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF1a237e)),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Column(
              children: [
                // Report Type
                _buildSectionTitle('Report Type'),
                const SizedBox(height: 8),
                _buildReportTypeDropdown(),

                const SizedBox(height: 16),

                // Date Range
                _buildSectionTitle('Date Range'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: 'From: ${_formatDate(_startDate)}',
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: _endDate,
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'To: ${_formatDate(_endDate)}',
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generateReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1a237e),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Generate Report'),
                  ),
                ),
              ],
            ),
          ),

          // Report Content
          Expanded(
            child: _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1a237e),
        ),
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedReportType,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        items: _reportTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedReportType = value!;
          });
        },
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF1a237e), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    // Mock report data - replace with actual API call
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1a237e),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _selectedReportType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Policies',
                  '42',
                  Icons.policy,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  '₹2.5L',
                  Icons.currency_rupee,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Commission',
                  '₹45K',
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Growth',
                  '+12.5%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Report Details
          const Text(
            'Report Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a237e),
            ),
          ),

          const SizedBox(height: 16),

          _buildReportTable(),

          const SizedBox(height: 24),

          // Charts Section (Placeholder)
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Chart visualization will be displayed here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
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
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable() {
    // Mock table data
    final tableData = [
      {'Date': '01/12/2024', 'Policy': 'POL001', 'Amount': '₹25,000', 'Status': 'Active'},
      {'Date': '02/12/2024', 'Policy': 'POL002', 'Amount': '₹15,000', 'Status': 'Active'},
      {'Date': '03/12/2024', 'Policy': 'POL003', 'Amount': '₹30,000', 'Status': 'Pending'},
      {'Date': '04/12/2024', 'Policy': 'POL004', 'Amount': '₹20,000', 'Status': 'Active'},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
            ),
            children: [
              _buildTableCell('Date', isHeader: true),
              _buildTableCell('Policy', isHeader: true),
              _buildTableCell('Amount', isHeader: true),
              _buildTableCell('Status', isHeader: true),
            ],
          ),
          // Data rows
          ...tableData.map((row) {
            return TableRow(
              children: [
                _buildTableCell(row['Date']!),
                _buildTableCell(row['Policy']!),
                _buildTableCell(row['Amount']!),
                _buildTableCell(
                  row['Status']!,
                  color: row['Status'] == 'Active' ? Colors.green : Colors.orange,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? const Color(0xFF1a237e) : Colors.black87),
          fontSize: isHeader ? 14 : 13,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating $_selectedReportType...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Call API to generate report
    setState(() {}); // Refresh UI
  }

  void _exportReport() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // Call API to generate PDF report
                final response = await ApiService.get(
                  '/api/v1/reports/export',
                  queryParameters: {
                    'type': _selectedReportType.toLowerCase().replaceAll(' ', '_'),
                    'format': 'pdf',
                    'start_date': _startDate.toIso8601String().split('T')[0],
                    'end_date': _endDate.toIso8601String().split('T')[0],
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report exported successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to export report: $e')),
                );
              }
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // Call API to generate Excel report
                final response = await ApiService.get(
                  '/api/v1/reports/export',
                  queryParameters: {
                    'type': _selectedReportType.toLowerCase().replaceAll(' ', '_'),
                    'format': 'excel',
                    'start_date': _startDate.toIso8601String().split('T')[0],
                    'end_date': _endDate.toIso8601String().split('T')[0],
                  },
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report exported successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to export report: $e')),
                );
              }
            },
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

