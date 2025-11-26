import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/policies_viewmodel.dart';
import '../widgets/policy_card.dart';
import '../widgets/policy_filters.dart';
import '../../../../core/widgets/loading/empty_state_card.dart';

class PoliciesListPage extends StatefulWidget {
  const PoliciesListPage({super.key});

  @override
  State<PoliciesListPage> createState() => _PoliciesListPageState();
}

class _PoliciesListPageState extends State<PoliciesListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoliciesViewModel>().loadPolicies();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<PoliciesViewModel>().loadMorePolicies();
    }
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
          'My Policies',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1a237e)),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: Consumer<PoliciesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.policies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.policies.isEmpty) {
            return _buildErrorView(viewModel);
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshPolicies,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildSearchBar(viewModel),
                  ),
                ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: _buildFilterChips(viewModel),
                ),

                // Summary Cards
                SliverToBoxAdapter(
                  child: _buildSummaryCards(viewModel),
                ),

                // Policies List
                if (viewModel.policies.isEmpty)
                  SliverFillRemaining(
                    child: EmptyStateCard(
                      icon: Icons.description,
                      title: 'No Policies Found',
                      message: _selectedFilter != null
                          ? 'No policies match your filter criteria. Try a different filter.'
                          : 'You don\'t have any policies yet. Get a quote to start!',
                      actionLabel: 'Get Quote',
                      onAction: () => context.push('/get-quote'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == viewModel.policies.length) {
                            return viewModel.hasMorePages
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          final policy = viewModel.policies[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PolicyCard(
                              policy: policy,
                              onTap: () => _navigateToPolicyDetail(policy.policyId),
                            ),
                          );
                        },
                        childCount: viewModel.policies.length + (viewModel.hasMorePages ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/get-quote'),
        backgroundColor: const Color(0xFF1a237e),
        icon: const Icon(Icons.request_quote, color: Colors.white),
        label: const Text(
          'Get Quote',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSearchBar(PoliciesViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search policies by number or name...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.setSearchQuery(null);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              viewModel.setSearchQuery(value.isEmpty ? null : value);
            }
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(PoliciesViewModel viewModel) {
    final filters = [
      {'label': 'All', 'value': null},
      {'label': 'Active', 'value': 'active'},
      {'label': 'Maturing', 'value': 'maturing'},
      {'label': 'Lapsed', 'value': 'lapsed'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter['value'] as String? : null;
                });
                viewModel.setStatusFilter(_selectedFilter);
              },
              selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
              checkmarkColor: const Color(0xFF1a237e),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF1a237e)
                    : Colors.grey.shade300,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(PoliciesViewModel viewModel) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            'Active',
            viewModel.activePolicies.length.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildSummaryCard(
            'Maturing',
            viewModel.policies
                .where((p) => p.maturityDate != null &&
                    p.maturityDate!.difference(DateTime.now()).inDays <= 90)
                .length
                .toString(),
            Icons.schedule,
            Colors.orange,
          ),
          _buildSummaryCard(
            'Lapsed',
            viewModel.lapsedPolicies.length.toString(),
            Icons.warning,
            Colors.red,
          ),
          _buildSummaryCard(
            'Total',
            viewModel.policies.length.toString(),
            Icons.list,
            const Color(0xFF1a237e),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildErrorView(PoliciesViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load policies',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            viewModel.error ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.refreshPolicies,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PolicyFiltersDialog(),
    );
  }

  void _navigateToPolicyDetail(String policyId) {
    context.push('/policy-details', extra: {'policyId': policyId});
  }
}
