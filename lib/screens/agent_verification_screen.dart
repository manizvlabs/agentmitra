import 'package:flutter/material.dart';
import '../core/widgets/offline_indicator.dart';

/// Agent Verification Screen for Customer Portal
/// Verifies agent identity and establishes connection for data upload
class AgentVerificationScreen extends StatefulWidget {
  const AgentVerificationScreen({super.key});

  @override
  State<AgentVerificationScreen> createState() => _AgentVerificationScreenState();
}

class _AgentVerificationScreenState extends State<AgentVerificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _verificationStatus = 'pending'; // pending, calling, verifying, success, failed

  // TODO: Implement real agent verification API integration
  final Map<String, String> _agentData = {};

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

                  // Agent Details
                  _buildAgentDetails(),

                  const SizedBox(height: 24),

                  // Verification Methods
                  _buildVerificationMethods(),

                  const SizedBox(height: 24),

                  // Verification Status
                  _buildVerificationStatus(),

                  const SizedBox(height: 24),

                  // Next Steps
                  if (_verificationStatus == 'success') _buildNextSteps(),

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
        'Agent Verification',
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
              Icons.verified_user,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Verifying Agent Identity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Secure Agent Authentication',
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

  Widget _buildAgentDetails() {
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
            'Agent Details to Verify',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAgentDetailRow('Name', _agentData['name']!, Icons.person),
          const SizedBox(height: 12),
          _buildAgentDetailRow('Agent Code', _agentData['code']!, Icons.badge),
          const SizedBox(height: 12),
          _buildAgentDetailRow('Phone', _agentData['phone']!, Icons.phone),
          const SizedBox(height: 12),
          _buildAgentDetailRow('Email', _agentData['email']!, Icons.email),
          const SizedBox(height: 12),
          _buildAgentDetailRow('Branch', _agentData['branch']!, Icons.business),
        ],
      ),
    );
  }

  Widget _buildAgentDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationMethods() {
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
            'Verification Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildVerificationMethod(
            icon: Icons.phone,
            title: 'Direct Call to Agent',
            description: 'Agent will confirm your identity',
            details: '📋 You\'ll receive verification code',
            color: Colors.green,
            onTap: _startPhoneVerification,
            isActive: _verificationStatus == 'calling',
          ),
          const SizedBox(height: 16),
          _buildVerificationMethod(
            icon: Icons.email,
            title: 'Email Verification',
            description: 'Agent receives verification request',
            details: '✅ Agent approves connection',
            color: Colors.blue,
            onTap: _startEmailVerification,
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationMethod({
    required IconData icon,
    required String title,
    required String description,
    required String details,
    required Color color,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return InkWell(
      onTap: _verificationStatus == 'pending' ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
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
                      color: isActive ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? color.withOpacity(0.8) : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
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
            'Verification Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    String statusText;
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (_verificationStatus) {
      case 'pending':
        statusText = 'Ready to Verify';
        statusColor = Colors.grey;
        statusIcon = Icons.hourglass_empty;
        statusMessage = 'Choose a verification method to begin';
        break;
      case 'calling':
        statusText = 'Calling Agent...';
        statusColor = Colors.blue;
        statusIcon = Icons.phone_in_talk;
        statusMessage = 'Please wait while we connect you to your agent';
        break;
      case 'verifying':
        statusText = 'Verifying...';
        statusColor = Colors.orange;
        statusIcon = Icons.verified;
        statusMessage = 'Agent is confirming your identity';
        break;
      case 'success':
        statusText = 'Agent Confirmed!';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusMessage = 'Connection established successfully';
        break;
      case 'failed':
        statusText = 'Verification Failed';
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusMessage = 'Unable to verify agent. Please try again';
        break;
      default:
        statusText = 'Unknown Status';
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusMessage = 'Status unknown';
    }

    return Container(
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
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
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
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Next Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNextStep(
            '📤 Agent will upload your policy data',
            'Policy details, premium history, and documents',
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '📱 You\'ll receive data available notification',
            'Push notification when data is ready',
          ),
          const SizedBox(height: 12),
          _buildNextStep(
            '🚀 Full app features will be unlocked',
            'Access to payments, analytics, and more',
          ),
        ],
      ),
    );
  }

  Widget _buildNextStep(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
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
    return Row(
      children: [
        if (_verificationStatus != 'success') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _callAgent,
              icon: const Icon(Icons.phone),
              label: const Text('Call Agent'),
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
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _verificationStatus == 'success' ? _goToHome : _tryAgain,
            icon: Icon(_verificationStatus == 'success' ? Icons.home : Icons.refresh),
            label: Text(_verificationStatus == 'success' ? 'Go to Home' : 'Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _verificationStatus == 'success' ? Colors.blue : Colors.red,
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

  void _startPhoneVerification() {
    setState(() {
      _verificationStatus = 'calling';
    });

    // Simulate calling process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _verificationStatus = 'verifying';
        });

        // Simulate verification process
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _verificationStatus = 'success';
            });
          }
        });
      }
    });
  }

  void _startEmailVerification() {
    setState(() {
      _verificationStatus = 'verifying';
    });

    // Simulate email verification process
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _verificationStatus = 'success';
        });
      }
    });
  }

  void _callAgent() {
    // TODO: Implement actual calling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling agent...')),
    );
  }

  void _tryAgain() {
    setState(() {
      _verificationStatus = 'pending';
    });
  }

  void _goToHome() {
    // TODO: Navigate to home with data available
    Navigator.of(context).pushReplacementNamed('/customer-dashboard');
  }
}
