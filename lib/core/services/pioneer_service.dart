import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Pioneer Feature Flag Service
/// Self-hosted alternative to FeatureHub
/// Can be easily switched between mock and real Pioneer API

/// Pioneer Feature Flag Service
/// Self-hosted feature flag management system
/// Supports both mock data (for development) and real Pioneer API
class PioneerService {
  static String? _scoutUrl;
  static String? _sdkKey;
  static String? _clientContext;
  static bool _isInitialized = false;
  static Map<String, dynamic> _features = {};
  static DateTime? _lastFetchTime;

  /// Whether to use mock data instead of real Pioneer API
  static bool _useMock = true;

  /// Initialize Pioneer with configuration
  static Future<void> initialize({
    String? scoutUrl,
    String? sdkKey,
    String? clientContext,
    bool useMock = true,
  }) async {
    if (_isInitialized) {
      debugPrint('Pioneer already initialized');
      return;
    }

    try {
      _scoutUrl = scoutUrl;
      _sdkKey = sdkKey;
      _clientContext = clientContext;
      _useMock = useMock;

      // Load initial features (mock or real)
      await _loadFeatures();

      _isInitialized = true;
      debugPrint('Pioneer initialized successfully (mock: $useMock)');
    } catch (e) {
      debugPrint('Failed to initialize Pioneer: $e');
      // Fall back to mock mode on error
      _useMock = true;
      await _loadMockFeatures();
      _isInitialized = true;
      debugPrint('Pioneer initialized with fallback to mock mode');
    }
  }

  /// Check if FeatureHub is initialized
  static bool get isInitialized => _isInitialized;

  /// Load features (either from mock data or Pioneer API)
  static Future<void> _loadFeatures() async {
    if (_useMock) {
      await _loadMockFeatures();
    } else {
      await _fetchFeaturesFromPioneer();
    }
  }

  /// Load mock features for development
  static Future<void> _loadMockFeatures() async {
    _features = {
      'CONTAINER_COLOUR_FEATURE': {
        'key': 'CONTAINER_COLOUR_FEATURE',
        'value': true,
        'type': 'BOOLEAN',
        'is_active': true,
        'version': 1,
        'rollout': 100,
      },
      'customer_dashboard_enabled': {
        'key': 'customer_dashboard_enabled',
        'value': false,
        'type': 'BOOLEAN',
        'is_active': false,
        'version': 1,
        'rollout': 0,
      },
      'agent_dashboard_enabled': {
        'key': 'agent_dashboard_enabled',
        'value': true,
        'type': 'BOOLEAN',
        'is_active': true,
        'version': 1,
        'rollout': 100,
      },
      'whatsapp_integration_enabled': {
        'key': 'whatsapp_integration_enabled',
        'value': true,
        'type': 'BOOLEAN',
        'is_active': true,
        'version': 1,
        'rollout': 100,
      },
    };
    _lastFetchTime = DateTime.now();
    debugPrint('Loaded ${_features.length} mock features');
  }

  /// Fetch features from real Pioneer API
  static Future<void> _fetchFeaturesFromPioneer() async {
    if (_scoutUrl == null) {
      throw Exception('Pioneer Scout URL not configured');
    }

    // Pioneer uses Scout daemon for SSE, but we can try the REST API first
    final compassUrl = _scoutUrl!.replaceAll('/features', '').replaceAll(':3030', ':3001');
    final uri = Uri.parse('$compassUrl/flags');

    try {
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
    } catch (e) {
      debugPrint('Error fetching features from Pioneer: $e');
      // Fall back to mock on API failure
      debugPrint('Falling back to mock features');
      await _loadMockFeatures();
    }
  }

  /// Check if a feature flag is enabled (synchronous - uses cached data)
  static bool isFeatureEnabledSync(String flagName, {bool defaultValue = false}) {
    if (!_isInitialized) {
      debugPrint('Pioneer not initialized, returning default value: $defaultValue');
      return defaultValue;
    }

    try {
      final feature = _features[flagName];
      if (feature == null) {
        debugPrint('Feature $flagName not found, returning default value: $defaultValue');
        return defaultValue;
      }

      // Pioneer stores boolean values in 'value' or 'is_active' field
      return feature['value'] ?? feature['is_active'] ?? defaultValue;
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
        await _loadFeatures();
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
    if (!_isInitialized || _useMock) {
      // In mock mode, just add to local features
      final newFeature = {
        'key': title,
        'value': isActive,
        'type': 'BOOLEAN',
        'is_active': isActive,
        'version': 1,
        'rollout': rollout,
        'title': title,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      _features[title] = newFeature;
      debugPrint('Created mock feature: $title');
      return true;
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll('/features', '').replaceAll(':3030', ':3001');
    final uri = Uri.parse('$compassUrl/flags');

    try {
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
        debugPrint('Failed to create feature: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error creating feature: $e');
      return false;
    }
  }

  /// Update an existing feature flag
  static Future<bool> updateFeature({
    required String title,
    String? description,
    bool? isActive,
    int? rollout,
  }) async {
    if (!_isInitialized) return false;

    if (_useMock) {
      // In mock mode, update local features
      if (_features.containsKey(title)) {
        final feature = Map<String, dynamic>.from(_features[title]);
        if (description != null) feature['description'] = description;
        if (isActive != null) {
          feature['is_active'] = isActive;
          feature['value'] = isActive;
        }
        if (rollout != null) feature['rollout'] = rollout;
        feature['updated_at'] = DateTime.now().toIso8601String();
        _features[title] = feature;
        debugPrint('Updated mock feature: $title');
        return true;
      }
      return false;
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll('/features', '').replaceAll(':3030', ':3001');

    // First, find the feature ID by getting all flags
    final allFlagsUri = Uri.parse('$compassUrl/flags');
    try {
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
    } catch (e) {
      debugPrint('Error updating feature: $e');
    }

    return false;
  }

  /// Delete a feature flag
  static Future<bool> deleteFeature(String title) async {
    if (!_isInitialized) return false;

    if (_useMock) {
      // In mock mode, remove from local features
      if (_features.containsKey(title)) {
        _features.remove(title);
        debugPrint('Deleted mock feature: $title');
        return true;
      }
      return false;
    }

    // Real Pioneer API call
    final compassUrl = _scoutUrl!.replaceAll('/features', '').replaceAll(':3030', ':3001');

    // First, find the feature ID
    final allFlagsUri = Uri.parse('$compassUrl/flags');
    try {
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
    } catch (e) {
      debugPrint('Error deleting feature: $e');
    }

    return false;
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
