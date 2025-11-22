/// Enhanced OTP Verification page with Material Design 3
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../core/services/logger_service.dart';
import '../widgets/otp_input.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  int _remainingSeconds = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Listen to OTP controller changes for auto-verification
    _otpController.addListener(_onOtpChanged);

    LoggerService().info('OTP verification page initialized for: ${widget.phoneNumber}', tag: 'OTPVerification');
  }

  void _onOtpChanged() {
    LoggerService().info('OTP changed: ${_otpController.text.length} digits', tag: 'OTPVerification');
    // Auto-verify when OTP is complete (6 digits)
    if (_otpController.text.length == 6 && !_isVerifying) {
      LoggerService().info('Auto-verifying complete OTP', tag: 'OTPVerification');
      _verifyOtp();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 60;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    LoggerService().info('Verifying OTP for: ${widget.phoneNumber}', tag: 'OTPVerification');

    setState(() {
      _isVerifying = true;
    });

    try {
      // For web demo, simulate successful verification
      // In a real app, this would use the AuthViewModel
      LoggerService().info('OTP verification simulation for: ${widget.phoneNumber}', tag: 'OTPVerification');

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // For demo purposes, accept any 6-digit OTP
      if (otp.length == 6 && mounted) {
        LoggerService().info('OTP verification successful (demo)', tag: 'OTPVerification');

        Navigator.of(context).pushNamedAndRemoveUntil('/customer-dashboard', (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        LoggerService().warning('Invalid OTP format', tag: 'OTPVerification');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP. Please enter 6 digits.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      LoggerService().error('OTP verification error: $e', tag: 'OTPVerification');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    LoggerService().info('Resending OTP to: ${widget.phoneNumber} (demo)', tag: 'OTPVerification');

    setState(() {
      _isResending = true;
    });

    try {
      // For demo purposes, simulate successful OTP resend
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        LoggerService().info('OTP resent successfully (demo)', tag: 'OTPVerification');
        _startTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService().error('OTP resend error: $e', tag: 'OTPVerification');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Verification Code',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a 6-digit code to ${widget.phoneNumber}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // OTP Input
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  alignment: Alignment.center,
                  child: OtpInput(
                    controller: _otpController,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Resend Timer/Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _canResend
                          ? "Didn't receive the code? "
                          : 'Resend code in ${_remainingSeconds}s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_canResend)
                      TextButton(
                        onPressed: _isResending ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        child: _isResending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend'),
                      ),
                  ],
                ),
              ),

              const Spacer(),

              // Verify Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_otpController.text.length == 6 && !_isVerifying)
                        ? _verifyOtp
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify & Continue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Getting Started CTA Link
              Center(
                child: TextButton(
                  onPressed: () {
                    LoggerService().info('Getting started CTA clicked', tag: 'OTPVerification');
                    // Navigate to getting started/onboarding flow
                    Navigator.of(context).pushReplacementNamed('/welcome');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Skip verification for demo →'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

}

