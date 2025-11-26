import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'cdn_service.dart';
import 'logger_service.dart';

/// Supported Languages
enum AppLanguage {
  english('en', 'English', 'US'),
  hindi('hi', 'हिंदी', 'IN'),
  telugu('te', 'తెలుగు', 'IN');

  const AppLanguage(this.code, this.name, this.countryCode);

  final String code;
  final String name;
  final String countryCode;

  Locale get locale => Locale(code, countryCode);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Localization Service
/// Provides multi-language support with dynamic language switching
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  static const String _languageKey = 'app_language';
  static const String _stringsKey = 'localized_strings';
  static const String _versionKeyPrefix = 'localization_version_';
  static const String _cacheKeyPrefix = 'l10n_cache_';

  AppLanguage _currentLanguage = AppLanguage.english;
  Map<String, Map<String, String>> _localizedStrings = {};
  Map<String, String> _fallbackStrings = {};
  bool _isInitialized = false;
  final CDNService _cdnService = CDNService();

  final StreamController<AppLanguage> _languageController = StreamController<AppLanguage>.broadcast();
  final StreamController<Map<String, String>> _stringsController = StreamController<Map<String, String>>.broadcast();

  // Public streams
  Stream<AppLanguage> get languageStream => _languageController.stream;
  Stream<Map<String, String>> get stringsStream => _stringsController.stream;

  // Getters
  AppLanguage get currentLanguage => _currentLanguage;
  Map<String, String> get currentStrings => _localizedStrings[_currentLanguage.code] ?? {};
  List<AppLanguage> get supportedLanguages => AppLanguage.values;

  /// Initialize localization service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved language
      final savedLanguageCode = prefs.getString(_languageKey);
      if (savedLanguageCode != null) {
        _currentLanguage = AppLanguage.fromCode(savedLanguageCode);
      }

      // Load default strings (fallback)
      await _loadDefaultStrings();

      // Try to load from CDN, fallback to cache, then to bundled files
      await _loadLocalizationForLanguage(_currentLanguage.code);

