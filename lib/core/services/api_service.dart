/// API Service for HTTP communication with backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8012';
  static const String apiVersion = '/api/v1';

  // Get full API URL - use relative URLs for web deployment
  static String get apiUrl {
    if (kIsWeb) {
      // When running on web through Nginx, use relative API paths
      return '/api/v1';
    }
    // For mobile/native apps, use direct backend URL
    return '$baseUrl$apiVersion';
  }

  // Get headers with authentication
  static Future<Map<String, String>> getHeaders() async {
    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      var url = '$apiUrl$endpoint';
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final queryString = queryParameters.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      return handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
      );

      return handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response (public method for use by other services)
  static dynamic handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{'success': true};
      }
      final decoded = jsonDecode(response.body);
      // Handle both List and Map responses
      if (decoded is List) {
        return decoded;
      }
      return decoded as Map<String, dynamic>;
    } else {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['detail'] ?? error['message'] ?? 'Request failed');
      } catch (_) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

