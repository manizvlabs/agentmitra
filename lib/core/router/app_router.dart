import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/phone_verification_screen.dart';
import '../../screens/trial_setup_screen.dart';
import '../../screens/trial_expiration_screen.dart';
import '../../screens/policy_details_screen.dart';
import '../../screens/whatsapp_integration_screen.dart';
import '../../screens/learning_center_screen.dart';
import '../../screens/agent_config_dashboard.dart';
import '../../screens/roi_analytics_dashboard.dart';
import '../../screens/marketing_campaign_builder.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/payments/presentation/pages/new_policy_page.dart';
import '../../features/payments/presentation/pages/new_claim_page.dart';
import '../../features/analytics/presentation/pages/reports_page.dart';
import '../../screens/my_policies_screen.dart';
import '../../features/agent/presentation/pages/agent_profile_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';

/// Application Router Configuration
/// Uses GoRouter for declarative routing with deep linking support
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Welcome Flow
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Authentication Flow
      GoRoute(
        path: '/phone-verification',
        name: 'phone-verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),

      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OtpVerificationPage(phoneNumber: phoneNumber ?? '');
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Onboarding Flow
      GoRoute(
        path: '/trial-setup',
        name: 'trial-setup',
        builder: (context, state) => const TrialSetupScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: '/trial-expiration',
        name: 'trial-expiration',
        builder: (context, state) => const TrialExpirationScreen(),
      ),

      // Customer Portal
      GoRoute(
        path: '/customer-dashboard',
        name: 'customer-dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: '/policy-details',
        name: 'policy-details',
        builder: (context, state) => const PolicyDetailsScreen(),
      ),

      GoRoute(
        path: '/whatsapp-integration',
        name: 'whatsapp-integration',
        builder: (context, state) => const WhatsappIntegrationScreen(),
      ),

      GoRoute(
        path: '/smart-chatbot',
        name: 'smart-chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationPage(),
      ),

      GoRoute(
        path: '/learning-center',
        name: 'learning-center',
        builder: (context, state) => const LearningCenterScreen(),
      ),

      // Agent Portal
      GoRoute(
        path: '/agent-config-dashboard',
        name: 'agent-config-dashboard',
        builder: (context, state) => const AgentConfigDashboard(),
      ),

      GoRoute(
        path: '/roi-analytics',
        name: 'roi-analytics',
        builder: (context, state) => const RoiAnalyticsDashboard(),
      ),

      GoRoute(
        path: '/campaign-builder',
        name: 'campaign-builder',
        builder: (context, state) => const MarketingCampaignBuilder(),
      ),

      // Policy Management Routes
      GoRoute(
        path: '/new-policy',
        name: 'new-policy',
        builder: (context, state) => const NewPolicyPage(),
      ),

      GoRoute(
        path: '/new-claim',
        name: 'new-claim',
        builder: (context, state) => const NewClaimPage(),
      ),

      GoRoute(
        path: '/policies',
        name: 'policies',
        builder: (context, state) => const MyPoliciesScreen(),
      ),

      GoRoute(
        path: '/policy/create',
        name: 'policy-create',
        builder: (context, state) => const NewPolicyPage(),
      ),

      // Reports Route
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const AgentProfilePage(),
      ),

      // Customers Route
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
      ),

      // Demo route (for development)
      GoRoute(
        path: '/demo',
        name: 'demo',
        builder: (context, state) => const _DemoNavigation(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}

/// Demo Navigation Widget for Development
class _DemoNavigation extends StatelessWidget {
  const _DemoNavigation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Mitra UI Demo'),
        backgroundColor: const Color(0xFF1a237e),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '🎨 Agent Mitra Unauthenticated UI Demo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a237e),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Click any button below to view the corresponding screen:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Navigation buttons for each screen
          _buildDemoButton(
            context,
            'Splash Screen',
            'Animated logo with loading indicator',
            () => context.go('/'),
          ),

          _buildDemoButton(
            context,
            'Welcome Screen',
            'Trial onboarding with CTA buttons',
            () => context.go('/welcome'),
          ),

          _buildDemoButton(
            context,
            'Phone Verification',
            'Mobile number input with validation',
            () => context.go('/phone-verification'),
          ),

          _buildDemoButton(
            context,
            'OTP Verification',
            '6-digit OTP input with timer',
            () => context.go('/otp-verification', extra: '+91 9876543210'),
          ),

          _buildDemoButton(
            context,
            'Login Page (New)',
            'New architecture login page',
            () => context.go('/login'),
          ),

          _buildDemoButton(
            context,
            'Trial Setup',
            'Profile setup with insurance preferences',
            () => context.go('/trial-setup'),
          ),

          _buildDemoButton(
            context,
            'Trial Expiration',
            'Subscription upgrade screen',
            () => context.go('/trial-expiration'),
          ),

          _buildDemoButton(
            context,
            'Customer Dashboard',
            'Home screen with policy overview',
            () => context.go('/customer-dashboard'),
          ),

          _buildDemoButton(
            context,
            'Policy Details',
            'Individual policy information & actions',
            () => context.go('/policy-details'),
          ),

          _buildDemoButton(
            context,
            'WhatsApp Integration',
            'Agent communication via WhatsApp',
            () => context.go('/whatsapp-integration'),
          ),

          _buildDemoButton(
            context,
            'Smart Chatbot',
            'AI assistant for policy queries',
            () => context.go('/smart-chatbot'),
          ),

          _buildDemoButton(
            context,
            'Learning Center',
            'Educational videos & tutorials',
            () => context.go('/learning-center'),
          ),

          _buildDemoButton(
            context,
            'Agent Config Dashboard',
            'Data import & management portal',
            () => context.go('/agent-config-dashboard'),
          ),

          _buildDemoButton(
            context,
            'ROI Analytics',
            'Revenue & performance analytics',
            () => context.go('/roi-analytics'),
          ),

          _buildDemoButton(
            context,
            'Campaign Builder',
            'Marketing campaign creation tool',
            () => context.go('/campaign-builder'),
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 Normal Flow:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
                SizedBox(height: 8),
                Text('Unauthenticated: Splash → Welcome → Phone → OTP → Trial Setup → Trial Expiration'),
                SizedBox(height: 8),
                Text('Customer Portal: Dashboard → Policy Details → WhatsApp → Chatbot → Learning'),
                SizedBox(height: 8),
                Text('Agent Portal: Config Dashboard → ROI Analytics → Campaign Builder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String title, String subtitle, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1a237e),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1a237e), width: 1),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
