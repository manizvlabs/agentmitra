import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'logger_service.dart';

/// Enhanced caching service for offline-first functionality
class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static const String _metadataBoxName = 'cache_metadata';

  final LoggerService _logger;
  Box<Map>? _cacheBox;
  Box<Map>? _metadataBox;

  CacheService(this._logger);

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      // Initialize Hive (if not already initialized)
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        _cacheBox = await Hive.openBox<Map>(_cacheBoxName);
      } else {
        _cacheBox = Hive.box<Map>(_cacheBoxName);
      }

      if (!Hive.isBoxOpen(_metadataBoxName)) {
        _metadataBox = await Hive.openBox<Map>(_metadataBoxName);
      } else {
        _metadataBox = Hive.box<Map>(_metadataBoxName);
      }

      _logger.info('Cache service initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize cache service', error: e);
      // Fallback to SharedPreferences
      _logger.info('Falling back to SharedPreferences for caching');
    }
  }

  /// Store data in cache with optional TTL
  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'ttl': ttl?.inSeconds,
      };

      if (_cacheBox != null) {
        await _cacheBox!.put(key, cacheEntry);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$key', jsonEncode(cacheEntry));
      }

      _logger.debug('Cached data for key: $key');
    } catch (e) {
      _logger.error('Failed to cache data for key: $key', error: e);
    }
  }

  /// Retrieve data from cache
  Future<T?> get<T>(String key) async {
    try {
      Map? cacheEntry;

      if (_cacheBox != null) {
        cacheEntry = _cacheBox!.get(key);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final cacheData = prefs.getString('cache_$key');
        if (cacheData != null) {
          cacheEntry = jsonDecode(cacheData) as Map;
        }
      }

      if (cacheEntry == null) {
        return null;
      }

      // Check TTL
      if (cacheEntry['ttl'] != null) {
        final timestamp = DateTime.parse(cacheEntry['timestamp']);
        final ttl = Duration(seconds: cacheEntry['ttl']);
        if (DateTime.now().difference(timestamp) > ttl) {
          // Cache expired, remove it
          await delete(key);
          return null;
        }
      }

      return cacheEntry['data'] as T?;
    } catch (e) {
      _logger.error('Failed to retrieve cached data for key: $key', error: e);
      return null;
    }
  }

  /// Delete cached data
  Future<void> delete(String key) async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.delete(key);
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('cache_$key');
      }

      _logger.debug('Deleted cached data for key: $key');
    } catch (e) {
      _logger.error('Failed to delete cached data for key: $key', error: e);
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    try {
      if (_cacheBox != null) {
        await _cacheBox!.clear();
      }

      if (_metadataBox != null) {
        await _metadataBox!.clear();
      }

      // Also clear SharedPreferences fallback
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }

      _logger.info('Cleared all cached data');
    } catch (e) {
      _logger.error('Failed to clear cached data', error: e);
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      int itemCount = 0;
      int totalSize = 0;

      if (_cacheBox != null) {
        itemCount = _cacheBox!.length;
        // Estimate size (rough calculation)
        totalSize = _cacheBox!.keys.length * 100; // Rough estimate
      } else {
        // Fallback statistics from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final cacheKeys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
        itemCount = cacheKeys.length;
        totalSize = cacheKeys.length * 200; // Rough estimate
      }

      return {
        'item_count': itemCount,
        'estimated_size_kb': totalSize / 1024,
        'cache_type': _cacheBox != null ? 'Hive' : 'SharedPreferences',
      };
    } catch (e) {
      _logger.error('Failed to get cache statistics', error: e);
      return {
        'item_count': 0,
        'estimated_size_kb': 0,
        'cache_type': 'error',
      };
    }
  }

  /// Check if key exists in cache
  Future<bool> exists(String key) async {
    try {
      if (_cacheBox != null) {
        return _cacheBox!.containsKey(key);
      } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey('cache_$key');
      }
    } catch (e) {
      _logger.error('Failed to check cache existence for key: $key', error: e);
      return false;
    }
  }

  /// Get all cache keys
  Future<List<String>> getKeys() async {
    try {
      if (_cacheBox != null) {
        return _cacheBox!.keys.cast<String>().toList();
      } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getKeys().where((key) => key.startsWith('cache_'))
            .map((key) => key.replaceFirst('cache_', ''))
            .toList();
      }
    } catch (e) {
      _logger.error('Failed to get cache keys', error: e);
      return [];
    }
  }

  /// Store multiple key-value pairs
  Future<void> setMultiple(Map<String, dynamic> data, {Duration? ttl}) async {
    for (final entry in data.entries) {
      await set(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Get multiple values by keys
  Future<Map<String, dynamic>> getMultiple(List<String> keys) async {
    final result = <String, dynamic>{};
    for (final key in keys) {
      final value = await get(key);
      if (value != null) {
        result[key] = value;
      }
    }
    return result;
  }

  /// Clean expired cache entries
  Future<void> cleanExpired() async {
    try {
      final keys = await getKeys();
      for (final key in keys) {
        // This will automatically clean expired entries when accessed
        await get(key);
      }
      _logger.info('Cleaned expired cache entries');
    } catch (e) {
      _logger.error('Failed to clean expired cache entries', error: e);
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      await _metadataBox?.close();
      _logger.info('Cache service disposed');
    } catch (e) {
      _logger.error('Failed to dispose cache service', error: e);
    }
  }
}
