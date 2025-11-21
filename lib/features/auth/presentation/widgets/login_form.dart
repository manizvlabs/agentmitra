/// Login form widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _agentCodeController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _useAgentCode = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final authResponse = await viewModel.login(
      phoneNumber: _phoneController.text.trim(),
      password: _useAgentCode ? null : _passwordController.text,
      agentCode: _useAgentCode ? _agentCodeController.text.trim() : null,
    );

    if (authResponse != null && mounted) {
      Navigator.of(context).pushReplacementNamed('/customer-dashboard');
    }
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    final success = await viewModel.sendOtp(_phoneController.text.trim());

    if (success && mounted) {
      Navigator.of(context).pushNamed(
        '/otp-verification',
        arguments: _phoneController.text.trim(),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _agentCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (!_useAgentCode)
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            )
          else
            TextFormField(
              controller: _agentCodeController,
              decoration: const InputDecoration(
                labelText: 'Agent Code',
                hintText: 'Enter your agent code',
                prefixIcon: Icon(Icons.badge),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your agent code';
                }
                return null;
              },
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _useAgentCode = !_useAgentCode;
              });
            },
            child: Text(
              _useAgentCode
                  ? 'Use password instead'
                  : 'Use agent code instead',
            ),
          ),
          const SizedBox(height: 24),
          Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return ElevatedButton(
                onPressed: viewModel.isLoading ? null : _handleLogin,
                child: viewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _handleSendOtp,
            child: const Text('Login with OTP'),
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
    );
  }
}

