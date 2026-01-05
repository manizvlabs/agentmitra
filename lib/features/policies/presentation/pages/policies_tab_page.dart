import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../viewmodels/policies_viewmodel.dart';
import '../widgets/policy_card.dart';
import '../../data/models/policy_models.dart';

/// Policies Tab Page - consolidates policy listing, search, and filtering
class PoliciesTabPage extends StatefulWidget {
  const PoliciesTabPage({super.key});

  @override
  State<PoliciesTabPage> createState() => _PoliciesTabPageState();
}

class _PoliciesTabPageState extends State<PoliciesTabPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late PoliciesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ServiceLocator.policiesViewModel;
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(_viewModel.state, _viewModel),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _viewModel.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar (when searching)
                if (_isSearching) _buildSearchBar(_viewModel),

                // Loading State
                if (_viewModel.state.isLoading && _viewModel.state.policies.isEmpty)
                  _buildLoadingState(),

                // Error State
                if (_viewModel.state.error != null && _viewModel.state.policies.isEmpty)
                  _buildErrorState(_viewModel.state.error!, _viewModel),

                // Content
                if (!_viewModel.state.isLoading || _viewModel.state.policies.isNotEmpty) ...[
                  _buildPolicyOverview(_viewModel.state.policies),
                  const SizedBox(height: 24),
                  _buildPolicyList(_viewModel.state, _viewModel),
                ],

                const SizedBox(height: 24),

                // Load More Button
                if (_viewModel.state.hasMoreData && !_viewModel.state.isLoading && !_viewModel.state.isLoadingMore)
                  _buildLoadMoreButton(_viewModel),

                // Loading More Indicator
                if (_viewModel.state.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(PoliciesState state, PoliciesViewModel viewModel) {
    final filteredCount = state.policies.length;
    final activeFilters = _getActiveFilters(state.filters);

    return AppBar(
      backgroundColor: Colors.red,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _isSearching || state.filters.searchQuery != null
            ? 'Policies (${filteredCount})'
            : 'My Policies',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                viewModel.searchPolicies('');
              }
            });
          },
        ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context, _viewModel.state.filters, _viewModel),
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

  Widget _buildSearchBar(PoliciesViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && _searchController.text == value) {
              viewModel.searchPolicies(value);
            }
          });
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
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

  Widget _buildErrorState(String error, PoliciesViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Failed to load policies',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => viewModel.refresh(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyOverview(List<Policy> policies) {
    final totalPolicies = policies.length;
    final totalCoverage = policies.fold<double>(
      0,
      (sum, policy) => sum + policy.sumAssured,
    );
    final monthlyPremium = policies
        .where((policy) => policy.status == 'active')
        .fold<double>(0, (sum, policy) => sum + policy.premiumAmount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                '₹${monthlyPremium ~/ 1000}K',
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

  Widget _buildPolicyList(PoliciesState state, PoliciesViewModel viewModel) {
    if (state.policies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
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
          itemCount: state.policies.length,
          itemBuilder: (context, index) {
            final policy = state.policies[index];
            return PolicyCard(
              policy: policy,
              onTap: () => _navigateToPolicyDetail(policy),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(PoliciesViewModel viewModel) {
    return Center(
      child: ElevatedButton(
        onPressed: () => viewModel.loadMorePolicies(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Text('Load More Policies'),
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

  List<Widget> _getActiveFilters(PolicyFilters filters) {
    final chips = <Widget>[];

    if (filters.status != null) {
      final statusText = filters.status.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
      chips.add(_buildFilterChip('Status: $statusText', () => _viewModel.setStatusFilter(null)));
    }

    if (filters.policyType != null) {
      final typeText = filters.policyType.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
      chips.add(_buildFilterChip('Type: $typeText', () => _viewModel.setPolicyTypeFilter(null)));
    }

    if (filters.providerId != null) {
      chips.add(_buildFilterChip('Provider: ${filters.providerId}', () => _viewModel.setProviderFilter(null)));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      chips.add(_buildFilterChip('Search: "${filters.searchQuery}"', () => _viewModel.searchPolicies('')));
    }

    return chips;
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

  void _showFilterDialog(BuildContext context, PolicyFilters currentFilters, PoliciesViewModel viewModel) {
    PolicyStatus? selectedStatus = currentFilters.status;
    PolicyType? selectedPolicyType = currentFilters.policyType;
    String? selectedProvider = currentFilters.providerId;

    final statusOptions = ['Active', 'Pending Approval', 'Lapsed', 'Matured', 'Cancelled'];
    final insuranceProviderOptions = ['LIC', 'ICICI Prudential', 'HDFC Life', 'Max Life', 'SBI Life', 'PNB MetLife'];
    final planTypeOptions = ['term_life', 'whole_life', 'endowment', 'ulip', 'money_back', 'pension'];

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
                  value: selectedStatus?.toString().split('.').last,
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
                      value: status.replaceAll(' ', '_').toLowerCase(),
                      child: Text(status),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value != null ? PolicyStatus.values.firstWhere(
                        (status) => status.toString().split('.').last == value,
                      ) : null;
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
                  value: selectedPolicyType?.toString().split('.').last,
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
                      selectedPolicyType = value != null ? PolicyType.values.firstWhere(
                        (type) => type.toString().split('.').last == value,
                      ) : null;
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
                viewModel.setStatusFilter(selectedStatus?.toString().split('.').last);
                viewModel.setProviderFilter(selectedProvider);
                viewModel.setPolicyTypeFilter(selectedPolicyType?.toString().split('.').last);
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPolicyDetail(Policy policy) {
    // TODO: Navigate to policy detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to ${policy.policyNumber} details')),
    );
  }
}
