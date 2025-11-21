import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../../data/models/onboarding_step.dart';

/// KYC Process Step Widget
class KycProcessStep extends StatefulWidget {
  const KycProcessStep({super.key});

  @override
  State<KycProcessStep> createState() => _KycProcessStepState();
}

class _KycProcessStepState extends State<KycProcessStep> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _occupationController = TextEditingController();

  String? _selectedGender;
  String? _selectedAnnualIncome;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _annualIncomes = [
    'Under ₹2.5 lakh',
    '₹2.5 lakh - ₹5 lakh',
    '₹5 lakh - ₹10 lakh',
    '₹10 lakh - ₹15 lakh',
    'Above ₹15 lakh'
  ];

  final List<String> _occupations = [
    'Salaried Employee',
    'Self Employed',
    'Business Owner',
    'Professional',
    'Student',
    'Retired',
    'Homemaker',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OnboardingViewModel>();
      final existingData = viewModel.kycProcessData;
      if (existingData != null) {
        _fullNameController.text = existingData.fullName ?? '';
        if (existingData.dateOfBirth != null) {
          _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(existingData.dateOfBirth!);
        }
        _selectedGender = existingData.gender;
        _addressController.text = existingData.address ?? '';
        _cityController.text = existingData.city ?? '';
        _stateController.text = existingData.state ?? '';
        _pincodeController.text = existingData.pincode ?? '';
        _occupationController.text = existingData.occupation ?? '';
        _selectedAnnualIncome = existingData.annualIncome;
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // At least 18 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC62828), // LIC Red
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
      _saveKycData();
    }
  }

  Future<void> _saveKycData() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<OnboardingViewModel>();
    final kycData = KycProcessData(
      fullName: _fullNameController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(_dateOfBirthController.text)
          : null,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      occupation: _occupationController.text.trim(),
      annualIncome: _selectedAnnualIncome,
      kycVerified: false, // Will be verified by backend
    );

    await viewModel.updateKycProcessData(kycData);
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
                  'Know Your Customer (KYC)',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Please provide your personal details for KYC verification. This information helps us serve you better and comply with regulatory requirements.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Personal Information Section
                _buildSectionHeader('Personal Information'),

                const SizedBox(height: 16),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name (as per Aadhaar)',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter your full name';
                    }
                    if (value!.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => _saveKycData(),
                ),

                const SizedBox(height: 16),

                // Date of Birth and Gender Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'DD/MM/YYYY',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please select date of birth';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: _genders.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select gender';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                          _saveKycData();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Address Information Section
                _buildSectionHeader('Address Information'),

                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your complete address',
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter your address';
                    }
                    if (value!.trim().length < 10) {
                      return 'Please enter complete address';
                    }
                    return null;
                  },
                  onChanged: (value) => _saveKycData(),
                ),

                const SizedBox(height: 16),

                // City and State Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          hintText: 'Enter city name',
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                        onChanged: (value) => _saveKycData(),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: InputDecoration(
                          labelText: 'State',
                          hintText: 'Enter state name',
                          prefixIcon: const Icon(Icons.map),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter state';
                          }
                          return null;
                        },
                        onChanged: (value) => _saveKycData(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pincode
                TextFormField(
                  controller: _pincodeController,
                  decoration: InputDecoration(
                    labelText: 'PIN Code',
                    hintText: 'Enter 6-digit PIN code',
                    prefixIcon: const Icon(Icons.pin_drop),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter PIN code';
                    }
                    if (value!.length != 6) {
                      return 'PIN code must be 6 digits';
                    }
                    return null;
                  },
                  onChanged: (value) => _saveKycData(),
                ),

                const SizedBox(height: 32),

                // Financial Information Section
                _buildSectionHeader('Financial Information'),

                const SizedBox(height: 16),

                // Occupation
                DropdownButtonFormField<String>(
                  value: _occupationController.text.isNotEmpty ? _occupationController.text : null,
                  decoration: InputDecoration(
                    labelText: 'Occupation',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _occupations.map((occupation) {
                    return DropdownMenuItem(
                      value: occupation,
                      child: Text(occupation),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select occupation';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _occupationController.text = value ?? '';
                    });
                    _saveKycData();
                  },
                ),

                const SizedBox(height: 16),

                // Annual Income
                DropdownButtonFormField<String>(
                  value: _selectedAnnualIncome,
                  decoration: InputDecoration(
                    labelText: 'Annual Income',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: _annualIncomes.map((income) {
                    return DropdownMenuItem(
                      value: income,
                      child: Text(income),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select annual income';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedAnnualIncome = value;
                    });
                    _saveKycData();
                  },
                ),

                const SizedBox(height: 32),

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your information is protected',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'All personal information is encrypted and used only for KYC verification and insurance services.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Verification Status
                if (_isFormValid())
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
                          Icons.verified_user,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'KYC information completed. Your details will be verified within 24-48 hours.',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a237e),
      ),
    );
  }

  bool _isFormValid() {
    return _fullNameController.text.trim().isNotEmpty &&
           _dateOfBirthController.text.trim().isNotEmpty &&
           _selectedGender != null &&
           _addressController.text.trim().isNotEmpty &&
           _cityController.text.trim().isNotEmpty &&
           _stateController.text.trim().isNotEmpty &&
           _pincodeController.text.trim().length == 6 &&
           _occupationController.text.trim().isNotEmpty &&
           _selectedAnnualIncome != null;
  }
}
