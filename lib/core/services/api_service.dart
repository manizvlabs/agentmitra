/// API Service for HTTP communication with backend
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8012';
  static const String apiVersion = '/api/v1';
  
  // Get full API URL
  static String get apiUrl => '$baseUrl$apiVersion';

  // Get headers with authentication
  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      var url = '$apiUrl$endpoint';
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final queryString = queryParameters.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url += '?$queryString';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl$endpoint'),
        headers: await getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Request failed');
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

