import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as provider;
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
import 'features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart';
import 'features/chatbot/data/repositories/chatbot_repository.dart';
import 'features/chatbot/data/datasources/chatbot_remote_datasource.dart';
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
        return provider.MultiProvider(
          providers: [
            provider.ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
            provider.ChangeNotifierProvider(create: (_) => PresentationViewModel()),
            provider.ChangeNotifierProvider(
              create: (_) => OnboardingViewModel(
                OnboardingRepository(
                  const OnboardingLocalDataSource(),
                ),
              )..initialize(),
            ),
            provider.ChangeNotifierProvider(
              create: (_) => DashboardViewModel(
                DashboardRepository(
                  DashboardRemoteDataSource(ApiService()),
                ),
                FeatureFlagService(),
              )..initialize(),
            ),
            provider.ChangeNotifierProxyProvider<AuthViewModel, ChatbotViewModel>(
              create: (context) => ChatbotViewModel(
                ChatbotRepository(
                  ChatbotRemoteDataSourceImpl(),
                ),
                'test-agent-id', // Fallback agent ID
              ),
              update: (context, authViewModel, previous) {
                final agentId = authViewModel.currentUser?.userId ?? 'test-agent-id';
                if (previous?.agentId != agentId) {
                  return ChatbotViewModel(
                    ChatbotRepository(
                      ChatbotRemoteDataSourceImpl(),
                    ),
                    agentId,
                  );
                }
                return previous ?? ChatbotViewModel(
                  ChatbotRepository(
                    ChatbotRemoteDataSourceImpl(),
                  ),
                  agentId,
                );
              },
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
