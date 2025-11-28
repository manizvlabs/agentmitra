import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities and widgets for improved compliance
class AccessibilityWidgets {
  /// Creates accessible text with proper semantic labels
  static Widget accessibleText(
    String text, {
    TextStyle? style,
    bool isHeading = false,
    String? semanticLabel,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      header: isHeading,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// Accessible button with enhanced feedback
  static Widget accessibleButton({
    required VoidCallback? onPressed,
    required Widget child,
    String? semanticLabel,
    String? tooltip,
    ButtonStyle? style,
    bool autofocus = false,
    FocusNode? focusNode,
    bool enableFeedback = true,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }

  /// Accessible icon button with proper labels
  static Widget accessibleIconButton({
    required VoidCallback? onPressed,
    required Icon icon,
    String? semanticLabel,
    String? tooltip,
    Color? color,
    double? iconSize,
    EdgeInsetsGeometry? padding,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return Semantics(
      label: semanticLabel ?? tooltip ?? 'Button',
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: color,
          iconSize: iconSize,
          padding: padding,
          autofocus: autofocus,
          focusNode: focusNode,
          tooltip: tooltip,
        ),
      ),
    );
  }

  /// Accessible card with proper semantic structure
  static Widget accessibleCard({
    required Widget child,
    String? semanticLabel,
    String? semanticHint,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool enableFeedback = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      container: true,
      child: Card(
        color: color,
        elevation: elevation,
        shape: shape,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  /// Accessible form field with validation feedback
  static Widget accessibleTextField({
    required TextEditingController controller,
    String? label,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    bool enabled = true,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        autofocus: autofocus,
        focusNode: focusNode,
      ),
    );
  }

  /// Accessible chart with data description
  static Widget accessibleChart({
    required Widget chart,
    required String title,
    required String description,
    List<String>? dataPoints,
    Map<String, dynamic>? metadata,
  }) {
    final dataDescription = dataPoints?.join(', ') ?? 'Chart data';
    final fullDescription = '$description. $dataDescription';

    return Semantics(
      label: title,
      hint: fullDescription,
      image: true,
      child: chart,
    );
  }

  /// Accessible data table with proper navigation
  static Widget accessibleDataTable({
    required List<DataColumn> columns,
    required List<DataRow> rows,
    String? semanticLabel,
    bool sortAscending = true,
    int? sortColumnIndex,
    ValueChanged<int>? onSelectAll,
    ValueChanged<bool?>? onSelectChanged,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Data table',
      child: DataTable(
        columns: columns,
        rows: rows,
        sortAscending: sortAscending,
        sortColumnIndex: sortColumnIndex,
        onSelectAll: onSelectAll,
      ),
    );
  }

  /// Accessible progress indicator with announcements
  static Widget accessibleProgressIndicator({
    double? value,
    String? semanticLabel,
    Color? color,
    double? strokeWidth,
    String? valueText,
  }) {
    final progressText = value != null
        ? '${(value * 100).round()}% complete'
        : 'Loading in progress';

    return Semantics(
      label: semanticLabel ?? 'Progress indicator',
      value: valueText ?? progressText,
      liveRegion: true,
      child: CircularProgressIndicator(
        value: value,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Accessible slider with value announcements
  static Widget accessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    double? min,
    double? max,
    int? divisions,
    String? semanticLabel,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Slider',
      value: value.toStringAsFixed(1),
      increasedValue: '${(value + 0.1).clamp(min ?? 0, max ?? 1)}',
      decreasedValue: '${(value - 0.1).clamp(min ?? 0, max ?? 1)}',
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min ?? 0.0,
        max: max ?? 1.0,
        divisions: divisions,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      ),
    );
  }

  /// Accessible switch with clear labels
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    String? semanticLabel,
    String? activeText,
    String? inactiveText,
    Color? activeColor,
    Color? activeTrackColor,
  }) {
    final stateText = value ? (activeText ?? 'On') : (inactiveText ?? 'Off');

    return Semantics(
      label: semanticLabel ?? 'Toggle switch',
      hint: 'Double tap to toggle',
      toggled: value,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeTrackColor,
      ),
    );
  }

  /// Accessible dropdown with proper announcements
  static Widget accessibleDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? semanticLabel,
    String? hint,
    bool isExpanded = false,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Dropdown menu',
      hint: hint ?? 'Double tap to open menu',
      button: true,
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: isExpanded,
        hint: hint != null ? Text(hint) : null,
      ),
    );
  }

  /// Accessible tab bar with proper navigation
  static Widget accessibleTabBar({
    required List<Widget> tabs,
    required TabController controller,
    String? semanticLabel,
    bool isScrollable = false,
    Color? indicatorColor,
    TabBarIndicatorSize? indicatorSize,
  }) {
    return Semantics(
      label: semanticLabel ?? 'Tab navigation',
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor,
        indicatorSize: indicatorSize ?? TabBarIndicatorSize.tab,
      ),
    );
  }

  /// Accessible dialog with proper focus management
  static Future<T?> showAccessibleDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    String? barrierLabel,
    Color? barrierColor,
    String? semanticLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? 'Close dialog',
      barrierColor: barrierColor,
      builder: (context) => Semantics(
        label: semanticLabel ?? 'Dialog',
        scopesRoute: true,
        explicitChildNodes: true,
        child: builder(context),
      ),
    );
  }

  /// Accessible snackbar with announcements
  static void showAccessibleSnackBar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          label: message,
          liveRegion: true,
          child: Text(message),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  /// Focus management utilities
  static void requestFocus(BuildContext context, FocusNode node) {
    FocusScope.of(context).requestFocus(node);
  }

  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Screen reader announcements
  static void announceToScreenReader(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// High contrast mode detection and adaptation
  static bool isHighContrastMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Large text scale factor detection
  static bool hasLargeText(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return textScale > 1.2;
  }

  /// Reduced motion preference detection
  static bool prefersReducedMotion(BuildContext context) {
    // In Flutter, we can check MediaQuery for animation scale
    // This is a placeholder for actual implementation
    return false;
  }
}

