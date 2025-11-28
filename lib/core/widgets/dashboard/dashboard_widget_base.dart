import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Base class for all dashboard widgets
abstract class DashboardWidget extends StatefulWidget {
  final String id;
  final String title;
  final WidgetSize size;
  final Map<String, dynamic>? config;
  final VoidCallback? onRemove;
  final VoidCallback? onConfigure;

  const DashboardWidget({
    Key? key,
    String? id,
    required this.title,
    this.size = WidgetSize.medium,
    this.config,
    this.onRemove,
    this.onConfigure,
  }) : id = id ?? const Uuid().v4(), super(key: key);

  @override
  DashboardWidgetState createState();

  /// Get the widget's data requirements
  Map<String, dynamic> getDataRequirements();

  /// Get the widget's configuration options
  List<WidgetConfigOption> getConfigOptions();

  /// Create a copy with new configuration
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  });
}

/// Base state class for dashboard widgets
abstract class DashboardWidgetState<T extends DashboardWidget> extends State<T> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  /// Load widget data
  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await fetchData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Override this method to fetch data
  Future<void> fetchData();

  /// Override this method to build the widget content
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: widget.size.height,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Widget header
            _buildHeader(),

            const SizedBox(height: 16),

            // Widget content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onConfigure != null)
              IconButton(
                icon: const Icon(Icons.settings, size: 20),
                onPressed: widget.onConfigure,
                tooltip: 'Configure',
              ),

            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: loadData,
              tooltip: 'Refresh',
            ),

            if (widget.onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: widget.onRemove,
                tooltip: 'Remove',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Widget size definitions
enum WidgetSize {
  small(200, 150),
  medium(400, 250),
  large(600, 350),
  extraLarge(800, 450);

  const WidgetSize(this.width, this.height);

  final double width;
  final double height;
}

/// Widget configuration option
class WidgetConfigOption {
  final String key;
  final String label;
  final String type; // 'text', 'number', 'boolean', 'select', 'date'
  final dynamic defaultValue;
  final List<dynamic>? options; // For select type
  final String? helpText;

  const WidgetConfigOption({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
    this.helpText,
  });
}

/// Widget position in grid
class WidgetPosition {
  final int row;
  final int col;
  final int width;
  final int height;

  const WidgetPosition({
    required this.row,
    required this.col,
    required this.width,
    required this.height,
  });

  WidgetPosition copyWith({
    int? row,
    int? col,
    int? width,
    int? height,
  }) {
    return WidgetPosition(
      row: row ?? this.row,
      col: col ?? this.col,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'width': width,
    'height': height,
  };

  factory WidgetPosition.fromJson(Map<String, dynamic> json) => WidgetPosition(
    row: json['row'],
    col: json['col'],
    width: json['width'],
    height: json['height'],
  );
}

/// Dashboard layout configuration
class DashboardLayout {
  final String id;
  final String name;
  final List<DashboardWidgetItem> widgets;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DashboardLayout({
    required this.id,
    required this.name,
    required this.widgets,
    required this.createdAt,
    required this.updatedAt,
  });

  DashboardLayout copyWith({
    String? name,
    List<DashboardWidgetItem>? widgets,
  }) {
    return DashboardLayout(
      id: id,
      name: name ?? this.name,
      widgets: widgets ?? this.widgets,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'widgets': widgets.map((w) => w.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DashboardLayout.fromJson(Map<String, dynamic> json) => DashboardLayout(
    id: json['id'],
    name: json['name'],
    widgets: (json['widgets'] as List).map((w) => DashboardWidgetItem.fromJson(w)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

/// Dashboard widget item for layout management
class DashboardWidgetItem {
  final String id;
  final String widgetType;
  final String title;
  final WidgetPosition position;
  final Map<String, dynamic>? config;
  final bool isVisible;

  const DashboardWidgetItem({
    required this.id,
    required this.widgetType,
    required this.title,
    required this.position,
    this.config,
    this.isVisible = true,
  });

  DashboardWidgetItem copyWith({
    String? title,
    WidgetPosition? position,
    Map<String, dynamic>? config,
    bool? isVisible,
  }) {
    return DashboardWidgetItem(
      id: id,
      widgetType: widgetType,
      title: title ?? this.title,
      position: position ?? this.position,
      config: config ?? this.config,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'widgetType': widgetType,
    'title': title,
    'position': position.toJson(),
    'config': config,
    'isVisible': isVisible,
  };

  factory DashboardWidgetItem.fromJson(Map<String, dynamic> json) => DashboardWidgetItem(
    id: json['id'],
    widgetType: json['widgetType'],
    title: json['title'],
    position: WidgetPosition.fromJson(json['position']),
    config: json['config'],
    isVisible: json['isVisible'] ?? true,
  );
}
