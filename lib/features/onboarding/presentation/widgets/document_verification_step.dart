import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../../data/models/onboarding_step.dart';

/// Document Verification Step Widget
class DocumentVerificationStep extends StatefulWidget {
  const DocumentVerificationStep({super.key});

  @override
  State<DocumentVerificationStep> createState() => _DocumentVerificationStepState();
}

class _DocumentVerificationStepState extends State<DocumentVerificationStep> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  // final ImagePicker _imagePicker = ImagePicker(); // Disabled for web compatibility

  dynamic _aadhaarFrontImage;
  dynamic _aadhaarBackImage;
  dynamic _panImage;

  @override
  void initState() {
    super.initState();
    // Load existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<OnboardingViewModel>();
      final existingData = viewModel.documentVerificationData;
      if (existingData != null) {
        _aadhaarController.text = existingData.aadhaarNumber ?? '';
        _panController.text = existingData.panNumber ?? '';
        // Note: File paths would need to be reconstructed from stored paths
      }
    });
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String source, String documentType) async {
    // TODO: Implement web-compatible image picking
    // try {
    //   final pickedFile = await _imagePicker.pickImage(
    //     source: source,
    //     imageQuality: 85,
    //     maxWidth: 1024,
    //     maxHeight: 1024,
    //   );

    //   if (pickedFile != null) {
    //     setState(() {
    //       switch (documentType) {
    //         case 'aadhaar_front':
    //           _aadhaarFrontImage = pickedFile.path; // Use path instead of File
    //           break;
    //         case 'aadhaar_back':
    //           _aadhaarBackImage = pickedFile.path;
    //           break;
    //         case 'pan':
    //           _panImage = pickedFile.path;
    //           break;
    //       }
    //     });

    //     // Save data
    //     await _saveDocumentData();
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Failed to pick image: $e')),
    //     );
    //   }
    // }
  }

  Future<void> _saveDocumentData() async {
    final viewModel = context.read<OnboardingViewModel>();
    final documentData = DocumentVerificationData(
      aadhaarNumber: _aadhaarController.text.trim(),
      panNumber: _panController.text.trim(),
      aadhaarFrontImage: _aadhaarFrontImage?.path,
      aadhaarBackImage: _aadhaarBackImage?.path,
      panImage: _panImage?.path,
      documentsVerified: false, // Will be set to true after verification
    );

    await viewModel.updateDocumentVerificationData(documentData);
  }

  void _showImageSourceDialog(String documentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage('camera', documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage('gallery', documentType);
              },
            ),
          ],
        ),
      ),
    );
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
                  'Document Verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Please provide your identity documents for verification. All information is encrypted and secure.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Aadhaar Number
                TextFormField(
                  controller: _aadhaarController,
                  decoration: InputDecoration(
                    labelText: 'Aadhaar Number',
                    hintText: 'Enter 12-digit Aadhaar number',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter Aadhaar number';
                    }
                    if (value!.length != 12) {
                      return 'Aadhaar number must be 12 digits';
                    }
                    return null;
                  },
                  onChanged: (value) => _saveDocumentData(),
                ),

                const SizedBox(height: 24),

                // Aadhaar Card Upload
                _buildDocumentUploadSection(
                  'Aadhaar Card',
                  'Upload front and back of your Aadhaar card',
                  [
                    _buildImageUploadField(
                      'Front Side',
                      _aadhaarFrontImage,
                      () => _showImageSourceDialog('aadhaar_front'),
                    ),
                    const SizedBox(height: 16),
                    _buildImageUploadField(
                      'Back Side',
                      _aadhaarBackImage,
                      () => _showImageSourceDialog('aadhaar_back'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // PAN Number
                TextFormField(
                  controller: _panController,
                  decoration: InputDecoration(
                    labelText: 'PAN Number',
                    hintText: 'Enter 10-character PAN number',
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Please enter PAN number';
                    }
                    if (value!.length != 10) {
                      return 'PAN number must be 10 characters';
                    }
                    // Basic PAN format validation
                    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
                    if (!panRegex.hasMatch(value)) {
                      return 'Invalid PAN format';
                    }
                    return null;
                  },
                  onChanged: (value) => _saveDocumentData(),
                ),

                const SizedBox(height: 24),

                // PAN Card Upload
                _buildDocumentUploadSection(
                  'PAN Card',
                  'Upload a clear photo of your PAN card',
                  [
                    _buildImageUploadField(
                      'PAN Card',
                      _panImage,
                      () => _showImageSourceDialog('pan'),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Security Notice
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
                        Icons.security,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your documents are secure',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'All documents are encrypted and stored securely. We comply with data protection regulations.',
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
                          Icons.verified,
                          color: Colors.green.shade600,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Documents ready for verification. Our team will review them within 24 hours.',
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

  Widget _buildDocumentUploadSection(String title, String subtitle, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageUploadField(String label, dynamic imageFile, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageFile != null ? Colors.green.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.add_photo_alternate,
                      color: Colors.grey.shade500,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    imageFile != null ? 'Image uploaded' : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 12,
                      color: imageFile != null ? Colors.green.shade600 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              imageFile != null ? Icons.check_circle : Icons.camera_alt,
              color: imageFile != null ? Colors.green.shade600 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _aadhaarController.text.length == 12 &&
           _panController.text.length == 10 &&
           _aadhaarFrontImage != null &&
           _aadhaarBackImage != null &&
           _panImage != null;
  }
}
