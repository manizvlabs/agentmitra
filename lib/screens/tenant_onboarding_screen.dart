import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/tenant_management/presentation/viewmodels/tenant_management_viewmodel.dart';
import '../shared/theme/app_theme.dart';
import '../shared/constants/app_constants.dart';

class TenantOnboardingScreen extends StatefulWidget {
  const TenantOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<TenantOnboardingScreen> createState() => _TenantOnboardingScreenState();
}

class _TenantOnboardingScreenState extends State<TenantOnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TenantManagementViewModel.simple(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tenant Management'),
          backgroundColor: AppTheme.vyaptixBlue,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Create Tenant', icon: Icon(Icons.add_business)),
              Tab(text: 'Manage Tenants', icon: Icon(Icons.business_center)),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCreateTenantTab(),
            _buildManageTenantsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateTenantTab() {
    return Consumer<TenantManagementViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Tenant',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.vyaptixBlue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Provision a new tenant with automated admin user setup',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (viewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => viewModel.clearError(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Tenant Information Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tenant Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tenant Code
                      TextFormField(
                        controller: viewModel.tenantCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Tenant Code *',
                          hintText: 'e.g., HDFC_LIFE, ICICI_PRU',
                          helperText: 'Unique identifier, uppercase letters/numbers/underscores only',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),

                      // Tenant Name
                      TextFormField(
                        controller: viewModel.tenantNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tenant Name *',
                          hintText: 'Full organization name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tenant Type
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedTenantType,
                        decoration: const InputDecoration(
                          labelText: 'Tenant Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: viewModel.tenantTypeOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) => viewModel.updateTenantType(value!),
                      ),
                      const SizedBox(height: 16),

                      // Subscription Plan
                      DropdownButtonFormField<String>(
                        value: viewModel.selectedSubscriptionPlan,
                        decoration: const InputDecoration(
                          labelText: 'Subscription Plan',
                          border: OutlineInputBorder(),
                        ),
                        items: viewModel.subscriptionPlanOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: (value) => viewModel.updateSubscriptionPlan(value!),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Configuration Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Max Users
                      Row(
                        children: [
                          Expanded(
                            child: Text('Max Users: ${viewModel.maxUsers}'),
                          ),
                          Expanded(
                            child: Slider(
                              value: viewModel.maxUsers.toDouble(),
                              min: 10,
                              max: 10000,
                              divisions: 99,
                              label: viewModel.maxUsers.toString(),
                              onChanged: (value) => viewModel.updateMaxUsers(value.toInt()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Storage Limit
                      Row(
                        children: [
                          Expanded(
                            child: Text('Storage: ${viewModel.storageLimitGb} GB'),
                          ),
                          Expanded(
                            child: Slider(
                              value: viewModel.storageLimitGb.toDouble(),
                              min: 1,
                              max: 1000,
                              divisions: 99,
                              label: '${viewModel.storageLimitGb} GB',
                              onChanged: (value) => viewModel.updateStorageLimit(value.toInt()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // API Rate Limit
                      Row(
                        children: [
                          Expanded(
                            child: Text('API Rate Limit: ${viewModel.apiRateLimit}/hour'),
                          ),
                          Expanded(
                            child: Slider(
                              value: viewModel.apiRateLimit.toDouble(),
                              min: 100,
                              max: 100000,
                              divisions: 999,
                              label: '${viewModel.apiRateLimit}/hour',
                              onChanged: (value) => viewModel.updateApiRateLimit(value.toInt()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Admin User Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrator Setup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This user will be assigned Super Admin role for the new tenant',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 16),

                      // Admin Phone
                      TextFormField(
                        controller: viewModel.adminPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Phone Number *',
                          hintText: '+91XXXXXXXXXX',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Admin Email
                      TextFormField(
                        controller: viewModel.adminEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Email',
                          hintText: 'admin@company.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Admin First Name
                      TextFormField(
                        controller: viewModel.adminFirstNameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin First Name',
                          hintText: 'John',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Admin Last Name
                      TextFormField(
                        controller: viewModel.adminLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Admin Last Name',
                          hintText: 'Doe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Email
                      TextFormField(
                        controller: viewModel.contactEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Email',
                          hintText: 'contact@company.com',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Contact Phone
                      TextFormField(
                        controller: viewModel.contactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          hintText: '+91XXXXXXXXXX',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Tenant Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: viewModel.isCreatingTenant
                      ? null
                      : () async {
                          final result = await viewModel.createTenant();
                          if (result != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tenant created successfully! Admin user provisioned.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _tabController.animateTo(1); // Switch to manage tab
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vyaptixBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: viewModel.isCreatingTenant
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Tenant',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManageTenantsTab() {
    return Consumer<TenantManagementViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingTenants) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.tenants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business_center, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No tenants found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first tenant using the Create Tenant tab',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vyaptixBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Tenant'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.loadTenants,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.tenants.length,
            itemBuilder: (context, index) {
              final tenant = viewModel.tenants[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tenant.tenantName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  tenant.tenantCode,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(tenant.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.category,
                            _getTenantTypeLabel(tenant.tenantType),
                          ),
                          const SizedBox(width: 8),
                          if (tenant.subscriptionPlan != null)
                            _buildInfoChip(
                              Icons.star,
                              tenant.subscriptionPlan!,
                            ),
                          const SizedBox(width: 8),
                          if (tenant.maxUsers != null)
                            _buildInfoChip(
                              Icons.people,
                              '${tenant.maxUsers} users',
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (tenant.contactEmail != null || tenant.contactPhone != null)
                        Row(
                          children: [
                            if (tenant.contactEmail != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.email, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tenant.contactEmail!,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (tenant.contactPhone != null)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        tenant.contactPhone!,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      if (tenant.createdAt != null)
                        Text(
                          'Created: ${_formatDate(tenant.createdAt!)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'inactive':
        color = Colors.red;
        label = 'Inactive';
        break;
      case 'provisioning':
        color = Colors.orange;
        label = 'Provisioning';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.blue.shade50,
      padding: EdgeInsets.zero,
    );
  }

  String _getTenantTypeLabel(String tenantType) {
    switch (tenantType) {
      case 'insurance_provider':
        return 'Insurance Provider';
      case 'independent_agent':
        return 'Independent Agent';
      case 'agent_network':
        return 'Agent Network';
      default:
        return tenantType;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
