import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/feature_flag_service.dart';
import '../shared/widgets/copyright_footer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _trialBannerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _trialBannerAnimation;

  bool _showTrialBanner = false;
  bool _trialFeaturesEnabled = false;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Trial banner animation controller
    _trialBannerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _trialBannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trialBannerController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Check feature flags and auth status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    // Check feature flags for trial features
    final featureFlagService = FeatureFlagService();
    _trialFeaturesEnabled = await featureFlagService.isFeatureEnabled('trial_enabled');

    if (_trialFeaturesEnabled) {
      setState(() {
        _showTrialBanner = true;
      });
      // Show trial banner after a delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _trialBannerController.forward();
        }
      });
    }

    // Check auth status
    await _checkAuthStatus();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _trialBannerController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = AuthService();
      final isAuthenticated = await authService.isAuthenticated();

      if (isAuthenticated && mounted) {
        // Get user role and navigate accordingly
        final user = await authService.getCurrentUser();
        if (user != null) {
          final role = user.role?.toLowerCase() ?? 'policyholder';
          
          // Navigate based on role
          if (mounted) {
            switch (role) {
              case 'policyholder':
              case 'customer':
                Navigator.of(context).pushReplacementNamed('/customer-dashboard');
                break;
              case 'agent':
              case 'junior_agent':
              case 'senior_agent':
                Navigator.of(context).pushReplacementNamed('/agent-dashboard');
                break;
              case 'provider_admin':
              case 'admin':
                Navigator.of(context).pushReplacementNamed('/agent-config-dashboard');
                break;
              case 'super_admin':
                Navigator.of(context).pushReplacementNamed('/agent-config-dashboard');
                break;
              default:
                // Stay on welcome screen
                break;
            }
          }
        }
      }
    } catch (e) {
      LoggerService().error('Error checking auth status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a237e),
              const Color(0xFF3949ab),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 20),

                // Main content area
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Welcome illustration/icon with animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.handshake,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),

                            // Welcome title
                            const Text(
                              'Welcome to LIC Agent App',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 16),

                            // Subtitle
                            Text(
                              'Connect with your agent & manage policies',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 40),

                            // Animated Trial Banner (only shown if trial features are enabled)
                            if (_showTrialBanner && _trialFeaturesEnabled)
                              AnimatedBuilder(
                                animation: _trialBannerController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _trialBannerAnimation.value,
                                    child: Opacity(
                                      opacity: _trialBannerAnimation.value,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 20),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF4caf50), Color(0xFF66bb6a)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4caf50).withOpacity(0.3),
                                              blurRadius: 15,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.celebration,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '🎉 14-Day Free Trial Available!',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Explore all premium features • No commitment required',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom action buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Get Started button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/phone-verification');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1a237e),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'GET STARTED',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Login option
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/phone-verification');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // Copyright and Trademark Footer
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: CopyrightFooter(
                            showFullDetails: false,
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
