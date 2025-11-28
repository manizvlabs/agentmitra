import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

/// Localization service for multi-language support
class LocalizationService {
  static const String _supportedLocalesPath = 'assets/l10n/';
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('te', 'IN'), // Telugu
  ];

  static const Locale fallbackLocale = Locale('en', 'US');

  Map<String, String> _localizedStrings = {};
  Locale _currentLocale = fallbackLocale;

  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  /// Initialize the localization service
  Future<void> initialize(Locale locale) async {
    _currentLocale = locale;
    await loadLocale(locale);
  }

  /// Load locale strings from assets
  Future<void> loadLocale(Locale locale) async {
    try {
      final String languageCode = locale.languageCode;
      final String countryCode = locale.countryCode ?? '';

      // Try to load language-specific file
      String fileName = 'app_$languageCode';
      if (countryCode.isNotEmpty) {
        fileName += '_$countryCode';
      }
      fileName += '.arb'; // ARB format (Application Resource Bundle)

      final String jsonString = await rootBundle.loadString('$_supportedLocalesPath$fileName');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      _currentLocale = locale;

      debugPrint('Loaded locale: $languageCode${countryCode.isNotEmpty ? '_$countryCode' : ''}');
    } catch (e) {
      debugPrint('Error loading locale $locale: $e');
      // Fallback to English
      if (locale != fallbackLocale) {
        await loadLocale(fallbackLocale);
      }
    }
  }

  /// Get localized string
  String translate(String key, {Map<String, String>? args}) {
    String translation = _localizedStrings[key] ?? key;

    // Replace arguments in the translation
    if (args != null) {
      args.forEach((argKey, argValue) {
        translation = translation.replaceAll('{$argKey}', argValue);
      });
    }

    return translation;
  }

  /// Get current locale
  Locale get currentLocale => _currentLocale;

  /// Check if a locale is supported
  bool isSupported(Locale locale) {
    return supportedLocales.any((supported) =>
      supported.languageCode == locale.languageCode &&
      (supported.countryCode == null || supported.countryCode == locale.countryCode)
    );
  }

  /// Get the best matching supported locale
  Locale getBestMatchingLocale(Locale deviceLocale) {
    // First, try exact match
    if (isSupported(deviceLocale)) {
      return deviceLocale;
    }

    // Then, try language-only match
    final languageMatch = supportedLocales.firstWhere(
      (locale) => locale.languageCode == deviceLocale.languageCode,
      orElse: () => fallbackLocale,
    );

    if (languageMatch != fallbackLocale) {
      return languageMatch;
    }

    // Finally, return fallback
    return fallbackLocale;
  }

  /// Get display name for a locale
  String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return locale.countryCode == 'US' ? 'English (US)' : 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'te':
        return 'తెలుగు (Telugu)';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Get list of supported locale display names
  List<Map<String, dynamic>> getSupportedLocalesInfo() {
    return supportedLocales.map((locale) {
      return {
        'locale': locale,
        'displayName': getLocaleDisplayName(locale),
        'flag': _getLocaleFlag(locale),
      };
    }).toList();
  }

  String _getLocaleFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'hi':
        return '🇮🇳';
      case 'te':
        return '🇮🇳';
      default:
        return '🌍';
    }
  }
}

/// Extension methods for easier localization usage
extension LocalizationExtensions on BuildContext {
  String translate(String key, {Map<String, String>? args}) {
    return LocalizationService().translate(key, args: args);
  }

  Locale get currentLocale => LocalizationService().currentLocale;

  bool isRTL() {
    return Bidi.isRtlLanguage(currentLocale.languageCode);
  }
}

/// Localization delegate for Flutter
class AppLocalizationsDelegate extends LocalizationsDelegate<LocalizationService> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => LocalizationService().isSupported(locale);

  @override
  Future<LocalizationService> load(Locale locale) async {
    final service = LocalizationService();
    await service.initialize(locale);
    return service;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Helper class for accessibility features
class AccessibilityService {
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 24.0;
  static const double _defaultFontSize = 16.0;

  static double _fontSize = _defaultFontSize;
  static bool _highContrast = false;
  static bool _reduceMotion = false;
  static bool _screenReaderEnabled = false;

  static double get fontSize => _fontSize;
  static bool get highContrast => _highContrast;
  static bool get reduceMotion => _reduceMotion;
  static bool get screenReaderEnabled => _screenReaderEnabled;

  /// Initialize accessibility settings
  static Future<void> initialize() async {
    // Load from preferences (would be implemented with shared preferences)
    // For now, use defaults
    _fontSize = _defaultFontSize;
    _highContrast = false;
    _reduceMotion = false;
    _screenReaderEnabled = false;
  }

  /// Set font size
  static void setFontSize(double size) {
    _fontSize = size.clamp(_minFontSize, _maxFontSize);
  }

  /// Toggle high contrast mode
  static void toggleHighContrast() {
    _highContrast = !_highContrast;
  }

  /// Toggle reduce motion
  static void toggleReduceMotion() {
    _reduceMotion = !_reduceMotion;
  }

  /// Set screen reader enabled
  static void setScreenReaderEnabled(bool enabled) {
    _screenReaderEnabled = enabled;
  }

  /// Get accessible text style
  static TextStyle getAccessibleTextStyle({
    TextStyle? baseStyle,
    bool isHeading = false,
    bool isButton = false,
  }) {
    final base = baseStyle ?? const TextStyle();

    return base.copyWith(
      fontSize: isHeading ? fontSize * 1.2 : fontSize,
      fontWeight: isButton ? FontWeight.w600 : base.fontWeight,
      height: isHeading ? 1.2 : 1.5, // Better line height for readability
      color: highContrast ? Colors.black : base.color,
      backgroundColor: highContrast ? Colors.white : base.backgroundColor,
    );
  }

  /// Get accessible button style
  static ButtonStyle getAccessibleButtonStyle({
    ButtonStyle? baseStyle,
    bool isPrimary = true,
  }) {
    return (baseStyle ?? ElevatedButton.styleFrom()).copyWith(
      minimumSize: const MaterialStatePropertyAll(Size(44, 44)), // Minimum touch target
      padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      )),
      textStyle: MaterialStatePropertyAll(
        getAccessibleTextStyle(isButton: true),
      ),
    );
  }

  /// Announce content to screen readers
  static void announce(String message) {
    if (screenReaderEnabled) {
      // In a real implementation, this would use platform-specific APIs
      debugPrint('Screen reader announcement: $message');
    }
  }
}

/// Custom text widget with accessibility features
class AccessibleText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final bool isHeading;
  final String? semanticsLabel;

  const AccessibleText(
    this.data, {
    Key? key,
    this.style,
    this.isHeading = false,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? (isHeading ? 'Heading: $data' : data),
      child: Text(
        data,
        style: AccessibilityService.getAccessibleTextStyle(
          baseStyle: style,
          isHeading: isHeading,
        ),
      ),
    );
  }
}

/// Custom button widget with accessibility features
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticsLabel;
  final bool isPrimary;

  const AccessibleButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.semanticsLabel,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticsLabel,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AccessibilityService.getAccessibleButtonStyle(isPrimary: isPrimary),
        child: child,
      ),
    );
  }
}