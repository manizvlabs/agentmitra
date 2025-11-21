/// Application-wide Constants
class AppConstants {
  // App Information
  static const String appName = 'Agent Mitra';
  static const String appVersion = '0.1.0';
  static const String appDescription = 'Insurance Agent Management Platform';

  // API Configuration
  static const String apiBaseUrl = 'http://localhost:8012';
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryAttempts = 3;

  // Storage Keys
  static const String storageAccessToken = 'access_token';
  static const String storageRefreshToken = 'refresh_token';
  static const String storageUserId = 'user_id';
  static const String storageAgentId = 'agent_id';
  static const String storageLanguage = 'language_preference';
  static const String storageTheme = 'theme_preference';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const int otpTimeoutSeconds = 300; // 5 minutes
  static const int sessionTimeoutMinutes = 30;
  static const int refreshTokenExpiryDays = 7;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int phoneNumberLength = 10;
  static const int otpLength = 6;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double minTouchTargetSize = 48.0;

  // Presentation Carousel
  static const int defaultSlideDuration = 4; // seconds
  static const double carouselHeight = 220.0;
  static const int maxSlidesPerPresentation = 20;
}

