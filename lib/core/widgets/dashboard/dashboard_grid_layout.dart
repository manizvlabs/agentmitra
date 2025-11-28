import 'package:flutter/material.dart';
import 'dashboard_widget_base.dart';
import 'dashboard_widget_registry.dart';

/// Drag-and-drop dashboard grid layout
class DashboardGridLayout extends StatefulWidget {
  final DashboardLayout layout;
  final bool isEditMode;
  final Function(DashboardLayout)? onLayoutChanged;
  final Function(DashboardWidgetItem)? onWidgetConfigure;
  final Function(DashboardWidgetItem)? onWidgetRemove;

  const DashboardGridLayout({
    Key? key,
    required this.layout,
    this.isEditMode = false,
    this.onLayoutChanged,
    this.onWidgetConfigure,
    this.onWidgetRemove,
  }) : super(key: key);

  @override
  State<DashboardGridLayout> createState() => _DashboardGridLayoutState();
}

class _DashboardGridLayoutState extends State<DashboardGridLayout> {
  late List<DashboardWidgetItem> _widgets;
  DashboardWidgetItem? _draggedWidget;
  Offset? _dragOffset;

  static const double _cellWidth = 120.0;
  static const double _cellHeight = 100.0;
  static const int _gridColumns = 12;

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.layout.widgets);
  }

  @override
  void didUpdateWidget(DashboardGridLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layout.id != widget.layout.id ||
        oldWidget.layout.widgets != widget.layout.widgets) {
      _widgets = List.from(widget.layout.widgets);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid background (only in edit mode)
        if (widget.isEditMode) _buildGridBackground(),

        // Widgets
        ..._widgets.where((w) => w.isVisible).map((widget) => _buildWidget(widget)),

        // Drag overlay
        if (_draggedWidget != null && _dragOffset != null)
          _buildDragOverlay(),
      ],
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }

  Widget _buildWidget(DashboardWidgetItem item) {
    final registry = DashboardWidgetRegistry();
    final widgetBuilder = registry.getWidgetBuilder(item.widgetType);

    if (widgetBuilder == null) {
      return _buildErrorWidget(item, 'Unknown widget type: ${item.widgetType}');
    }

    final widget = widgetBuilder(
      id: item.id,
      title: item.title,
      config: item.config,
      onRemove: widget.isEditMode ? () => _removeWidget(item) : null,
      onConfigure: () => _configureWidget(item),
    );

    return Positioned(
      left: item.position.col * _cellWidth,
      top: item.position.row * _cellHeight,
      width: item.position.width * _cellWidth,
      height: item.position.height * _cellHeight,
      child: widget.isEditMode
          ? _buildDraggableWidget(widget, item)
          : widget,
    );
  }

  Widget _buildDraggableWidget(Widget child, DashboardWidgetItem item) {
    return LongPressDraggable<DashboardWidgetItem>(
      data: item,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: item.position.width * _cellWidth,
          height: item.position.height * _cellHeight,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: child,
      ),
      onDragStarted: () {
        setState(() {
          _draggedWidget = item;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggedWidget = null;
          _dragOffset = null;
        });
      },
      onDraggableCanceled: (velocity, offset) {
        setState(() {
          _draggedWidget = null;
          _dragOffset = null;
        });
      },
      child: DragTarget<DashboardWidgetItem>(
        onWillAcceptWithDetails: (details) => details.data != item,
        onAcceptWithDetails: (details) => _handleDrop(details.data, item.position),
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              border: candidateData.isNotEmpty
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildDragOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text('Drop to move widget'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(DashboardWidgetItem item, String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              'Widget Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.red.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleDrop(DashboardWidgetItem draggedItem, WidgetPosition targetPosition) {
    setState(() {
      // Find the dragged item and update its position
      final draggedIndex = _widgets.indexWhere((w) => w.id == draggedItem.id);
      if (draggedIndex != -1) {
        _widgets[draggedIndex] = _widgets[draggedIndex].copyWith(
          position: targetPosition,
        );
      }
    });

    // Notify parent of layout change
    _notifyLayoutChanged();
  }

  void _removeWidget(DashboardWidgetItem item) {
    setState(() {
      _widgets.removeWhere((w) => w.id == item.id);
    });

    widget.onWidgetRemove?.call(item);
    _notifyLayoutChanged();
  }

  void _configureWidget(DashboardWidgetItem item) {
    widget.onWidgetConfigure?.call(item);
  }

  void _notifyLayoutChanged() {
    final updatedLayout = widget.layout.copyWith(
      widgets: _widgets,
    );
    widget.onLayoutChanged?.call(updatedLayout);
  }

  void addWidget(DashboardWidgetItem widget) {
    setState(() {
      _widgets.add(widget);
    });
    _notifyLayoutChanged();
  }

  void updateWidget(DashboardWidgetItem updatedWidget) {
    setState(() {
      final index = _widgets.indexWhere((w) => w.id == updatedWidget.id);
      if (index != -1) {
        _widgets[index] = updatedWidget;
      }
    });
    _notifyLayoutChanged();
  }
}

/// Grid painter for edit mode background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    const cellWidth = 120.0;
    const cellHeight = 100.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += cellWidth) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += cellHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Widget configuration dialog
class WidgetConfigDialog extends StatefulWidget {
  final DashboardWidgetItem widget;
  final Function(DashboardWidgetItem)? onSave;

  const WidgetConfigDialog({
    Key? key,
    required this.widget,
    this.onSave,
  }) : super(key: key);

  @override
  State<WidgetConfigDialog> createState() => _WidgetConfigDialogState();
}

class _WidgetConfigDialogState extends State<WidgetConfigDialog> {
  late TextEditingController _titleController;
  late Map<String, dynamic> _config;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.widget.title);
    _config = Map.from(widget.widget.config ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = DashboardWidgetRegistry();
    final widgetBuilder = registry.getWidgetBuilder(widget.widget.widgetType);
    final configOptions = widgetBuilder?.getConfigOptions() ?? [];

    return AlertDialog(
      title: Text('Configure ${widget.widget.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Widget Title',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Configuration options
            if (configOptions.isNotEmpty) ...[
              const Text(
                'Configuration',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...configOptions.map((option) => _buildConfigField(option)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveConfiguration,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildConfigField(WidgetConfigOption option) {
    switch (option.type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            decoration: InputDecoration(
              labelText: option.label,
              hintText: option.helpText,
              border: const OutlineInputBorder(),
            ),
            controller: TextEditingController(text: _config[option.key]?.toString() ?? ''),
            onChanged: (value) => _config[option.key] = value,
          ),
        );

      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextField(
            decoration: InputDecoration(
              labelText: option.label,
              hintText: option.helpText,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: _config[option.key]?.toString() ?? ''),
            onChanged: (value) => _config[option.key] = double.tryParse(value) ?? 0,
          ),
        );

      case 'boolean':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CheckboxListTile(
            title: Text(option.label),
            subtitle: option.helpText != null ? Text(option.helpText!) : null,
            value: _config[option.key] ?? option.defaultValue ?? false,
            onChanged: (value) => setState(() => _config[option.key] = value),
          ),
        );

      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              labelText: option.label,
              border: const OutlineInputBorder(),
            ),
            value: _config[option.key] ?? option.defaultValue,
            items: (option.options ?? []).map((opt) {
              return DropdownMenuItem(
                value: opt,
                child: Text(opt.toString()),
              );
            }).toList(),
            onChanged: (value) => setState(() => _config[option.key] = value),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _saveConfiguration() {
    final updatedWidget = widget.widget.copyWith(
      title: _titleController.text,
      config: _config,
    );

    widget.onSave?.call(updatedWidget);
    Navigator.of(context).pop();
  }
}
