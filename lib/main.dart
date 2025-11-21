import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/storage_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/feature_flag_service.dart';
import 'core/router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'core/providers/global_providers.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/presentations/presentation/viewmodels/presentation_viewmodel.dart';
import 'features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import 'features/onboarding/data/repositories/onboarding_repository.dart';
import 'features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'features/dashboard/data/repositories/dashboard_repository.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'core/services/api_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services
  await StorageService.initialize();

  // Initialize logging
  await LoggerService().initialize(enableFileLogging: false);
  LoggerService().info('Agent Mitra App Starting', tag: 'App');

  // Initialize feature flags
  await FeatureFlagService().initialize();
  LoggerService().info('Feature flags initialized', tag: 'FeatureFlags');

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

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X/XS dimensions
      minTextAdapt: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
            ChangeNotifierProvider(create: (_) => PresentationViewModel()),
            ChangeNotifierProvider(
              create: (_) => OnboardingViewModel(
                OnboardingRepository(
                  const OnboardingLocalDataSource(),
                ),
              )..initialize(),
            ),
            ChangeNotifierProvider(
              create: (_) => DashboardViewModel(
                DashboardRepository(
                  DashboardRemoteDataSource(ApiService()),
                ),
                // TODO: Inject proper feature flag service when available
                null, // Will be updated when feature flag service is properly implemented
              )..initialize(),
            ),
          ],
          child: MaterialApp.router(
            title: 'Agent Mitra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}
