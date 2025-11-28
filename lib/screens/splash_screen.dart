import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:async';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../core/services/feature_flag_service.dart';
import '../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;

  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingFadeAnimation;

  // Feature flag validation
  late FeatureFlagService _featureFlagService;
  bool _featureFlagsValidated = false;
  String _validationStatus = 'Initializing...';
  Map<String, bool> _essentialFeatures = {};

  @override
  void initState() {
    super.initState();

    _featureFlagService = FeatureFlagService();

    // Logo animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // Loading animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _loadingFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _logoAnimationController.forward();

    Timer(const Duration(milliseconds: 800), () {
      _loadingAnimationController.forward();
    });

    // Start feature flag validation
    _validateFeatureFlags();
  }

  /// Validate essential feature flags
  Future<void> _validateFeatureFlags() async {
    try {
      setState(() {
        _validationStatus = 'Checking app features...';
      });

      // Essential features that must be available
      final essentialFeatures = [
        'dashboard_enabled',
        'login_enabled',
        'registration_enabled',
        'otp_verification_enabled',
      ];

      final results = <String, bool>{};

      // Check each essential feature
      for (final feature in essentialFeatures) {
        try {
          final isEnabled = await _featureFlagService.isFeatureEnabled(feature);
          results[feature] = isEnabled;
          setState(() {
            _validationStatus = 'Checking $feature...';
            _essentialFeatures = Map.from(results);
          });
        } catch (e) {
          debugPrint('Error checking feature flag $feature: $e');
          results[feature] = false; // Default to disabled on error
        }
      }

      setState(() {
        _featureFlagsValidated = true;
        _essentialFeatures = results;
        _validationStatus = 'App ready!';
      });

      // Wait a bit for smooth UX, then navigate
      Timer(const Duration(milliseconds: 1500), () async {
        if (mounted) {
          await _navigateBasedOnState();
        }
      });

    } catch (e) {
      debugPrint('Error validating feature flags: $e');
      // Continue with navigation even if feature flag validation fails
      setState(() {
        _featureFlagsValidated = true;
        _validationStatus = 'Proceeding with limited features...';
      });

      Timer(const Duration(milliseconds: 1000), () async {
        if (mounted) {
          await _navigateBasedOnState();
        }
      });
    }
  }

  /// Navigate based on authentication and feature flag validation
  Future<void> _navigateBasedOnState() async {
    if (!mounted) return;

    final authViewModel = provider.Provider.of<AuthViewModel>(context, listen: false);
    final isAuthenticated = authViewModel.isAuthenticated;

    // Check if essential features are available
    final hasEssentialFeatures = _essentialFeatures.values.every((enabled) => enabled);

    if (!hasEssentialFeatures) {
      // Show error screen if essential features are disabled
      _showFeatureDisabledDialog();
      return;
    }

    // Navigate based on authentication status
    if (isAuthenticated) {
      // Check user role for appropriate dashboard
      final currentUser = await AuthService().getCurrentUser(context);
      if (currentUser?.role == 'agent' || currentUser?.role?.contains('agent') == true) {
        Navigator.of(context).pushReplacementNamed('/agent-dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/customer-dashboard');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  /// Show dialog when essential features are disabled
  void _showFeatureDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Service Unavailable'),
        content: const Text(
          'Some essential app features are currently unavailable. '
          'Please try again later or contact support.'
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Force quit the app
              // Note: This is not ideal for mobile apps, but for demo purposes
              Navigator.of(context).pop();
              // In a real app, you might want to show a maintenance screen instead
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    _featureFlagService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e), // Deep blue background
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a237e), // Deep blue
                Color(0xFF3949ab), // Lighter blue
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo/Icon placeholder (using emoji as per wireframes)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.business_center,
                                  size: 60,
                                  color: Color(0xFF1a237e),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // App Name
                              const Text(
                                'AGENT MITRA',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Tagline
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Friend of Agents',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _loadingAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _loadingFadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Loading indicator
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Loading text
                          Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Feature flag check indicator
                          Text(
                            _validationStatus,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),

                          // Show feature validation progress
                          if (_essentialFeatures.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              child: Column(
                                children: [
                                  Text(
                                    'Validated ${_essentialFeatures.length} features',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: _essentialFeatures.length / 4, // Assuming 4 essential features
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom spacing
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
