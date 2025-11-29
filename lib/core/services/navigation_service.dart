import 'package:flutter/material.dart';

/// Navigation history item
class NavigationItem {
  final String title;
  final String route;
  final Map<String, dynamic>? arguments;
  final DateTime timestamp;

  const NavigationItem({
    required this.title,
    required this.route,
    this.arguments,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'route': route,
      'arguments': arguments,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NavigationItem.fromJson(Map<String, dynamic> json) {
    return NavigationItem(
      title: json['title'],
      route: json['route'],
      arguments: json['arguments'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Navigation service for breadcrumb management
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final List<NavigationItem> _navigationHistory = [];
  static const int _maxHistorySize = 10;

  /// Stream for navigation updates
  final StreamController<List<NavigationItem>> _historyController =
      StreamController<List<NavigationItem>>.broadcast();

  Stream<List<NavigationItem>> get historyStream => _historyController.stream;

  /// Add navigation item to history
  void addNavigationItem(String title, String route, [Map<String, dynamic>? arguments]) {
    final item = NavigationItem(
      title: title,
      route: route,
      arguments: arguments,
      timestamp: DateTime.now(),
    );

    // Remove duplicate consecutive items
    if (_navigationHistory.isNotEmpty &&
        _navigationHistory.last.route == route) {
      return;
    }

    _navigationHistory.add(item);

    // Keep history size manageable
    if (_navigationHistory.length > _maxHistorySize) {
      _navigationHistory.removeAt(0);
    }

    _historyController.add(List.from(_navigationHistory));
  }

  /// Remove last navigation item
  void removeLastItem() {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeLast();
      _historyController.add(List.from(_navigationHistory));
    }
  }

  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
    _historyController.add([]);
  }

  /// Get current navigation history
  List<NavigationItem> getHistory() {
    return List.from(_navigationHistory);
  }

  /// Get breadcrumbs (last few items for display)
  List<NavigationItem> getBreadcrumbs({int maxItems = 3}) {
    if (_navigationHistory.length <= maxItems) {
      return List.from(_navigationHistory);
    }

    // Return last maxItems items
    return _navigationHistory.sublist(_navigationHistory.length - maxItems);
  }

  /// Navigate with breadcrumb tracking
  Future<T?> navigateWithBreadcrumb<T>(
    BuildContext context,
    String route,
    String title, {
    Map<String, dynamic>? arguments,
    bool clearHistory = false,
  }) {
    if (clearHistory) {
      this.clearHistory();
    }

    addNavigationItem(title, route, arguments);
    return Navigator.of(context).pushNamed<T>(route, arguments: arguments);
  }

  /// Pop with breadcrumb management
  void popWithBreadcrumb(BuildContext context) {
    removeLastItem();
    Navigator.of(context).pop();
  }

  void dispose() {
    _historyController.close();
  }
}

/// Breadcrumb navigation widget
class BreadcrumbNavigation extends StatelessWidget {
  final int maxItems;
  final double fontSize;
  final Color? textColor;
  final Color? separatorColor;

  const BreadcrumbNavigation({
    super.key,
    this.maxItems = 3,
    this.fontSize = 14.0,
    this.textColor,
    this.separatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NavigationItem>>(
      stream: NavigationService().historyStream,
      builder: (context, snapshot) {
        final breadcrumbs = snapshot.data ?? NavigationService().getBreadcrumbs(maxItems: maxItems);

        if (breadcrumbs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.home,
                size: 16,
                color: textColor ?? Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(breadcrumbs.length * 2 - 1, (index) {
                      if (index.isEven) {
                        // Breadcrumb item
                        final itemIndex = index ~/ 2;
                        final item = breadcrumbs[itemIndex];
                        final isLast = itemIndex == breadcrumbs.length - 1;

                        return GestureDetector(
                          onTap: isLast ? null : () {
                            // Navigate back to this item
                            Navigator.of(context).popUntil((route) {
                              return route.settings.name == item.route;
                            });
                          },
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: isLast
                                  ? textColor ?? Theme.of(context).primaryColor
                                  : (textColor ?? Theme.of(context).textTheme.bodyMedium?.color)?.withOpacity(0.7),
                              fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                              decoration: isLast ? null : TextDecoration.underline,
                            ),
                          ),
                        );
                      } else {
                        // Separator
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: separatorColor ?? (textColor ?? Theme.of(context).textTheme.bodyMedium?.color)?.withOpacity(0.5),
                          ),
                        );
                      }
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Extension for easy navigation with breadcrumbs
extension NavigatorExtension on BuildContext {
  Future<T?> navigateWithBreadcrumb<T>(
    String route,
    String title, {
    Map<String, dynamic>? arguments,
    bool clearHistory = false,
  }) {
    return NavigationService().navigateWithBreadcrumb<T>(
      this,
      route,
      title,
      arguments: arguments,
      clearHistory: clearHistory,
    );
  }

  void popWithBreadcrumb() {
    NavigationService().popWithBreadcrumb(this);
  }
}
