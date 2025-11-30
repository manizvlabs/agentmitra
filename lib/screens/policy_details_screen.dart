import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../features/payments/presentation/viewmodels/policy_detail_viewmodel.dart';
import '../features/payments/presentation/viewmodels/policies_viewmodel.dart';
import '../features/payments/data/repositories/policy_repository.dart';
import '../features/payments/data/datasources/policy_remote_datasource.dart';
import '../features/payments/data/datasources/policy_local_datasource.dart';
import '../features/payments/data/models/policy_model.dart';

class PolicyDetailsScreen extends ConsumerStatefulWidget {
  const PolicyDetailsScreen({super.key});

  @override
  ConsumerState<PolicyDetailsScreen> createState() => _PolicyDetailsScreenState();
}

class _PolicyDetailsScreenState extends ConsumerState<PolicyDetailsScreen> {
  PolicyDetailViewModel? _viewModel;
  Policy? _selectedPolicy;

  @override
  void initState() {
    super.initState();

    // Check for navigation arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments;
        String? policyId;

        if (args is Map<String, dynamic> && args.containsKey('policyId')) {
          policyId = args['policyId'] as String?;
        }

        // Load policies
        context.read<PoliciesViewModel>().loadPolicies();

        // If a specific policy was requested, find and select it
        if (policyId != null) {
          _selectPolicyById(policyId);
        }
      }
    });
  }

  void _selectPolicyById(String policyId) {
    final policiesViewModel = context.read<PoliciesViewModel>();
    final policies = policiesViewModel.policies;

    // Find the policy by ID
    Policy? policy;
    try {
      policy = policies.firstWhere((p) => p.policyId == policyId);
    } catch (e) {
      policy = null;
    }

    if (policy != null) {
      setState(() {
        _selectedPolicy = policy;
        _viewModel = _createViewModel(policy!.policyId);
      });
    }
  }

  PolicyDetailViewModel _createViewModel(String policyId) {
    final repository = PolicyRepository(
      PolicyRemoteDataSourceImpl(),
      PolicyLocalDataSourceImpl(),
    );
    return PolicyDetailViewModel(repository, policyId);
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policiesViewModel = context.watch<PoliciesViewModel>();
    final policies = policiesViewModel.policies;
    final isLoadingPolicies = policiesViewModel.isLoading;

    // If we have a policyId from navigation but haven't selected it yet, try to select it
    if (_selectedPolicy == null && policies.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map<String, dynamic> && args.containsKey('policyId')) {
          final policyId = args['policyId'] as String?;
          if (policyId != null) {
            _selectPolicyById(policyId);
          }
        }
      });
    }

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
            'Policy Details',
            style: TextStyle(
              color: Color(0xFF1a237e),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            provider.Consumer<PolicyDetailViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.download, color: Color(0xFF1a237e)),
                  onPressed: viewModel.policy != null
                      ? () => _downloadDocuments(context, viewModel.policy!)
                      : null,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF1a237e)),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
        body: isLoadingPolicies
            ? const Center(child: CircularProgressIndicator())
            : policies.isEmpty
                ? _buildNoPoliciesState()
                : _selectedPolicy != null && _viewModel != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: provider.ChangeNotifierProvider.value(
                          value: _viewModel!,
                          child: provider.Consumer<PolicyDetailViewModel>(
                            builder: (context, viewModel, child) {
                            if (viewModel.isLoading && viewModel.policy == null) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (viewModel.error != null && viewModel.policy == null) {
                              return _buildPolicyErrorState(viewModel);
                            }

                            final policy = viewModel.policy;
                            if (policy == null) {
                              return const Center(child: Text('Policy not found'));
                            }

                            return _buildPolicyDetailsContent(policy, viewModel);
                          }),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPolicySelector(policies),
                            const SizedBox(height: 16),
                            if (_selectedPolicy != null && _viewModel != null) ...[
                          provider.ChangeNotifierProvider.value(
                            value: _viewModel!,
                            child: provider.Consumer<PolicyDetailViewModel>(
                              builder: (context, viewModel, child) {
                              if (viewModel.isLoading && viewModel.policy == null) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (viewModel.error != null && viewModel.policy == null) {
                                return _buildPolicyErrorState(viewModel);
                              }

                              final policy = viewModel.policy;
                              if (policy == null) {
                                return const Center(child: Text('Policy not found'));
                              }

                              return _buildPolicyDetailsContent(policy, viewModel);
                              },
                            ),
                          ),
                        ] else ...[
                          _buildSelectPolicyPrompt(),
                        ],
                      ],
                    ),
                  ),
    );
  }

  Widget _buildPolicySelector(List<Policy> policies) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Policy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a237e),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Policy>(
            value: _selectedPolicy,
            hint: const Text('Choose a policy to view details'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: policies.map((policy) {
              return DropdownMenuItem<Policy>(
                value: policy,
                child: Text('${policy.policyNumber} - ${policy.planName}'),
              );
            }).toList(),
            onChanged: (Policy? newValue) {
              setState(() {
                _selectedPolicy = newValue;
                if (newValue != null) {
                  _viewModel = _createViewModel(newValue.policyId);
                  _viewModel?.loadPolicyDetails();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoPoliciesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.policy_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          const Text(
            'No Policies Taken Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You haven\'t purchased any insurance policies yet.\nContact an agent to get started with your insurance journey.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/get-quote'),
            icon: const Icon(Icons.add),
            label: const Text('Get Insurance Quote'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a237e),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectPolicyPrompt() {
    return Container(
      padding: const EdgeInsets.all(40),
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
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.policy, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select a policy from the dropdown above to view its details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyErrorState(PolicyDetailViewModel viewModel) {
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
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load policy details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.refresh(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaturityCountdownBanner(DateTime maturityDate, int daysUntilMaturity) {
    final years = daysUntilMaturity ~/ 365;
    final months = (daysUntilMaturity % 365) ~/ 30;
    final days = daysUntilMaturity % 30;
    final isNearMaturity = daysUntilMaturity <= 365;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isNearMaturity
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isNearMaturity ? Colors.orange : Colors.blue).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isNearMaturity ? Icons.warning : Icons.calendar_today,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNearMaturity ? 'Maturity Approaching!' : 'Maturity Countdown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(maturityDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$years years',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$months months $days days',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyDetailsContent(Policy policy, PolicyDetailViewModel viewModel) {
    final maturityDate = policy.maturityDate ?? DateTime.now().add(const Duration(days: 365 * 20));
    final nextPaymentDate = policy.nextPaymentDate ?? DateTime.now().add(const Duration(days: 30));
    final daysUntilMaturity = maturityDate.difference(DateTime.now()).inDays;

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Policy Header Card
            _buildPolicyHeaderCard(policy),
            const SizedBox(height: 24),

            // Maturity Countdown Banner (if applicable)
            if (daysUntilMaturity <= 365 * 2)
              _buildMaturityCountdownBanner(maturityDate, daysUntilMaturity),

            // Premium & Payment Section
            _buildPremiumSection(policy, nextPaymentDate, viewModel),
            const SizedBox(height: 24),

            // Payment History Timeline
            _buildPaymentHistorySection(viewModel),
            const SizedBox(height: 24),

            // Coverage & Benefits
            _buildCoverageSection(policy, maturityDate, daysUntilMaturity),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context, policy, viewModel),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyHeaderCard(policy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a237e), Color(0xFF3949ab)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '📄 Policy No: ${policy.policyNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildStatusBadge(policy.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '📋 Plan: ${policy.planName}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'Start Date: ${_formatDate(policy.startDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Active';
        break;
      case 'pending_approval':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'lapsed':
        color = Colors.red;
        text = 'Lapsed';
        break;
      case 'matured':
        color = Colors.blue;
        text = 'Matured';
        break;
      case 'cancelled':
        color = Colors.grey;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(policy, DateTime nextPaymentDate, PolicyDetailViewModel viewModel) {
    final isDueSoon = nextPaymentDate.difference(DateTime.now()).inDays <= 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💰 Premium & Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Premium Amount',
                '₹${policy.premiumAmount.toStringAsFixed(0)}',
                null,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                'Next Due Date',
                _formatDate(nextPaymentDate),
                isDueSoon ? Colors.red : null,
              ),
              if (isDueSoon) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment due soon! Please pay to avoid policy lapse.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(height: 24),
              _buildInfoRow('Payment Frequency', policy.premiumFrequency, null),
              const Divider(height: 24),
              _buildInfoRow('Payment Mode', policy.premiumMode ?? 'Manual', Colors.green),
              if (policy.outstandingAmount != null && policy.outstandingAmount! > 0) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  'Outstanding Amount',
                  '₹${policy.outstandingAmount!.toStringAsFixed(0)}',
                  Colors.red,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistorySection(PolicyDetailViewModel viewModel) {
    final payments = viewModel.premiums.take(5).toList(); // Show last 5 payments

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📊 Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full payment history
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: payments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.payment, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'No payment history available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: payments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final payment = entry.value;
                    final isLast = index == payments.length - 1;
                    final isPaid = payment.status == 'completed' || payment.status == 'success';

                    return Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${payment.amount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isPaid ? 'Paid' : payment.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isPaid ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(payment.paymentDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (payment.transactionId != null)
                                Text(
                                  'TXN: ${payment.transactionId}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildCoverageSection(policy, DateTime maturityDate, int daysUntilMaturity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👥 Coverage & Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Sum Assured',
                '₹${policy.sumAssured.toStringAsFixed(0)}',
                Colors.green,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Maturity Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDate(maturityDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a237e),
                        ),
                      ),
                      Text(
                        '${(daysUntilMaturity / 365).toStringAsFixed(1)} years remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, policy, PolicyDetailViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Pay Premium',
                Icons.payment,
                Colors.blue,
                () => Navigator.of(context).pushNamed('/premium-payment'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Contact Agent',
                Icons.phone,
                Colors.green,
                () => Navigator.of(context).pushNamed('/whatsapp-integration'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'File Claim',
                Icons.assignment,
                Colors.orange,
                () => Navigator.of(context).pushNamed('/claims/new'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Download Docs',
                Icons.download,
                Colors.purple,
                () => _downloadDocuments(context, policy),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color? valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? const Color(0xFF1a237e),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _downloadDocuments(BuildContext context, policy) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Download Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 16),
            if (policy.policyDocumentUrl != null)
              ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('Policy Document'),
                subtitle: const Text('PDF format'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  Navigator.pop(context);
                  _downloadFile(context, policy.policyDocumentUrl!, 'Policy_Document_${policy.policyNumber}.pdf');
                },
              ),
            if (policy.applicationFormUrl != null)
              ListTile(
                leading: const Icon(Icons.description, color: Colors.green),
                title: const Text('Application Form'),
                subtitle: const Text('PDF format'),
                trailing: const Icon(Icons.download),
                onTap: () {
                  Navigator.pop(context);
                  _downloadFile(context, policy.applicationFormUrl!, 'Application_Form_${policy.policyNumber}.pdf');
                },
              ),
            if (policy.policyDocumentUrl == null && policy.applicationFormUrl == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No documents available for download',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _downloadFile(BuildContext context, String url, String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $fileName...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Open downloaded file
          },
        ),
      ),
    );
    // TODO: Implement actual file download using url_launcher or http package
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Policy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print Policy'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement print
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Policy Information'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show policy info
              },
            ),
          ],
        ),
      ),
    );
  }
}
