import 'package:flutter/material.dart';
import '../core/widgets/offline_indicator.dart';

/// Document Upload & Verification Screen for Customer Portal
/// Handles KYC document upload, OCR processing, and selfie verification
class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Upload status tracking
  Map<String, String> _uploadStatus = {
    'aadhar': 'pending', // pending, uploaded, processing, completed, failed
    'selfie': 'pending',
    'address': 'pending',
  };

  // OCR results
  Map<String, dynamic> _ocrResults = {};

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
    super.dispose();
  }

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

                  // Required Documents
                  _buildRequiredDocuments(),

                  const SizedBox(height: 24),

                  // Upload Process
                  _buildUploadProcess(),

                  const SizedBox(height: 24),

                  // Upload Status
                  _buildUploadStatus(),

                  const SizedBox(height: 24),

                  // OCR Results (if available)
                  if (_ocrResults.isNotEmpty) _buildOcrResults(),

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
        'Document Verification',
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
              Icons.upload_file,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Identity Documents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'KYC Verification Required',
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

  Widget _buildRequiredDocuments() {
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
            'Required Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentRequirement(
            icon: Icons.credit_card,
            title: 'Government ID',
            subtitle: 'Choose One',
            options: ['Aadhaar Card', 'Voter ID', 'Driving License', 'Passport'],
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildDocumentRequirement(
            icon: Icons.camera_alt,
            title: 'Recent Photo',
            subtitle: 'Selfie',
            options: ['Clear face photo', 'Well-lit environment', 'No sunglasses or hats'],
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRequirement({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: color.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildUploadProcess() {
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
            'Upload Process',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            number: '1️⃣',
            title: 'Select Document Type',
            description: 'Choose the type of document to upload',
          ),
          const SizedBox(height: 12),
          _buildProcessStep(
            number: '2️⃣',
            title: 'Take Photo or Choose from Gallery',
            description: 'Capture or select document image',
          ),
          const SizedBox(height: 12),
          _buildProcessStep(
            number: '3️⃣',
            title: 'OCR Processing',
            description: 'Automatic text recognition and validation',
          ),
          const SizedBox(height: 12),
          _buildProcessStep(
            number: '4️⃣',
            title: 'Manual Verification if Needed',
            description: 'Human review for complex cases',
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 16,
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
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadStatus() {
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
            'Upload Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusItem(
            title: 'Aadhaar Card',
            status: _uploadStatus['aadhar']!,
            onTap: () => _uploadDocument('aadhar'),
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            title: 'Selfie',
            status: _uploadStatus['selfie']!,
            onTap: () => _uploadDocument('selfie'),
          ),
          const SizedBox(height: 12),
          _buildStatusItem(
            title: 'Address Verification',
            status: _uploadStatus['address']!,
            onTap: () => _uploadDocument('address'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required String title,
    required String status,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Not Uploaded';
        break;
      case 'uploaded':
        statusColor = Colors.blue;
        statusIcon = Icons.cloud_upload;
        statusText = 'Uploaded';
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Processing';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Unknown';
    }

    return InkWell(
      onTap: status == 'pending' ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOcrResults() {
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
                Icons.document_scanner,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'OCR Results & Validation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOcrResult('Name', 'Amit Sharma', true),
          const SizedBox(height: 8),
          _buildOcrResult('DOB', '15/03/1985', true),
          const SizedBox(height: 8),
          _buildOcrResult('Address', 'Auto-filled from document', true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.yellow.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.yellow.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manual review may be required',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.yellow.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcrResult(String label, String value, bool matched) {
    return Row(
      children: [
        Icon(
          matched ? Icons.check_circle : Icons.error,
          color: matched ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: matched ? Colors.green : Colors.red,
            ),
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
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
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
                onPressed: _chooseFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose File'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
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
            onPressed: _submitForReview,
            icon: const Icon(Icons.send),
            label: const Text('Submit for Review'),
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

  void _uploadDocument(String type) {
    // Simulate upload process
    setState(() {
      _uploadStatus[type] = 'uploaded';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _uploadStatus[type] = 'processing';
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _uploadStatus[type] = 'completed';
            });

            // Simulate OCR results for Aadhaar
            if (type == 'aadhar') {
              _ocrResults = {
                'name': 'Amit Sharma',
                'dob': '15/03/1985',
                'address': 'Mumbai, Maharashtra',
              };
            }
          }
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading $type document...')),
    );
  }

  void _takePhoto() {
    // TODO: Implement camera capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera capture coming soon!')),
    );
  }

  void _chooseFromGallery() {
    // TODO: Implement gallery selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery selection coming soon!')),
    );
  }

  void _submitForReview() {
    bool allCompleted = _uploadStatus.values.every((status) => status == 'completed');

    if (!allCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Navigate to KYC verification status
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting documents for review...')),
    );
  }
}
