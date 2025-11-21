import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../../data/models/onboarding_step.dart';

/// Emergency Contacts Step Widget
class EmergencyContactsStep extends StatefulWidget {
  const EmergencyContactsStep({super.key});

  @override
  State<EmergencyContactsStep> createState() => _EmergencyContactsStepState();
}

class _EmergencyContactsStepState extends State<EmergencyContactsStep> {
  final _formKey = GlobalKey<FormState>();
  final _primaryNameController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _secondaryNameController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();

  String? _primaryRelation;
  String? _secondaryRelation;

  final List<String> _relations = [
    'Parent',
    'Spouse',
    'Child',
    'Sibling',
    'Friend',
    'Colleague',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OnboardingViewModel>();
      final existingData = viewModel.emergencyContactsData;
      if (existingData != null) {
        _primaryNameController.text = existingData.primaryContactName ?? '';
        _primaryRelation = existingData.primaryContactRelation;
        _primaryPhoneController.text = existingData.primaryContactPhone ?? '';
        _secondaryNameController.text = existingData.secondaryContactName ?? '';
        _secondaryRelation = existingData.secondaryContactRelation;
        _secondaryPhoneController.text = existingData.secondaryContactPhone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _primaryNameController.dispose();
    _primaryPhoneController.dispose();
    _secondaryNameController.dispose();
    _secondaryPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveEmergencyContactsData() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<OnboardingViewModel>();
    final contactsData = EmergencyContactsData(
      primaryContactName: _primaryNameController.text.trim(),
      primaryContactRelation: _primaryRelation,
      primaryContactPhone: _primaryPhoneController.text.trim(),
      secondaryContactName: _secondaryNameController.text.trim().isNotEmpty
          ? _secondaryNameController.text.trim()
          : null,
      secondaryContactRelation: _secondaryRelation,
      secondaryContactPhone: _secondaryPhoneController.text.trim().isNotEmpty
          ? _secondaryPhoneController.text.trim()
          : null,
    );

    await viewModel.updateEmergencyContactsData(contactsData);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Add emergency contacts who can be reached in case of urgent situations. This helps us ensure your safety and provide timely assistance.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Primary Contact Section
                _buildContactSection(
                  'Primary Emergency Contact',
                  'Main contact person for emergencies',
                  _primaryNameController,
                  _primaryRelation,
                  _primaryPhoneController,
                  true, // Required
                ),

                const SizedBox(height: 32),

                // Secondary Contact Section
                _buildContactSection(
                  'Secondary Emergency Contact (Optional)',
                  'Additional contact person',
                  _secondaryNameController,
                  _secondaryRelation,
                  _secondaryPhoneController,
                  false, // Optional
                ),

                const SizedBox(height: 32),

                // Important Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency contacts will be used only in case of emergencies',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'These contacts will be contacted only for critical situations related to your insurance policies or health emergencies.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Privacy Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your emergency contacts are stored securely and will never be shared with third parties.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Access Info
                _buildInfoCard(
                  context,
                  icon: Icons.emergency,
                  title: 'Emergency Situations',
                  description: 'Policy claims, health emergencies, payment issues',
                  color: Colors.red.shade50,
                  iconColor: Colors.red.shade600,
                ),

                const SizedBox(height: 16),

                _buildInfoCard(
                  context,
                  icon: Icons.contact_phone,
                  title: 'Contact Methods',
                  description: 'SMS, WhatsApp, and phone calls',
                  color: Colors.green.shade50,
                  iconColor: Colors.green.shade600,
                ),

                const SizedBox(height: 32),

                // Verification Status
                if (_isPrimaryContactValid())
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Emergency contacts saved successfully. You can update them anytime from your profile settings.',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactSection(
    String title,
    String subtitle,
    TextEditingController nameController,
    String? selectedRelation,
    TextEditingController phoneController,
    bool isRequired,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isRequired) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          // Name Field
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter contact person\'s full name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
            validator: isRequired
                ? (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter contact name';
                    }
                    if (value!.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  }
                : null,
            onChanged: (value) => _saveEmergencyContactsData(),
          ),

          const SizedBox(height: 16),

          // Relation and Phone Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedRelation,
                  decoration: InputDecoration(
                    labelText: 'Relation',
                    prefixIcon: const Icon(Icons.family_restroom),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _relations.map((relation) {
                    return DropdownMenuItem(
                      value: relation,
                      child: Text(relation),
                    );
                  }).toList(),
                  validator: isRequired
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select relation';
                          }
                          return null;
                        }
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (nameController == _primaryNameController) {
                        _primaryRelation = value;
                      } else {
                        _secondaryRelation = value;
                      }
                    });
                    _saveEmergencyContactsData();
                  },
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 XXXXX XXXXX',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: isRequired
                      ? (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter phone number';
                          }
                          if (value!.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        }
                      : (value) {
                          if (value != null && value.isNotEmpty && value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                  onChanged: (value) => _saveEmergencyContactsData(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isPrimaryContactValid() {
    return _primaryNameController.text.trim().isNotEmpty &&
           _primaryRelation != null &&
           _primaryPhoneController.text.trim().length == 10;
  }
}
