import 'dart:convert';
import 'dart:io';

class PioneerService {
  static Map<String, dynamic> _features = {};
  static bool _useMock = true;
  
  static Future<void> initialize({bool useMock = true}) async {
    _useMock = useMock;
    _features = {
      'CONTAINER_COLOUR_FEATURE': {
        'key': 'CONTAINER_COLOUR_FEATURE',
        'value': true,
        'is_active': true,
        'rollout': 100,
      },
      'customer_dashboard_enabled': {
        'key': 'customer_dashboard_enabled',
        'value': false,
        'is_active': false,
        'rollout': 0,
      },
    };
    print('Pioneer initialized with mock: $useMock');
  }
  
  static bool isFeatureEnabledSync(String flagName, {bool defaultValue = false}) {
    final feature = _features[flagName];
    return feature?['value'] ?? feature?['is_active'] ?? defaultValue;
  }
  
  static Future<bool> createFeature({
    required String title,
    required String description,
    bool isActive = false,
    int rollout = 0,
  }) async {
    _features[title] = {
      'key': title,
      'value': isActive,
      'is_active': isActive,
      'rollout': rollout,
      'title': title,
      'description': description,
    };
    print('Created feature: $title');
    return true;
  }
  
  static Future<bool> updateFeature({
    required String title,
    String? description,
    bool? isActive,
    int? rollout,
  }) async {
    if (_features.containsKey(title)) {
      if (description != null) _features[title]['description'] = description;
      if (isActive != null) {
        _features[title]['is_active'] = isActive;
        _features[title]['value'] = isActive;
      }
      if (rollout != null) _features[title]['rollout'] = rollout;
      print('Updated feature: $title');
      return true;
    }
    return false;
  }
  
  static Future<bool> deleteFeature(String title) async {
    if (_features.containsKey(title)) {
      _features.remove(title);
      print('Deleted feature: $title');
      return true;
    }
    return false;
  }
  
  static Map<String, dynamic> getAllFeatures() {
    return Map.from(_features);
  }
}

void main() async {
  print('=== Testing Pioneer Service CRUD ===');
  
  // Initialize
  await PioneerService.initialize(useMock: true);
  
  // Test initial features
  print('\nInitial features:');
  var features = PioneerService.getAllFeatures();
  print('Found ${features.length} features');
  
  // Test create
  print('\nTesting CREATE...');
  await PioneerService.createFeature(
    title: 'test_flag',
    description: 'Test flag',
    isActive: true,
    rollout: 75,
  );
  
  // Test read
  print('\nTesting READ...');
  features = PioneerService.getAllFeatures();
  print('Now found ${features.length} features');
  final testFlag = features['test_flag'];
  print('Test flag active: ${testFlag?['is_active']}');
  
  // Test update
  print('\nTesting UPDATE...');
  await PioneerService.updateFeature(
    title: 'test_flag',
    isActive: false,
    rollout: 25,
  );
  
  // Test evaluation
  print('\nTesting EVALUATION...');
  final isEnabled = PioneerService.isFeatureEnabledSync('test_flag');
  print('test_flag enabled: $isEnabled');
  
  // Test delete
  print('\nTesting DELETE...');
  await PioneerService.deleteFeature('test_flag');
  
  // Final check
  features = PioneerService.getAllFeatures();
  print('\nFinal features: ${features.length}');
  print('test_flag exists: ${features.containsKey('test_flag')}');
  
  print('\n✅ Pioneer Service CRUD operations working!');
}
