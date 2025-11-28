import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';
import '../config/app_config.dart';

/// CDN Service for loading localization files and other assets from CDN
class CDNService {
  static final CDNService _instance = CDNService._internal();
  factory CDNService() => _instance;
  CDNService._internal();

  static AppConfig get _config => AppConfig();

  static String get cdnBaseUrl => _config.cdnBaseUrl;
  static String get l10nBaseUrl => '$cdnBaseUrl/l10n/v1';
  static Duration get requestTimeout => Duration(seconds: _config.apiTimeoutSeconds);

  /// Load ARB file from CDN
  Future<Map<String, dynamic>> loadARBFile(String locale) async {
    try {
      final url = Uri.parse('$l10nBaseUrl/app_$locale.arb');
      
      final response = await http.get(
        url,
        headers: {
          'Cache-Control': 'no-cache',
          'Accept': 'application/json',
        },
      ).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final arbData = json.decode(response.body) as Map<String, dynamic>;
        LoggerService().info('Successfully loaded ARB file from CDN for locale: $locale');
        return arbData;
      } else {
        LoggerService().warning('Failed to load ARB file from CDN: ${response.statusCode}');
        throw Exception('Failed to load ARB file: ${response.statusCode}');
      }
    } catch (e) {
      LoggerService().error('Error loading ARB file from CDN: $e');
      rethrow;
    }
  }

  /// Check if CDN is available
  Future<bool> checkCDNAvailability() async {
    try {
      final response = await http.head(
        Uri.parse('$l10nBaseUrl/app_en.arb'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      LoggerService().warning('CDN not available: $e');
      return false;
    }
  }

  /// Get version from CDN ARB file
  Future<String?> getVersionFromCDN(String locale) async {
    try {
      final arbData = await loadARBFile(locale);
      return arbData['@@version'] as String?;
    } catch (e) {
      LoggerService().error('Failed to get version from CDN: $e');
      return null;
    }
  }
}

