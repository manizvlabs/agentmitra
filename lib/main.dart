import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'core/services/storage_service.dart';
import 'core/mocks/mock_dashboard_viewmodel.dart';
import 'core/mocks/mock_auth_viewmodel_simple.dart';
import 'core/mocks/mock_notification_viewmodel_simple.dart';
import 'core/mocks/mock_onboarding_viewmodel_simple.dart';
import 'core/mocks/mock_chatbot_viewmodel_simple.dart';
import 'core/mocks/mock_agent_profile_viewmodel_simple.dart';
import 'core/mocks/mock_claims_viewmodel_simple.dart';
import 'core/mocks/mock_policies_viewmodel_simple.dart';
import 'core/providers/global_providers.dart';
import 'shared/theme/app_theme.dart';
import 'features/presentations/presentation/viewmodels/presentation_viewmodel.dart';
// Import all screens for web-compatible routing (no GoRouter)
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/phone_verification_screen.dart';
import 'screens/trial_setup_screen.dart';
import 'screens/trial_expiration_screen.dart';
import 'screens/policy_details_screen.dart';
import 'screens/whatsapp_integration_screen.dart';
import 'screens/learning_center_screen.dart';
import 'screens/agent_config_dashboard.dart';
import 'screens/roi_analytics_dashboard.dart';
import 'screens/marketing_campaign_builder.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/notifications/presentation/pages/notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling for web)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed (this is OK for demo): $e');
  }

  // Initialize storage service (web-compatible)
  if (!kIsWeb) {
    try {
      await StorageService.initialize();
      print('Storage service initialized');
    } catch (e) {
      print('Storage service initialization failed: $e');
    }
  } else {
    print('Using web-compatible storage (in-memory)');
  }

  runApp(
    const ProviderScope(
      child: AgentMitraApp(),
    ),
  );
}

class AgentMitraApp extends ConsumerWidget {
  const AgentMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode from Riverpod
    final themeMode = ref.watch(themeModeProvider);

    return provider.MultiProvider(
      providers: [
        // Mock ViewModels for web compatibility
        provider.ChangeNotifierProvider(
          create: (_) => MockDashboardViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockAuthViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockNotificationViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockOnboardingViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockChatbotViewModel('current-agent'),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockAgentProfileViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockClaimsViewModel(),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => MockPoliciesViewModel(),
        ),
        // Real ViewModels (may need repositories in production)
        provider.ChangeNotifierProvider(
          create: (_) => PresentationViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Agent Mitra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: '/splash',
        routes: {
        // Splash & Welcome Flow
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),

        // Authentication Flow
        '/phone-verification': (context) => const PhoneVerificationScreen(),
        '/otp-verification': (context) {
          // Extract phone number from arguments if available
          final args = ModalRoute.of(context)?.settings.arguments;
          final phoneNumber = args is String ? args : '+91 9876543210';
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
        '/login': (context) => const LoginPage(),

        // Onboarding Flow
        '/trial-setup': (context) => const TrialSetupScreen(),
        '/onboarding': (context) => const OnboardingPage(),
        '/trial-expiration': (context) => const TrialExpirationScreen(),

        // Customer Portal
        '/customer-dashboard': (context) => const DashboardPage(),
        '/policy-details': (context) => const PolicyDetailsScreen(),
        '/whatsapp-integration': (context) => const WhatsappIntegrationScreen(),
        '/smart-chatbot': (context) => const ChatbotPage(),
        '/notifications': (context) => const NotificationPage(),
        '/learning-center': (context) => const LearningCenterScreen(),

        // Agent Portal
        '/agent-config-dashboard': (context) => const AgentConfigDashboard(),
        '/roi-analytics': (context) => const RoiAnalyticsDashboard(),
        '/campaign-builder': (context) => const MarketingCampaignBuilder(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('404 - Page Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Page not found',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Route: ${settings.name}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/splash'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    );
  }
}