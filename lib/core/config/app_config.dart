import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
class AppConfig {
  static AppConfig? _instance;
  static bool _initialized = false;

  factory AppConfig() {
    debugPrint('DEBUG: AppConfig() factory called, _instance is null: ${_instance == null}');
    if (_instance == null) {
      debugPrint('DEBUG: Creating AppConfig singleton instance');
      _instance = AppConfig._internal();
    } else {
      debugPrint('DEBUG: Returning existing AppConfig singleton instance');
    }
    return _instance!;
  }

  AppConfig._internal() {
    debugPrint('DEBUG: AppConfig._internal() called, calling _loadConfig()');
    _loadConfig();
    debugPrint('DEBUG: AppConfig._internal() completed');
  }

  late final String _appName;
  late final String _appVersion;
  late final String _environment;
  late final bool _debug;

  // API Configuration
  late final String _apiBaseUrl;
  late final String _wsBaseUrl;
  late final String _apiVersion;
  late final int _apiTimeoutSeconds;
  late final int _apiRetryAttempts;
  late final int _apiRetryDelaySeconds;

  // Authentication
  late final String _jwtAccessTokenKey;
  late final String _jwtRefreshTokenKey;
  late final bool _biometricEnabled;
  late final bool _autoLoginEnabled;
  late final int _sessionTimeoutMinutes;

  // Feature Flags
  late final bool _enableChatbot;
  late final bool _enableVideoTutorials;
  late final bool _enableWhatsappIntegration;
  late final bool _enablePaymentProcessing;
  late final bool _enableAnalytics;
  late final bool _enableNotifications;
  late final bool _enableVoiceInput;
  late final bool _enableFileAttachments;

  // External Services
  late final String _whatsappBusinessNumber;
  late final String _whatsappWebUrl;
  late final String _cdnBaseUrl;
  late final int _cdnImageQuality;
  late final String _cdnVideoQuality;

  // Payment Gateways
  late final String _razorpayKeyId;
  late final String _stripePublishableKey;

  // Analytics & Monitoring
  late final bool _analyticsEnabled;
  late final bool _crashReportingEnabled;
  late final bool _performanceMonitoringEnabled;
  late final bool _errorTrackingEnabled;

  // Storage & Cache
  late final int _cacheMaxSizeMb;
  late final int _cacheTtlHours;
  late final bool _localStorageEncryptionEnabled;

  // UI/UX Configuration
  late final String _themeMode;
  late final String _language;
  late final List<String> _supportedLanguages;
  late final String _dateFormat;
  late final String _timeFormat;
  late final String _currencySymbol;
  late final String _numberFormat;

  // Notification Settings
  late final bool _notificationSoundEnabled;
  late final bool _notificationVibrationEnabled;
  late final bool _notificationBadgeEnabled;
  late final bool _pushNotificationEnabled;

  // Development Settings
  late final String _logLevel;
  late final bool _enableDeveloperOptions;
  late final bool _mockDataEnabled;
  late final bool _apiLoggingEnabled;

  // Compliance & Security
  late final bool _dataEncryptionEnabled;
  late final bool _biometricAuthEnabled;
  late final bool _screenshotPreventionEnabled;
  late final bool _rootDetectionEnabled;

  // Performance Settings
  late final int _imageCompressionQuality;
  late final bool _videoCompressionEnabled;
  late final bool _lazyLoadingEnabled;
  late final int _paginationPageSize;

  // Integration Keys
  late final String _firebaseApiKey;
  late final String _firebaseProjectId;
  late final String _firebaseAppId;
  late final String _firebaseMessagingSenderId;

  // Pioneer Feature Flags
  late final bool _pioneerEnabled;
  late final String _pioneerUrl;
  late final String _pioneerApiKey;
  late final String _pioneerScoutUrl;

  // Platform Specific
  late final String _iosAppStoreId;
  late final String _iosDeepLinkScheme;
  late final String _androidPackageName;
  late final String _androidDeepLinkScheme;
  late final String _androidPlayStoreUrl;

  // Third Party Integrations
  late final String _googleClientId;
  late final String _facebookAppId;
  late final String _intercomAppId;
  late final String _zendeskUrl;

  // Experimental Features
  late final bool _enableAiInsights;
  late final bool _enableAdvancedAnalytics;
  late final bool _enableVoiceCommands;
  late final bool _enableArPreview;

