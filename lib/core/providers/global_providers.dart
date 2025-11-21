import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

    LoggerService().info('App initialization completed', tag: 'AppInit');
    return true;
  } catch (e) {
    LoggerService().error('App initialization failed: $e', tag: 'AppInit');
    return false;
  }
});

/// Network connectivity provider
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityResult>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<ConnectivityResult> {
  final Connectivity _connectivity = Connectivity();
  final LoggerService _logger = LoggerService();

  ConnectivityNotifier() : super(ConnectivityResult.wifi) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Get initial connectivity status
      final result = await _connectivity.checkConnectivity();
      state = result;

      // Listen for connectivity changes
      _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
        state = result;
        _logger.info('Connectivity changed: ${result.name}', tag: 'Connectivity');

        // TODO: Trigger sync operations when coming back online
        if (_isConnected(result)) {
          _handleReconnected();
        }
      });
    } catch (e) {
      _logger.error('Failed to initialize connectivity monitoring: $e', tag: 'Connectivity');
    }
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  bool get isConnected => _isConnected(state);

  void _handleReconnected() {
    _logger.info('Device reconnected to network', tag: 'Connectivity');
    // TODO: Trigger pending sync operations
  }

  /// Manually check connectivity
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      state = result;
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
