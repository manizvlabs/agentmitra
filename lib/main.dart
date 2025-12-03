import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/storage_service.dart';
import 'core/services/pioneer_service.dart';
import 'core/di/service_locator.dart';
import 'core/providers/global_providers.dart';
import 'core/config/app_config.dart';
import 'shared/theme/app_theme.dart';
import 'navigation/navigation_router.dart';
import 'features/presentations/presentation/viewmodels/presentation_viewmodel.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import 'features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'features/agent/presentation/viewmodels/agent_profile_viewmodel.dart';
import 'features/payments/presentation/viewmodels/claims_viewmodel.dart';
import 'features/payments/presentation/viewmodels/policies_viewmodel.dart';
import 'features/customers/presentation/viewmodels/customer_viewmodel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize configuration from environment variables
  try {
    await dotenv.load(fileName: '.env');
    print('Environment configuration loaded successfully');
  } catch (e) {
    print('Warning: Could not load .env file, using fallback values: $e');
  }

  // Initialize app configuration
  try {
    await AppConfig.initialize();
    print('App configuration initialized successfully');
  } catch (e) {
    print('App configuration initialization failed: $e');
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
    final config = AppConfig();
    if (config.pioneerEnabled) {
      await PioneerService.initialize(
        scoutUrl: config.pioneerScoutUrl,
        sdkKey: config.pioneerApiKey,
      );
      print('Pioneer initialized successfully');
    } else {
      print('Pioneer disabled - using mock mode');
    }
  } catch (e) {
    print('Pioneer initialization failed: $e');
    print('App cannot start without Pioneer service. Please ensure Pioneer is running.');
    throw e; // Re-throw to prevent app startup
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
        provider.ChangeNotifierProvider<AuthViewModel>(
          create: (_) => ServiceLocator.authViewModel,
        ),
        // Dashboard ViewModel - connects to real analytics APIs
        provider.ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => ServiceLocator.dashboardViewModel,
        ),
        // Notification ViewModel - mock data for testing
        provider.ChangeNotifierProvider<NotificationViewModel>(
          create: (_) => ServiceLocator.notificationViewModel,
        ),
        // Onboarding ViewModel - mock data for testing
        provider.ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => ServiceLocator.onboardingViewModel,
        ),
        // Agent Profile ViewModel - mock data for testing
        provider.ChangeNotifierProvider<AgentProfileViewModel>(
          create: (_) => ServiceLocator.agentProfileViewModel,
        ),
        // Claims ViewModel - mock data for testing
        provider.ChangeNotifierProvider<ClaimsViewModel>(
          create: (_) => ServiceLocator.claimsViewModel,
        ),
        // Policies ViewModel - mock data for testing
        provider.ChangeNotifierProvider<PoliciesViewModel>(
          create: (_) => ServiceLocator.policiesViewModel,
        ),
        // Chatbot ViewModel
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.createChatbotViewModel(),
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
        // User Management ViewModel
        provider.ChangeNotifierProvider(
          create: (_) => ServiceLocator.userManagementViewModel,
        ),
        // RBAC Service Provider
        provider.Provider(
          create: (_) => ServiceLocator.rbacService,
        ),
      ],
      child: Builder(
        builder: (context) {
          // Initialize navigation router inside the provider scope
          final navigationRouter = NavigationRouter();

          return MaterialApp(
            title: 'Agent Mitra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: navigationRouter.getInitialRoute(context),
            onGenerateRoute: (settings) {
              // Handle hash-based routing for web
              String routeName = settings.name ?? '/';
              if (kIsWeb && routeName.startsWith('#')) {
                routeName = routeName.substring(1);
              }
              if (!routeName.startsWith('/')) {
                routeName = '/$routeName';
              }

              // Use NavigationRouter to generate routes
              final routes = navigationRouter.generateRoutes(context);
              final routeBuilder = routes[routeName];
              if (routeBuilder != null) {
                return MaterialPageRoute(
                  builder: routeBuilder,
                  settings: RouteSettings(name: routeName, arguments: settings.arguments),
                );
              }
              return null; // Let onUnknownRoute handle it
            },
            routes: navigationRouter.generateRoutes(context),
            onUnknownRoute: (settings) {
              return navigationRouter.onUnknownRoute(settings, context);
            },
          );
        },
      ),
    );
  }

}
