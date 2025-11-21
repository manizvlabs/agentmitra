/// Feature Flag Service
/// Provides runtime feature flag configuration with caching and API sync
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../../shared/constants/feature_flags.dart' as constants;

class FeatureFlagService {
  static final FeatureFlagService _instance = FeatureFlagService._internal();
  factory FeatureFlagService() => _instance;
  FeatureFlagService._internal();

  static const String _cacheKey = 'feature_flags_cache';
  static const String _cacheTimestampKey = 'feature_flags_cache_timestamp';
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const Duration _syncInterval = Duration(minutes: 10);

  Map<String, bool> _flagCache = {};
  DateTime? _lastSync;
  Timer? _syncTimer;
  bool _isInitialized = false;

  /// Initialize feature flag service
  /// Loads from cache first, then syncs with backend
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load from cache
    await _loadFromCache();

    // Sync with backend
    await syncFlags();

    // Start periodic sync
    _startPeriodicSync();

    _isInitialized = true;
  }

  /// Check if a feature is enabled
  /// Returns cached value immediately, syncs in background
  Future<bool> isFeatureEnabled(String flagName) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Return cached value if available
    if (_flagCache.containsKey(flagName)) {
      return _flagCache[flagName] ?? false;
    }

    // Fallback to constants if not in cache
    return _getDefaultValue(flagName);
  }

  /// Synchronous check (uses cache only)
  bool isFeatureEnabledSync(String flagName) {
    return _flagCache[flagName] ?? _getDefaultValue(flagName);
  }

  /// Sync feature flags from backend API
  Future<void> syncFlags() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/feature-flags');

      if (response['flags'] != null) {
        final flags = Map<String, bool>.from(
          response['flags'] as Map<String, dynamic>,
        );

        _flagCache = flags;
        _lastSync = DateTime.now();

        // Save to cache
        await _saveToCache(flags);
      }
    } catch (e) {
      // If API fails, use cached values or defaults
      print('Feature flag sync failed: $e');
    }
  }

  /// Clear cache and force refresh
  Future<void> clearCache() async {
    _flagCache.clear();
    _lastSync = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimestampKey);
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncFlags());
  }

  /// Stop periodic sync
  void stopSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Load flags from local cache
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString(_cacheKey);
      final timestampStr = prefs.getString(_cacheTimestampKey);

      if (cacheJson != null && timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final now = DateTime.now();

        // Check if cache is still valid
        if (now.difference(timestamp) < _cacheExpiry) {
          final data = Map<String, dynamic>.from(
            json.decode(cacheJson) as Map<String, dynamic>,
          );
          _flagCache = Map<String, bool>.from(data);
          _lastSync = timestamp;
        }
      }
    } catch (e) {
      print('Failed to load feature flags from cache: $e');
    }
  }

  /// Save flags to local cache
  Future<void> _saveToCache(Map<String, bool> flags) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(flags));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Failed to save feature flags to cache: $e');
    }
  }

  /// Get default value from constants
  bool _getDefaultValue(String flagName) {
    // Map API flag names to constant properties
    switch (flagName) {
      case 'phone_auth_enabled':
        return constants.FeatureFlags.phoneAuthEnabled;
      case 'otp_verification_enabled':
        return constants.FeatureFlags.otpVerificationEnabled;
      case 'biometric_auth_enabled':
        return constants.FeatureFlags.biometricAuthEnabled;
      case 'agent_code_login_enabled':
        return constants.FeatureFlags.agentCodeLoginEnabled;
      case 'dashboard_enabled':
        return constants.FeatureFlags.dashboardEnabled;
      case 'policies_enabled':
        return constants.FeatureFlags.policiesEnabled;
      case 'payments_enabled':
        return constants.FeatureFlags.paymentsEnabled;
      case 'chat_enabled':
        return constants.FeatureFlags.chatEnabled;
      case 'notifications_enabled':
        return constants.FeatureFlags.notificationsEnabled;
      case 'presentation_carousel_enabled':
        return constants.FeatureFlags.presentationCarouselEnabled;
      case 'presentation_editor_enabled':
        return constants.FeatureFlags.presentationEditorEnabled;
      case 'whatsapp_integration_enabled':
        return constants.FeatureFlags.whatsappIntegrationEnabled;
      case 'chatbot_enabled':
        return constants.FeatureFlags.chatbotEnabled;
      case 'analytics_enabled':
        return constants.FeatureFlags.analyticsEnabled;
      default:
        return false;
    }
  }
}


