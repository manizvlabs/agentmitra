import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/loading_overlay.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  List<Map<String, dynamic>> _outstandingPayments = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  Map<String, dynamic>? _selectedPayment;

  // Payment Methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': Icons.account_balance_wallet,
      'description': 'Pay using UPI apps like Google Pay, PhonePe, Paytm',
      'color': Colors.blue,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, Mastercard, RuPay cards accepted',
      'color': Colors.purple,
    },
    {
      'id': 'netbanking',
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'description': 'Pay directly from your bank account',
      'color': Colors.green,
    },
    {
      'id': 'wallet',
      'name': 'Digital Wallets',
      'icon': Icons.account_balance_wallet,
      'description': 'Paytm, Mobikwik, Ola Money, etc.',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      // Load outstanding payments
      final outstandingResponse = await ApiService.get(
        '/api/v1/payments/outstanding/${AuthService().currentUser?.id}'
      );
      _outstandingPayments = List<Map<String, dynamic>>.from(outstandingResponse['data'] ?? []);

      // Load payment history
      final historyResponse = await ApiService.get(
        '/api/v1/payments/history/${AuthService().currentUser?.id}'
      );
      _paymentHistory = List<Map<String, dynamic>>.from(historyResponse['data'] ?? []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payments: $e')),
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
        title: const Text('Payments'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Outstanding'),
            Tab(text: 'History'),
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
              _buildOutstandingPaymentsTab(),
              _buildPaymentHistoryTab(),
            ],
          ),
      floatingActionButton: _outstandingPayments.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () => _showPaymentMethodSelection(context),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.payment),
            label: const Text('Pay All'),
          )
        : null,
    );
  }

  Widget _buildOutstandingPaymentsTab() {
    if (_outstandingPayments.isEmpty) {
      return _buildEmptyState(
        'No Outstanding Payments',
        'All your premiums are paid up to date!',
        Icons.check_circle,
        Colors.green,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _outstandingPayments.length,
        itemBuilder: (context, index) {
          final payment = _outstandingPayments[index];
          return _buildPaymentCard(payment, true);
        },
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    if (_paymentHistory.isEmpty) {
      return _buildEmptyState(
        'No Payment History',
        'Your payment history will appear here',
        Icons.history,
        Colors.grey,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentHistory.length,
        itemBuilder: (context, index) {
          final payment = _paymentHistory[index];
          return _buildPaymentCard(payment, false);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, bool isOutstanding) {
    final amount = payment['amount'] ?? 0.0;
    final dueDate = payment['due_date'] ?? payment['payment_date'];
    final policyNumber = payment['policy_number'] ?? 'N/A';
    final status = payment['status'] ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Policy: $policyNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 4),
            Text(
              isOutstanding ? 'Due Date: $dueDate' : 'Paid on: $dueDate',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            if (isOutstanding) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _initiatePayment(payment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'due':
        return Colors.orange;
      case 'failed':
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _initiatePayment(Map<String, dynamic> payment) {
    setState(() => _selectedPayment = payment);
    _showPaymentMethodSelection(context);
  }

  void _showPaymentMethodSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _buildPaymentMethodSheet(scrollController),
      ),
    );
  }

  Widget _buildPaymentMethodSheet(ScrollController scrollController) {
    final totalAmount = _selectedPayment != null
      ? _selectedPayment!['amount']
      : _outstandingPayments.fold(0.0, (sum, payment) => sum + (payment['amount'] ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return _buildPaymentMethodTile(method);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: method['color'].withOpacity(0.1),
          child: Icon(method['icon'], color: method['color']),
        ),
        title: Text(
          method['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(method['description']),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _processPayment(method),
      ),
    );
  }

  Future<void> _processPayment(Map<String, dynamic> method) async {
    Navigator.of(context).pop(); // Close payment method sheet

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingOverlay(isLoading: true),
    );

    try {
      // Prepare payment data
      final paymentData = {
        'payment_method': method['id'],
        'amount': _selectedPayment?['amount'] ??
                 _outstandingPayments.fold(0.0, (sum, payment) => sum + (payment['amount'] ?? 0.0)),
        'user_id': AuthService().currentUser?.id,
        'payment_type': _selectedPayment != null ? 'single' : 'bulk',
        'items': _selectedPayment != null ? [_selectedPayment] : _outstandingPayments,
      };

      // Process payment
      final response = await ApiService.post('/api/v1/payments/process', paymentData);

      Navigator.of(context).pop(); // Close loading overlay

      if (response['success'] == true) {
        _showPaymentSuccessDialog(response['data']);
      } else {
        _showPaymentFailureDialog(response['message'] ?? 'Payment failed');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading overlay
      _showPaymentFailureDialog('Payment failed: $e');
    }
  }

  void _showPaymentSuccessDialog(Map<String, dynamic> paymentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount Paid: ₹${paymentData['amount']?.toStringAsFixed(2)}'),
            Text('Transaction ID: ${paymentData['transaction_id']}'),
            Text('Payment Method: ${paymentData['payment_method']}'),
            if (paymentData['receipt_url'] != null)
              const Text('Receipt has been sent to your email'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadPayments(); // Refresh payment data
            },
            child: const Text('Done'),
          ),
          if (paymentData['receipt_url'] != null)
            ElevatedButton(
              onPressed: () {
                // Open receipt URL
                Navigator.of(context).pop();
              },
              child: const Text('View Receipt'),
            ),
        ],
      ),
    );
  }

  void _showPaymentFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retry'),
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
