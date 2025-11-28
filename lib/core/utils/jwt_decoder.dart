import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/logger_service.dart';

/// JWT Decoder utility for extracting payload data from JWT tokens
class JwtDecoder {
  static final LoggerService _logger = LoggerService();

  /// Decode JWT token payload without verification (for client-side use)
  /// Note: In production, you should verify the token signature
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        _logger.error('Invalid JWT token format');
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if needed
      final normalizedPayload = _base64UrlNormalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);

      final payloadMap = jsonDecode(decodedString) as Map<String, dynamic>;
      _logger.debug('JWT payload decoded successfully');
      return payloadMap;
    } catch (e) {
      _logger.error('Failed to decode JWT payload', error: e);
      return null;
    }
  }

  /// Extract user roles from JWT payload
  static List<String> extractRoles(String token) {
    final payload = decodePayload(token);
    if (payload == null) return [];

    // Try different possible field names for roles
    final roles = payload['roles'] ?? payload['user_roles'] ?? [];

    if (roles is List) {
      return List<String>.from(roles);
    } else if (roles is String) {
      // If roles is a single string, convert to list
      return [roles];
    }

    return [];
  }

  /// Extract user permissions from JWT payload
  static List<String> extractPermissions(String token) {
    final payload = decodePayload(token);
    if (payload == null) return [];

    // Try different possible field names for permissions
    final permissions = payload['permissions'] ?? payload['user_permissions'] ?? [];

    if (permissions is List) {
      return List<String>.from(permissions);
    }

    return [];
  }

  /// Extract user ID from JWT payload
  static String? extractUserId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    // Try different possible field names
    return payload['sub'] ?? payload['user_id'] ?? payload['userId'];
  }

  /// Extract tenant ID from JWT payload
  static String? extractTenantId(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return payload['tenant_id'] ?? payload['tenantId'];
  }

  /// Extract user role (legacy field) from JWT payload
  static String? extractRole(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return payload['role'];
  }

  /// Extract email from JWT payload
  static String? extractEmail(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return payload['email'];
  }

  /// Extract phone number from JWT payload
  static String? extractPhoneNumber(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    return payload['phone_number'] ?? payload['phoneNumber'];
  }

  /// Extract feature flags from JWT payload
  static Map<String, dynamic> extractFeatureFlags(String token) {
    final payload = decodePayload(token);
    if (payload == null) return {};

    final featureFlags = payload['feature_flags'] ?? payload['featureFlags'] ?? {};

    if (featureFlags is Map) {
      return Map<String, dynamic>.from(featureFlags);
    }

    return {};
  }

  /// Check if JWT token is expired
  static bool isTokenExpired(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return false; // No expiration set

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    final now = DateTime.now();

    return now.isAfter(expiryDate);
  }

  /// Get token expiration date
  static DateTime? getTokenExpiration(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Normalize base64url string by adding padding if needed
  static String _base64UrlNormalize(String base64UrlString) {
    final padding = base64UrlString.length % 4;
    if (padding == 0) {
      return base64UrlString;
    } else if (padding == 2) {
      return base64UrlString + '==';
    } else if (padding == 3) {
      return base64UrlString + '=';
    } else {
      return base64UrlString;
    }
  }

  /// Validate JWT token format (basic validation)
  static bool isValidTokenFormat(String token) {
    final parts = token.split('.');
    return parts.length == 3 &&
           parts[0].isNotEmpty &&
           parts[1].isNotEmpty &&
           parts[2].isNotEmpty;
  }
}
