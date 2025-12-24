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
  print('=== STARTING AGENT MITRA APP INITIALIZATION ===');

  WidgetsFlutterBinding.ensureInitialized();
  print('✓ WidgetsFlutterBinding initialized');

  // Initialize configuration from environment variables
  print('Loading environment configuration...');
  try {
    await dotenv.load(fileName: '.env');
    print('✓ Environment configuration loaded successfully');
  } catch (e) {
    print('⚠ Warning: Could not load .env file, using fallback values: $e');
  }

  // Initialize app configuration
  print('Initializing app configuration...');
  try {
    await AppConfig.initialize();
    print('✓ App configuration initialized successfully');
  } catch (e) {
    print('✗ App configuration initialization failed: $e');
  }

  // Initialize storage service (web-compatible)
  print('Initializing storage service...');
  if (!kIsWeb) {
    try {
      await StorageService.initialize();
      print('✓ Storage service initialized');
    } catch (e) {
      print('✗ Storage service initialization failed: $e');
    }
  } else {
    print('✓ Web platform detected - using in-memory storage');
  }

  // Initialize Service Locator (dependency injection container)
  print('Initializing Service Locator...');
  try {
    await ServiceLocator.initialize();
    print('✓ Service Locator initialized successfully');
  } catch (e) {
    print('✗ Service Locator initialization failed: $e');
  }

  // Initialize Pioneer for feature flag management
  print('Initializing Pioneer feature flags...');
  try {
    final config = AppConfig();
    if (config.pioneerEnabled) {
      print('  - Pioneer is enabled, initializing...');
      await PioneerService.initialize(
        scoutUrl: config.pioneerScoutUrl,
        sdkKey: config.pioneerApiKey,
      );
      print('✓ Pioneer initialized successfully');
    } else {
      print('✓ Pioneer disabled - using default feature flags');
    }
  } catch (e) {
    print('✗ Pioneer initialization failed: $e');
    print('  - Continuing with default feature flags - some features may be limited');
    // Don't throw - allow app to continue with default flags
  }

  print('Starting Flutter app...');
  runApp(
    const ProviderScope(
      child: AgentMitraApp(),
    ),
  );
  print('✓ Flutter app started successfully');
}

class AgentMitraApp extends ConsumerWidget {
  const AgentMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Building AgentMitraApp widget...');
    // Watch theme mode from Riverpod
    final themeMode = ref.watch(themeModeProvider);
    print('✓ Theme mode loaded: $themeMode');

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
    print('✓ AgentMitraApp widget built successfully');
  }

}
