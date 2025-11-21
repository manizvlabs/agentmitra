import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/policies_viewmodel.dart';

class PolicyFiltersDialog extends StatefulWidget {
  const PolicyFiltersDialog({super.key});

  @override
  State<PolicyFiltersDialog> createState() => _PolicyFiltersDialogState();
}

class _PolicyFiltersDialogState extends State<PolicyFiltersDialog> {
  String? _selectedStatus;
  String? _selectedProvider;
  String? _selectedPlanType;

  final List<String> _statusOptions = [
    'active',
    'pending_approval',
    'lapsed',
    'matured',
    'cancelled',
  ];

  final List<String> _providerOptions = [
    'LIC',
    'HDFC Life',
    'ICICI Prudential',
    'SBI Life',
  ];

  final List<String> _planTypeOptions = [
    'term_life',
    'whole_life',
    'ulip',
    'endowment',
    'money_back',
  ];

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<PoliciesViewModel>();
    _selectedStatus = viewModel.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Policies'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusOptions.map((status) {
                final isSelected = _selectedStatus == status;
                return FilterChip(
                  label: Text(_formatStatus(status)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                  selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF1a237e),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Provider Filter
            const Text(
              'Insurance Provider',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _providerOptions.map((provider) {
                final isSelected = _selectedProvider == provider;
                return FilterChip(
                  label: Text(provider),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedProvider = selected ? provider : null;
                    });
                  },
                  selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF1a237e),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Plan Type Filter
            const Text(
              'Plan Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a237e),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _planTypeOptions.map((planType) {
                final isSelected = _selectedPlanType == planType;
                return FilterChip(
                  label: Text(_formatPlanType(planType)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPlanType = selected ? planType : null;
                    });
                  },
                  selectedColor: const Color(0xFF1a237e).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF1a237e),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedStatus = null;
              _selectedProvider = null;
              _selectedPlanType = null;
            });
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final viewModel = context.read<PoliciesViewModel>();

            // For now, only apply status filter as other filters need backend support
            viewModel.setStatusFilter(_selectedStatus);

            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a237e),
            foregroundColor: Colors.white,
          ),
          child: const Text('Apply Filters'),
        ),
      ],
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'pending_approval':
        return 'Pending';
      case 'lapsed':
        return 'Lapsed';
      case 'matured':
        return 'Matured';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _formatPlanType(String planType) {
    switch (planType) {
      case 'term_life':
        return 'Term Life';
      case 'whole_life':
        return 'Whole Life';
      case 'ulip':
        return 'ULIP';
      case 'endowment':
        return 'Endowment';
      case 'money_back':
        return 'Money Back';
      default:
        return planType;
    }
  }
}
