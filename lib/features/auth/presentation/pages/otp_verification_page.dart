/// OTP Verification page
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../viewmodels/auth_viewmodel.dart';
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

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  int _remainingSeconds = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
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
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final authResponse = await viewModel.verifyOtp(
      phoneNumber: widget.phoneNumber,
      otp: _otpController.text,
    );

    if (authResponse != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/customer-dashboard');
    } else if (mounted && viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'Verification failed')),
      );
    }
  }

  Future<void> _resendOtp() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await viewModel.sendOtp(widget.phoneNumber);
    
    if (success && mounted) {
      setState(() {
        _remainingSeconds = 60;
        _canResend = false;
      });
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              OtpInput(controller: _otpController),
              const SizedBox(height: 24),
              Consumer<AuthViewModel>(
                builder: (context, viewModel, child) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _verifyOtp,
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify OTP'),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (!_canResend)
                Text(
                  'Resend OTP in $_remainingSeconds seconds',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                )
              else
                TextButton(
                  onPressed: _resendOtp,
                  child: const Text('Resend OTP'),
                ),
              if (context.watch<AuthViewModel>().hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    context.watch<AuthViewModel>().errorMessage ?? '',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

