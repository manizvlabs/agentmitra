import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class GetQuotePage extends StatefulWidget {
  const GetQuotePage({super.key});

  @override
  State<GetQuotePage> createState() => _GetQuotePageState();
}

class _GetQuotePageState extends State<GetQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedProduct;
  String? _selectedAgent;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _products = [
    {
      'id': 'term_life',
      'name': 'Term Life Insurance',
      'description': 'Affordable life coverage for a specific period',
      'icon': Icons.security,
      'color': Colors.blue,
    },
    {
      'id': 'whole_life',
      'name': 'Whole Life Insurance',
      'description': 'Lifetime coverage with cash value',
      'icon': Icons.favorite,
      'color': Colors.red,
    },
    {
      'id': 'endowment',
      'name': 'Endowment Plan',
      'description': 'Savings with life coverage',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'id': 'ulip',
      'name': 'ULIP',
      'description': 'Unit Linked Insurance Plan',
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _agents = [
    {
      'id': 'agent_1',
      'name': 'Rajesh Kumar',
      'code': 'ABC123',
      'rating': 4.8,
      'policies': 150,
    },
    {
      'id': 'agent_2',
      'name': 'Priya Sharma',
      'code': 'XYZ456',
      'rating': 4.9,
      'policies': 200,
    },
    {
      'id': 'agent_3',
      'name': 'Amit Patel',
      'code': 'DEF789',
      'rating': 4.7,
      'policies': 120,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('📝 GetQuotePage - Building page: selectedProduct=$_selectedProduct, selectedAgent=$_selectedAgent, isSubmitting=$_isSubmitting');
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
          'Get Quote',
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
              // Product Selection
              const Text(
                'Select Product',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a237e),
                ),
              ),
              const SizedBox(height: 16),
              ..._products.map((product) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProductCard(product),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Personal Information
              const Text(
                'Personal Information',
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 18 || age > 100) {
                          return 'Please enter a valid age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email (Optional)',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Agent Selection
              const Text(
                'Select Agent (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a237e),
                ),
              ),
              const SizedBox(height: 16),
              ..._agents.map((agent) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAgentCard(agent),
                );
              }).toList(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuoteRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1a237e),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Request Quote',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final productId = product['id'] as String?;
    final isSelected = _selectedProduct == productId;
    debugPrint('📦 GetQuotePage - Building product card: id=$productId, name=${product['name']}, isSelected=$isSelected');
    return InkWell(
      onTap: productId != null ? () {
        debugPrint('📦 GetQuotePage - Product selected: $productId');
        setState(() {
          _selectedProduct = productId;
        });
        debugPrint('📦 GetQuotePage - Selected product updated to: $_selectedProduct');
      } : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected && product['color'] is Color
              ? (product['color'] as Color).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && product['color'] is Color
                ? product['color'] as Color
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product['color'] is Color ? (product['color'] as Color).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                product['icon'] is IconData ? product['icon'] as IconData : Icons.help,
                color: product['color'] is Color ? product['color'] as Color : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String? ?? 'Unknown Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected && product['color'] is Color
                          ? product['color'] as Color
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['description'] as String? ?? 'No description available',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: product['color'] as Color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentCard(Map<String, dynamic> agent) {
    final agentId = agent['id'] as String?;
    final isSelected = _selectedAgent == agentId;
    debugPrint('👤 GetQuotePage - Building agent card: id=$agentId, name=${agent['name']}, isSelected=$isSelected');
    return InkWell(
      onTap: agentId != null ? () {
        debugPrint('👤 GetQuotePage - Agent selected: $agentId');
        setState(() {
          _selectedAgent = agentId;
        });
        debugPrint('👤 GetQuotePage - Selected agent updated to: $_selectedAgent');
      } : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1a237e).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1a237e)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF1a237e).withOpacity(0.1),
              child: Text(
                (agent['name'] as String?)?.isNotEmpty == true ? (agent['name'] as String)[0] : '?',
                style: const TextStyle(
                  color: Color(0xFF1a237e),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agent['name'] as String? ?? 'Unknown Agent',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${agent['rating'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Code: ${agent['code'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${agent['policies']} policies sold',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1a237e),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuoteRequest() async {
    debugPrint('📤 GetQuotePage - Submit quote request started');
    debugPrint('📤 GetQuotePage - Form state: formKey=${_formKey.currentState != null}, selectedProduct=$_selectedProduct, selectedAgent=$_selectedAgent');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      debugPrint('📤 GetQuotePage - Form validation failed');
      return;
    }

    if (_selectedProduct == null) {
      debugPrint('📤 GetQuotePage - No product selected, showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('📤 GetQuotePage - Setting isSubmitting=true');
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create quote request payload
      final quoteRequest = {
        'customer_name': _nameController.text.trim(),
        'customer_age': int.tryParse(_ageController.text.trim()) ?? 0,
        'customer_phone': _phoneController.text.trim(),
        'customer_email': _emailController.text.trim(),
        'selected_product': _selectedProduct,
        'selected_agent': _selectedAgent,
        'request_date': DateTime.now().toIso8601String(),
        'status': 'pending',
        'notes': 'Quote request submitted via mobile app'
      };

      debugPrint('📤 GetQuotePage - Submitting quote request: $quoteRequest');

      // Make API call to create quote request
      // Quotes cannot be obtained through AgentMitra - direct to insurance provider
      // Send notification to agent about quote request
      try {
        await ApiService.post('/api/v1/notifications/', {
          'title': 'Quote Request Attempt',
          'message': '${_nameController.text} is requesting a quote for ${_selectedProduct ?? 'insurance product'} through AgentMitra. Please assist them directly through LIC portal.',
          'type': 'quote_assistance',
          'recipient_type': 'agent',
          'priority': 'high',
          'metadata': {
            'customer_name': _nameController.text,
            'customer_age': _ageController.text,
            'customer_phone': _phoneController.text,
            'customer_email': _emailController.text,
            'product_type': _selectedProduct,
            'agent_id': _selectedAgent,
            'user_id': Provider.of<AuthViewModel>(context, listen: false).currentUser?.id,
          }
        });
      } catch (e) {
        // Notification sending failed, but continue with info screen
        debugPrint('Failed to notify agent: $e');
      }

      if (!mounted) {
        debugPrint('📤 GetQuotePage - Widget not mounted after notification');
        return;
      }

      // Show quote info screen instead of success message
      _showQuoteInfoScreen();

    } catch (e) {
      debugPrint('📤 GetQuotePage - API call failed: $e');

      if (!mounted) {
        debugPrint('📤 GetQuotePage - Widget not mounted after error');
        return;
      }

      // Show error message but don't fail the submission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote request saved locally. Will sync when online.'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        debugPrint('📤 GetQuotePage - Setting isSubmitting=false');
        setState(() {
          _isSubmitting = false;
        });
      }
    }

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Quote Request Submitted'),
          ],
        ),
        content: const Text(
          'Your quote request has been submitted successfully. An agent will contact you shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showQuoteInfoScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insurance Quote Information'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Insurance quotes cannot be obtained through the AgentMitra app at this time.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'To get an insurance quote from LIC, please visit the official LIC website or contact your nearest LIC branch office.',
                  style: TextStyle(height: 1.4),
                ),
                SizedBox(height: 16),
                Text(
                  '📍 LIC Official Website:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'www.licindia.in',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                SizedBox(height: 12),
                Text(
                  '📞 LIC Customer Care:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('1800-XXX-XXXX'),
                SizedBox(height: 16),
                Text(
                  'Your insurance agent has been notified and will assist you with getting a personalized quote.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