      _isInitialized = true;
      LoggerService().info('Localization service initialized with language: ${_currentLanguage.name}');
    } catch (e) {
      LoggerService().error('Failed to initialize localization service: $e');
    }
  }

  /// Set current language
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    await _saveLanguage(language);
    _languageController.add(language);

    // Load strings for new language
    await _loadStringsForLanguage(language);

    LoggerService().info('Language changed to: ${language.name}');
  }

  /// Get localized string
  String getString(String key, {Map<String, String>? args, String? locale}) {
    final targetLocale = locale ?? _currentLanguage.code;
    String? value = _localizedStrings[targetLocale]?[key];

    // Try fallback strings
    value ??= _fallbackStrings[key];

    // Try English fallback
    value ??= _localizedStrings['en']?[key];

    // Final fallback to key
    value ??= key;

    if (value == key && key != '') {
      LoggerService().warning('Missing localization key: $key');
    }

    // Replace arguments if provided
    if (args != null) {
      args.forEach((argKey, argValue) {
        value = value!.replaceAll('{$argKey}', argValue);
      });
    }

    return value!;
  }

  /// Check if string exists for current language
  bool hasString(String key) {
    return currentStrings.containsKey(key);
  }

  /// Get text direction for current language
  TextDirection get textDirection {
    // Add RTL language detection here if needed
    // For now, all supported languages are LTR
    return TextDirection.ltr;
  }

  /// Get locale for current language
  Locale get currentLocale => _currentLanguage.locale;

  /// Get language info
  Map<String, dynamic> getLanguageInfo(AppLanguage language) {
    return {
      'code': language.code,
      'name': language.name,
      'countryCode': language.countryCode,
      'locale': language.locale.toString(),
      'isRTL': false, // Add RTL detection logic if needed
    };
  }

  // Private methods

  Future<void> _loadDefaultStrings() async {
    // Load default English strings as fallback
    _fallbackStrings = Map<String, String>.from(_englishStrings);
    _localizedStrings['en'] = Map<String, String>.from(_englishStrings);

    // Load other language strings as fallback
    _localizedStrings['hi'] = Map<String, String>.from(_hindiStrings);
    _localizedStrings['te'] = Map<String, String>.from(_teluguStrings);

    LoggerService().info('Default localized strings loaded');
  }

  Future<void> _loadStringsForLanguage(AppLanguage language) async {
    await _loadLocalizationForLanguage(language.code);
    final strings = _localizedStrings[language.code];
    if (strings != null) {
      _stringsController.add(strings);
    }
  }

  /// Load localization with CDN -> Cache -> Fallback strategy
  Future<void> _loadLocalizationForLanguage(String locale) async {
    // Try CDN first
    try {
      if (await _cdnService.checkCDNAvailability()) {
        final cdnStrings = await _loadFromCDN(locale);
        if (cdnStrings.isNotEmpty) {
          _localizedStrings[locale] = cdnStrings;
          await _cacheLocalization(locale, cdnStrings);
          LoggerService().info('Loaded localization from CDN for locale: $locale');
          return;
        }
      }
    } catch (e) {
      LoggerService().warning('CDN load failed for $locale, trying cache: $e');
    }

    // Try cache
    try {
      final cachedStrings = await _loadFromCache(locale);
      if (cachedStrings.isNotEmpty) {
        _localizedStrings[locale] = cachedStrings;
        LoggerService().info('Loaded localization from cache for locale: $locale');
        return;
      }
    } catch (e) {
      LoggerService().warning('Cache load failed for $locale, using fallback: $e');
    }

    // Use bundled fallback
    try {
      final fallbackStrings = await _loadFallbackLocalization(locale);
      if (fallbackStrings.isNotEmpty) {
        _localizedStrings[locale] = fallbackStrings;
        _fallbackStrings.addAll(fallbackStrings);
        LoggerService().info('Loaded localization from fallback for locale: $locale');
      }
    } catch (e) {
      LoggerService().error('Fallback localization failed for $locale: $e');
    }
  }

  /// Load from CDN
  Future<Map<String, String>> _loadFromCDN(String locale) async {
    try {
      final arbData = await _cdnService.loadARBFile(locale);
      final strings = <String, String>{};

      arbData.forEach((key, value) {
        if (!key.startsWith('@')) {
          strings[key] = value.toString();
        }
      });

      // Cache version info
      final prefs = await SharedPreferences.getInstance();
      final version = arbData['@@version'] as String? ?? '1.0.0';
      await prefs.setString('$_versionKeyPrefix$locale', version);

      return strings;
    } catch (e) {
      LoggerService().error('Failed to load from CDN: $e');
      return {};
    }
  }

  /// Load from cache
  Future<Map<String, String>> _loadFromCache(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cacheKeyPrefix$locale');

      if (cachedData != null) {
        return Map<String, String>.from(json.decode(cachedData) as Map<String, dynamic>);
      }
    } catch (e) {
      LoggerService().error('Failed to load from cache: $e');
    }
    return {};
  }

  /// Load fallback localization from assets
  Future<Map<String, String>> _loadFallbackLocalization(String locale) async {
    try {
      // Try to load from assets/l10n/app_{locale}.arb
      // Note: On web, the path should not have 'assets/' prefix as it's added automatically
      final assetPath = 'assets/l10n/app_$locale.arb';
      final jsonString = await rootBundle.loadString(assetPath);
      final arbData = json.decode(jsonString) as Map<String, dynamic>;
      final strings = <String, String>{};

      arbData.forEach((key, value) {
        if (!key.startsWith('@')) {
          strings[key] = value.toString();
        }
      });

      return strings;
    } catch (e) {
      // If asset file doesn't exist, use hardcoded strings
      LoggerService().warning('Asset file not found for $locale, using hardcoded strings');
      return _getHardcodedStrings(locale);
    }
  }

  /// Get hardcoded strings as fallback
  Map<String, String> _getHardcodedStrings(String locale) {
    switch (locale) {
      case 'hi':
        return _hindiStrings;
      case 'te':
        return _teluguStrings;
      default:
        return _englishStrings;
    }
  }

  /// Cache localization strings
  Future<void> _cacheLocalization(String locale, Map<String, String> strings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cacheKeyPrefix$locale', json.encode(strings));
    } catch (e) {
      LoggerService().error('Failed to cache localization: $e');
    }
  }

  /// Check for updates from CDN
  Future<bool> checkForUpdates(String locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getString('$_versionKeyPrefix$locale') ?? '0.0.0';

      final cdnVersion = await _cdnService.getVersionFromCDN(locale);
      if (cdnVersion != null && _isNewerVersion(cdnVersion, currentVersion)) {
        return true;
      }
    } catch (e) {
      LoggerService().warning('Failed to check for updates: $e');
    }
    return false;
  }

  /// Check if new version is newer than current
  bool _isNewerVersion(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        if (newParts.length > i && currentParts.length > i) {
          if (newParts[i] > currentParts[i]) return true;
          if (newParts[i] < currentParts[i]) return false;
        }
      }
    } catch (e) {
      LoggerService().error('Version comparison failed: $e');
    }
    return false;
  }

  /// Background sync for localization updates
  Future<void> syncLocalizations(List<String> locales) async {
    for (final locale in locales) {
      try {
        if (await checkForUpdates(locale)) {
          await _loadLocalizationForLanguage(locale);
          LoggerService().info('Synced localization for locale: $locale');
        }
      } catch (e) {
        LoggerService().error('Failed to sync localization for $locale: $e');
      }
    }
  }

  Future<void> _saveLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (e) {
      LoggerService().error('Failed to save language preference: $e');
    }
  }

  // Deprecated: Use _loadFromCache instead
  Future<void> _loadCachedStrings() async {
    // This method is kept for backward compatibility
    // New implementation uses _loadFromCache per locale
  }

  Future<void> _saveStringsToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stringsKey, json.encode(_localizedStrings));
    } catch (e) {
      LoggerService().error('Failed to save strings to cache: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _languageController.close();
    _stringsController.close();
  }

  // Language string definitions

  static const Map<String, String> _englishStrings = {
    // Common
    'app_name': 'Agent Mitra',
    'ok': 'OK',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'back': 'Back',
    'next': 'Next',
    'previous': 'Previous',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'retry': 'Retry',
    'close': 'Close',
    'search': 'Search',
    'filter': 'Filter',
    'sort': 'Sort',
    'settings': 'Settings',

    // Navigation
    'home': 'Home',
    'daily_quotes': 'Daily Quotes',
    'my_policies': 'My Policies',
    'premium_calendar': 'Premium Calendar',
    'agent_chat': 'Agent Chat',
    'reminders': 'Reminders',
    'presentations': 'Presentations',
    'profile': 'Profile',
    'accessibility': 'Accessibility',
    'logout': 'Logout',

    // Authentication
    'phone_verification': 'Phone Verification',
    'enter_phone_number': 'Enter your phone number',
    'enter_otp': 'Enter OTP',
    'verify': 'Verify',
    'resend_otp': 'Resend OTP',

    // Dashboard
    'welcome': 'Welcome',
    'total_policies': 'Total Policies',
    'active_clients': 'Active Clients',
    'monthly_revenue': 'Monthly Revenue',
    'pending_tasks': 'Pending Tasks',

    // Policies
    'policy_details': 'Policy Details',
    'policy_number': 'Policy Number',
    'client_name': 'Client Name',
    'premium_amount': 'Premium Amount',
    'next_due_date': 'Next Due Date',
    'coverage_amount': 'Coverage Amount',
    'policy_type': 'Policy Type',

    // Quotes
    'create_quote': 'Create Quote',
    'quote_text': 'Quote Text',
    'background_template': 'Background Template',
    'agent_branding': 'Agent Branding',
    'send_quote': 'Send Quote',
    'share_quote': 'Share Quote',

    // WhatsApp
    'send_whatsapp': 'Send via WhatsApp',
    'whatsapp_message': 'WhatsApp Message',
    'message_sent': 'Message sent successfully',
    'message_failed': 'Failed to send message',

    // Accessibility
    'accessibility_settings': 'Accessibility Settings',
    'text_size': 'Text Size',
    'high_contrast': 'High Contrast',
    'screen_reader': 'Screen Reader',
    'reduced_motion': 'Reduced Motion',
    'large_touch_targets': 'Large Touch Targets',
    'reset_settings': 'Reset Settings',

    // Languages
    'language': 'Language',
    'select_language': 'Select Language',
    'english': 'English',
    'hindi': 'हिंदी',
    'telugu': 'తెలుగు',

    // Error messages
    'network_error': 'Network connection error',
    'server_error': 'Server error occurred',
    'validation_error': 'Please check your input',
    'permission_denied': 'Permission denied',
    'feature_not_available': 'Feature not available',

    // Success messages
    'data_saved': 'Data saved successfully',
    'settings_updated': 'Settings updated successfully',
    'profile_updated': 'Profile updated successfully',
  };

  static const Map<String, String> _hindiStrings = {
    // Common
    'app_name': 'एजेंट मित्र',
    'ok': 'ठीक है',
    'cancel': 'रद्द करें',
    'save': 'सहेजें',
    'delete': 'मिटाएं',
    'edit': 'संपादित करें',
    'back': 'पीछे',
    'next': 'अगला',
    'previous': 'पिछला',
    'loading': 'लोड हो रहा है...',
    'error': 'त्रुटि',
    'success': 'सफलता',
    'retry': 'पुनः प्रयास',
    'close': 'बंद करें',
    'search': 'खोजें',
    'filter': 'फिल्टर',
    'sort': 'क्रमबद्ध करें',
    'settings': 'सेटिंग्स',

    // Navigation
    'home': 'होम',
    'daily_quotes': 'दैनिक उद्धरण',
    'my_policies': 'मेरी पॉलिसियाँ',
    'premium_calendar': 'प्रीमियम कैलेंडर',
    'agent_chat': 'एजेंट चैट',
    'reminders': 'रिमाइंडर',
    'presentations': 'प्रस्तुतियाँ',
    'profile': 'प्रोफाइल',
    'accessibility': 'सुलभता',
    'logout': 'लॉगआउट',

    // Authentication
    'phone_verification': 'फोन सत्यापन',
    'enter_phone_number': 'अपना फोन नंबर दर्ज करें',
    'enter_otp': 'OTP दर्ज करें',
    'verify': 'सत्यापित करें',
    'resend_otp': 'OTP पुनः भेजें',

    // Dashboard
    'welcome': 'स्वागत है',
    'total_policies': 'कुल पॉलिसियाँ',
    'active_clients': 'सक्रिय ग्राहक',
    'monthly_revenue': 'मासिक राजस्व',
    'pending_tasks': 'लंबित कार्य',

    // Policies
    'policy_details': 'पॉलिसी विवरण',
    'policy_number': 'पॉलिसी संख्या',
    'client_name': 'ग्राहक का नाम',
    'premium_amount': 'प्रीमियम राशि',
    'next_due_date': 'अगली देय तिथि',
    'coverage_amount': 'कवरेज राशि',
    'policy_type': 'पॉलिसी प्रकार',

    // Quotes
    'create_quote': 'उद्धरण बनाएं',
    'quote_text': 'उद्धरण पाठ',
    'background_template': 'पृष्ठभूमि टेम्प्लेट',
    'agent_branding': 'एजेंट ब्रांडिंग',
    'send_quote': 'उद्धरण भेजें',
    'share_quote': 'उद्धरण साझा करें',

    // WhatsApp
    'send_whatsapp': 'WhatsApp के माध्यम से भेजें',
    'whatsapp_message': 'WhatsApp संदेश',
    'message_sent': 'संदेश सफलतापूर्वक भेजा गया',
    'message_failed': 'संदेश भेजने में विफल',

    // Accessibility
    'accessibility_settings': 'सुलभता सेटिंग्स',
    'text_size': 'पाठ का आकार',
    'high_contrast': 'उच्च कंट्रास्ट',
    'screen_reader': 'स्क्रीन रीडर',
    'reduced_motion': 'कम गति',
    'large_touch_targets': 'बड़े टच टारगेट',
    'reset_settings': 'सेटिंग्स रीसेट करें',

    // Languages
    'language': 'भाषा',
    'select_language': 'भाषा चुनें',
    'english': 'English',
    'hindi': 'हिंदी',
    'telugu': 'తెలుగు',

    // Error messages
    'network_error': 'नेटवर्क कनेक्शन त्रुटि',
    'server_error': 'सर्वर त्रुटि हुई',
    'validation_error': 'कृपया अपना इनपुट जांचें',
    'permission_denied': 'अनुमति अस्वीकृत',
    'feature_not_available': 'फीचर उपलब्ध नहीं है',

    // Success messages
    'data_saved': 'डेटा सफलतापूर्वक सहेजा गया',
    'settings_updated': 'सेटिंग्स अपडेट हो गईं',
    'profile_updated': 'प्रोफाइल अपडेट हो गई',
  };

  static const Map<String, String> _teluguStrings = {
    // Common
    'app_name': 'ఏజెంట్ మిత్ర',
    'ok': 'సరే',
    'cancel': 'రద్దు చేయండి',
    'save': 'సేవ్ చేయండి',
    'delete': 'తొలగించు',
    'edit': 'సవరించు',
    'back': 'వెనుకకు',
    'next': 'తదుపరి',
    'previous': 'మునుపటి',
    'loading': 'లోడ్ అవుతోంది...',
    'error': 'లోపం',
    'success': 'విజయం',
    'retry': 'మళ్లీ ప్రయత్నించు',
    'close': 'మూసివేయి',
    'search': 'వెతకండి',
    'filter': 'ఫిల్టర్',
    'sort': 'క్రమబద్ధీకరించు',
    'settings': 'సెట్టింగులు',

    // Navigation
    'home': 'హోమ్',
    'daily_quotes': 'రోజువారీ కోట్స్',
    'my_policies': 'నా పాలసీలు',
    'premium_calendar': 'ప్రీమియం క్యాలెండర్',
    'agent_chat': 'ఏజెంట్ చాట్',
    'reminders': 'రిమైండర్స్',
    'presentations': 'ప్రెజెంటేషన్స్',
    'profile': 'ప్రొఫైల్',
    'accessibility': 'ప్రాప్యత',
    'logout': 'లాగ్ అవుట్',

    // Authentication
    'phone_verification': 'ఫోన్ ధృవీకరణ',
    'enter_phone_number': 'మీ ఫోన్ నంబర్ నమోదు చేయండి',
    'enter_otp': 'OTP నమోదు చేయండి',
    'verify': 'ధృవీకరించు',
    'resend_otp': 'OTP మళ్లీ పంపు',

    // Dashboard
    'welcome': 'స్వాగతం',
    'total_policies': 'మొత్తం పాలసీలు',
    'active_clients': 'క్రియాశీల క్లయింట్స్',
    'monthly_revenue': 'నెలసరి రెవెన్యూ',
    'pending_tasks': 'పెండింగ్ టాస్క్స్',

    // Policies
    'policy_details': 'పాలసీ వివరాలు',
    'policy_number': 'పాలసీ నంబర్',
    'client_name': 'క్లయింట్ పేరు',
    'premium_amount': 'ప్రీమియం మొత్తం',
    'next_due_date': 'తదుపరి చెల్లింపు తేదీ',
    'coverage_amount': 'కవరేజ్ మొత్తం',
    'policy_type': 'పాలసీ రకం',

    // Quotes
    'create_quote': 'కోట్ సృష్టించు',
    'quote_text': 'కోట్ టెక్స్ట్',
    'background_template': 'బ్యాక్‌గ్రౌండ్ టెంప్లేట్',
    'agent_branding': 'ఏజెంట్ బ్రాండింగ్',
    'send_quote': 'కోట్ పంపు',
    'share_quote': 'కోట్ షేర్ చేయు',

    // WhatsApp
    'send_whatsapp': 'WhatsApp ద్వారా పంపు',
    'whatsapp_message': 'WhatsApp మెసేజ్',
    'message_sent': 'మెసేజ్ విజయవంతంగా పంపబడింది',
    'message_failed': 'మెసేజ్ పంపడంలో విఫలమైంది',

    // Accessibility
    'accessibility_settings': 'ప్రాప్యత సెట్టింగులు',
    'text_size': 'టెక్స్ట్ సైజ్',
    'high_contrast': 'హై కంట్రాస్ట్',
    'screen_reader': 'స్క్రీన్ రీడర్',
    'reduced_motion': 'తగ్గించిన మోషన్',
    'large_touch_targets': 'పెద్ద టచ్ టార్గెట్స్',
    'reset_settings': 'సెట్టింగులను రీసెట్ చేయు',

    // Languages
    'language': 'భాష',
    'select_language': 'భాష ఎంచుకోండి',
    'english': 'English',
    'hindi': 'हिंदी',
    'telugu': 'తెలుగు',

    // Error messages
    'network_error': 'నెట్వర్క్ కనెక్షన్ లోపం',
    'server_error': 'సర్వర్ లోపం సంభవించింది',
    'validation_error': 'దయచేసి మీ ఇన్‌పుట్ తనిఖీ చేయండి',
    'permission_denied': 'అనుమతి నిరాకరించబడింది',
    'feature_not_available': 'ఫీచర్ అందుబాటులో లేదు',

    // Success messages
    'data_saved': 'డేటా విజయవంతంగా సేవ్ చేయబడింది',
    'settings_updated': 'సెట్టింగులు అప్‌డేట్ అయ్యాయి',
    'profile_updated': 'ప్రొఫైల్ అప్‌డేట్ అయింది',
  };
}
