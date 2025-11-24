import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/campaigns/presentation/viewmodels/callback_viewmodel.dart';
import '../features/campaigns/data/models/callback_model.dart';

class CallbackRequestManagement extends StatefulWidget {
  const CallbackRequestManagement({super.key});

  @override
  State<CallbackRequestManagement> createState() => _CallbackRequestManagementState();
}

class _CallbackRequestManagementState extends State<CallbackRequestManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CallbackViewModel _viewModel = CallbackViewModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Callback Requests',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1a237e),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1a237e),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'High Priority'),
            Tab(text: 'Pending'),
            Tab(text: 'Assigned'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1a237e)),
            onPressed: () => _viewModel.loadCallbacks(),
          ),
        ],
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCallbackList(_viewModel.callbacks),
                _buildCallbackList(_viewModel.highPriorityCallbacks),
                _buildCallbackList(_viewModel.pendingCallbacks),
                _buildCallbackList(_viewModel.assignedCallbacks),
              ],
            ),
    );
  }

  Widget _buildCallbackList(List<CallbackRequest> callbacks) {
    if (callbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_callback, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No callback requests',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.loadCallbacks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: callbacks.length,
        itemBuilder: (context, index) {
          final callback = callbacks[index];
          return _buildCallbackCard(callback);
        },
      ),
    );
  }

  Widget _buildCallbackCard(CallbackRequest callback) {
    Color priorityColor;
    IconData priorityIcon;
    switch (callback.priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      default:
        priorityColor = Colors.green;
        priorityIcon = Icons.arrow_downward;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showCallbackDetails(callback),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(priorityIcon, color: priorityColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          callback.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          callback.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(callback.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      callback.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(callback.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    callback.customerPhone,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    callback.requestType,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  if (callback.dueAt != null)
                    Text(
                      'Due: ${DateFormat('MMM dd, HH:mm').format(callback.dueAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: callback.dueAt!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.grey.shade600,
                        fontWeight: callback.dueAt!.isBefore(DateTime.now())
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (callback.status == 'pending')
                    OutlinedButton.icon(
                      onPressed: () => _assignCallback(callback),
                      icon: const Icon(Icons.person_add, size: 16),
                      label: const Text('Assign'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _initiateCall(callback),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (callback.status != 'completed')
                    ElevatedButton.icon(
                      onPressed: () => _completeCallback(callback),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCallbackDetails(CallbackRequest callback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Callback Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow('Customer', callback.customerName),
              _buildDetailRow('Phone', callback.customerPhone),
              if (callback.customerEmail != null)
                _buildDetailRow('Email', callback.customerEmail!),
              _buildDetailRow('Request Type', callback.requestType),
              _buildDetailRow('Priority', callback.priority.toUpperCase()),
              _buildDetailRow('Priority Score', callback.priorityScore.toStringAsFixed(1)),
              _buildDetailRow('Status', callback.status.toUpperCase()),
              if (callback.dueAt != null)
                _buildDetailRow(
                  'Due Date',
                  DateFormat('MMM dd, yyyy HH:mm').format(callback.dueAt!),
                ),
              if (callback.createdAt != null)
                _buildDetailRow(
                  'Created',
                  DateFormat('MMM dd, yyyy HH:mm').format(callback.createdAt!),
                ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(callback.description),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _initiateCall(callback);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _scheduleCallback(callback);
                      },
                      icon: const Icon(Icons.schedule),
                      label: const Text('Schedule'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
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

  Future<void> _initiateCall(CallbackRequest callback) async {
    final uri = Uri.parse('tel:${callback.customerPhone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      // Update status to assigned if pending
      if (callback.status == 'pending') {
        await _viewModel.assignCallback(callback.callbackRequestId);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make phone call')),
        );
      }
    }
  }

  Future<void> _assignCallback(CallbackRequest callback) async {
    final success = await _viewModel.assignCallback(callback.callbackRequestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Callback assigned successfully'
              : _viewModel.errorMessage ?? 'Failed to assign callback'),
        ),
      );
    }
  }

  Future<void> _completeCallback(CallbackRequest callback) async {
    final resolution = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Callback'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Resolution Notes',
            hintText: 'Enter resolution details...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Get text from TextField
              Navigator.pop(context, 'Resolved');
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (resolution != null) {
      final success = await _viewModel.completeCallback(
        callback.callbackRequestId,
        resolution: resolution,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Callback completed successfully'
                : _viewModel.errorMessage ?? 'Failed to complete callback'),
          ),
        );
      }
    }
  }

  Future<void> _scheduleCallback(CallbackRequest callback) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Callback scheduled for ${DateFormat('MMM dd, yyyy').format(date)} at ${time.format(context)}',
            ),
          ),
        );
      }
    }
  }
}

