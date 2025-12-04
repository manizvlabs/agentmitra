import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';
import 'data_import_progress_screen.dart';

class ExcelUploadScreen extends StatefulWidget {
  const ExcelUploadScreen({super.key});

  @override
  State<ExcelUploadScreen> createState() => _ExcelUploadScreenState();
}

class _ExcelUploadScreenState extends State<ExcelUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  PlatformFile? _selectedFile;
  bool _isValidating = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _validationStatus = '';
  Map<String, dynamic> _fileValidation = {};
  List<String> _validationErrors = [];
  List<String> _validationWarnings = [];

  // File requirements
  final List<String> _allowedExtensions = ['xlsx', 'xls', 'csv'];
  final int _maxFileSizeMB = 10;
  final int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
        withData: false, // We'll read the file later if needed
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        setState(() {
          _selectedFile = file;
          _fileValidation = {};
          _validationErrors = [];
          _validationWarnings = [];
        });

        // Validate the selected file
        await _validateFile(file);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      _showErrorSnackBar('Error selecting file: $e');
    }
  }

  Future<void> _validateFile(PlatformFile file) async {
    setState(() {
      _isValidating = true;
      _validationStatus = 'Validating file...';
    });

    try {
      // Basic file validation
      final validation = await _performFileValidation(file);

      setState(() {
        _fileValidation = validation;
        _validationErrors = validation['errors'] ?? [];
        _validationWarnings = validation['warnings'] ?? [];
        _isValidating = false;
        _validationStatus = validation['isValid'] ? 'File validated successfully' : 'File validation failed';
      });

    } catch (e) {
      debugPrint('Error validating file: $e');
      setState(() {
        _isValidating = false;
        _validationStatus = 'Validation error';
        _validationErrors = ['Failed to validate file: $e'];
      });
    }
  }

  Future<Map<String, dynamic>> _performFileValidation(PlatformFile file) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Check file extension
    final extension = file.extension?.toLowerCase();
    if (extension == null || !_allowedExtensions.contains(extension)) {
      errors.add('Invalid file type. Allowed formats: ${_allowedExtensions.join(", ")}');
    }

    // Check file size
    if (file.size > _maxFileSizeBytes) {
      errors.add('File too large. Maximum size: ${_maxFileSizeMB}MB');
    }

    // Additional validation can be added here
    // For example: reading file headers, checking column structure, etc.

    // Simulate reading file metadata
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation results (in real app, this would analyze the file)
    if (extension == 'xlsx' || extension == 'xls') {
      // Check for Excel-specific issues
      warnings.add('Excel files may contain formatting that could affect import');
    }

    if (file.size < 1024) { // Less than 1KB
      warnings.add('File seems very small. Please verify it contains data');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'fileInfo': {
        'name': file.name,
        'size': file.size,
        'extension': extension,
        'path': file.path,
      },
    };
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null || !_fileValidation['isValid']) {
      _showErrorSnackBar('Please select a valid file first');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _uploadProgress = progress;
        });
      }

      // Call actual upload API (from project plan section 2.1: POST /api/v1/import/upload)
      final response = await ApiService.post(
        '/api/v1/import/upload',
        data: {
          'fileName': _selectedFile!.name,
          'fileSize': _selectedFile!.size,
          'fileType': _selectedFile!.extension,
          // In real implementation, you'd upload the file data
        },
      );

      if (response['success'] == true) {
        final importId = response['data']['importId'];
        final totalRecords = response['data']['totalRecords'] ?? 0;

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DataImportProgressScreen(
                importId: importId,
                fileName: _selectedFile!.name,
                totalRecords: totalRecords,
              ),
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Upload failed');
      }

    } catch (e) {
      debugPrint('Error uploading file: $e');
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorSnackBar('Upload failed: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedFile = null;
      _fileValidation = {};
      _validationErrors = [];
      _validationWarnings = [];
      _validationStatus = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Excel Upload',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LoadingOverlay(
            isLoading: _isUploading,
            loadingMessage: 'Uploading file... ${(uploadProgress * 100).toInt()}%',
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Upload Excel File',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Select and upload an Excel file to import data into the system',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // File Requirements Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'File Requirements',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildRequirementItem(
                            Icons.file_present,
                            'Supported formats',
                            _allowedExtensions.join(", ").toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem(
                            Icons.storage,
                            'Maximum file size',
                            '${_maxFileSizeMB}MB',
                          ),
                          const SizedBox(height: 12),
                          _buildRequirementItem(
                            Icons.table_chart,
                            'File structure',
                            'First row should contain headers',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // File Selection Area
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: _isValidating || _isUploading ? null : _pickFile,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedFile != null
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).dividerColor,
                            width: _selectedFile != null ? 2 : 1,
                            style: _selectedFile != null ? BorderStyle.solid : BorderStyle.none,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _selectedFile != null ? Icons.file_present : Icons.cloud_upload,
                              size: 64,
                              color: _selectedFile != null
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).iconTheme.color?.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFile != null
                                  ? _selectedFile!.name
                                  : 'Tap to select Excel file',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _selectedFile != null
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedFile != null
                                  ? 'File size: ${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                                  : 'Supported formats: ${_allowedExtensions.join(", ").toUpperCase()}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Validation Status
                  if (_validationStatus.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: _fileValidation['isValid'] == true
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              _fileValidation['isValid'] == true
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: _fileValidation['isValid'] == true
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _validationStatus,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _fileValidation['isValid'] == true
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Validation Errors
                  if (_validationErrors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.red.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  'Validation Errors',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._validationErrors.map((error) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $error',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red[600],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Validation Warnings
                  if (_validationWarnings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.orange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Warnings',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._validationWarnings.map((warning) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• $warning',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange[600],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      if (_selectedFile != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isValidating || _isUploading ? null : _resetSelection,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Clear Selection'),
                          ),
                        ),
                      if (_selectedFile != null) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (_selectedFile == null ||
                                     !_fileValidation['isValid'] == true ||
                                     _isValidating ||
                                     _isUploading)
                              ? null
                              : _uploadFile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Upload & Import'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Help text
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Show help dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Upload Help'),
                            content: const Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• Ensure your Excel file has headers in the first row'),
                                Text('• Check that all required columns are present'),
                                Text('• Verify data formats match the expected types'),
                                Text('• Remove any empty rows before uploading'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Need help with file format?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
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
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
