import 'package:flutter/material.dart';
import 'dashboard_widget_base.dart';
import '../../widgets/interactive_chart_widget.dart';

/// Registry for dashboard widgets
class DashboardWidgetRegistry {
  static final DashboardWidgetRegistry _instance = DashboardWidgetRegistry._internal();
  factory DashboardWidgetRegistry() => _instance;
  DashboardWidgetRegistry._internal();

  final Map<String, WidgetBuilder> _widgetBuilders = {};
  final Map<String, WidgetMetadata> _widgetMetadata = {};

  /// Register a widget type
  void registerWidget(String type, WidgetBuilder builder, WidgetMetadata metadata) {
    _widgetBuilders[type] = builder;
    _widgetMetadata[type] = metadata;
  }

  /// Get widget builder for type
  WidgetBuilder? getWidgetBuilder(String type) => _widgetBuilders[type];

  /// Get widget metadata for type
  WidgetMetadata? getWidgetMetadata(String type) => _widgetMetadata[type];

  /// Get all registered widget types
  List<String> getRegisteredTypes() => _widgetBuilders.keys.toList();

  /// Get all widget metadata
  List<WidgetMetadata> getAllMetadata() => _widgetMetadata.values.toList();

  /// Initialize default widgets
  void initializeDefaultWidgets() {
    // KPI Cards Widget
    registerWidget(
      'kpi_cards',
      (id, title, config, onRemove, onConfigure) => KPICardsWidget(
        id: id,
        title: title ?? 'KPI Cards',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'kpi_cards',
        name: 'KPI Cards',
        description: 'Display key performance indicators',
        icon: Icons.dashboard,
        category: 'Analytics',
        defaultSize: WidgetSize.medium,
      ),
    );

    // Revenue Chart Widget
    registerWidget(
      'revenue_chart',
      (id, title, config, onRemove, onConfigure) => RevenueChartWidget(
        id: id,
        title: title ?? 'Revenue Chart',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'revenue_chart',
        name: 'Revenue Chart',
        description: 'Interactive revenue trend chart',
        icon: Icons.trending_up,
        category: 'Charts',
        defaultSize: WidgetSize.large,
      ),
    );

    // Customer Metrics Widget
    registerWidget(
      'customer_metrics',
      (id, title, config, onRemove, onConfigure) => CustomerMetricsWidget(
        id: id,
        title: title ?? 'Customer Metrics',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'customer_metrics',
        name: 'Customer Metrics',
        description: 'Customer acquisition and retention metrics',
        icon: Icons.people,
        category: 'Customers',
        defaultSize: WidgetSize.medium,
      ),
    );

    // ROI Dashboard Widget
    registerWidget(
      'roi_summary',
      (id, title, config, onRemove, onConfigure) => ROISummaryWidget(
        id: id,
        title: title ?? 'ROI Summary',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'roi_summary',
        name: 'ROI Summary',
        description: 'Return on investment overview',
        icon: Icons.account_balance_wallet,
        category: 'Finance',
        defaultSize: WidgetSize.medium,
      ),
    );

    // Recent Activity Widget
    registerWidget(
      'recent_activity',
      (id, title, config, onRemove, onConfigure) => RecentActivityWidget(
        id: id,
        title: title ?? 'Recent Activity',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'recent_activity',
        name: 'Recent Activity',
        description: 'Latest system activities and updates',
        icon: Icons.history,
        category: 'Activity',
        defaultSize: WidgetSize.small,
      ),
    );

    // Predictive Insights Widget
    registerWidget(
      'predictive_insights',
      (id, title, config, onRemove, onConfigure) => PredictiveInsightsWidget(
        id: id,
        title: title ?? 'Predictive Insights',
        config: config,
        onRemove: onRemove,
        onConfigure: onConfigure,
      ),
      const WidgetMetadata(
        type: 'predictive_insights',
        name: 'Predictive Insights',
        description: 'AI-powered predictions and recommendations',
        icon: Icons.lightbulb,
        category: 'AI',
        defaultSize: WidgetSize.large,
      ),
    );
  }