  void _loadConfig() {
    debugPrint('DEBUG: _loadConfig() started, _initialized = $_initialized');
    // Load environment variables
    _appName = dotenv.get('APP_NAME', fallback: 'Agent Mitra');
    _appVersion = dotenv.get('APP_VERSION', fallback: '1.0.0');
    _environment = dotenv.get('ENVIRONMENT', fallback: 'development');
    _debug = dotenv.get('DEBUG', fallback: 'true') == 'true';

    // Pioneer Feature Flags - assign early since Pioneer init happens during _loadConfig execution
    // For development, make Pioneer optional to allow testing without external services
    if (kIsWeb && _debug) {
      // In debug web mode, make Pioneer optional for easier development
      _pioneerEnabled = dotenv.get('PIONEER_ENABLED', fallback: 'false') == 'true';
      _pioneerUrl = 'http://localhost/pioneer';
      _pioneerApiKey = 'test-sdk-key-12345';
      _pioneerScoutUrl = 'http://localhost/pioneer';
    } else if (kIsWeb) {
      _pioneerEnabled = true;
      _pioneerUrl = 'http://localhost/pioneer';
      _pioneerApiKey = 'test-sdk-key-12345';
      _pioneerScoutUrl = 'http://localhost/pioneer';
    } else {
      _pioneerEnabled = dotenv.get('PIONEER_ENABLED', fallback: 'true') == 'true';
      _pioneerUrl = dotenv.get('PIONEER_URL', fallback: 'http://localhost:4001');
      _pioneerApiKey = dotenv.get('PIONEER_API_KEY', fallback: 'test-sdk-key-12345');
      _pioneerScoutUrl = dotenv.get('PIONEER_SCOUT_URL', fallback: 'http://localhost:4002');
    }

    // API Configuration
    // For web builds served through nginx proxy, use empty base URL to use same origin
    // This allows nginx to proxy /api/ requests to the backend
    // For mobile apps, use Nginx proxy at port 80 to match production setup
    // For development web (port 8080), proxy to backend directly
    final defaultApiUrl = kIsWeb ? 'http://localhost:8012' : 'http://localhost:80';
    final defaultWsUrl = kIsWeb ? 'ws://localhost:8012' : 'ws://localhost:80';
    _apiBaseUrl = dotenv.get('API_BASE_URL', fallback: defaultApiUrl);
    _wsBaseUrl = dotenv.get('WS_BASE_URL', fallback: defaultWsUrl);

    // Debug output for web builds
    if (kIsWeb) {
      debugPrint('DEBUG: API_BASE_URL set to: $_apiBaseUrl');
      debugPrint('DEBUG: WS_BASE_URL set to: $_wsBaseUrl');
      debugPrint('DEBUG: Full API URL: ${fullApiUrl}');
    }
    debugPrint('DEBUG: About to assign _apiVersion');
    _apiVersion = dotenv.get('API_VERSION', fallback: '/api/v1');
    debugPrint('DEBUG: _apiVersion assigned: $_apiVersion');
    _apiTimeoutSeconds = int.parse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30'));
    _apiRetryAttempts = int.parse(dotenv.get('API_RETRY_ATTEMPTS', fallback: '3'));
    _apiRetryDelaySeconds = int.parse(dotenv.get('API_RETRY_DELAY_SECONDS', fallback: '2'));

    // Authentication
    _jwtAccessTokenKey = dotenv.get('JWT_ACCESS_TOKEN_KEY', fallback: 'agent_mitra_access_token');
    _jwtRefreshTokenKey = dotenv.get('JWT_REFRESH_TOKEN_KEY', fallback: 'agent_mitra_refresh_token');
    _biometricEnabled = dotenv.get('BIOMETRIC_ENABLED', fallback: 'true') == 'true';
    _autoLoginEnabled = dotenv.get('AUTO_LOGIN_ENABLED', fallback: 'true') == 'true';
    _sessionTimeoutMinutes = int.parse(dotenv.get('SESSION_TIMEOUT_MINUTES', fallback: '60'));

    // Feature Flags
    _enableChatbot = dotenv.get('ENABLE_CHATBOT', fallback: 'true') == 'true';
    _enableVideoTutorials = dotenv.get('ENABLE_VIDEO_TUTORIALS', fallback: 'true') == 'true';
    _enableWhatsappIntegration = dotenv.get('ENABLE_WHATSAPP_INTEGRATION', fallback: 'true') == 'true';
    _enablePaymentProcessing = dotenv.get('ENABLE_PAYMENT_PROCESSING', fallback: 'false') == 'true';
    _enableAnalytics = dotenv.get('ENABLE_ANALYTICS', fallback: 'true') == 'true';
    _enableNotifications = dotenv.get('ENABLE_NOTIFICATIONS', fallback: 'true') == 'true';
    _enableVoiceInput = dotenv.get('ENABLE_VOICE_INPUT', fallback: 'false') == 'true';
    _enableFileAttachments = dotenv.get('ENABLE_FILE_ATTACHMENTS', fallback: 'true') == 'true';

    // External Services
    _whatsappBusinessNumber = dotenv.get('WHATSAPP_BUSINESS_NUMBER', fallback: '+919876543210');
    _whatsappWebUrl = dotenv.get('WHATSAPP_WEB_URL', fallback: 'https://wa.me/');
    _cdnBaseUrl = dotenv.get('CDN_BASE_URL', fallback: 'https://cdn.agentmitra.com');
    _cdnImageQuality = int.parse(dotenv.get('CDN_IMAGE_QUALITY', fallback: '80'));
    _cdnVideoQuality = dotenv.get('CDN_VIDEO_QUALITY', fallback: '720p');

    // Payment Gateways
    _razorpayKeyId = dotenv.get('RAZORPAY_KEY_ID', fallback: 'your_razorpay_key_id');
    _stripePublishableKey = dotenv.get('STRIPE_PUBLISHABLE_KEY', fallback: 'your_stripe_publishable_key');

    // Analytics & Monitoring
    _analyticsEnabled = dotenv.get('ANALYTICS_ENABLED', fallback: 'true') == 'true';
    _crashReportingEnabled = dotenv.get('CRASH_REPORTING_ENABLED', fallback: 'true') == 'true';
    _performanceMonitoringEnabled = dotenv.get('PERFORMANCE_MONITORING_ENABLED', fallback: 'true') == 'true';
    _errorTrackingEnabled = dotenv.get('ERROR_TRACKING_ENABLED', fallback: 'true') == 'true';

    // Storage & Cache
    _cacheMaxSizeMb = int.parse(dotenv.get('CACHE_MAX_SIZE_MB', fallback: '50'));
    _cacheTtlHours = int.parse(dotenv.get('CACHE_TTL_HOURS', fallback: '24'));
    _localStorageEncryptionEnabled = dotenv.get('LOCAL_STORAGE_ENCRYPTION_ENABLED', fallback: 'true') == 'true';

    // UI/UX Configuration
    _themeMode = dotenv.get('THEME_MODE', fallback: 'system');
    _language = dotenv.get('LANGUAGE', fallback: 'en');
    _supportedLanguages = dotenv.get('SUPPORTED_LANGUAGES', fallback: 'en,hi,te').split(',');
    _dateFormat = dotenv.get('DATE_FORMAT', fallback: 'dd/MM/yyyy');
    _timeFormat = dotenv.get('TIME_FORMAT', fallback: 'HH:mm');
    _currencySymbol = dotenv.get('CURRENCY_SYMBOL', fallback: '₹');
    _numberFormat = dotenv.get('NUMBER_FORMAT', fallback: 'en_IN');

    // Notification Settings
    _notificationSoundEnabled = dotenv.get('NOTIFICATION_SOUND_ENABLED', fallback: 'true') == 'true';
    _notificationVibrationEnabled = dotenv.get('NOTIFICATION_VIBRATION_ENABLED', fallback: 'true') == 'true';
    _notificationBadgeEnabled = dotenv.get('NOTIFICATION_BADGE_ENABLED', fallback: 'true') == 'true';
    _pushNotificationEnabled = dotenv.get('PUSH_NOTIFICATION_ENABLED', fallback: 'true') == 'true';

    // Development Settings
    _logLevel = dotenv.get('LOG_LEVEL', fallback: 'info');
    _enableDeveloperOptions = dotenv.get('ENABLE_DEVELOPER_OPTIONS', fallback: 'false') == 'true';
    _mockDataEnabled = dotenv.get('MOCK_DATA_ENABLED', fallback: 'false') == 'true';
    _apiLoggingEnabled = dotenv.get('API_LOGGING_ENABLED', fallback: 'true') == 'true';

    // Compliance & Security
    _dataEncryptionEnabled = dotenv.get('DATA_ENCRYPTION_ENABLED', fallback: 'true') == 'true';
    _biometricAuthEnabled = dotenv.get('BIOMETRIC_AUTH_ENABLED', fallback: 'true') == 'true';
    _screenshotPreventionEnabled = dotenv.get('SCREENSHOT_PREVENTION_ENABLED', fallback: 'false') == 'true';
    _rootDetectionEnabled = dotenv.get('ROOT_DETECTION_ENABLED', fallback: 'true') == 'true';

    // Performance Settings
    _imageCompressionQuality = int.parse(dotenv.get('IMAGE_COMPRESSION_QUALITY', fallback: '80'));
    _videoCompressionEnabled = dotenv.get('VIDEO_COMPRESSION_ENABLED', fallback: 'true') == 'true';
    _lazyLoadingEnabled = dotenv.get('LAZY_LOADING_ENABLED', fallback: 'true') == 'true';
    _paginationPageSize = int.parse(dotenv.get('PAGINATION_PAGE_SIZE', fallback: '20'));

    // Integration Keys
    _firebaseApiKey = dotenv.get('FIREBASE_API_KEY', fallback: 'your_firebase_api_key');
    _firebaseProjectId = dotenv.get('FIREBASE_PROJECT_ID', fallback: 'your_firebase_project_id');
    _firebaseAppId = dotenv.get('FIREBASE_APP_ID', fallback: 'your_firebase_app_id');
    _firebaseMessagingSenderId = dotenv.get('FIREBASE_MESSAGING_SENDER_ID', fallback: 'your_firebase_sender_id');


    // Platform Specific
    _iosAppStoreId = dotenv.get('IOS_APP_STORE_ID', fallback: 'com.agentmitra.app');
    _iosDeepLinkScheme = dotenv.get('IOS_DEEP_LINK_SCHEME', fallback: 'agentmitra');
    _androidPackageName = dotenv.get('ANDROID_PACKAGE_NAME', fallback: 'com.agentmitra.app');
    _androidDeepLinkScheme = dotenv.get('ANDROID_DEEP_LINK_SCHEME', fallback: 'agentmitra');
    _androidPlayStoreUrl = dotenv.get('ANDROID_PLAY_STORE_URL', fallback: 'https://play.google.com/store/apps/details?id=com.agentmitra.app');

    // Third Party Integrations
    _googleClientId = dotenv.get('GOOGLE_CLIENT_ID', fallback: 'your_google_client_id');
    _facebookAppId = dotenv.get('FACEBOOK_APP_ID', fallback: 'your_facebook_app_id');
    _intercomAppId = dotenv.get('INTERCOM_APP_ID', fallback: 'your_intercom_app_id');
    _zendeskUrl = dotenv.get('ZENDESK_URL', fallback: 'your_zendesk_url');

    // Experimental Features
    _enableAiInsights = dotenv.get('ENABLE_AI_INSIGHTS', fallback: 'false') == 'true';
    _enableAdvancedAnalytics = dotenv.get('ENABLE_ADVANCED_ANALYTICS', fallback: 'false') == 'true';
    _enableVoiceCommands = dotenv.get('ENABLE_VOICE_COMMANDS', fallback: 'false') == 'true';
    _enableArPreview = dotenv.get('ENABLE_AR_PREVIEW', fallback: 'false') == 'true';

    debugPrint('DEBUG: _loadConfig() completed successfully');
  }

