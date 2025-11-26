import 'package:flutter/material.dart';
import '../../../../core/services/agent_service.dart';
import 'package:provider/provider.dart';
import '../../../customers/presentation/viewmodels/customer_viewmodel.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/repositories/policy_repository.dart';
import '../../data/datasources/policy_remote_datasource.dart';
import '../../data/datasources/policy_local_datasource.dart';

class NewPolicyPage extends StatefulWidget {
  const NewPolicyPage({super.key});

  @override
  State<NewPolicyPage> createState() => _NewPolicyPageState();
}

class _NewPolicyPageState extends State<NewPolicyPage> {
  final _formKey = GlobalKey<FormState>();
  final _policyNumberController = TextEditingController();
  final _planNameController = TextEditingController();
  final _sumAssuredController = TextEditingController();
  final _premiumAmountController = TextEditingController();
  
  String? _selectedCustomerId;
  Customer? _selectedCustomer;
  String _policyType = 'Life Insurance';
  String _category = 'life';
  String _premiumFrequency = 'monthly';
  String _premiumMode = 'Online';
  DateTime _applicationDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime? _maturityDate;
  bool _isSubmitting = false;

  final List<String> _policyTypes = [
    'Life Insurance',
    'Health Insurance',
    'Motor Insurance',
    'General Insurance',
  ];

  final List<String> _premiumFrequencies = ['monthly', 'quarterly', 'half_yearly', 'annual'];
  final List<String> _premiumModes = ['Online', 'Offline', 'Auto-debit'];

  @override
  void initState() {
    super.initState();
    // Load customers when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CustomerViewModel>().loadCustomers();
      }
    });
  }

  @override
  void dispose() {
    _policyNumberController.dispose();
    _planNameController.dispose();
    _sumAssuredController.dispose();
    _premiumAmountController.dispose();
    super.dispose();
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
          'New Policy',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy Type
              _buildSectionTitle('Policy Type'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _policyType,
                items: _policyTypes,
                onChanged: (value) {
                  setState(() {
                    _policyType = value!;
                    if (value.contains('Life')) {
                      _category = 'life';
                    } else if (value.contains('Health')) {
                      _category = 'health';
                    } else {
                      _category = 'general';
                    }
                  });
                },
              ),

              const SizedBox(height: 24),

              // Policy Number
              _buildSectionTitle('Policy Number *'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: _policyNumberController,
                hintText: 'Enter policy number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Policy number is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Plan Name
              _buildSectionTitle('Plan Name *'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: _planNameController,
                hintText: 'e.g., LIC Jeevan Anand',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plan name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Sum Assured
              _buildSectionTitle('Sum Assured (₹) *'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: _sumAssuredController,
                hintText: 'Enter sum assured amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Sum assured is required';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Premium Amount
              _buildSectionTitle('Premium Amount (₹) *'),
              const SizedBox(height: 8),
              _buildTextFormField(
                controller: _premiumAmountController,
                hintText: 'Enter premium amount',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Premium amount is required';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Premium Frequency
              _buildSectionTitle('Premium Frequency *'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _premiumFrequency,
                items: _premiumFrequencies.map((e) => e.replaceAll('_', ' ').toUpperCase()).toList(),
                onChanged: (value) {
                  setState(() {
                    _premiumFrequency = _premiumFrequencies[_premiumFrequencies
                        .indexWhere((e) => e.replaceAll('_', ' ').toUpperCase() == value)];
                  });
                },
              ),

              const SizedBox(height: 24),

              // Premium Mode
              _buildSectionTitle('Premium Mode'),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _premiumMode,
                items: _premiumModes,
                onChanged: (value) {
                  setState(() {
                    _premiumMode = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Application Date
              _buildSectionTitle('Application Date *'),
              const SizedBox(height: 8),
              _buildDatePicker(
                label: _formatDate(_applicationDate),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _applicationDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _applicationDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Start Date
              _buildSectionTitle('Start Date *'),
              const SizedBox(height: 8),
              _buildDatePicker(
                label: _formatDate(_startDate),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: _applicationDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),

              // Maturity Date (Optional)
              _buildSectionTitle('Maturity Date (Optional)'),
              const SizedBox(height: 8),
              _buildDatePicker(
                label: _maturityDate != null ? _formatDate(_maturityDate!) : 'Select maturity date',
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate.add(const Duration(days: 365)),
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365 * 50)),
                  );
                  if (date != null) {
                    setState(() {
                      _maturityDate = date;
                    });
                  }
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitPolicy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a237e),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Policy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a237e),
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    return Consumer<CustomerViewModel>(
      builder: (context, customerViewModel, child) {
        // Load customers if not loaded
        if (customerViewModel.customers.isEmpty && !customerViewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            customerViewModel.loadCustomers();
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCustomerId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Select a customer',
            ),
            items: customerViewModel.customers.map((customer) {
              return DropdownMenuItem(
                value: customer.userId,
                child: Text(customer.fullName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCustomerId = value;
                _selectedCustomer = customerViewModel.customers
                    .firstWhere((c) => c.userId == value);
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a customer';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1a237e), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: label.contains('Select') ? Colors.grey.shade600 : Colors.black87,
              ),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF1a237e)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submitPolicy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Get agent ID from auth context
      final agentId = await AgentService().getCurrentAgentId();
      if (agentId == null) {
        throw Exception('Agent ID not available');
      }

      final policyData = {
        'policy_number': _policyNumberController.text.trim(),
        'policyholder_id': _selectedCustomerId,
        'agent_id': agentId,
        'provider_id': 'LIC', // TODO: Get from selection
        'policy_type': _policyType,
        'plan_name': _planNameController.text.trim(),
        'plan_code': _planNameController.text.trim().toUpperCase().replaceAll(' ', '_'),
        'category': _category,
        'sum_assured': double.parse(_sumAssuredController.text),
        'premium_amount': double.parse(_premiumAmountController.text),
        'premium_frequency': _premiumFrequency,
        'premium_mode': _premiumMode.toLowerCase(),
        'application_date': _applicationDate.toIso8601String().split('T')[0],
        'start_date': _startDate.toIso8601String().split('T')[0],
        if (_maturityDate != null) 'maturity_date': _maturityDate!.toIso8601String().split('T')[0],
      };

      final repository = PolicyRepository(
        PolicyRemoteDataSourceImpl(),
        PolicyLocalDataSourceImpl(),
      );

      final result = await repository.createPolicy(policyData);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create policy: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (policy) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Policy created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create policy: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

