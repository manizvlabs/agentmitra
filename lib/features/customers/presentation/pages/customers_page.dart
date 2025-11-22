import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/customer_viewmodel.dart';
import '../../data/models/customer_model.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerViewModel>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<CustomerViewModel>().loadMoreCustomers();
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
          'Customers',
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
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.customers.isEmpty) {
            return _buildErrorView(viewModel);
          }

          if (viewModel.customers.isEmpty) {
            return _buildEmptyView();
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshCustomers,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.customers.length +
                  (viewModel.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.customers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final customer = viewModel.customers[index];
                return _buildCustomerCard(customer);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(CustomerViewModel viewModel) {
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
            'Failed to load customers',
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
            onPressed: viewModel.refreshCustomers,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first customer',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1a237e).withOpacity(0.1),
          child: Text(
            customer.fullName.isNotEmpty
                ? customer.fullName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFF1a237e),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phoneNumber != null)
              Text(
                customer.phoneNumber!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            if (customer.email != null)
              Text(
                customer.email!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          // TODO: Navigate to customer detail page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${customer.fullName}')),
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Customers'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter name, phone, or email',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<CustomerViewModel>().clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CustomerViewModel>().setSearchQuery(
                    _searchController.text.isEmpty
                        ? null
                        : _searchController.text,
                  );
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Customers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String?>(
                value: null,
                groupValue: context.read<CustomerViewModel>().statusFilter,
                onChanged: (value) {
                  context.read<CustomerViewModel>().setStatusFilter(null);
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Active'),
              leading: Radio<String?>(
                value: 'active',
                groupValue: context.read<CustomerViewModel>().statusFilter,
                onChanged: (value) {
                  context.read<CustomerViewModel>().setStatusFilter('active');
                  Navigator.of(context).pop();
                },
              ),
            ),
            ListTile(
              title: const Text('Inactive'),
              leading: Radio<String?>(
                value: 'inactive',
                groupValue: context.read<CustomerViewModel>().statusFilter,
                onChanged: (value) {
                  context.read<CustomerViewModel>().setStatusFilter('inactive');
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

