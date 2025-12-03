import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:async';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../core/services/feature_flag_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/rbac_service.dart';
import '../shared/widgets/vyaptix_logo.dart';
import '../shared/widgets/copyright_footer.dart';
import '../shared/theme/app_theme.dart';

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

      // Check if user is authenticated
      final authViewModel = provider.Provider.of<AuthViewModel>(context, listen: false);
      final isAuthenticated = authViewModel.isAuthenticated;

      // If not authenticated, skip feature flag validation and assume essential features are enabled
      if (!isAuthenticated) {
        debugPrint('User not authenticated, skipping feature flag validation');
        setState(() {
          _validationStatus = 'Initializing app...';
          _featureFlagsValidated = true;
          // Assume essential features are enabled when not authenticated
          _essentialFeatures = {
            for (final feature in essentialFeatures) feature: true
          };
        });

        Timer(const Duration(milliseconds: 1000), () async {
          if (mounted) {
            await _navigateBasedOnState();
          }
        });
        return;
      }

      // Check each essential feature only if authenticated
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
          results[feature] = true; // Default to enabled on error (for essential features)
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
        _validationStatus = 'App ready!';
        // Assume essential features are enabled on error
        _essentialFeatures = {
          'dashboard_enabled': true,
          'login_enabled': true,
          'registration_enabled': true,
          'otp_verification_enabled': true,
        };
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
      final userRole = currentUser?.userRole;

      // Debug logging
      debugPrint('🔍 Splash Screen Debug:');
      debugPrint('  - Current User: ${currentUser?.fullName}');
      debugPrint('  - User ID: ${currentUser?.userId}');
      debugPrint('  - Legacy Role: ${currentUser?.role}');
      debugPrint('  - Roles List: ${currentUser?.roles}');
      debugPrint('  - UserRole Enum: $userRole');
      debugPrint('  - UserRole Value: ${userRole?.value}');

      // Determine route based on user role (Phase 1: Navigation Architecture)
      String targetRoute;
      if (userRole == null) {
        // No role, go to welcome
        targetRoute = '/welcome';
      } else {
        // Route to appropriate navigation container based on role
        switch (userRole) {
          case UserRole.policyholder:
          case UserRole.regionalManager:
            targetRoute = '/customer-portal';
            break;
          case UserRole.juniorAgent:
          case UserRole.seniorAgent:
            targetRoute = '/agent-portal';
            break;
          case UserRole.superAdmin:
          case UserRole.providerAdmin:
            targetRoute = '/admin-portal';
            break;
          default:
            targetRoute = '/welcome';
        }
      }

      debugPrint('🚀 Splash Screen navigating to: $targetRoute');
      Navigator.of(context).pushReplacementNamed(targetRoute);
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
      backgroundColor: AppTheme.vyaptixBlueDark,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.vyaptixBlueDark,
                AppTheme.vyaptixBlue,
                AppTheme.vyaptixBlueLight,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section with VyaptIX Logo
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
                              // VyaptIX Logo
                              const VyaptixLogo(
                                size: 140,
                                showTagline: true,
                                showPoweredBy: false,
                              ),
                              const SizedBox(height: 32),
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
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
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

              // Powered by VyaptIX and Copyright Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FadeTransition(
                  opacity: _loadingFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 1,
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const VyaptixLogo(
                        size: 60,
                        showTagline: false,
                        showPoweredBy: true,
                      ),
                      const SizedBox(height: 24),
                      // Copyright and Trademark Information
                      const CopyrightFooter(
                        showFullDetails: true,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
