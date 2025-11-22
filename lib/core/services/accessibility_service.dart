import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Accessibility Service
/// Provides comprehensive accessibility features including screen reader support,
/// font scaling, high contrast mode, and focus management
class AccessibilityService {
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  static const String _fontScaleKey = 'accessibility_font_scale';
  static const String _highContrastKey = 'accessibility_high_contrast';
  static const String _screenReaderKey = 'accessibility_screen_reader';
  static const String _reducedMotionKey = 'accessibility_reduced_motion';
  static const String _largeTouchTargetsKey = 'accessibility_large_touch_targets';

  // Default accessibility settings
  static const double _defaultFontScale = 1.0;
  static const bool _defaultHighContrast = false;
  static const bool _defaultScreenReader = false;
  static const bool _defaultReducedMotion = false;
  static const bool _defaultLargeTouchTargets = false;

  // Current settings
  double _fontScale = _defaultFontScale;
  bool _highContrast = _defaultHighContrast;
  bool _screenReader = _defaultScreenReader;
  bool _reducedMotion = _defaultReducedMotion;
  bool _largeTouchTargets = _defaultLargeTouchTargets;

  bool _isInitialized = false;

  // Stream controllers for reactive updates
  final StreamController<double> _fontScaleController = StreamController<double>.broadcast();
  final StreamController<bool> _highContrastController = StreamController<bool>.broadcast();
  final StreamController<bool> _screenReaderController = StreamController<bool>.broadcast();
  final StreamController<bool> _reducedMotionController = StreamController<bool>.broadcast();
  final StreamController<bool> _largeTouchTargetsController = StreamController<bool>.broadcast();

  // Public streams
  Stream<double> get fontScaleStream => _fontScaleController.stream;
  Stream<bool> get highContrastStream => _highContrastController.stream;
  Stream<bool> get screenReaderStream => _screenReaderController.stream;
  Stream<bool> get reducedMotionStream => _reducedMotionController.stream;
  Stream<bool> get largeTouchTargetsStream => _largeTouchTargetsController.stream;

  // Getters
  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;
  bool get screenReader => _screenReader;
  bool get reducedMotion => _reducedMotion;
  bool get largeTouchTargets => _largeTouchTargets;

  /// Initialize accessibility service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _fontScale = prefs.getDouble(_fontScaleKey) ?? _defaultFontScale;
      _highContrast = prefs.getBool(_highContrastKey) ?? _defaultHighContrast;
      _screenReader = prefs.getBool(_screenReaderKey) ?? _defaultScreenReader;
      _reducedMotion = prefs.getBool(_reducedMotionKey) ?? _defaultReducedMotion;
      _largeTouchTargets = prefs.getBool(_largeTouchTargetsKey) ?? _defaultLargeTouchTargets;

