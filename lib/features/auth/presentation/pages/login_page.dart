/// Enhanced Login page with biometric authentication
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/logger_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _biometricAvailable = false;
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _checkBiometricSupport();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final isAvailable = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable = isAvailable && canCheckBiometrics && availableBiometrics.isNotEmpty;
        _isBiometricSupported = availableBiometrics.isNotEmpty;
      });

      LoggerService().info('Biometric support checked - Available: $_biometricAvailable, Supported: $_isBiometricSupported');
    } catch (e) {
      LoggerService().error('Biometric support check failed: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Agent Mitra',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        // Biometric authentication successful
        LoggerService().info('Biometric authentication successful');

        // Navigate to dashboard or show success
        context.go('/customer-dashboard');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService().error('Biometric authentication failed: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo/Brand Section
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your Agent Mitra account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Biometric Authentication (if available)
                if (_biometricAvailable) ...[
                  _buildBiometricSection(),
                  const SizedBox(height: 32),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],

                // Login Form
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return LoginForm(
                      onLoginSuccess: () {
                        context.go('/customer-dashboard');
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Additional Options
                _buildAdditionalOptions(),

                const SizedBox(height: 32),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getBiometricIcon(),
            size: 48,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Login',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your fingerprint or face to login instantly',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _authenticateWithBiometrics,
            icon: Icon(_getBiometricIcon()),
            label: const Text('Login with Biometrics'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    // In a real app, you'd check the available biometrics
    // For now, default to fingerprint
    return Icons.fingerprint;
  }

  Widget _buildAdditionalOptions() {
    return Column(
      children: [
        // Forgot Password
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password flow
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forgot password feature coming soon!')),
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Don't have an account
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to registration or onboarding
                context.go('/onboarding');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Get Started',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your login credentials are encrypted and secure.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

