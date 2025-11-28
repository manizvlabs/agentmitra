import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../core/services/dashboard_realtime_service.dart';
import '../../../../../core/widgets/dashboard/dashboard_widget_base.dart';

/// Dashboard state management using Provider pattern
class DashboardProvider extends ChangeNotifier {
  final DashboardRealtimeService _realtimeService = DashboardRealtimeService();

  DashboardLayout _currentLayout;
  bool _isEditMode = false;
  bool _isLoading = false;
  String? _error;
  final Map<String, dynamic> _widgetData = {};

  // Real-time subscriptions
  final Map<String, StreamSubscription<DashboardUpdate>> _subscriptions = {};

  DashboardProvider(this._currentLayout) {
    _initializeRealtimeUpdates();
  }

  // Getters
  DashboardLayout get currentLayout => _currentLayout;
  bool get isEditMode => _isEditMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get widgetData => Map.unmodifiable(_widgetData);

  // Setters with notifications
  set isEditMode(bool value) {
    if (_isEditMode != value) {
      _isEditMode = value;
      notifyListeners();
    }
  }

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  set error(String? value) {
    if (_error != value) {
      _error = value;
      notifyListeners();
    }
  }

  /// Initialize real-time updates for all widgets
  void _initializeRealtimeUpdates() {
    // Initialize WebSocket connection
    _realtimeService.initialize();

    // Subscribe to layout-wide updates
    _subscribeToWidgetUpdates('all');

    // Subscribe to individual widget updates
    for (final widget in _currentLayout.widgets) {
      _subscribeToWidgetUpdates(widget.id);
    }
  }

  /// Subscribe to real-time updates for a specific widget
  void _subscribeToWidgetUpdates(String widgetId) {
    if (_subscriptions.containsKey(widgetId)) {
      _subscriptions[widgetId]?.cancel();
    }

    _subscriptions[widgetId] = _realtimeService.subscribeToWidget(
      widgetId,
      _handleRealtimeUpdate,
    );
  }

  /// Handle real-time updates from WebSocket
  void _handleRealtimeUpdate(DashboardUpdate update) {
    debugPrint('Received real-time update: ${update.type} for ${update.widgetId}');

    switch (update.type) {
      case 'data_update':
        _updateWidgetData(update.widgetId, update.data);
        break;

      case 'config_update':
        _updateWidgetConfig(update.widgetId, update.data);
        break;

      case 'layout_update':
        _updateLayout(update.data);
        break;

      case 'widget_added':
        _addWidgetFromUpdate(update.data);
        break;

      case 'widget_removed':
        _removeWidgetFromUpdate(update.widgetId);
        break;

      default:
        debugPrint('Unknown update type: ${update.type}');
    }

    notifyListeners();
  }

  /// Update widget data
  void _updateWidgetData(String widgetId, Map<String, dynamic> data) {
    _widgetData[widgetId] = data;
    debugPrint('Updated data for widget $widgetId: $data');
  }

