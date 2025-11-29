import 'package:flutter/material.dart';
import '../core/widgets/offline_indicator.dart';
import '../core/widgets/context_aware_back_button.dart';
import '../core/services/navigation_service.dart';

// Add this import for WorkflowStepIndicator
import '../core/widgets/context_aware_back_button.dart';

/// KYC Verification Status Screen for Customer Portal
/// Shows verification progress, checklist, and next steps after document upload
class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Verification progress simulation
  double _overallProgress = 0.0;
  Map<String, VerificationStep> _verificationSteps = {
    'document_validation': VerificationStep('Document Validation', 'pending'),
    'identity_verification': VerificationStep('Identity Verification', 'pending'),
    'address_verification': VerificationStep('Address Verification', 'pending'),
    'database_check': VerificationStep('Database Check', 'pending'),
    'manual_review': VerificationStep('Manual Review', 'pending'),
  };

  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // Biometric capture state
  bool _biometricEnabled = false;
  String? _biometricType; // 'fingerprint' or 'face'
  bool _isCapturingBiometric = false;

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

    // Simulate verification progress
    _startVerificationProcess();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startVerificationProcess() {
    // Simulate the verification process with realistic timing
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _verificationSteps['document_validation'] = VerificationStep('Document Validation', 'completed');
          _overallProgress = 0.2;
        });
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _verificationSteps['identity_verification'] = VerificationStep('Identity Verification', 'completed');
          _overallProgress = 0.4;
        });
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _verificationSteps['address_verification'] = VerificationStep('Address Verification', 'completed');
          _overallProgress = 0.6;
        });
      }
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() {
          _verificationSteps['database_check'] = VerificationStep('Database Check', 'processing');
          _overallProgress = 0.8;
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _verificationSteps['database_check'] = VerificationStep('Database Check', 'completed');
          _verificationSteps['manual_review'] = VerificationStep('Manual Review', 'processing');
          _overallProgress = 0.9;
        });
      }
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _verificationSteps['manual_review'] = VerificationStep('Manual Review', 'completed');
          _overallProgress = 1.0;
        });
      }
    });
  }

  int _getCurrentStep() {
    // Calculate current step based on verification progress
    if (_overallProgress >= 1.0) return 4; // Completed
    if (_overallProgress >= 0.8) return 3; // Manual Review
    if (_overallProgress >= 0.6) return 2; // Database Check
    if (_overallProgress >= 0.3) return 1; // Identity Verification
    return 0; // Document Validation
  }

  @override
  Widget build(BuildContext context) {
    // Initialize breadcrumb for this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService().addNavigationItem('KYC Verification', '/kyc-verification');
    });

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

                  const SizedBox(height: 16),

                  // Workflow Step Indicator
                  WorkflowStepIndicator(
                    currentStep: _getCurrentStep(),
                    totalSteps: 5,
                    stepLabels: const [
                      'Document Upload',
                      'Validation',
                      'Verification',
                      'Review',
                      'Approval'
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Overall Progress
                  _buildOverallProgress(),

                  const SizedBox(height: 24),

                  // Verification Checklist
                  _buildVerificationChecklist(),

                  const SizedBox(height: 24),

                  // Current Status
                  _buildCurrentStatus(),

                  const SizedBox(height: 24),

                  // What Happens Next
                  _buildWhatHappensNext(),

                  const SizedBox(height: 24),

                  // Biometric Setup Section
                  _buildBiometricSetup(),

                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildNotificationSettings(),

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
    return ContextAwareAppBar(
      title: 'KYC Verification',
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      showBreadcrumbs: true,
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
              Icons.verified_user,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Know Your Customer Verification',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Verification Progress & Status',
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

  Widget _buildOverallProgress() {
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
              const Text(
                'Overall Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(_overallProgress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _overallProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _overallProgress == 1.0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressMessage(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _getProgressMessage() {
    if (_overallProgress == 0.0) {
      return 'Starting verification process...';
    } else if (_overallProgress < 0.5) {
      return 'Validating documents...';
    } else if (_overallProgress < 0.8) {
      return 'Checking identity and address...';
    } else if (_overallProgress < 1.0) {
      return 'Final verification steps...';
    } else {
      return 'Verification completed successfully!';
    }
  }

  Widget _buildVerificationChecklist() {
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
            'Verification Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._verificationSteps.entries.map((entry) {
            return _buildVerificationStep(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildVerificationStep(String key, VerificationStep step) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (step.status) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case 'processing':
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Processing';
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Failed';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus() {
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
            'Current Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _overallProgress == 1.0 ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _overallProgress == 1.0 ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _overallProgress == 1.0 ? Icons.check_circle : Icons.info,
                  color: _overallProgress == 1.0 ? Colors.green : Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _overallProgress == 1.0 ? 'Verification Completed!' : 'Processing your documents...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _overallProgress == 1.0 ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _overallProgress == 1.0
                            ? 'Your identity has been verified successfully'
                            : 'Estimated completion: 2-3 business days',
                        style: TextStyle(
                          fontSize: 12,
                          color: _overallProgress == 1.0
                              ? Colors.green.withOpacity(0.8)
                              : Colors.blue.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatHappensNext() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.arrow_forward,
                color: Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'What Happens Next?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNextStep(
            '✅ Approved: Full app access unlocked',
            'You\'ll receive immediate access to all features',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '⚠️ Additional Info Needed: We\'ll contact you',
            'May require additional documentation or clarification',
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '❌ Rejected: Reason provided with appeal option',
            'You can appeal the decision with additional evidence',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(String title, String description, Color color) {
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricSetup() {
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
              Icon(Icons.fingerprint, color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Biometric Authentication Setup',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Enable biometric authentication for faster and secure access to your account.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Biometric Login'),
            subtitle: Text(_biometricEnabled ? 'Biometric authentication is active' : 'Tap to enable'),
            value: _biometricEnabled,
            onChanged: (value) {
              if (value) {
                _showBiometricTypeDialog();
              } else {
                setState(() {
                  _biometricEnabled = false;
                  _biometricType = null;
                });
              }
            },
            activeColor: Theme.of(context).primaryColor,
          ),
          if (_biometricEnabled && _biometricType != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _biometricType == 'fingerprint' ? Icons.fingerprint : Icons.face,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _biometricType == 'fingerprint'
                          ? 'Fingerprint authentication enabled'
                          : 'Face ID authentication enabled',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  if (_isCapturingBiometric)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showBiometricTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Biometric Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.blue),
              title: const Text('Fingerprint'),
              subtitle: const Text('Use your fingerprint to unlock'),
              onTap: () {
                Navigator.pop(context);
                _captureBiometric('fingerprint');
              },
            ),
            ListTile(
              leading: const Icon(Icons.face, color: Colors.purple),
              title: const Text('Face ID'),
              subtitle: const Text('Use facial recognition to unlock'),
              onTap: () {
                Navigator.pop(context);
                _captureBiometric('face');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _captureBiometric(String type) {
    setState(() {
      _isCapturingBiometric = true;
    });

    // Simulate biometric capture
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _biometricEnabled = true;
          _biometricType = type;
          _isCapturingBiometric = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${type == 'fingerprint' ? 'Fingerprint' : 'Face ID'} authentication enabled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  Widget _buildNotificationSettings() {
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
            'Notification Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Stay updated on your verification status',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationOption(
            'Push notifications',
            'Instant alerts on your device',
            _pushNotifications,
            (value) => setState(() => _pushNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildNotificationOption(
            'Email notifications',
            'Status updates via email',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
          const SizedBox(height: 12),
          _buildNotificationOption(
            'SMS alerts',
            'Important updates via SMS',
            _smsNotifications,
            (value) => setState(() => _smsNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
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
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing status...')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Check Status'),
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
          child: ElevatedButton.icon(
            onPressed: _overallProgress == 1.0 ? _goToHome : null,
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _overallProgress == 1.0 ? Colors.red : Colors.grey,
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

  void _goToHome() {
    // TODO: Navigate to home with full access
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome! Full app access unlocked.')),
    );
  }
}

/// Data class for verification steps
class VerificationStep {
  final String title;
  final String status; // pending, processing, completed, failed

  VerificationStep(this.title, this.status);
}
