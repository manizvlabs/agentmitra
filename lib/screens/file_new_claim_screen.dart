import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/loading_overlay.dart';

class FileNewClaimScreen extends StatefulWidget {
  final String? policyId;

  const FileNewClaimScreen({super.key, this.policyId});

  @override
  State<FileNewClaimScreen> createState() => _FileNewClaimScreenState();
}

class _FileNewClaimScreenState extends State<FileNewClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _selectedPolicyId = '';
  String _claimType = 'medical';
  String _description = '';
  bool _isSubmitting = false;
  List<File> _supportingDocuments = [];
  List<Map<String, dynamic>> _policies = [];

  final List<Map<String, String>> _claimTypes = [
    {'value': 'medical', 'label': 'Medical Claim'},
    {'value': 'accident', 'label': 'Accident Claim'},
    {'value': 'critical_illness', 'label': 'Critical Illness Claim'},
    {'value': 'disability', 'label': 'Disability Claim'},
    {'value': 'death', 'label': 'Death Claim'},
    {'value': 'maturity', 'label': 'Maturity Claim'},
    {'value': 'surrender', 'label': 'Surrender Claim'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.policyId != null) {
      _selectedPolicyId = widget.policyId!;
    }
    _loadUserPolicies();
  }

  Future<void> _loadUserPolicies() async {
    try {
      final response = await ApiService.get('/api/v1/policies/', queryParameters: {
        'policyholder_id': AuthService().currentUser?.id,
      });
      setState(() {
        _policies = List<Map<String, dynamic>>.from(response['data'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load policies: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File New Claim'),
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
                // Policy Selection
                const Text(
                  'Select Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPolicySelector(),
                const SizedBox(height: 24),

                // Claim Type
                const Text(
                  'Claim Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _claimType,
                  items: _claimTypes.map((type) => DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  )).toList(),
                  onChanged: (value) => setState(() => _claimType = value!),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Please select a claim type' : null,
                ),
                const SizedBox(height: 24),

                // Description
                const Text(
                  'Claim Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe the incident and claim details...',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Description is required';
                    }
                    if (value!.length < 50) {
                      return 'Please provide a detailed description (at least 50 characters)';
                    }
                    return null;
                  },
                  onChanged: (value) => _description = value,
                ),
                const SizedBox(height: 24),

                // Supporting Documents
                const Text(
                  'Supporting Documents',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDocumentUploadSection(),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Claim',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Text
                const Text(
                  'Note: All claims are subject to verification and approval. You will receive a confirmation once your claim is submitted.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySelector() {
    if (_policies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No active policies found. Please contact your agent to purchase a policy.'),
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedPolicyId.isNotEmpty ? _selectedPolicyId : null,
      hint: const Text('Select a policy'),
      items: _policies.map((policy) => DropdownMenuItem(
        value: policy['policy_id'],
        child: Text('${policy['policy_number']} - ${policy['plan_name']}'),
      )).toList(),
      onChanged: (value) => setState(() => _selectedPolicyId = value!),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please select a policy' : null,
    );
  }

  Widget _buildDocumentUploadSection() {
    return Column(
      children: [
        // Document List
        if (_supportingDocuments.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _supportingDocuments.length,
              itemBuilder: (context, index) {
                final file = _supportingDocuments[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(file.path.split('/').last),
                    subtitle: Text('${(file.lengthSync() / 1024).round()} KB'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _supportingDocuments.removeAt(index)),
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 16),

        // Upload Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Text(
          'Upload medical reports, bills, incident photos, or other supporting documents',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _supportingDocuments.add(File(pickedFile.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() => _supportingDocuments.add(File(pickedFile.path)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take photo: $e')),
        );
      }
    }
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPolicyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a policy')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare claim data
      final claimData = {
        'policy_id': _selectedPolicyId,
        'claim_type': _claimType,
        'description': _description,
        'user_id': AuthService().currentUser?.id,
        'supporting_documents': _supportingDocuments.map((file) => file.path.split('/').last).toList(),
      };

      // Claims cannot be processed through AgentMitra - direct to insurance provider
      // Send notification to agent about claim attempt
      try {
        await ApiService.post('/api/v1/notifications/', {
          'title': 'Claim Filing Attempt',
          'message': '${AuthService().currentUser?.name ?? 'Policyholder'} is trying to file a claim for policy $_selectedPolicyId through AgentMitra. Please assist them directly through LIC portal.',
          'type': 'claim_assistance',
          'recipient_type': 'agent',
          'priority': 'high',
          'metadata': {
            'policy_id': _selectedPolicyId,
            'user_id': AuthService().currentUser?.id,
            'claim_type': _claimType,
            'description': _description,
          }
        });
      } catch (e) {
        // Notification sending failed, but continue with info screen
        print('Failed to notify agent: $e');
      }

      if (mounted) {
        // Show info screen instead of success message
        _showClaimInfoScreen();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit claim: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showClaimInfoScreen() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Claim Filing Information'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Claims cannot be filed through the AgentMitra app at this time.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'To file a claim for your LIC insurance policy, please visit the official LIC website or contact your nearest LIC branch office.',
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
                  'Your agent has been notified and will assist you with the claim process.',
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
