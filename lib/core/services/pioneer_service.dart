import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Pioneer Feature Flag Service
/// Self-hosted feature flag management system
/// Connects to real Pioneer API endpoints only
class PioneerService {
  static String? _scoutUrl;
  static String? _sdkKey;
  static String? _clientContext;
  static bool _isInitialized = false;
  static Map<String, dynamic> _features = {};
  static DateTime? _lastFetchTime;

  /// Initialize Pioneer with configuration
  static Future<void> initialize({
    required String scoutUrl,
    String? sdkKey,
    String? clientContext,
  }) async {
    if (_isInitialized) {
      debugPrint('Pioneer already initialized');
      return;
    }

    if (scoutUrl.isEmpty) {
      throw Exception('Pioneer Scout URL is required');
    }

    try {
      _scoutUrl = scoutUrl;
      _sdkKey = sdkKey;
      _clientContext = clientContext;

      // Load initial features from Pioneer API
      await _loadFeatures();

      _isInitialized = true;
      debugPrint('Pioneer initialized successfully (real API)');
    } catch (e) {
      debugPrint('Failed to initialize Pioneer: $e');
      throw Exception('Pioneer initialization failed: $e');
    }
  }

  /// Check if FeatureHub is initialized
  static bool get isInitialized => _isInitialized;

  /// Get default value for a feature flag when Pioneer is not available
  static bool _getDefaultValueForFlag(String flagName) {
    // Default feature flag values (conservative defaults)
    const defaultFlags = {
      'payments_enabled': false,
      'chat_enabled': true,
      'presentation_carousel_enabled': false,
      'CONTAINER_COLOUR_FEATURE': false,
      'analytics_enabled': true,
      'notifications_enabled': true,
      'voice_input_enabled': false,
      'file_attachments_enabled': true,
      'video_tutorials_enabled': true,
      'whatsapp_integration_enabled': true,
      'advanced_analytics_enabled': false,
      'ai_insights_enabled': false,
      'voice_commands_enabled': false,
      'ar_preview_enabled': false,
    };

    return defaultFlags[flagName] ?? false;
  }

  /// Load features from Pioneer API
  static Future<void> _loadFeatures() async {
    await _fetchFeaturesFromPioneer();
  }

