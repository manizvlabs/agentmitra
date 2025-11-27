import 'package:flutter/material.dart';
import '../core/widgets/offline_indicator.dart';

/// Emergency Contact Setup Screen for Customer Portal
/// Allows customers to set up emergency contacts for policy-related communications
class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form controllers - support multiple contacts
  List<EmergencyContact> _contacts = [
    EmergencyContact(), // Primary contact
  ];
  
  int _currentContactIndex = 0;
  
  // Form state
  bool _useSameAddress = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var contact in _contacts) {
      contact.nameController.dispose();
      contact.phoneController.dispose();
    }
    super.dispose();
  }
  
  EmergencyContact get _currentContact => _contacts[_currentContactIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Header
                  _buildMainHeader(),

                  const SizedBox(height: 24),

                  // Contact List Header
                  if (_contacts.length > 1) _buildContactListHeader(),

                  const SizedBox(height: 24),

                  // Emergency Contact Form
                  _buildContactForm(),

                  const SizedBox(height: 24),

                  // Address Information
                  _buildAddressSection(),

                  const SizedBox(height: 24),

                  // Why Emergency Contact
                  _buildWhyEmergencyContact(),

                  const SizedBox(height: 24),

                  // Privacy & Security
                  _buildPrivacySecurity(),

                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),

                  // Offline indicator
                  const OfflineIndicator(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Emergency Contact',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () {
            // TODO: Show help
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.contact_emergency,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add Emergency Contact',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Someone to Contact in Case of Emergency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_contacts.length, (index) {
                  final isSelected = index == _currentContactIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentContactIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.blue.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            index == 0 ? 'Primary' : 'Contact ${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isSelected && index > 0) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _contacts[index].nameController.dispose();
                                  _contacts[index].phoneController.dispose();
                                  _contacts.removeAt(index);
                                  if (_currentContactIndex >= _contacts.length) {
                                    _currentContactIndex = _contacts.length - 1;
                                  }
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (_contacts.length < 3)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _contacts.add(EmergencyContact());
                  _currentContactIndex = _contacts.length - 1;
                });
              },
              tooltip: 'Add Contact',
            ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentContactIndex == 0
                      ? 'Primary Emergency Contact Details'
                      : 'Emergency Contact ${_currentContactIndex + 1} Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: _currentContact.nameController,
            label: 'Full Name',
            hint: 'Enter full name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: _currentContact.phoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildRelationshipDropdown(),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Relationship',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentContact.relationship,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: _currentContact.relationshipOptions.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(relationship),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _currentContact.relationship = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
            'Address Information (Optional)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _useSameAddress,
                onChanged: (value) {
                  setState(() {
                    _useSameAddress = value ?? true;
                  });
                },
                activeColor: Colors.red,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Same as my address',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!_useSameAddress) ...[
            const SizedBox(height: 16),
            const Text(
              'Or enter different address:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentContact.addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter complete address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWhyEmergencyContact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Why Emergency Contact?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEmergencyReason(
            'Claim Processing',
            'Contact for verification during claims',
            Icons.assignment,
          ),
          const SizedBox(height: 12),
          _buildEmergencyReason(
            'Premium Issues',
            'Payment confirmations and overdue notices',
            Icons.payment,
          ),
          const SizedBox(height: 12),
          _buildEmergencyReason(
            'Policy Changes',
            'Authorization required for modifications',
            Icons.edit_document,
          ),
          const SizedBox(height: 12),
          _buildEmergencyReason(
            'Critical Illness',
            'Immediate notification for emergencies',
            Icons.local_hospital,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyReason(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySecurity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.security,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Privacy & Security',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPrivacyPoint(
            '🔐 Information is encrypted and secure',
            'Your data is protected with bank-level security',
          ),
          const SizedBox(height: 12),
          _buildPrivacyPoint(
            '📞 Only contacted for policy-related emergencies',
            'We never share your information with third parties',
          ),
          const SizedBox(height: 12),
          _buildPrivacyPoint(
            '❌ Never shared with third parties',
            'Your emergency contact details remain private',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addAnotherContact,
                icon: const Icon(Icons.add),
                label: const Text('Add Another'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _skipForNow,
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip for Now'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.grey),
                  foregroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveContact,
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _addAnotherContact() {
    if (_contacts.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 3 emergency contacts allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _contacts.add(EmergencyContact());
      _currentContactIndex = _contacts.length - 1;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added contact ${_contacts.length}. Please fill in the details.')),
    );
  }

  void _skipForNow() {
    // TODO: Navigate to next step, skip emergency contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Skipping emergency contact setup...')),
    );
  }

  void _saveContact() {
    // Validate all contacts
    bool hasInvalidContact = false;
    for (int i = 0; i < _contacts.length; i++) {
      final contact = _contacts[i];
      if (contact.nameController.text.isEmpty || contact.phoneController.text.isEmpty) {
        hasInvalidContact = true;
        setState(() {
          _currentContactIndex = i;
        });
        break;
      }
    }

    if (hasInvalidContact) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter name and phone number for all contacts'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate at least primary contact
    if (_contacts[0].nameController.text.isEmpty || _contacts[0].phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primary contact is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Save all emergency contacts
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_contacts.length} emergency contact(s) saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Emergency Contact Data Model
class EmergencyContact {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String relationship = 'Spouse';
  
  final List<String> relationshipOptions = [
    'Spouse',
    'Parent',
    'Sibling',
    'Child',
    'Friend',
    'Other',
  ];
}