  /// Update widget configuration
  void _updateWidgetConfig(String widgetId, Map<String, dynamic> config) {
    final widgetIndex = _currentLayout.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex != -1) {
      final updatedWidget = _currentLayout.widgets[widgetIndex].copyWith(config: config);
      _currentLayout = _currentLayout.copyWith(
        widgets: _currentLayout.widgets..[widgetIndex] = updatedWidget,
      );
      debugPrint('Updated config for widget $widgetId: $config');
    }
  }

  /// Update entire layout
  void _updateLayout(Map<String, dynamic> layoutData) {
    // This would parse and update the entire layout
    debugPrint('Layout update received: $layoutData');
  }

  /// Add widget from real-time update
  void _addWidgetFromUpdate(Map<String, dynamic> widgetData) {
    final widget = DashboardWidgetItem.fromJson(widgetData);
    _currentLayout = _currentLayout.copyWith(
      widgets: [..._currentLayout.widgets, widget],
    );
    _subscribeToWidgetUpdates(widget.id);
    debugPrint('Added widget: ${widget.id}');
  }

  /// Remove widget from real-time update
  void _removeWidgetFromUpdate(String widgetId) {
    _currentLayout = _currentLayout.copyWith(
      widgets: _currentLayout.widgets.where((w) => w.id != widgetId).toList(),
    );
    _subscriptions[widgetId]?.cancel();
    _subscriptions.remove(widgetId);
    _widgetData.remove(widgetId);
    debugPrint('Removed widget: $widgetId');
  }

  /// Add a new widget to the dashboard
  void addWidget(DashboardWidgetItem widget) {
    _currentLayout = _currentLayout.copyWith(
      widgets: [..._currentLayout.widgets, widget],
    );
    _subscribeToWidgetUpdates(widget.id);

    // Send update to server
    _realtimeService.updateWidgetConfig('layout', {
      'action': 'add_widget',
      'widget': widget.toJson(),
    });

    notifyListeners();
  }

  /// Remove a widget from the dashboard
  void removeWidget(String widgetId) {
    _currentLayout = _currentLayout.copyWith(
      widgets: _currentLayout.widgets.where((w) => w.id != widgetId).toList(),
    );
    _subscriptions[widgetId]?.cancel();
    _subscriptions.remove(widgetId);
    _widgetData.remove(widgetId);

    // Send update to server
    _realtimeService.updateWidgetConfig('layout', {
      'action': 'remove_widget',
      'widgetId': widgetId,
    });

    notifyListeners();
  }

  /// Update widget position
  void updateWidgetPosition(String widgetId, WidgetPosition newPosition) {
    final widgetIndex = _currentLayout.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex != -1) {
      final updatedWidget = _currentLayout.widgets[widgetIndex].copyWith(
        position: newPosition,
      );
      _currentLayout = _currentLayout.copyWith(
        widgets: _currentLayout.widgets..[widgetIndex] = updatedWidget,
      );

      // Send update to server
      _realtimeService.updateWidgetConfig(widgetId, {
        'position': newPosition.toJson(),
      });

      notifyListeners();
    }
  }

  /// Update widget configuration
  void updateWidgetConfig(String widgetId, Map<String, dynamic> config) {
    final widgetIndex = _currentLayout.widgets.indexWhere((w) => w.id == widgetId);
    if (widgetIndex != -1) {
      final updatedWidget = _currentLayout.widgets[widgetIndex].copyWith(
        config: config,
      );
      _currentLayout = _currentLayout.copyWith(
        widgets: _currentLayout.widgets..[widgetIndex] = updatedWidget,
      );

      // Send update to server
      _realtimeService.updateWidgetConfig(widgetId, config);

      notifyListeners();
    }
  }

  /// Save current layout
  Future<void> saveLayout() async {
    try {
      isLoading = true;
      error = null;

      // Here you would typically save to a backend service
      // For now, we'll just simulate the save
      await Future.delayed(const Duration(seconds: 1));

      _currentLayout = _currentLayout.copyWith(
        updatedAt: DateTime.now(),
      );

      debugPrint('Layout saved successfully');
    } catch (e) {
      error = 'Failed to save layout: $e';
      debugPrint('Error saving layout: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Load layout from storage/server
  Future<void> loadLayout(String layoutId) async {
    try {
      isLoading = true;
      error = null;

      // Here you would typically load from a backend service
      // For now, we'll just simulate loading
      await Future.delayed(const Duration(seconds: 1));

      debugPrint('Layout loaded successfully');
    } catch (e) {
      error = 'Failed to load layout: $e';
      debugPrint('Error loading layout: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Refresh all widget data
  Future<void> refreshAllWidgets() async {
    try {
      isLoading = true;
      error = null;

      // Request data refresh for all widgets
      _realtimeService.requestDataUpdate('all', params: {'action': 'refresh'});

      // Simulate refresh delay
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('All widgets refreshed');
    } catch (e) {
      error = 'Failed to refresh widgets: $e';
      debugPrint('Error refreshing widgets: $e');
    } finally {
      isLoading = false;
    }
  }

  /// Get widget data
  dynamic getWidgetData(String widgetId) {
    return _widgetData[widgetId];
  }

  /// Check if widget has data
  bool hasWidgetData(String widgetId) {
    return _widgetData.containsKey(widgetId);
  }

  /// Clear all data and reset state
  void reset() {
    _widgetData.clear();
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _isEditMode = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// Get connection status
  Stream<ConnectionStatus> get connectionStatus => _realtimeService.connectionStatus;

  ConnectionStatus get currentConnectionStatus => _realtimeService.currentStatus;

  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Disconnect WebSocket
    _realtimeService.disconnect();

    super.dispose();
  }
}

/// Widget-specific state managers
class WidgetDataProvider extends ChangeNotifier {
  final String widgetId;
  dynamic _data;
  bool _isLoading = false;
  String? _error;

  WidgetDataProvider(this.widgetId);

  dynamic get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  set data(dynamic value) {
    if (_data != value) {
      _data = value;
      notifyListeners();
    }
  }

  set isLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  set error(String? value) {
    if (_error != value) {
      _error = value;
      notifyListeners();
    }
  }

  /// Load data for this widget
  Future<void> loadData() async {
    try {
      isLoading = true;
      error = null;

      // Here you would implement actual data loading logic
      // For now, we'll just simulate it
      await Future.delayed(const Duration(seconds: 1));

      // Simulate data
      data = {'loaded': true, 'timestamp': DateTime.now()};

    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadData();
  }
}

/// Dashboard layout manager for managing multiple layouts
class DashboardLayoutManager extends ChangeNotifier {
  final List<DashboardLayout> _layouts = [];
  DashboardLayout? _activeLayout;

  List<DashboardLayout> get layouts => List.unmodifiable(_layouts);
  DashboardLayout? get activeLayout => _activeLayout;

  /// Add a new layout
  void addLayout(DashboardLayout layout) {
    _layouts.add(layout);
    if (_activeLayout == null) {
      _activeLayout = layout;
    }
    notifyListeners();
  }

  /// Remove a layout
  void removeLayout(String layoutId) {
    _layouts.removeWhere((layout) => layout.id == layoutId);
    if (_activeLayout?.id == layoutId) {
      _activeLayout = _layouts.isNotEmpty ? _layouts.first : null;
    }
    notifyListeners();
  }

  /// Set active layout
  void setActiveLayout(String layoutId) {
    final layout = _layouts.firstWhere(
      (layout) => layout.id == layoutId,
      orElse: () => throw Exception('Layout not found'),
    );
    _activeLayout = layout;
    notifyListeners();
  }

  /// Update a layout
  void updateLayout(DashboardLayout updatedLayout) {
    final index = _layouts.indexWhere((layout) => layout.id == updatedLayout.id);
    if (index != -1) {
      _layouts[index] = updatedLayout;
      if (_activeLayout?.id == updatedLayout.id) {
        _activeLayout = updatedLayout;
      }
      notifyListeners();
    }
  }

  /// Create default layout
  DashboardLayout createDefaultLayout() {
    return DashboardLayout(
      id: 'default-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Default Dashboard',
      widgets: [
        DashboardWidgetItem(
          id: 'kpi-1',
          widgetType: 'kpi_cards',
          title: 'Revenue KPIs',
          position: WidgetPosition(row: 0, col: 0, width: 2, height: 2),
        ),
        DashboardWidgetItem(
          id: 'chart-1',
          widgetType: 'revenue_chart',
          title: 'Revenue Trend',
          position: WidgetPosition(row: 0, col: 2, width: 2, height: 3),
        ),
        DashboardWidgetItem(
          id: 'insights-1',
          widgetType: 'predictive_insights',
          title: 'AI Insights',
          position: WidgetPosition(row: 3, col: 0, width: 2, height: 2),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Reset to default layout
  void resetToDefault() {
    _layouts.clear();
    final defaultLayout = createDefaultLayout();
    addLayout(defaultLayout);
  }
}

/// Dashboard theme provider for consistent theming
class DashboardThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _cardElevation = 2.0;
  BorderRadius _cardBorderRadius = const BorderRadius.all(Radius.circular(12));

  bool get isDarkMode => _isDarkMode;
  double get cardElevation => _cardElevation;
  BorderRadius get cardBorderRadius => _cardBorderRadius;

  set isDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  set cardElevation(double value) {
    if (_cardElevation != value) {
      _cardElevation = value;
      notifyListeners();
    }
  }

  set cardBorderRadius(BorderRadius value) {
    if (_cardBorderRadius != value) {
      _cardBorderRadius = value;
      notifyListeners();
    }
  }

  /// Get theme data for dashboard
  ThemeData getDashboardTheme(BuildContext context) {
    final baseTheme = Theme.of(context);
    return baseTheme.copyWith(
      cardTheme: CardTheme(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(borderRadius: cardBorderRadius),
      ),
      // Add more dashboard-specific theming
    );
  }
}
