import 'package:flutter/material.dart';
import 'dart:async';
import 'api_service.dart';
import 'auth_service.dart';

/// Simplified Feature Flag Service
/// Essential features are always enabled, others use defaults
class FeatureFlagService {
  /// Essential features that are always enabled for app functionality
  static const Map<String, bool> _essentialFeatures = {
    'dashboard_enabled': true,
    'login_enabled': true,
    'registration_enabled': true,
    'otp_verification_enabled': true,
  };

  /// Default values for other features
  static const Map<String, bool> _defaultFeatures = {
    'payments_enabled': false,
    'chat_enabled': true,
    'presentation_carousel_enabled': false,
    'analytics_enabled': true,
    'notifications_enabled': true,
    'voice_input_enabled': false,
    'file_attachments_enabled': true,
    'video_tutorials_enabled': true,
    'whatsapp_integration_enabled': true,
    'advanced_analytics_enabled': false,
    'ai_insights_enabled': false,
  };

  /// Check if a feature flag is enabled
  Future<bool> isFeatureEnabled(String flagName, {String? userId, String? tenantId}) async {
    // Essential features are always enabled
    if (_essentialFeatures.containsKey(flagName)) {
      return _essentialFeatures[flagName]!;
    }

    // Other features use defaults
    return _defaultFeatures[flagName] ?? false;
  }

  /// Synchronous check for feature flags (for performance)
  bool isFeatureEnabledSync(String flagName, {String? userId, String? tenantId}) {
    // Essential features are always enabled
    if (_essentialFeatures.containsKey(flagName)) {
      return _essentialFeatures[flagName]!;
    }

    // Other features use defaults
    return _defaultFeatures[flagName] ?? false;
  }

  /// Check if user has a specific permission (simplified)
  Future<bool> hasPermission(String permission, {String? userId}) async {
    // For demo purposes, always return true
    return true;
  }
}