  // Getters for all configuration values
  String get appName => _appName;
  String get appVersion => _appVersion;
  String get environment => _environment;
  bool get debug => _debug;

  String get apiBaseUrl => _apiBaseUrl;
  String get wsBaseUrl => _wsBaseUrl;
  String get apiVersion => _apiVersion;
  String get fullApiUrl => '$_apiBaseUrl$_apiVersion';
  int get apiTimeoutSeconds => _apiTimeoutSeconds;
  int get apiRetryAttempts => _apiRetryAttempts;
  int get apiRetryDelaySeconds => _apiRetryDelaySeconds;

  String get jwtAccessTokenKey => _jwtAccessTokenKey;
  String get jwtRefreshTokenKey => _jwtRefreshTokenKey;
  bool get biometricEnabled => _biometricEnabled;
  bool get autoLoginEnabled => _autoLoginEnabled;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  bool get enableChatbot => _enableChatbot;
  bool get enableVideoTutorials => _enableVideoTutorials;
  bool get enableWhatsappIntegration => _enableWhatsappIntegration;
  bool get enablePaymentProcessing => _enablePaymentProcessing;
  bool get enableAnalytics => _enableAnalytics;
  bool get enableNotifications => _enableNotifications;
  bool get enableVoiceInput => _enableVoiceInput;
  bool get enableFileAttachments => _enableFileAttachments;

