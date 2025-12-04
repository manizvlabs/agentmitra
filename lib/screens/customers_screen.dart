import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // Filter options
  final List<Map<String, dynamic>> _filterOptions = [
    {'value': 'all', 'label': 'All Customers', 'icon': Icons.people},
    {'value': 'active', 'label': 'Active Policies', 'icon': Icons.check_circle, 'color': Colors.green},
    {'value': 'pending', 'label': 'Pending Approval', 'icon': Icons.pending, 'color': Colors.orange},
    {'value': 'overdue', 'label': 'Payment Overdue', 'icon': Icons.warning, 'color': Colors.red},
    {'value': 'high_value', 'label': 'High Value', 'icon': Icons.star, 'color': Colors.amber},
    {'value': 'new', 'label': 'Recently Added', 'icon': Icons.new_releases, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = await AuthService().getCurrentUser(context);
      final response = await ApiService.get('/api/v1/users/', queryParameters: {'role': 'policyholder'});
      setState(() {
        _customers = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        // Search filter
        final matchesSearch = _searchQuery.isEmpty ||
          customer['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer['phone'].toString().contains(_searchQuery) ||
          customer['policy_number'].toString().contains(_searchQuery);

        if (!matchesSearch) return false;

        // Category filter
        switch (_selectedFilter) {
          case 'active':
            return customer['policy_status'] == 'active';
          case 'pending':
            return customer['policy_status'] == 'pending_approval';
          case 'overdue':
            return customer['payment_status'] == 'overdue';
          case 'high_value':
            return (customer['sum_assured'] ?? 0) > 500000;
          case 'new':
            final createdDate = DateTime.parse(customer['created_at']);
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            return createdDate.isAfter(thirtyDaysAgo);
          default:
            return true;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Customers'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search customers by name, phone, or policy number',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _applyFilters();
                },
              ),
            ),

            // Filter Chips
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter['value'];

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        children: [
                          Icon(
                            filter['icon'],
                            size: 16,
                            color: isSelected ? Colors.white : filter['color'],
                          ),
                          const SizedBox(width: 4),
                          Text(filter['label']),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = selected ? filter['value'] : 'all');
                        _applyFilters();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: filter['color'],
                      checkmarkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),

            // Customer Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${_filteredCustomers.length} customers',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),

            // Customer List
            Expanded(
              child: _filteredCustomers.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadCustomers,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerDialog(),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Customer', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer) {
    final status = customer['policy_status'] ?? 'unknown';
    final paymentStatus = customer['payment_status'] ?? 'unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _showCustomerDetails(customer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      customer['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          customer['phone'] ?? '',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusBadge(status, 'policy'),
                      const SizedBox(height: 4),
                      _buildStatusBadge(paymentStatus, 'payment'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCustomerMetric(
                      'Policy',
                      customer['policy_number'] ?? 'N/A',
                      Icons.policy,
                    ),
                  ),
                  Expanded(
                    child: _buildCustomerMetric(
                      'Sum Assured',
                      '₹${(customer['sum_assured'] ?? 0).toStringAsFixed(0)}',
                      Icons.account_balance_wallet,
                    ),
                  ),
                  Expanded(
                    child: _buildCustomerMetric(
                      'Premium',
                      '₹${(customer['premium_amount'] ?? 0).toStringAsFixed(0)}',
                      Icons.payments,
                    ),
                  ),
                ],
              ),
              if (customer['last_payment_date'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last payment: ${customer['last_payment_date']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String type) {
    Color color;
    String label;

    if (type == 'policy') {
      switch (status) {
        case 'active':
          color = Colors.green;
          label = 'Active';
          break;
        case 'pending_approval':
          color = Colors.orange;
          label = 'Pending';
          break;
        case 'expired':
          color = Colors.red;
          label = 'Expired';
          break;
        default:
          color = Colors.grey;
          label = 'Unknown';
      }
    } else {
      // Payment status
      switch (status) {
        case 'paid':
          color = Colors.green;
          label = 'Paid';
          break;
        case 'overdue':
          color = Colors.red;
          label = 'Overdue';
          break;
        case 'pending':
          color = Colors.orange;
          label = 'Pending';
          break;
        default:
          color = Colors.grey;
          label = 'Unknown';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCustomerMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'all' ? Icons.people_outline : Icons.filter_list,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
              ? 'No customers found'
              : 'No customers match the selected filter',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
              ? 'Your customers will appear here once you add them'
              : 'Try adjusting your filters to see more results',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_selectedFilter != 'all')
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedFilter = 'all');
                _applyFilters();
              },
              child: const Text('Show All Customers'),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Customers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Row(
                children: [
                  Icon(filter['icon'], color: filter['color'], size: 20),
                  const SizedBox(width: 8),
                  Text(filter['label']),
                ],
              ),
              value: filter['value'],
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                _applyFilters();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
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

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _buildCustomerDetailsSheet(customer, scrollController),
      ),
    );
  }

  Widget _buildCustomerDetailsSheet(Map<String, dynamic> customer, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  customer['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer['name'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      customer['phone'] ?? '',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailSection('Policy Information', [
                  _buildDetailRow('Policy Number', customer['policy_number'] ?? 'N/A'),
                  _buildDetailRow('Policy Type', customer['policy_type'] ?? 'N/A'),
                  _buildDetailRow('Sum Assured', '₹${(customer['sum_assured'] ?? 0).toStringAsFixed(2)}'),
                  _buildDetailRow('Premium Amount', '₹${(customer['premium_amount'] ?? 0).toStringAsFixed(2)}'),
                  _buildDetailRow('Policy Status', customer['policy_status'] ?? 'Unknown'),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('Payment Information', [
                  _buildDetailRow('Payment Status', customer['payment_status'] ?? 'Unknown'),
                  _buildDetailRow('Last Payment', customer['last_payment_date'] ?? 'N/A'),
                  _buildDetailRow('Next Due Date', customer['next_due_date'] ?? 'N/A'),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('Contact Information', [
                  _buildDetailRow('Email', customer['email'] ?? 'Not provided'),
                  _buildDetailRow('Address', customer['address'] ?? 'Not provided'),
                  _buildDetailRow('Date of Birth', customer['date_of_birth'] ?? 'Not provided'),
                ]),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactCustomer(customer),
                        icon: const Icon(Icons.call, color: Colors.white),
                        label: const Text('Contact', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendReminder(customer),
                        icon: const Icon(Icons.notifications, color: Colors.white),
                        label: const Text('Send Reminder', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: const Text('Customer addition feature will be available soon. You can add customers through the web portal for now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _contactCustomer(Map<String, dynamic> customer) {
    // Implement contact functionality (WhatsApp, call, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting ${customer['name']}...')),
    );
  }

  void _sendReminder(Map<String, dynamic> customer) {
    // Implement reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending payment reminder to ${customer['name']}...')),
    );
  }
}