  /// Fetch features from Pioneer API
  static Future<void> _fetchFeaturesFromPioneer() async {
    if (_scoutUrl == null) {
      throw Exception('Pioneer Scout URL not configured');
    }

    // Use compass-server for REST API (port 4001), scout is for SSE (port 4002)
    final compassUrl = _scoutUrl!.replaceAll(':4002', ':4001');
    final uri = Uri.parse('$compassUrl/api/flags');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('flags')) {
        final flags = data['flags'] as List<dynamic>;
        _features = {};

        for (final flag in flags) {
          if (flag is Map<String, dynamic> && flag.containsKey('title')) {
            final key = flag['title'] as String;
            _features[key] = {
              'key': key,
              'value': flag['is_active'] ?? false,
              'type': 'BOOLEAN',
              'is_active': flag['is_active'] ?? false,
              'version': flag['version'] ?? 1,
              'rollout': flag['rollout'] ?? 0,
            };
          }
        }

        _lastFetchTime = DateTime.now();
        debugPrint('Fetched ${flags.length} features from Pioneer API');
      } else {
        throw Exception('Unexpected API response format');
      }
    } else {
      throw Exception('Failed to fetch features: ${response.statusCode} ${response.body}');
    }
  }

  /// Check if a feature flag is enabled (synchronous - uses cached data)
  static bool isFeatureEnabledSync(String flagName) {
    if (!_isInitialized) {
      debugPrint('Pioneer not initialized, returning default value for $flagName');
      return _getDefaultValueForFlag(flagName);
    }

    final feature = _features[flagName];
    if (feature == null) {
      debugPrint('Feature flag "$flagName" not found in Pioneer, returning default');
      return _getDefaultValueForFlag(flagName);
    }

    // Pioneer stores boolean values in 'value' or 'is_active' field
    return feature['value'] ?? feature['is_active'] ?? false;
  }

  /// Check if a feature flag is enabled (asynchronous - fetches fresh data)
  static Future<bool> isFeatureEnabled(String flagName) async {
    if (!_isInitialized) {
      debugPrint('Pioneer not initialized, returning default value for $flagName');
      return _getDefaultValueForFlag(flagName);
    }

    // Refresh features periodically (every 5 minutes)
    if (_lastFetchTime == null ||
        DateTime.now().difference(_lastFetchTime!) > const Duration(minutes: 5)) {
      try {
        await _loadFeatures();
      } catch (e) {
        debugPrint('Failed to refresh Pioneer features: $e, using cached/default values');
      }
    }

    return isFeatureEnabledSync(flagName);
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
  static Stream<bool> listenToFeature(String flagName) {
    // For now, return a stream that emits the current value
    // In a full implementation, you'd use WebSockets or polling for real-time updates
    return Stream.value(isFeatureEnabledSync(flagName));
  }

  /// Force refresh of all features
  static Future<void> refreshFeatures() async {
    if (!_isInitialized) {
      debugPrint('FeatureHub not initialized, cannot refresh');
      return;
    }

    try {
      await _loadFeatures();
    } catch (e) {
      debugPrint('Error refreshing features: $e');
    }
  }

  /// Create a new feature flag
  static Future<bool> createFeature({
    required String title,
    required String description,
    bool isActive = false,
    int rollout = 0,
  }) async {
    if (!_isInitialized) {
      throw Exception('Pioneer not initialized');
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll(':4002', ':4001');
    final uri = Uri.parse('$compassUrl/flags');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'flag': {
          'title': title,
          'description': description,
          'is_active': isActive,
          'rollout': rollout,
        }
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Refresh features after creation
      await _loadFeatures();
      debugPrint('Created feature: $title');
      return true;
    } else {
      throw Exception('Failed to create feature: ${response.statusCode} ${response.body}');
    }
  }

  /// Update an existing feature flag
  static Future<bool> updateFeature({
    required String title,
    String? description,
    bool? isActive,
    int? rollout,
  }) async {
    if (!_isInitialized) {
      throw Exception('Pioneer not initialized');
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll(':4002', ':4001');

    // First, find the feature ID by getting all flags
    final allFlagsUri = Uri.parse('$compassUrl/flags');

    final listResponse = await http.get(allFlagsUri);
    if (listResponse.statusCode == 200) {
      final data = json.decode(listResponse.body);
      if (data is Map<String, dynamic> && data.containsKey('flags')) {
        final flags = data['flags'] as List<dynamic>;
        final flag = flags.firstWhere(
          (f) => f is Map<String, dynamic> && f['title'] == title,
          orElse: () => null,
        );

        if (flag != null && flag['id'] != null) {
          final flagId = flag['id'];
          final updateUri = Uri.parse('$compassUrl/flags/$flagId');

          final updateData = <String, dynamic>{};
          if (description != null) updateData['description'] = description;
          if (isActive != null) updateData['is_active'] = isActive;
          if (rollout != null) updateData['rollout'] = rollout;

          final response = await http.put(
            updateUri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'flag': updateData}),
          );

          if (response.statusCode == 200) {
            // Refresh features after update
            await _loadFeatures();
            debugPrint('Updated feature: $title');
            return true;
          }
        }
      }
    }

    throw Exception('Failed to update feature: $title');
  }

  /// Delete a feature flag
  static Future<bool> deleteFeature(String title) async {
    if (!_isInitialized) {
      throw Exception('Pioneer not initialized');
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll(':4002', ':4001');

    // First, find the feature ID
    final allFlagsUri = Uri.parse('$compassUrl/flags');

    final listResponse = await http.get(allFlagsUri);
    if (listResponse.statusCode == 200) {
      final data = json.decode(listResponse.body);
      if (data is Map<String, dynamic> && data.containsKey('flags')) {
        final flags = data['flags'] as List<dynamic>;
        final flag = flags.firstWhere(
          (f) => f is Map<String, dynamic> && f['title'] == title,
          orElse: () => null,
        );

        if (flag != null && flag['id'] != null) {
          final flagId = flag['id'];
          final deleteUri = Uri.parse('$compassUrl/flags/$flagId');

          final response = await http.delete(deleteUri);

          if (response.statusCode == 200) {
            // Refresh features after deletion
            await _loadFeatures();
            debugPrint('Deleted feature: $title');
            return true;
          }
        }
      }
    }

    throw Exception('Failed to delete feature: $title');
  }

  /// Shutdown Pioneer (cleanup)
  static void shutdown() {
    _scoutUrl = null;
    _sdkKey = null;
    _clientContext = null;
    _features.clear();
    _lastFetchTime = null;
    _isInitialized = false;
    debugPrint('Pioneer shutdown');
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