  String get whatsappBusinessNumber => _whatsappBusinessNumber;
  String get whatsappWebUrl => _whatsappWebUrl;
  String get cdnBaseUrl => _cdnBaseUrl;
  int get cdnImageQuality => _cdnImageQuality;
  String get cdnVideoQuality => _cdnVideoQuality;

  String get razorpayKeyId => _razorpayKeyId;
  String get stripePublishableKey => _stripePublishableKey;

  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashReportingEnabled => _crashReportingEnabled;
  bool get performanceMonitoringEnabled => _performanceMonitoringEnabled;
  bool get errorTrackingEnabled => _errorTrackingEnabled;

  int get cacheMaxSizeMb => _cacheMaxSizeMb;
  int get cacheTtlHours => _cacheTtlHours;
  bool get localStorageEncryptionEnabled => _localStorageEncryptionEnabled;

  String get themeMode => _themeMode;
  String get language => _language;
  List<String> get supportedLanguages => _supportedLanguages;
  String get dateFormat => _dateFormat;
  String get timeFormat => _timeFormat;
  String get currencySymbol => _currencySymbol;
  String get numberFormat => _numberFormat;

  bool get notificationSoundEnabled => _notificationSoundEnabled;
  bool get notificationVibrationEnabled => _notificationVibrationEnabled;
  bool get notificationBadgeEnabled => _notificationBadgeEnabled;
  bool get pushNotificationEnabled => _pushNotificationEnabled;