      _isInitialized = true;
      LoggerService().info('Accessibility service initialized');
    } catch (e) {
      LoggerService().error('Failed to initialize accessibility service: $e');
    }
  }

  /// Set font scale
  Future<void> setFontScale(double scale) async {
    if (scale < 0.5 || scale > 3.0) return; // Reasonable bounds

    _fontScale = scale;
    await _saveFontScale(scale);
    _fontScaleController.add(scale);

    LoggerService().info('Font scale updated to: $scale');
  }

  /// Set high contrast mode
  Future<void> setHighContrast(bool enabled) async {
    _highContrast = enabled;
    await _saveHighContrast(enabled);
    _highContrastController.add(enabled);

    LoggerService().info('High contrast mode ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set screen reader mode
  Future<void> setScreenReader(bool enabled) async {
    _screenReader = enabled;
    await _saveScreenReader(enabled);
    _screenReaderController.add(enabled);

    LoggerService().info('Screen reader mode ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set reduced motion
  Future<void> setReducedMotion(bool enabled) async {
    _reducedMotion = enabled;
    await _saveReducedMotion(enabled);
    _reducedMotionController.add(enabled);

    LoggerService().info('Reduced motion ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set large touch targets
  Future<void> setLargeTouchTargets(bool enabled) async {
    _largeTouchTargets = enabled;
    await _saveLargeTouchTargets(enabled);
    _largeTouchTargetsController.add(enabled);

    LoggerService().info('Large touch targets ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Reset all accessibility settings to defaults
  Future<void> resetToDefaults() async {
    await setFontScale(_defaultFontScale);
    await setHighContrast(_defaultHighContrast);
    await setScreenReader(_defaultScreenReader);
    await setReducedMotion(_defaultReducedMotion);
    await setLargeTouchTargets(_defaultLargeTouchTargets);

    LoggerService().info('Accessibility settings reset to defaults');
  }

  /// Get accessible text style based on current settings
  TextStyle getAccessibleTextStyle({
    required TextStyle baseStyle,
    bool isHeading = false,
    bool isImportant = false,
  }) {
    double effectiveFontSize = baseStyle.fontSize ?? 14.0;
    effectiveFontSize *= _fontScale;

    // Minimum font sizes for accessibility
    if (isHeading) {
      effectiveFontSize = effectiveFontSize.clamp(18.0, double.infinity);
    } else if (isImportant) {
      effectiveFontSize = effectiveFontSize.clamp(16.0, double.infinity);
    } else {
      effectiveFontSize = effectiveFontSize.clamp(14.0, double.infinity);
    }

    return baseStyle.copyWith(
      fontSize: effectiveFontSize,
      fontWeight: _highContrast && isImportant ? FontWeight.bold : baseStyle.fontWeight,
      color: _highContrast ? _getHighContrastColor(baseStyle.color) : baseStyle.color,
    );
  }

  /// Get accessible button style
  ButtonStyle getAccessibleButtonStyle({
    required ButtonStyle baseStyle,
    bool isPrimary = false,
  }) {
    final minSize = _largeTouchTargets ? const Size(48, 48) : const Size(36, 36);

    return baseStyle.copyWith(
      minimumSize: MaterialStateProperty.all(minSize),
      padding: MaterialStateProperty.all(
        _largeTouchTargets ? const EdgeInsets.all(12) : const EdgeInsets.all(8),
      ),
    );
  }

  /// Get accessible animation duration
  Duration getAccessibleAnimationDuration({
    required Duration baseDuration,
  }) {
    return _reducedMotion ? baseDuration * 0.3 : baseDuration;
  }

  /// Get accessible color scheme
  ColorScheme getAccessibleColorScheme({
    required ColorScheme baseScheme,
  }) {
    if (!_highContrast) return baseScheme;

    return baseScheme.copyWith(
      primary: Colors.yellow,
      onPrimary: Colors.black,
      secondary: Colors.white,
      onSecondary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    );
  }

  /// Announce content to screen readers
  void announceToScreenReader(String message) {
    if (_screenReader) {
      // TODO: Implement screen reader announcement using platform-specific APIs
      LoggerService().info('Screen reader announcement: $message');
    }
  }

  /// Focus management helper
  void requestFocus(FocusNode focusNode) {
    focusNode.requestFocus();
    if (_screenReader) {
      // Add slight delay for screen readers to catch up
      Future.delayed(const Duration(milliseconds: 100), () {
      });
    }
  }

  /// Get accessibility settings summary
  Map<String, dynamic> getSettingsSummary() {
    return {
      'fontScale': _fontScale,
      'highContrast': _highContrast,
      'screenReader': _screenReader,
      'reducedMotion': _reducedMotion,
      'largeTouchTargets': _largeTouchTargets,
    };
  }

  // Private save methods
  Future<void> _saveFontScale(double scale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_fontScaleKey, scale);
    } catch (e) {
      LoggerService().error('Failed to save font scale: $e');
    }
  }

  Future<void> _saveHighContrast(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_highContrastKey, enabled);
    } catch (e) {
      LoggerService().error('Failed to save high contrast setting: $e');
    }
  }

  Future<void> _saveScreenReader(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_screenReaderKey, enabled);
    } catch (e) {
      LoggerService().error('Failed to save screen reader setting: $e');
    }
  }

  Future<void> _saveReducedMotion(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reducedMotionKey, enabled);
    } catch (e) {
      LoggerService().error('Failed to save reduced motion setting: $e');
    }
  }

  Future<void> _saveLargeTouchTargets(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_largeTouchTargetsKey, enabled);
    } catch (e) {
      LoggerService().error('Failed to save large touch targets setting: $e');
    }
  }

  // Helper method for high contrast colors
  Color _getHighContrastColor(Color? originalColor) {
    if (originalColor == null) return Colors.white;

    // Calculate luminance to determine if color is light or dark
    final luminance = originalColor.computeLuminance();

    // Return black for light colors, white for dark colors
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Dispose of resources
  void dispose() {
    _fontScaleController.close();
    _highContrastController.close();
    _screenReaderController.close();
    _reducedMotionController.close();
    _largeTouchTargetsController.close();
  }
}

/// Accessibility Widget Extensions
class AccessibilityExtensions {
  /// Wrap widget with accessibility features
  static Widget makeAccessible({
    required Widget child,
    required String label,
    String? hint,
    bool? excludeSemantics,
    VoidCallback? onTap,
    bool isButton = false,
    bool isHeading = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics ?? false,
      button: isButton,
      onTap: onTap != null ? () => onTap() : null,
      child: child,
    );
  }

  /// Create accessible text
  static Widget accessibleText({
    required String text,
    TextStyle? style,
    bool isHeading = false,
    bool isImportant = false,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    final accessibleStyle = AccessibilityService().getAccessibleTextStyle(
      baseStyle: style ?? const TextStyle(),
      isHeading: isHeading,
      isImportant: isImportant,
    );

    return Semantics(
      label: text,
      child: Text(
        text,
        style: accessibleStyle,
        textAlign: textAlign,
        maxLines: maxLines,
      ),
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    String? label,
    String? hint,
    bool isPrimary = false,
    ButtonStyle? style,
  }) {
    final accessibleStyle = AccessibilityService().getAccessibleButtonStyle(
      baseStyle: style ?? ElevatedButton.styleFrom(),
      isPrimary: isPrimary,
    );

    return Semantics(
      label: label,
      hint: hint,
      button: true,
      onTap: onPressed,
      child: ElevatedButton(
        onPressed: onPressed,
        style: accessibleStyle,
        child: child,
      ),
    );
  }
}

/// Focus Management Helper
class FocusHelper {
  static void moveFocusToNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void moveFocusToPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
