import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/storage_service.dart';
import 'core/services/logger_service.dart';
import 'core/services/feature_flag_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/services/sync_service.dart';
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
import 'features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/datasources/notification_local_datasource.dart';
import 'core/services/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  LoggerService().info('Firebase initialized', tag: 'Firebase');

  // Initialize core services
  await StorageService.initialize();

  // Initialize logging
  await LoggerService().initialize(enableFileLogging: false);
  LoggerService().info('Agent Mitra App Starting', tag: 'App');

  // Initialize feature flags
  await FeatureFlagService().initialize();
  LoggerService().info('Feature flags initialized', tag: 'FeatureFlags');

  // Initialize push notifications
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  LoggerService().info('Push notification service initialized', tag: 'PushNotifications');

  // Initialize offline queue service
  final offlineQueueService = OfflineQueueService(
    LoggerService(),
    Connectivity(),
  );
  LoggerService().info('Offline queue service initialized', tag: 'OfflineQueue');

  // Initialize sync service
  final syncService = SyncService(
    LoggerService(),
    Connectivity(),
  );
  await syncService.initialize();
  LoggerService().info('Sync service initialized', tag: 'SyncService');

  runApp(
    ProviderScope(
      child: AgentMitraApp(
        pushNotificationService: pushNotificationService,
        offlineQueueService: offlineQueueService,
        syncService: syncService,
      ),
    ),
  );
}

class AgentMitraApp extends ConsumerWidget {
  final PushNotificationService pushNotificationService;
  final OfflineQueueService offlineQueueService;
  final SyncService syncService;

  const AgentMitraApp({
    super.key,
    required this.pushNotificationService,
    required this.offlineQueueService,
    required this.syncService,
  });

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
            // Core Services
            provider.Provider.value(value: pushNotificationService),
            provider.Provider.value(value: offlineQueueService),
            provider.Provider.value(value: syncService),

            // Auth ViewModel
            provider.ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),

            // Presentation ViewModel
            provider.ChangeNotifierProvider(create: (_) => PresentationViewModel()),

            // Onboarding ViewModel
            provider.ChangeNotifierProvider(
              create: (_) => OnboardingViewModel(
                OnboardingRepository(
                  const OnboardingLocalDataSource(),
                ),
              )..initialize(),
            ),

            // Dashboard ViewModel
            provider.ChangeNotifierProvider(
              create: (_) => DashboardViewModel(
                DashboardRepository(
                  DashboardRemoteDataSource(ApiService()),
                ),
                FeatureFlagService(),
              )..initialize(),
            ),

            // Chatbot ViewModel
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

            // Notification ViewModel
            provider.ChangeNotifierProvider(
              create: (_) => NotificationViewModel(
                NotificationRepository(
                  NotificationRemoteDataSource(ApiService(), LoggerService()),
                  NotificationLocalDataSource(LoggerService(), Connectivity()),
                  Connectivity(),
                  offlineQueueService,
                  syncService,
                  LoggerService(),
                ),
                offlineQueueService,
                LoggerService(),
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
