import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'core/services/storage_service.dart';
import 'core/services/pioneer_service.dart';
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
import 'screens/customer_dashboard.dart';
import 'screens/whatsapp_integration_screen.dart';
import 'screens/learning_center_screen.dart';
import 'screens/agent_config_dashboard.dart';
import 'screens/roi_analytics_dashboard.dart';
import 'screens/marketing_campaign_builder.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
// Temporarily disable complex screens to focus on auth
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/chatbot/presentation/pages/chatbot_page.dart';
import 'features/notifications/presentation/pages/notification_page.dart';
import 'features/agent/presentation/pages/agent_profile_page.dart';
import 'features/payments/presentation/pages/claims_page.dart';
import 'features/payments/presentation/pages/policies_list_page.dart';
import 'features/payments/presentation/pages/premium_payment_page.dart';
import 'features/payments/presentation/pages/get_quote_page.dart';
import 'features/payments/presentation/viewmodels/policies_viewmodel.dart';
import 'features/customers/presentation/viewmodels/customer_viewmodel.dart';
import 'screens/daily_quotes_screen.dart';
import 'screens/my_policies_screen.dart';
import 'screens/data_pending_screen.dart';
import 'screens/campaign_performance_screen.dart';
import 'screens/content_performance_screen.dart';
import 'screens/accessibility_settings_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/premium_calendar_screen.dart';
import 'screens/agent_chat_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/callback_request_management.dart';
import 'screens/global_search_screen.dart';
import 'screens/test_phase1_screen.dart';
import 'screens/pioneer_demo_screen.dart';
import 'features/presentations/presentation/pages/presentation_list_page.dart';
import 'features/presentations/presentation/pages/presentation_editor_page.dart';
import 'features/presentations/data/models/presentation_model.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
// Configuration Portal Pages
import 'features/config_portal/presentation/pages/data_import_dashboard_page.dart';
import 'features/config_portal/presentation/pages/excel_template_config_page.dart';
import 'features/config_portal/presentation/pages/customer_data_management_page.dart';
import 'features/config_portal/presentation/pages/reporting_dashboard_page.dart';
import 'features/config_portal/presentation/pages/user_management_page.dart';
import 'core/widgets/protected_route.dart';
import 'core/services/rbac_service.dart';

/// Placeholder screen for routes that are not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '$title - Coming Soon!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is currently under development.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    // Web uses in-memory storage - this is expected behavior
    // No need to log as it's not an error or warning
  }

  // Initialize Service Locator (dependency injection container)
  try {
    await ServiceLocator.initialize();
    print('Service Locator initialized successfully');
  } catch (e) {
    print('Service Locator initialization failed: $e');
  }

  // Initialize Pioneer for feature flag management
  try {
    // Pioneer configuration - now using real Pioneer server
    await PioneerService.initialize(
      useMock: false, // Using real Pioneer server
      scoutUrl: 'http://localhost:4002', // Scout SSE endpoint
      sdkKey: '4cbeeba0-37e8-45fc-b306-32c0cd497c92', // SDK key from Pioneer server
    );
    print('Pioneer initialized successfully (real mode)');
  } catch (e) {
    print('Pioneer initialization failed: $e');
    print('Falling back to mock mode for development');
    // Fall back to mock mode on error
    try {
      await PioneerService.initialize(useMock: true);
      print('Pioneer initialized with fallback to mock mode');
    } catch (fallbackError) {
      print('Fallback initialization also failed: $fallbackError');
      print('App will continue with default feature flag values');
    }
  }

  runApp(
    const ProviderScope(
      child: AgentMitraApp(),
    ),
  );
}

class AgentMitraApp extends ConsumerWidget {
  const AgentMitraApp({super.key});