/// Custom accessible widgets extending Flutter widgets
class AccessibleText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final bool isHeading;
  final String? semanticLabel;
  final String? semanticHint;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleText(
    this.data, {
    Key? key,
    this.style,
    this.isHeading = false,
    this.semanticLabel,
    this.semanticHint,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? data,
      hint: semanticHint,
      header: isHeading,
      child: Text(
        data,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleButton({
    Key? key,
    this.onPressed,
    required this.child,
    this.semanticLabel,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }
}

class AccessibleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final String? semanticLabel;
  final String? tooltip;
  final Color? color;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleIconButton({
    Key? key,
    this.onPressed,
    required this.icon,
    this.semanticLabel,
    this.tooltip,
    this.color,
    this.iconSize,
    this.padding,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? tooltip ?? 'Button',
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: color,
          iconSize: iconSize,
          padding: padding,
          autofocus: autofocus,
          focusNode: focusNode,
          tooltip: tooltip,
        ),
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const AccessibleCard({
    Key? key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      container: true,
      child: Card(
        color: color,
        elevation: elevation,
        shape: shape,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Accessibility service for managing accessibility preferences
class AccessibilityService extends ChangeNotifier {
  bool _highContrastMode = false;
  bool _largeTextMode = false;
  bool _reducedMotionMode = false;
  bool _screenReaderEnabled = false;

  bool get highContrastMode => _highContrastMode;
  bool get largeTextMode => _largeTextMode;
  bool get reducedMotionMode => _reducedMotionMode;
  bool get screenReaderEnabled => _screenReaderEnabled;

  set highContrastMode(bool value) {
    if (_highContrastMode != value) {
      _highContrastMode = value;
      notifyListeners();
    }
  }

  set largeTextMode(bool value) {
    if (_largeTextMode != value) {
      _largeTextMode = value;
      notifyListeners();
    }
  }

  set reducedMotionMode(bool value) {
    if (_reducedMotionMode != value) {
      _reducedMotionMode = value;
      notifyListeners();
    }
  }

  set screenReaderEnabled(bool value) {
    if (_screenReaderEnabled != value) {
      _screenReaderEnabled = value;
      notifyListeners();
    }
  }

  /// Get appropriate text style based on accessibility preferences
  TextStyle getAccessibleTextStyle(BuildContext context, TextStyle baseStyle) {
    TextStyle style = baseStyle;

    if (_highContrastMode) {
      style = style.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      );
    }

    if (_largeTextMode) {
      style = style.copyWith(
        fontSize: (style.fontSize ?? 14) * 1.2,
      );
    }

    return style;
  }

  /// Get appropriate animation duration based on motion preferences
  Duration getAccessibleAnimationDuration(Duration baseDuration) {
    return _reducedMotionMode ? const Duration(milliseconds: 0) : baseDuration;
  }

  /// Announce content to screen readers
  void announce(String message) {
    if (_screenReaderEnabled) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }
}

/// Extension methods for accessibility
extension AccessibilityExtensions on BuildContext {
  AccessibilityService get accessibility => AccessibilityService();

  bool get isHighContrastMode => MediaQuery.of(this).platformBrightness == Brightness.dark;

  bool get hasLargeText => MediaQuery.of(this).textScaleFactor > 1.2;

  bool get prefersReducedMotion => false; // Platform-specific implementation needed

  void announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }
}