  /// Create a new widget instance
  DashboardWidgetItem createWidget(String type, {
    String? title,
    WidgetPosition? position,
    Map<String, dynamic>? config,
  }) {
    final metadata = _widgetMetadata[type];
    if (metadata == null) {
      throw Exception('Unknown widget type: $type');
    }

    return DashboardWidgetItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      widgetType: type,
      title: title ?? metadata.name,
      position: position ?? WidgetPosition(row: 0, col: 0, width: 3, height: 2),
      config: config,
    );
  }
}

/// Widget metadata for registry
class WidgetMetadata {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final WidgetSize defaultSize;

  const WidgetMetadata({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.defaultSize,
  });
}

/// Widget builder function type
typedef WidgetBuilder = DashboardWidget Function({
  String? id,
  String? title,
  Map<String, dynamic>? config,
  VoidCallback? onRemove,
  VoidCallback? onConfigure,
});

/// Example widget implementations

class KPICardsWidget extends DashboardWidget {
  const KPICardsWidget({
    super.key,
    super.id,
    super.title = 'KPI Cards',
    super.size = WidgetSize.medium,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _KPICardsWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {
    'kpi_metrics': ['total_revenue', 'total_customers', 'conversion_rate'],
  };

  @override
  List<WidgetConfigOption> getConfigOptions() => [
    const WidgetConfigOption(
      key: 'show_trends',
      label: 'Show Trends',
      type: 'boolean',
      defaultValue: true,
      helpText: 'Display trend indicators for KPIs',
    ),
    const WidgetConfigOption(
      key: 'refresh_interval',
      label: 'Refresh Interval',
      type: 'select',
      defaultValue: '30s',
      options: ['15s', '30s', '1m', '5m'],
      helpText: 'How often to refresh KPI data',
    ),
  ];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return KPICardsWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _KPICardsWidgetState extends DashboardWidgetState<KPICardsWidget> {
  List<Map<String, dynamic>> _kpiData = [];

  @override
  Future<void> fetchData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _kpiData = [
      {
        'title': 'Total Revenue',
        'value': '₹2,450,000',
        'change': '+12.5%',
        'trend': 'up',
        'icon': Icons.attach_money,
      },
      {
        'title': 'Active Customers',
        'value': '1,234',
        'change': '+8.2%',
        'trend': 'up',
        'icon': Icons.people,
      },
      {
        'title': 'Conversion Rate',
        'value': '3.8%',
        'change': '-2.1%',
        'trend': 'down',
        'icon': Icons.trending_up,
      },
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: _kpiData.length,
      itemBuilder: (context, index) {
        final kpi = _kpiData[index];
        return _buildKPICard(context, kpi);
      },
    );
  }

  Widget _buildKPICard(BuildContext context, Map<String, dynamic> kpi) {
    final isPositive = kpi['trend'] == 'up';
    final showTrends = widget.config?['show_trends'] ?? true;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(kpi['icon'], size: 20, color: Theme.of(context).primaryColor),
                const Spacer(),
                if (showTrends)
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kpi['title'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kpi['value'],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showTrends) ...[
              const SizedBox(height: 4),
              Text(
                kpi['change'],
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RevenueChartWidget extends DashboardWidget {
  const RevenueChartWidget({
    super.key,
    super.id,
    super.title = 'Revenue Chart',
    super.size = WidgetSize.large,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _RevenueChartWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {
    'revenue_data': ['daily_revenue', 'monthly_targets'],
  };

  @override
  List<WidgetConfigOption> getConfigOptions() => [
    const WidgetConfigOption(
      key: 'chart_type',
      label: 'Chart Type',
      type: 'select',
      defaultValue: 'line',
      options: ['line', 'bar', 'area'],
      helpText: 'Type of chart to display',
    ),
    const WidgetConfigOption(
      key: 'time_range',
      label: 'Time Range',
      type: 'select',
      defaultValue: '30d',
      options: ['7d', '30d', '90d', '1y'],
      helpText: 'Time period for the chart',
    ),
  ];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return RevenueChartWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _RevenueChartWidgetState extends DashboardWidgetState<RevenueChartWidget> {
  List<ChartDataPoint> _chartData = [];

  @override
  Future<void> fetchData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate sample data
    _chartData = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      final value = 50000 + (index * 1000) + (DateTime.now().millisecondsSinceEpoch % 10000);
      return ChartDataPoint(
        id: 'revenue_$index',
        label: '${date.day}/${date.month}',
        value: value.toDouble(),
        timestamp: date,
      );
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    final chartType = widget.config?['chart_type'] ?? 'line';

    return InteractiveChartWidget(
      chartType: ChartType.values.firstWhere(
        (type) => type.name == chartType,
        orElse: () => ChartType.line,
      ),
      data: _chartData,
      title: widget.title,
      enableExport: true,
      enableTimeFilter: true,
      onDataPointTap: (point) {
        // Handle chart interaction
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${point.label} - ₹${point.value.toStringAsFixed(0)}')),
        );
      },
      onDrillDown: (action) {
        // Handle drill-down actions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Drill down: $action')),
        );
      },
    );
  }
}

// Placeholder implementations for other widgets
class CustomerMetricsWidget extends DashboardWidget {
  const CustomerMetricsWidget({
    super.key,
    super.id,
    super.title = 'Customer Metrics',
    super.size = WidgetSize.medium,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _CustomerMetricsWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {};

  @override
  List<WidgetConfigOption> getConfigOptions() => [];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return CustomerMetricsWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _CustomerMetricsWidgetState extends DashboardWidgetState<CustomerMetricsWidget> {
  @override
  Future<void> fetchData() async => await Future.delayed(const Duration(seconds: 1));

  @override
  Widget buildContent(BuildContext context) => const Center(child: Text('Customer metrics coming soon'));
}

class ROISummaryWidget extends DashboardWidget {
  const ROISummaryWidget({
    super.key,
    super.id,
    super.title = 'ROI Summary',
    super.size = WidgetSize.medium,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _ROISummaryWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {};

  @override
  List<WidgetConfigOption> getConfigOptions() => [];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return ROISummaryWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _ROISummaryWidgetState extends DashboardWidgetState<ROISummaryWidget> {
  @override
  Future<void> fetchData() async => await Future.delayed(const Duration(seconds: 1));

  @override
  Widget buildContent(BuildContext context) => const Center(child: Text('ROI summary coming soon'));
}

class RecentActivityWidget extends DashboardWidget {
  const RecentActivityWidget({
    super.key,
    super.id,
    super.title = 'Recent Activity',
    super.size = WidgetSize.small,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _RecentActivityWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {};

  @override
  List<WidgetConfigOption> getConfigOptions() => [];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return RecentActivityWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _RecentActivityWidgetState extends DashboardWidgetState<RecentActivityWidget> {
  @override
  Future<void> fetchData() async => await Future.delayed(const Duration(seconds: 1));

  @override
  Widget buildContent(BuildContext context) => const Center(child: Text('Recent activity coming soon'));
}

class PredictiveInsightsWidget extends DashboardWidget {
  const PredictiveInsightsWidget({
    super.key,
    super.id,
    super.title = 'Predictive Insights',
    super.size = WidgetSize.large,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  DashboardWidgetState createState() => _PredictiveInsightsWidgetState();

  @override
  Map<String, dynamic> getDataRequirements() => {};

  @override
  List<WidgetConfigOption> getConfigOptions() => [];

  @override
  DashboardWidget copyWith({
    String? title,
    WidgetSize? size,
    Map<String, dynamic>? config,
  }) {
    return PredictiveInsightsWidget(
      id: id,
      title: title ?? this.title,
      size: size ?? this.size,
      config: config ?? this.config,
      onRemove: onRemove,
      onConfigure: onConfigure,
    );
  }
}

class _PredictiveInsightsWidgetState extends DashboardWidgetState<PredictiveInsightsWidget> {
  @override
  Future<void> fetchData() async => await Future.delayed(const Duration(seconds: 1));

  @override
  Widget buildContent(BuildContext context) => const Center(child: Text('Predictive insights coming soon'));
}
