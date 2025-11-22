/// Enhanced Login form widget with comprehensive validation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/mocks/mock_auth_viewmodel_simple.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginForm({super.key, this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _agentCodeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _formAnimation;

  bool _isPasswordVisible = false;
  bool _useAgentCode = false;
  bool _rememberMe = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Add listeners to validate form in real-time
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _agentCodeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _agentCodeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      LoggerService().warning('Form validation failed');
      return;
    }

    LoggerService().info('Attempting login with phone: ${_phoneController.text}', tag: 'LoginForm');

    final viewModel = Provider.of<MockAuthViewModel>(context, listen: false);
    final authResponse = await viewModel.login(
      phoneNumber: _phoneController.text.trim(),
      password: _useAgentCode ? null : _passwordController.text,
      agentCode: _useAgentCode ? _agentCodeController.text.trim() : null,
    );

    if (authResponse != null && mounted) {
      LoggerService().info('Login successful', tag: 'LoginForm');

      // Save remember me preference
      if (_rememberMe) {
        // TODO: Save login credentials securely
      }

      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!.call();
      } else {
        context.go('/customer-dashboard');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      LoggerService().warning('Login failed', tag: 'LoginForm');
    }
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    LoggerService().info('Sending OTP to: ${_phoneController.text}', tag: 'LoginForm');

    final viewModel = Provider.of<MockAuthViewModel>(context, listen: false);
    await viewModel.sendOtp(_phoneController.text.trim());

    if (!viewModel.hasError && mounted) {
      LoggerService().info('OTP sent successfully', tag: 'LoginForm');
      context.go('/otp-verification', extra: _phoneController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your phone number'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      LoggerService().error('Failed to send OTP', tag: 'LoginForm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _formAnimation,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone Number Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter 10-digit phone number',
                prefixIcon: const Icon(Icons.phone_android),
                prefixText: '+91 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                counterText: '', // Hide counter
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length != 10) {
                  return 'Please enter a valid 10-digit phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Authentication Method Toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _useAgentCode = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_useAgentCode
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Password',
                          style: TextStyle(
                            color: !_useAgentCode
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _useAgentCode = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _useAgentCode
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Agent Code',
                          style: TextStyle(
                            color: _useAgentCode
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Password or Agent Code Field
            if (!_useAgentCode)
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              )
            else
              TextFormField(
                controller: _agentCodeController,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Agent Code',
                  hintText: 'Enter 6-digit agent code',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  counterText: '',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your agent code';
                  }
                  if (value.trim().length != 6) {
                    return 'Agent code must be 6 digits';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 16),

            // Remember Me Checkbox
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Login Buttons
            Consumer<MockAuthViewModel>(
              builder: (context, viewModel, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Primary Login Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: ElevatedButton(
                        onPressed: (viewModel.isLoading || !_isFormValid) ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _isFormValid ? 2 : 0,
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // OTP Login Button
                    OutlinedButton(
                      onPressed: viewModel.isLoading ? null : _handleSendOtp,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Login with OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Error Message
            Consumer<MockAuthViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage ?? 'An error occurred',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

