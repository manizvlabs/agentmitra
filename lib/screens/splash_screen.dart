import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'dart:async';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();

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

    // Navigate based on authentication state
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Check if user is already authenticated
        // For now, use demo logic - in production, check AuthViewModel.isAuthenticated
        final authViewModel = provider.Provider.of<AuthViewModel>(context, listen: false);
        final isAuthenticated = authViewModel.isAuthenticated;

        // Navigate based on authentication status
        if (isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/customer-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/welcome');
        }

        // Previous test navigation (removed):
        // Navigator.of(context).pushReplacementNamed('/test-phase1');
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
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
                          // Feature flag check indicator (UI simulation)
                          Text(
                            'Checking app features...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
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
