import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/theme/app_theme.dart';
import '../services/feature_flag_service.dart';
import '../services/logger_service.dart';
import '../services/storage_service.dart';

/// Global Riverpod providers for app-wide state management

/// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

/// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize core services
    await StorageService.initialize();
    await LoggerService().initialize(enableFileLogging: false);
    await FeatureFlagService().initialize();

    LoggerService().info('App initialization completed', tag: 'AppInit');
    return true;
  } catch (e) {
    LoggerService().error('App initialization failed: $e', tag: 'AppInit');
    return false;
  }
});

/// Network connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true); // Assume connected by default

  void setConnected(bool connected) {
    state = connected;
  }
}

/// App configuration provider
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig();
});

class AppConfig {
  const AppConfig();

  // App constants
  String get appName => 'Agent Mitra';
  String get appVersion => '1.0.0';
  String get apiBaseUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8012',
  );

  // Feature flags
  bool get enableMockData => const bool.fromEnvironment('ENABLE_MOCK_DATA', defaultValue: true);
  bool get enableAnalytics => const bool.fromEnvironment('ENABLE_ANALYTICS', defaultValue: false);
  bool get enableCrashReporting => const bool.fromEnvironment('ENABLE_CRASH_REPORTING', defaultValue: false);

  // UI constants
  double get defaultBorderRadius => 12.0;
  double get defaultPadding => 16.0;
  double get defaultMargin => 16.0;

  // Animation durations
  Duration get shortAnimationDuration => const Duration(milliseconds: 200);
  Duration get mediumAnimationDuration => const Duration(milliseconds: 300);
  Duration get longAnimationDuration => const Duration(milliseconds: 500);
}

/// Feature flag provider with reactive updates
final featureFlagProvider = StateNotifierProvider<FeatureFlagNotifier, Map<String, bool>>((ref) {
  return FeatureFlagNotifier();
});

class FeatureFlagNotifier extends StateNotifier<Map<String, bool>> {
  FeatureFlagNotifier() : super({}) {
    _loadFeatureFlags();
  }

  Future<void> _loadFeatureFlags() async {
    try {
      final flags = await FeatureFlagService().getAllFlags();
      state = flags;
    } catch (e) {
      LoggerService().error('Failed to load feature flags: $e', tag: 'FeatureFlags');
    }
  }

  Future<void> refreshFlags() async {
    await _loadFeatureFlags();
  }

  bool getFlag(String key, {bool defaultValue = false}) {
    return state[key] ?? defaultValue;
  }

  Future<void> setFlag(String key, bool value) async {
    try {
      await FeatureFlagService().setFlag(key, value);
      state = {...state, key: value};
    } catch (e) {
      LoggerService().error('Failed to set feature flag $key: $e', tag: 'FeatureFlags');
    }
  }
}

/// User session provider
final userSessionProvider = StateNotifierProvider<UserSessionNotifier, UserSession?>((ref) {
  return UserSessionNotifier();
});

class UserSessionNotifier extends StateNotifier<UserSession?> {
  UserSessionNotifier() : super(null);

  void setSession(UserSession session) {
    state = session;
  }

  void clearSession() {
    state = null;
  }

  bool get isAuthenticated => state != null;
  String? get userId => state?.userId;
  String? get userType => state?.userType;
}

class UserSession {
  final String userId;
  final String userType; // 'agent' or 'customer'
  final String? token;
  final DateTime? expiresAt;

  const UserSession({
    required this.userId,
    required this.userType,
    this.token,
    this.expiresAt,
  });

  bool get isExpired {
    return expiresAt != null && DateTime.now().isAfter(expiresAt!);
  }

  UserSession copyWith({
    String? userId,
    String? userType,
    String? token,
    DateTime? expiresAt,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

/// App lifecycle provider
final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier();
});

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  AppLifecycleNotifier() : super(AppLifecycleState.resumed);

  void setLifecycleState(AppLifecycleState lifecycleState) {
    state = lifecycleState;
  }
}

/// Global loading state provider
final globalLoadingProvider = StateNotifierProvider<GlobalLoadingNotifier, bool>((ref) {
  return GlobalLoadingNotifier();
});

class GlobalLoadingNotifier extends StateNotifier<bool> {
  GlobalLoadingNotifier() : super(false);

  void showLoading() {
    state = true;
  }

  void hideLoading() {
    state = false;
  }

  void setLoading(bool loading) {
    state = loading;
  }
}

/// Global error state provider
final globalErrorProvider = StateNotifierProvider<GlobalErrorNotifier, String?>((ref) {
  return GlobalErrorNotifier();
});

class GlobalErrorNotifier extends StateNotifier<String?> {
  GlobalErrorNotifier() : super(null);

  void setError(String error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}
