import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Pioneer Feature Flag Service
/// Self-hosted alternative to FeatureHub
/// Can be easily switched between mock and real Pioneer API

/// FeatureHub service for feature flag management using REST API
class FeatureHubService {
  static String? _edgeUrl;
  static List<String>? _apiKeys;
  static String? _clientContext;
  static bool _isInitialized = false;
  static Map<String, dynamic> _features = {};
  static DateTime? _lastFetchTime;

  /// Initialize FeatureHub with configuration
  static Future<void> initialize({
    required String edgeUrl,
    required List<String> apiKeys,
    String? clientContext,
  }) async {
    if (_isInitialized) {
      debugPrint('FeatureHub already initialized');
      return;
    }

    try {
      _edgeUrl = edgeUrl;
      _apiKeys = List.from(apiKeys);
      _clientContext = clientContext;

      // Test connection and fetch initial features
      await _fetchFeatures();

      _isInitialized = true;
      debugPrint('FeatureHub initialized successfully with ${apiKeys.length} API keys');
    } catch (e) {
      debugPrint('Failed to initialize FeatureHub: $e');
      rethrow;
    }
  }

  /// Check if FeatureHub is initialized
  static bool get isInitialized => _isInitialized;

  /// Fetch features from FeatureHub API
  static Future<void> _fetchFeatures() async {
    if (_edgeUrl == null || _apiKeys == null || _apiKeys!.isEmpty) {
      throw Exception('FeatureHub not configured');
    }

    final uri = Uri.parse(_edgeUrl!);
    final headers = <String, String>{};

    // Add API keys to headers (FeatureHub expects them in a specific format)
    for (int i = 0; i < _apiKeys!.length; i++) {
      headers['apiKey'] = _apiKeys![i];
    }

    // Add client context if provided
    if (_clientContext != null) {
      headers['FH-CLIENT-CONTEXT'] = _clientContext!;
    }

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final features = json.decode(response.body) as List<dynamic>;
        _features = {};

        for (final feature in features) {
          if (feature is Map<String, dynamic> && feature.containsKey('key')) {
            _features[feature['key']] = feature;
          }
        }

        _lastFetchTime = DateTime.now();
        debugPrint('Fetched ${features.length} features from FeatureHub');
      } else {
        throw Exception('Failed to fetch features: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching features: $e');
      throw e;
    }
  }

  /// Check if a feature flag is enabled (synchronous - uses cached data)
  static bool isFeatureEnabledSync(String flagName, {bool defaultValue = false}) {
    if (!_isInitialized) {
      debugPrint('FeatureHub not initialized, returning default value: $defaultValue');
      return defaultValue;
    }

    try {
      final feature = _features[flagName];
      if (feature == null) {
        debugPrint('Feature $flagName not found, returning default value: $defaultValue');
        return defaultValue;
      }

      // FeatureHub stores boolean values differently based on type
      if (feature['type'] == 'BOOLEAN') {
        return feature['value'] ?? defaultValue;
      }

      return defaultValue;
    } catch (e) {
      debugPrint('Error checking feature flag $flagName: $e');
      return defaultValue;
    }
  }

  /// Check if a feature flag is enabled (asynchronous - fetches fresh data)
  static Future<bool> isFeatureEnabled(String flagName, {bool defaultValue = false}) async {
    if (!_isInitialized) {
      debugPrint('FeatureHub not initialized, returning default value: $defaultValue');
      return defaultValue;
    }

    try {
      // Refresh features periodically (every 5 minutes)
      if (_lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!) > const Duration(minutes: 5)) {
        await _fetchFeatures();
      }

      return isFeatureEnabledSync(flagName, defaultValue: defaultValue);
    } catch (e) {
      debugPrint('Error checking feature flag $flagName: $e');
      return defaultValue;
    }
  }

  /// Get string feature value
  static String getStringFeature(String flagName, {String defaultValue = ''}) {
    if (!_isInitialized) {
      return defaultValue;
    }

    try {
      final feature = _features[flagName];
      if (feature == null || feature['type'] != 'STRING') {
        return defaultValue;
      }

      return feature['value'] ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting string feature $flagName: $e');
      return defaultValue;
    }
  }

  /// Get number feature value
  static num getNumberFeature(String flagName, {num defaultValue = 0}) {
    if (!_isInitialized) {
      return defaultValue;
    }

    try {
      final feature = _features[flagName];
      if (feature == null || feature['type'] != 'NUMBER') {
        return defaultValue;
      }

      return feature['value'] ?? defaultValue;
    } catch (e) {
      debugPrint('Error getting number feature $flagName: $e');
      return defaultValue;
    }
  }

  /// Get JSON feature value
  static Map<String, dynamic>? getJsonFeature(String flagName) {
    if (!_isInitialized) {
      return null;
    }

    try {
      final feature = _features[flagName];
      if (feature == null || feature['type'] != 'JSON') {
        return null;
      }

      return feature['value'];
    } catch (e) {
      debugPrint('Error getting JSON feature $flagName: $e');
      return null;
    }
  }

  /// Listen to feature flag changes (simplified - returns current value stream)
  static Stream<bool> listenToFeature(String flagName, {bool defaultValue = false}) {
    // For now, return a stream that emits the current value
    // In a full implementation, you'd use WebSockets or polling for real-time updates
    return Stream.value(isFeatureEnabledSync(flagName, defaultValue: defaultValue));
  }

  /// Force refresh of all features
  static Future<void> refreshFeatures() async {
    if (!_isInitialized) {
      debugPrint('FeatureHub not initialized, cannot refresh');
      return;
    }

    try {
      await _fetchFeatures();
    } catch (e) {
      debugPrint('Error refreshing features: $e');
    }
  }

  /// Shutdown FeatureHub (cleanup)
  static void shutdown() {
    _edgeUrl = null;
    _apiKeys = null;
    _clientContext = null;
    _features.clear();
    _lastFetchTime = null;
    _isInitialized = false;
    debugPrint('FeatureHub shutdown');
  }

  /// Get all available features (for debugging)
  static Map<String, dynamic> getAllFeatures() {
    return Map.from(_features);
  }

  /// Get feature details for debugging
  static Map<String, dynamic>? getFeatureDetails(String flagName) {
    return _features[flagName];
  }
}
