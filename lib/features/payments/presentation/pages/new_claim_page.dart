import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/claims_viewmodel.dart';
import '../../policies/presentation/viewmodels/policies_viewmodel.dart';
import '../../policies/data/models/policy_model.dart';

class NewClaimPage extends StatefulWidget {
  const NewClaimPage({super.key});

  @override
  State<NewClaimPage> createState() => _NewClaimPageState();
}

class _NewClaimPageState extends State<NewClaimPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  final List<String> _claimTypes = [
    'Death Claim',
    'Maturity Claim',
    'Surrender Claim',
    'Medical Claim',
    'Accident Claim',
    'Critical Illness Claim',
    'Disability Claim',
    'Other',
  ];

  String? _selectedPolicyId;
  String? _selectedClaimType;
  DateTime _incidentDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
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
          'New Claim',
          style: TextStyle(
            color: Color(0xFF1a237e),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<ClaimsViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Policy Selection
                  _buildSectionTitle('Select Policy *'),
                  const SizedBox(height: 8),
                  _buildPolicyDropdown(viewModel),

                  const SizedBox(height: 24),

                  // Claim Type
                  _buildSectionTitle('Claim Type *'),
                  const SizedBox(height: 8),
                  _buildClaimTypeDropdown(),

                  const SizedBox(height: 24),

                  // Incident Date
                  _buildSectionTitle('Incident Date *'),
                  const SizedBox(height: 8),
                  _buildDatePicker(
                    label: _formatDate(_incidentDate),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _incidentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _incidentDate = date;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Claim Amount
                  _buildSectionTitle('Claim Amount (₹) *'),
                  const SizedBox(height: 8),
                  _buildTextFormField(
                    controller: _amountController,
                    hintText: 'Enter claim amount',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Claim amount is required';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Description
                  _buildSectionTitle('Description *'),
                  const SizedBox(height: 8),
                  _buildTextArea(
                    controller: _descriptionController,
                    hintText: 'Describe the incident and claim details...',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Description is required';
                      }
                      if (value.length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Document Upload Section
                  _buildSectionTitle('Supporting Documents'),
                  const SizedBox(height: 8),
                  _buildDocumentUploadSection(viewModel),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _submitClaim(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1a237e),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Claim',
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
          );
        },
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

  Widget _buildPolicyDropdown(ClaimsViewModel viewModel) {
    return Consumer<PoliciesViewModel>(
      builder: (context, policiesViewModel, child) {
        // Load policies if not loaded
        if (policiesViewModel.policies.isEmpty && !policiesViewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            policiesViewModel.loadPolicies();
          });
        }

        if (policiesViewModel.isLoading && policiesViewModel.policies.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPolicyId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Choose a policy',
            ),
            items: policiesViewModel.policies.map((policy) {
              return DropdownMenuItem(
                value: policy.policyId,
                child: Text('${policy.planName} - ${policy.policyNumber}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPolicyId = value;
                viewModel.setPolicyId(value ?? '');
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a policy';
              }
              return null;
            },
          ),
        );
      },
    );
  }

  Widget _buildClaimTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedClaimType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Select claim type',
        ),
        items: _claimTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedClaimType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a claim type';
          }
          return null;
        },
      ),
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

  Widget _buildTextArea({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
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
              style: const TextStyle(color: Colors.black87),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFF1a237e)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadSection(ClaimsViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement file picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document upload coming soon!')),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1a237e)),
                  foregroundColor: const Color(0xFF1a237e),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement camera
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera capture coming soon!')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1a237e)),
                  foregroundColor: const Color(0xFF1a237e),
                ),
              ),
            ),
          ],
        ),
        if (viewModel.selectedImage != null || viewModel.selectedDocument != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text('Document attached'),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    viewModel.clearSelectedFiles();
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submitClaim(ClaimsViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPolicyId == null || _selectedClaimType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update viewModel
    viewModel.setClaimType(_selectedClaimType!);
    viewModel.setDescription(_descriptionController.text);
    viewModel.setClaimedAmount(double.parse(_amountController.text));
    viewModel.setIncidentDate(_incidentDate);

    // Submit claim
    final result = await viewModel.submitClaim();

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit claim: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (claim) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Claim submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