  // Helper function to get initial route from URL hash
  static String _getInitialRoute() {
    if (kIsWeb) {
      // Check if there's a hash in the URL
      final uri = Uri.base;
      if (uri.hasFragment && uri.fragment.isNotEmpty) {
        String route = uri.fragment;
        if (!route.startsWith('/')) {
          route = '/$route';
        }
        // Verify route exists in routes map
        if (_routes.containsKey(route)) {
          return route;
        }
      }
    }
    return '/splash'; // Default to splash screen
  }

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
        // Chatbot ViewModel
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.createChatbotViewModel('current-agent'),
        ),
        provider.ChangeNotifierProvider(
          create: (_) => PresentationViewModel(),
        ),
        // Customer ViewModel
        provider.ChangeNotifierProvider(
          create: (_) => CustomerViewModel(),
        ),
        // Policies ViewModel (for New Claim page)
        provider.ChangeNotifierProvider(
          create: (_) => PoliciesViewModel(),
        ),
        // RBAC Service Provider
        provider.Provider(
          create: (_) => ServiceLocator.rbacService,
        ),
      ],
      child: MaterialApp(
        title: 'Agent Mitra',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: _getInitialRoute(), // Get initial route from URL hash if available
        onGenerateRoute: (settings) {
          // Handle hash-based routing for web
          String routeName = settings.name ?? '/';
          if (kIsWeb && routeName.startsWith('#')) {
            routeName = routeName.substring(1);
          }
          if (!routeName.startsWith('/')) {
            routeName = '/$routeName';
          }
          
          // Try to find route in routes map
          final routeBuilder = _routes[routeName];
          if (routeBuilder != null) {
            return MaterialPageRoute(
              builder: routeBuilder,
              settings: RouteSettings(name: routeName, arguments: settings.arguments),
            );
          }
          return null; // Let onUnknownRoute handle it
        },
        routes: _routes,
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

  // Helper function to wrap protected routes
  static WidgetBuilder _protectedRoute(
    WidgetBuilder builder, {
    List<UserRole>? requiredRoles,
    List<String>? requiredPermissions,
  }) {
    return (context) => ProtectedRoute(
      requiredRoles: requiredRoles,
      requiredPermissions: requiredPermissions,
      child: builder(context),
    );
  }

  // Define routes map as static
  static final Map<String, WidgetBuilder> _routes = {
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

    // Onboarding Flow (Protected - requires authentication)
    '/trial-setup': _protectedRoute((context) => const TrialSetupScreen()),
    '/onboarding': _protectedRoute((context) => const OnboardingPage()),
    '/trial-expiration': _protectedRoute((context) => const TrialExpirationScreen()),

    // Customer Portal (Protected - requires authentication)
    '/customer-dashboard': _protectedRoute(
      (context) => const CustomerDashboard(),
      requiredRoles: [UserRole.policyholder],
    ),
    '/policies': _protectedRoute(
      (context) => const PoliciesListPage(),
      requiredPermissions: ['policies.read'],
    ),
    '/claims': _protectedRoute(
      (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return ClaimsPage(policyId: args as String?);
      },
      requiredPermissions: ['policies.read'],
    ),
    '/claims/new': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'File New Claim'),
      requiredPermissions: ['policies.create'],
    ),
    '/policy-details': _protectedRoute(
      (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final policyId = args is Map<String, dynamic> ? args['policyId'] : null;
        return PolicyDetailsScreen(policyId: policyId);
      },
      requiredPermissions: ['policies.read'],
    ),
    '/premium-payment': _protectedRoute(
      (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final map = args is Map<String, dynamic> ? args : {};
        return PremiumPaymentPage(
          policyId: map['policyId'],
          amount: map['amount']?.toDouble(),
        );
      },
      requiredPermissions: ['policies.update'],
    ),
    '/get-quote': _protectedRoute(
      (context) => const GetQuotePage(),
      requiredPermissions: ['policies.create'],
    ),
    '/policy/create': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'Create New Policy'),
      requiredPermissions: ['policies.create'],
    ),
    '/whatsapp-integration': _protectedRoute(
      (context) => const WhatsappIntegrationScreen(),
    ),
    '/smart-chatbot': _protectedRoute(
      (context) => const ChatbotPage(),
    ),
    '/notifications': _protectedRoute(
      (context) => const NotificationPage(),
    ),
    '/learning-center': _protectedRoute(
      (context) => const LearningCenterScreen(),
    ),

    // Phase 1 Test Screen (Public for testing)
    '/test-phase1': (context) => const TestPhase1Screen(),
    '/pioneer-demo': (context) => const PioneerDemoScreen(),
    '/data-pending': _protectedRoute((context) => const DataPendingScreen()),

    // Agent Portal (Protected - requires agent role)
    '/agent-profile': _protectedRoute(
      (context) => const AgentProfilePage(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/daily-quotes': _protectedRoute(
      (context) => const DailyQuotesScreen(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/my-policies': _protectedRoute(
      (context) => const MyPoliciesScreen(),
      requiredPermissions: ['policies.read'],
    ),
    '/premium-calendar': _protectedRoute(
      (context) => const PremiumCalendarScreen(),
      requiredPermissions: ['policies.read'],
    ),
    '/agent-chat': _protectedRoute(
      (context) => const AgentChatScreen(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/reminders': _protectedRoute(
      (context) => const RemindersScreen(),
    ),
    '/presentations': _protectedRoute(
      (context) => const PresentationListPage(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/presentation-list': _protectedRoute(
      (context) => const PresentationListPage(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/presentation-editor': _protectedRoute(
      (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final presentation = args is PresentationModel ? args : null;
        return PresentationEditorPage(presentation: presentation);
      },
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/campaign-performance': _protectedRoute(
      (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        return CampaignPerformanceScreen(campaignId: args is String ? args : null);
      },
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/content-performance': _protectedRoute(
      (context) => const ContentPerformanceScreen(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/accessibility-settings': _protectedRoute(
      (context) => const AccessibilitySettingsScreen(),
    ),
    '/language-selection': _protectedRoute(
      (context) => const LanguageSelectionScreen(),
    ),
    '/payments': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'Payments'),
      requiredPermissions: ['policies.read'],
    ),
    '/reports': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'Reports'),
      requiredPermissions: ['reports.read'],
    ),
    '/customers': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'Customers'),
      requiredPermissions: ['customers.read'],
    ),
    '/settings': _protectedRoute(
      (context) => const PlaceholderScreen(title: 'Settings'),
    ),
    '/global-search': _protectedRoute(
      (context) => const GlobalSearchScreen(),
    ),
    '/agent-config-dashboard': _protectedRoute(
      (context) => const AgentConfigDashboard(),
      requiredRoles: [UserRole.providerAdmin, UserRole.superAdmin],
    ),
    '/roi-analytics': _protectedRoute(
      (context) => const RoiAnalyticsDashboard(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent, UserRole.regionalManager],
    ),
    '/campaign-builder': _protectedRoute(
      (context) => const MarketingCampaignBuilder(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    
    // Configuration Portal Routes (Protected with RBAC)
    '/data-import-dashboard': _protectedRoute(
      (context) => const DataImportDashboardPage(),
      requiredPermissions: ['data_import.read'],
    ),
    '/excel-template-config': _protectedRoute(
      (context) => const ExcelTemplateConfigPage(),
      requiredPermissions: ['data_import.create'],
    ),
    '/customer-data-management': _protectedRoute(
      (context) => const CustomerDataManagementPage(),
      requiredPermissions: ['customers.read'],
    ),
    '/reporting-dashboard': _protectedRoute(
      (context) => const ReportingDashboardPage(),
      requiredPermissions: ['reports.read'],
    ),
    '/user-management': _protectedRoute(
      (context) => const UserManagementPage(),
      requiredRoles: [UserRole.superAdmin, UserRole.providerAdmin],
      requiredPermissions: ['users.read'],
    ),
    
    // Dashboard and Callback Management (Protected)
    '/agent-dashboard': _protectedRoute(
      (context) => const DashboardPage(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/dashboard': _protectedRoute(
      (context) => const DashboardPage(),
      requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
    ),
    '/callback-management': _protectedRoute(
      (context) => const CallbackRequestManagement(),
      requiredRoles: [UserRole.supportStaff, UserRole.seniorAgent],
    ),
  };
}
