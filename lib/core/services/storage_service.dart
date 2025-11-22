/// Storage Service for local data persistence
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Web-compatible storage implementation
class WebStorage {
  static final Map<String, dynamic> _storage = {};

  static Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }

  static String? getString(String key) {
    return _storage[key] as String?;
  }

  static Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }

  static int? getInt(String key) {
    return _storage[key] as int?;
  }

  static Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }

  static bool? getBool(String key) {
    return _storage[key] as bool?;
  }

  static Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }

  static double? getDouble(String key) {
    return _storage[key] as double?;
  }

  static Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }

  static Future<bool> clear() async {
    _storage.clear();
    return true;
  }

  static bool containsKey(String key) {
    return _storage.containsKey(key);
  }
}

class StorageService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  /// Initialize storage service
  static Future<void> initialize() async {
    if (kIsWeb) {
      // For web, use in-memory storage (you can enhance this with localStorage later)
      _isInitialized = true;
    } else {
      // For mobile/desktop, use SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Check if initialized
  static bool get isInitialized => _isInitialized;

  // String operations
  static Future<bool> setString(String key, String value) async {
    if (kIsWeb) {
      return await WebStorage.setString(key, value);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.setString(key, value);
  }

  static String? getString(String key) {
    if (kIsWeb) {
      return WebStorage.getString(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!.getString(key);
  }

  // Int operations
  static Future<bool> setInt(String key, int value) async {
    if (kIsWeb) {
      return await WebStorage.setInt(key, value);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    if (kIsWeb) {
      return WebStorage.getInt(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!.getInt(key);
  }

  // Bool operations
  static Future<bool> setBool(String key, bool value) async {
    if (kIsWeb) {
      return await WebStorage.setBool(key, value);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    if (kIsWeb) {
      return WebStorage.getBool(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!.getBool(key);
  }

  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    if (kIsWeb) {
      return await WebStorage.setDouble(key, value);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.setDouble(key, value);
  }

  static double? getDouble(String key) {
    if (kIsWeb) {
      return WebStorage.getDouble(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!.getDouble(key);
  }

  // Remove key
  static Future<bool> remove(String key) async {
    if (kIsWeb) {
      return await WebStorage.remove(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.remove(key);
  }

  // Clear all
  static Future<bool> clear() async {
    if (kIsWeb) {
      return await WebStorage.clear();
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return await _prefs!.clear();
  }

  // Check if key exists
  static bool containsKey(String key) {
    if (kIsWeb) {
      return WebStorage.containsKey(key);
    }
    if (!_isInitialized || _prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!.containsKey(key);
  }
}

