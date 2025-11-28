import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class CreateNewPolicyScreen extends StatefulWidget {
  const CreateNewPolicyScreen({super.key});

  @override
  State<CreateNewPolicyScreen> createState() => _CreateNewPolicyScreenState();
}

class _CreateNewPolicyScreenState extends State<CreateNewPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Policy Details
  String _policyType = 'term_life';
  double _sumAssured = 1000000; // 10 lakhs default
  int _termYears = 20;
  String _paymentFrequency = 'annual';

  // Policy Types
  final List<Map<String, dynamic>> _policyTypes = [
    {
      'value': 'term_life',
      'label': 'Term Life Insurance',
      'description': 'Pure life coverage with no savings component',
      'min_sum': 500000,
      'max_sum': 10000000,
    },
    {
      'value': 'whole_life',
      'label': 'Whole Life Insurance',
      'description': 'Lifetime coverage with savings component',
      'min_sum': 500000,
      'max_sum': 5000000,
    },
    {
      'value': 'endowment',
      'label': 'Endowment Plan',
      'description': 'Life coverage with maturity benefit',
      'min_sum': 100000,
      'max_sum': 5000000,
    },
    {
      'value': 'ulip',
      'label': 'Unit Linked Insurance Plan',
      'description': 'Investment-oriented life insurance',
      'min_sum': 100000,
      'max_sum': 25000000,
    },
    {
      'value': 'money_back',
      'label': 'Money Back Policy',
      'description': 'Regular payouts with life coverage',
      'min_sum': 100000,
      'max_sum': 5000000,
    },
  ];

  // Payment Frequencies
  final List<Map<String, String>> _paymentFrequencies = [
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'quarterly', 'label': 'Quarterly'},
    {'value': 'half_yearly', 'label': 'Half-Yearly'},
    {'value': 'annual', 'label': 'Annual'},
  ];

  Map<String, dynamic>? _selectedPolicyType;

  @override
  void initState() {
    super.initState();
    _selectedPolicyType = _policyTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Policy'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Policy Type Selection
                const Text(
                  'Policy Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPolicyTypeSelector(),
                if (_selectedPolicyType != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      _selectedPolicyType!['description'],
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Sum Assured
                const Text(
                  'Sum Assured',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _sumAssured.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                    hintText: 'Enter sum assured amount',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Sum assured is required';
                    }
                    final amount = double.tryParse(value!);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (_selectedPolicyType != null) {
                      if (amount < _selectedPolicyType!['min_sum']) {
                        return 'Minimum sum assured is ₹${_selectedPolicyType!['min_sum']}';
                      }
                      if (amount > _selectedPolicyType!['max_sum']) {
                        return 'Maximum sum assured is ₹${_selectedPolicyType!['max_sum']}';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final amount = double.tryParse(value);
                    if (amount != null) {
                      setState(() => _sumAssured = amount);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Policy Term
                const Text(
                  'Policy Term',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Term (Years)'),
                          Text(
                            '$_termYears years',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _termYears.toDouble(),
                        min: 5,
                        max: 40,
                        divisions: 35,
                        label: _termYears.toString(),
                        activeColor: Colors.red,
                        onChanged: (value) => setState(() => _termYears = value.toInt()),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('5 years', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('40 years', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Frequency
                const Text(
                  'Payment Frequency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _paymentFrequency,
                  items: _paymentFrequencies.map((freq) =>
                    DropdownMenuItem(value: freq['value'], child: Text(freq['label']!))
                  ).toList(),
                  onChanged: (value) => setState(() => _paymentFrequency = value!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 32),

                // Premium Calculator Preview
                _buildPremiumPreview(),
                const SizedBox(height: 32),

                // Create Policy Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _createPolicy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create Policy',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms and Conditions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Premium amounts are estimates and may vary based on age, health, and other factors.\n'
                        '• Actual premium will be calculated during the application process.\n'
                        '• Medical examination may be required for high sum assured amounts.\n'
                        '• Terms and conditions apply.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _policyType,
      items: _policyTypes.map((type) => DropdownMenuItem(
        value: type['value'],
        child: Text(type['label']),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _policyType = value!;
          _selectedPolicyType = _policyTypes.firstWhere((type) => type['value'] == value);
          // Adjust sum assured if it's outside the new policy type's range
          if (_sumAssured < _selectedPolicyType!['min_sum']) {
            _sumAssured = _selectedPolicyType!['min_sum'].toDouble();
          } else if (_sumAssured > _selectedPolicyType!['max_sum']) {
            _sumAssured = _selectedPolicyType!['max_sum'].toDouble();
          }
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please select a policy type' : null,
    );
  }

  Widget _buildPremiumPreview() {
    // Simple premium calculation (this would be replaced with actual calculation service)
    final annualPremium = _calculateEstimatedPremium();
    final monthlyPremium = annualPremium / 12;
    final quarterlyPremium = annualPremium / 4;
    final halfYearlyPremium = annualPremium / 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated Premium Preview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 12),
          _buildPremiumRow('Annual Premium', annualPremium, _paymentFrequency == 'annual'),
          _buildPremiumRow('Half-Yearly Premium', halfYearlyPremium, _paymentFrequency == 'half_yearly'),
          _buildPremiumRow('Quarterly Premium', quarterlyPremium, _paymentFrequency == 'quarterly'),
          _buildPremiumRow('Monthly Premium', monthlyPremium, _paymentFrequency == 'monthly'),
          const SizedBox(height: 8),
          const Text(
            '* Estimates are for illustration only. Actual premium will be calculated based on age, health, and other factors.',
            style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumRow(String label, double amount, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.black87,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateEstimatedPremium() {
    // Simple premium calculation logic
    // This is a rough estimate and would be replaced with actual actuarial calculations

    // Base premium per lakh per year (varies by policy type)
    double baseRatePerLakh = 500; // Default for term life

    switch (_policyType) {
      case 'term_life':
        baseRatePerLakh = 300; // Lower for pure term
        break;
      case 'whole_life':
        baseRatePerLakh = 800; // Higher due to savings component
        break;
      case 'endowment':
        baseRatePerLakh = 600;
        break;
      case 'ulip':
        baseRatePerLakh = 400; // Investment-oriented
        break;
      case 'money_back':
        baseRatePerLakh = 700; // Higher due to regular payouts
        break;
    }

    // Calculate base annual premium
    double annualPremium = (_sumAssured / 100000) * baseRatePerLakh;

    // Adjust for term (longer terms slightly increase premium)
    double termMultiplier = 1.0 + (_termYears - 20) * 0.005;
    annualPremium *= termMultiplier;

    // Cap the premium for reasonableness
    annualPremium = annualPremium.clamp(1000, 100000);

    return annualPremium;
  }

  Future<void> _createPolicy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Prepare policy data
      final policyData = {
        'policy_type': _policyType,
        'sum_assured': _sumAssured,
        'term_years': _termYears,
        'payment_frequency': _paymentFrequency,
        'estimated_annual_premium': _calculateEstimatedPremium(),
        'user_id': (await AuthService().getCurrentUser(context))?.id,
        'agent_id': (await AuthService().getCurrentUser(context))?.agentId, // Assuming user has agent relationship
      };

      // Create policy
      final response = await ApiService.post('/api/v1/policies', policyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Policy created successfully! Proceeding to application process.'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to policy details or application process
        Navigator.of(context).pop(response['data']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create policy: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
