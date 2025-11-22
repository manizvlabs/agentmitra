import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mocks/mock_policies_viewmodel_simple.dart';
import '../widgets/policy_card.dart';
import '../widgets/policy_filters.dart';

class PoliciesListPage extends StatefulWidget {
  const PoliciesListPage({super.key});

  @override
  State<PoliciesListPage> createState() => _PoliciesListPageState();
}

class _PoliciesListPageState extends State<PoliciesListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MockPoliciesViewModel>().loadPolicies();
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
      context.read<MockPoliciesViewModel>().loadMorePolicies();
    }
  }

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
          'My Policies',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1a237e)),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF1a237e)),
            onPressed: () => _showFiltersDialog(context),
          ),
        ],
      ),
      body: Consumer<MockPoliciesViewModel>(
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
                // Summary Cards
                SliverToBoxAdapter(
                  child: _buildSummaryCards(viewModel),
                ),

                // Policies List
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPolicy(),
        backgroundColor: const Color(0xFF1a237e),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCards(MockPoliciesViewModel viewModel) {
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
            'Pending',
            viewModel.pendingPolicies.length.toString(),
            Icons.pending,
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

  Widget _buildErrorView(MockPoliciesViewModel viewModel) {
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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Policies'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter policy number or name',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Debounced search can be implemented here
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<MockPoliciesViewModel>().clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MockPoliciesViewModel>().setSearchQuery(
                    _searchController.text.isEmpty ? null : _searchController.text,
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
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
    // TODO: Navigate to policy detail page
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => PolicyDetailPage(policyId: policyId),
    //   ),
    // );
  }

  void _navigateToAddPolicy() {
    // TODO: Navigate to add policy page
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => AddPolicyPage(),
    //   ),
    // );
  }
}