  String get logLevel => _logLevel;
  bool get enableDeveloperOptions => _enableDeveloperOptions;
  bool get mockDataEnabled => _mockDataEnabled;
  bool get apiLoggingEnabled => _apiLoggingEnabled;

  bool get dataEncryptionEnabled => _dataEncryptionEnabled;
  bool get biometricAuthEnabled => _biometricAuthEnabled;
  bool get screenshotPreventionEnabled => _screenshotPreventionEnabled;
  bool get rootDetectionEnabled => _rootDetectionEnabled;

  int get imageCompressionQuality => _imageCompressionQuality;
  bool get videoCompressionEnabled => _videoCompressionEnabled;
  bool get lazyLoadingEnabled => _lazyLoadingEnabled;
  int get paginationPageSize => _paginationPageSize;

  String get firebaseApiKey => _firebaseApiKey;
  String get firebaseProjectId => _firebaseProjectId;
  String get firebaseAppId => _firebaseAppId;
  String get firebaseMessagingSenderId => _firebaseMessagingSenderId;

  bool get pioneerEnabled => _pioneerEnabled;
  String get pioneerUrl => _pioneerUrl;
  String get pioneerApiKey => _pioneerApiKey;
  String get pioneerScoutUrl => _pioneerScoutUrl;

  String get iosAppStoreId => _iosAppStoreId;
  String get iosDeepLinkScheme => _iosDeepLinkScheme;
  String get androidPackageName => _androidPackageName;
  String get androidDeepLinkScheme => _androidDeepLinkScheme;
  String get androidPlayStoreUrl => _androidPlayStoreUrl;

  String get googleClientId => _googleClientId;
  String get facebookAppId => _facebookAppId;
  String get intercomAppId => _intercomAppId;
  String get zendeskUrl => _zendeskUrl;

  bool get enableAiInsights => _enableAiInsights;
  bool get enableAdvancedAnalytics => _enableAdvancedAnalytics;
  bool get enableVoiceCommands => _enableVoiceCommands;
  bool get enableArPreview => _enableArPreview;

  /// Initialize configuration by loading .env file
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('DEBUG: AppConfig already initialized');
      return;
    }

    debugPrint('DEBUG: AppConfig.initialize() called - loading .env file');
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
      debugPrint('DEBUG: AppConfig.initialize() completed successfully');
    } catch (e) {
      debugPrint('Warning: Could not load .env file, using fallback values: $e');
      // Still mark as initialized to avoid repeated attempts
      _initialized = true;
    }
  }

  /// Get configuration value with fallback
  static T get<T>(String key, T fallback) {
    try {
      final value = dotenv.get(key);
      if (value.isEmpty) return fallback;

      // Type conversion based on fallback type
      if (T == bool) {
        return (value.toLowerCase() == 'true') as T;
      } else if (T == int) {
        return int.tryParse(value) as T? ?? fallback;
      } else if (T == double) {
        return double.tryParse(value) as T? ?? fallback;
      } else if (T == String) {
        return value as T;
      } else if (T == List<String>) {
        return (value.split(',').map((e) => e.trim()).toList()) as T;
      }

      return fallback;
    } catch (e) {
      return fallback;
    }
  }
}
