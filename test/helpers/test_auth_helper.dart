import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Test authentication helper for REAL DATA testing
class TestAuthHelper {
  static const String superAdminPhone = '+919876543200';
  static const String testPassword = 'testpassword';

  static const String apiBaseUrl = 'http://localhost:8012/api/v1';

  // Login with Super Admin credentials and store token
  static Future<bool> authenticateAsSuperAdmin() async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Tenant-ID': '00000000-0000-0000-0000-000000000000',
        },
        body: jsonEncode({
          'phone_number': superAdminPhone,
          'password': testPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        if (accessToken != null) {
          // Store token in secure storage
          const storage = FlutterSecureStorage();
          await storage.write(key: 'access_token', value: accessToken);
          print('✅ Successfully authenticated as Super Admin');
          return true;
        }
      }

      print('❌ Authentication failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('❌ Authentication error: $e');
      return false;
    }
  }

  // Clear authentication token
  static Future<void> clearAuthentication() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
  }

  // Test authentication by making a simple authenticated request
  static Future<bool> verifyAuthentication() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        print('❌ No access token found');
        return false;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Tenant-ID': '00000000-0000-0000-0000-000000000000',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Authentication verified successfully');
        return true;
      } else {
        print('❌ Authentication verification failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Authentication verification error: $e');
      return false;
    }
  }
}
