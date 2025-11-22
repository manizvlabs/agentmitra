import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'core/services/storage_service.dart';
import 'core/di/service_locator.dart';
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
// Temporarily disable complex screens to focus on auth
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/notifications/presentation/pages/notification_page.dart';
import 'features/agent/presentation/pages/agent_profile_page.dart';
import 'features/payments/presentation/pages/claims_page.dart';
import 'features/payments/presentation/pages/policies_list_page.dart';
import 'screens/daily_quotes_screen.dart';
import 'screens/my_policies_screen.dart';
import 'screens/data_pending_screen.dart';
import 'screens/agent_discovery_screen.dart';
import 'screens/agent_verification_screen.dart';
import 'screens/document_upload_screen.dart';
import 'screens/emergency_contact_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize Service Locator (dependency injection container)
  try {
    await ServiceLocator.initialize();
    print('Service Locator initialized successfully');
  } catch (e) {
    print('Service Locator initialization failed: $e');
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
        // Real ViewModels connected to backend APIs via Service Locator
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.authViewModel,
        ),
        // Dashboard ViewModel - connects to real analytics APIs
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.dashboardViewModel,
        ),
        // Notification ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.notificationViewModel,
        ),
        // Onboarding ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.onboardingViewModel,
        ),
        // Agent Profile ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.agentProfileViewModel,
        ),
        // Claims ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.claimsViewModel,
        ),
        // Policies ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.policiesViewModel,
        ),
        // Chatbot ViewModel - mock data for testing
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.createChatbotViewModel('current-agent'),
        ),
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
        '/policies': (context) => const PoliciesListPage(),
        '/claims': (context) {
          // Extract policyId from arguments if available
          final args = ModalRoute.of(context)?.settings.arguments;
          return ClaimsPage(policyId: args as String?);
        },
        '/policy-details': (context) => const PolicyDetailsScreen(),
        '/whatsapp-integration': (context) => const WhatsappIntegrationScreen(),
        '/smart-chatbot': (context) => const ChatbotPage(),
        '/notifications': (context) => const NotificationPage(),
        '/learning-center': (context) => const LearningCenterScreen(),
        '/data-pending': (context) => const DataPendingScreen(),
        '/agent-discovery': (context) => const AgentDiscoveryScreen(),
        '/agent-verification': (context) => const AgentVerificationScreen(),
        '/document-upload': (context) => const DocumentUploadScreen(),
        '/emergency-contact': (context) => const EmergencyContactScreen(),

        // Agent Portal
        '/agent-profile': (context) => const AgentProfilePage(),
        '/daily-quotes': (context) => const DailyQuotesScreen(),
        '/my-policies': (context) => const MyPoliciesScreen(),
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