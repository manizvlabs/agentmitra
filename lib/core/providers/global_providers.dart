import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logger_service.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';

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

    LoggerService().info('App initialization completed', tag: 'AppInit');
    return true;
  } catch (e) {
    LoggerService().error('App initialization failed: $e', tag: 'AppInit');
    return false;
  }
});

/// Network connectivity provider - simplified for web compatibility
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  final LoggerService _logger = LoggerService();

  ConnectivityNotifier() : super(true) { // Assume connected by default
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Listen for connectivity changes using our custom service
      ConnectivityService.onConnectivityChanged.listen((bool isConnected) {
        state = isConnected;
        _logger.info('Connectivity changed: $isConnected', tag: 'Connectivity');

        // TODO: Trigger sync operations when coming back online
        if (isConnected) {
          _handleReconnected();
        }
      });
    } catch (e) {
      _logger.error('Failed to initialize connectivity monitoring: $e', tag: 'Connectivity');
    }
  }

  bool get isConnected => state;

  void _handleReconnected() {
    _logger.info('Device reconnected to network', tag: 'Connectivity');
    // TODO: Trigger pending sync operations
  }

  /// Manually check connectivity
  Future<void> checkConnectivity() async {
    try {
      state = ConnectivityService.isConnected;
    } catch (e) {
      _logger.error('Failed to check connectivity: $e', tag: 'Connectivity');
    }
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
