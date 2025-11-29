import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/offline_indicator.dart';
import '../core/services/whatsapp_business_service.dart';
import '../features/payments/presentation/viewmodels/policies_viewmodel.dart';
import '../features/payments/data/models/policy_model.dart';
import '../features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import '../features/notifications/data/models/notification_model.dart';
import '../core/di/service_locator.dart';

/// My Policies Screen for Agent App
/// Displays policy information, client management, and segmentation tools
class MyPoliciesScreen extends StatefulWidget {
  const MyPoliciesScreen({super.key});

  @override
  State<MyPoliciesScreen> createState() => _MyPoliciesScreenState();
}

class _MyPoliciesScreenState extends State<MyPoliciesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Load real data using view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PoliciesViewModel>().loadPolicies();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final policiesViewModel = context.watch<PoliciesViewModel>();
    final policies = policiesViewModel.policies;
    final isLoading = policiesViewModel.isLoading;

    // Use policies from viewmodel (already filtered by search and status)
    final filteredPolicies = policies;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(filteredPolicies.length, policies.length, policiesViewModel),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<PoliciesViewModel>().loadPolicies();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar (when searching)
                    if (_isSearching) _buildSearchBar(),

                    // Loading State
                    if (isLoading && policies.isEmpty) _buildLoadingState(),

                    // Policy List (when loaded)
                    if (!isLoading || policies.isNotEmpty) ...[
                      _buildPolicyOverview(policies),
                      const SizedBox(height: 24),
                      _buildPolicyList(filteredPolicies),
                      const SizedBox(height: 24),
                      _buildClientManagement(),
                      const SizedBox(height: 24),
                      _buildClientSegmentation(),
                    ],

                    const SizedBox(height: 24),

                    // Offline indicator
                    const OfflineIndicator(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(int filteredCount, int totalCount, PoliciesViewModel viewModel) {
    // Build filter chips for active filters
    final activeFilters = <Widget>[];
    if (viewModel.selectedStatus != null) {
      activeFilters.add(_buildFilterChip(
        'Status: ${viewModel.selectedStatus!.replaceAll('_', ' ').toUpperCase()}',
        () => viewModel.setStatusFilter(null),
      ));
    }
    if (viewModel.selectedProviderId != null) {
      activeFilters.add(_buildFilterChip(
        'Provider: ${viewModel.selectedProviderId}',
        () => viewModel.setProviderFilter(null),
      ));
    }
    if (viewModel.selectedPolicyType != null) {
      activeFilters.add(_buildFilterChip(
        'Type: ${viewModel.selectedPolicyType!.replaceAll('_', ' ').toUpperCase()}',
        () => viewModel.setPolicyTypeFilter(null),
      ));
    }

    return AppBar(
      backgroundColor: Colors.red,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _searchQuery.isEmpty ? 'My Policies' : 'My Policies (${filteredCount}/${totalCount})',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _searchQuery = '';
              }
            });
          },
        ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              final viewModel = context.read<PoliciesViewModel>();
              _showFilterDialog(context, viewModel);
            },
          ),
      ],
      bottom: activeFilters.isNotEmpty
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: activeFilters,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search policies by number, plan, or client...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
        ),
        onChanged: (value) {
        // Update viewmodel search
        final policiesViewModel = context.read<PoliciesViewModel>();
        policiesViewModel.setSearchQuery(value.isEmpty ? null : value);
      },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red.withOpacity(0.8),
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Policy Data...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyOverview(List<Policy> policies) {
    final totalPolicies = policies.length;
    final totalCoverage = policies.fold<double>(0, (sum, policy) => sum + policy.sumAssured);
    final nextPayment = policies
        .where((policy) => policy.status == 'Active')
        .map((policy) => policy.premiumAmount)
        .fold<double>(0, (sum, premium) => sum + premium);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Policy Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildOverviewItem(
                'Active Policies',
                totalPolicies.toString(),
                Icons.policy,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildOverviewItem(
                'Total Coverage',
                '₹${(totalCoverage / 100000).round()}L',
                Icons.shield,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildOverviewItem(
                'Monthly Premium',
                '₹${nextPayment ~/ 1000}K',
                Icons.currency_rupee,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyList(List<Policy> policies) {
    if (policies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.policy, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No policies found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Policy Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: policies.length,
          itemBuilder: (context, index) {
            final policy = policies[index];
            return _buildPolicyCard(policy);
          },
        ),
      ],
    );
  }

  Widget _buildPolicyCard(Policy policy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.policy,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.policyNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      policy.planName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(policy.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  policy.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(policy.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPolicyDetail(
                  'Premium',
                  '₹${policy.premiumAmount.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                ),
              ),
              Expanded(
                child: _buildPolicyDetail(
                  'Coverage',
                  '₹${policy.sumAssured.toStringAsFixed(0)}',
                  Icons.shield,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPolicyDetail(
                  'Frequency',
                  policy.premiumFrequency,
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildPolicyDetail(
                  'Next Due',
                  policy.nextPaymentDate != null
                      ? '${policy.nextPaymentDate!.day}/${policy.nextPaymentDate!.month}/${policy.nextPaymentDate!.year}'
                      : 'N/A',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Send notification to agent about customer's interest in new policy quotations
                    await _notifyAgentOfQuoteInterest(context);
                    Navigator.of(context).pushNamed('/get-quote');
                  },
                  icon: const Icon(Icons.request_quote, size: 16),
                  label: const Text('Get Quote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final success = await WhatsAppBusinessService.sendPolicyMessage(
                      phoneNumber: '+919876543210', // Placeholder phone
                      policyNumber: policy.policyNumber,
                      policyType: policy.planName,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Policy message sent via WhatsApp!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send WhatsApp message')),
                      );
                    }
                  },
                  icon: const Icon(Icons.message, size: 16),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
      case 'pending_approval':
        return Colors.orange;
      case 'lapsed':
      case 'cancelled':
        return Colors.red;
      case 'matured':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPolicyDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientManagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Client Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Complete client profiles with personal information, family composition, and policy associations.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildManagementActions(),
        ],
      ),
    );
  }

  Widget _buildManagementActions() {
    return Column(
      children: [
        _buildManagementAction(
          'View Client Database',
          'Access complete client profiles and information',
          Icons.storage,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Client database coming soon!')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildManagementAction(
          'Add New Client',
          'Register new clients and create profiles',
          Icons.person_add,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add client feature coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildManagementAction(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSegmentation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.segment,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Client Segmentation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Organize clients into custom groups for targeted communication and analysis.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildSegmentationOptions(),
        ],
      ),
    );
  }

  Widget _buildSegmentationOptions() {
    final segments = [
      {'name': 'Age Groups', 'examples': '25-35, 35-45, 45-55, 55+', 'icon': Icons.calendar_today},
      {'name': 'Professional Categories', 'examples': 'Doctors, Engineers, Teachers', 'icon': Icons.work},
      {'name': 'Marital Status', 'examples': 'Single, Married, Divorced', 'icon': Icons.family_restroom},
      {'name': 'Family Status', 'examples': 'Nuclear, Joint, Single Parent', 'icon': Icons.groups},
      {'name': 'Community Groups', 'examples': 'Local groups and associations', 'icon': Icons.location_city},
      {'name': 'Custom Groups', 'examples': 'User-defined segments', 'icon': Icons.settings},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  segment['icon'] as IconData,
                  color: Colors.green,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      segment['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      segment['examples'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _notifyAgentOfQuoteInterest(BuildContext context) async {
    try {
      final authViewModel = ServiceLocator.authViewModel;
      await authViewModel.initialize(); // Ensure user data is loaded
      final currentUser = authViewModel.currentUser;

      if (currentUser == null) {
        // User not logged in, can't send notification
        return;
      }

      final notificationViewModel = context.read<NotificationViewModel>();
      final customerName = currentUser.fullName ?? currentUser.phoneNumber ?? 'Customer';

      // Create notification for agent's interest in new policy quotations
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'New Policy Quote Interest',
        body: '$customerName is interested in getting quotations for new insurance policies. Please follow up to provide personalized quotes.',
        timestamp: DateTime.now(),
        type: NotificationType.general,
        priority: NotificationPriority.medium,
        data: {
          'customer_id': currentUser.userId,
          'customer_name': customerName,
          'request_type': 'new_policy_quote',
          'source': 'my_policies_screen',
        },
        category: 'Customer Interest',
        senderId: currentUser.userId,
      );

      await notificationViewModel.addNotification(notification);

      // Show success message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your request has been sent to your agent!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Log error but don't show to user to avoid interrupting the flow
      debugPrint('Failed to send quote interest notification: $e');
    }
  }

  void _showFilterDialog(BuildContext context, PoliciesViewModel viewModel) {
    final statusOptions = ['active', 'pending_approval', 'lapsed', 'matured', 'cancelled'];
    final insuranceProviderOptions = ['LIC', 'ICICI Prudential', 'HDFC Life', 'Max Life', 'SBI Life', 'PNB MetLife'];
    final planTypeOptions = ['term_life', 'whole_life', 'endowment', 'ulip', 'money_back', 'pension'];

    String? selectedStatus = viewModel.selectedStatus;
    String? selectedProvider = viewModel.selectedProviderId;
    String? selectedPolicyType = viewModel.selectedPolicyType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter Policies'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Filter
                const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  hint: const Text('All Statuses'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...statusOptions.map((status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status.replaceAll('_', ' ').toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Insurance Provider Filter
                const Text('Insurance Provider', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedProvider,
                  hint: const Text('All Providers'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Providers'),
                    ),
                    ...insuranceProviderOptions.map((provider) => DropdownMenuItem<String>(
                      value: provider,
                      child: Text(provider),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedProvider = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Plan Type Filter
                const Text('Plan Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPolicyType,
                  hint: const Text('All Plan Types'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Plan Types'),
                    ),
                    ...planTypeOptions.map((type) => DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.replaceAll('_', ' ').toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPolicyType = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.setStatusFilter(selectedStatus);
                viewModel.setProviderFilter(selectedProvider);
                viewModel.setPolicyTypeFilter(selectedPolicyType);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add new policy coming soon!')),
        );
      },
    );
  }
}
