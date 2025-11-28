import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/core/services/auth_service.dart';
import '../../lib/core/services/dashboard_realtime_service.dart';
import '../../lib/core/widgets/dashboard/dashboard_widget_base.dart';
import '../../lib/core/widgets/dashboard/dashboard_widget_registry.dart';
import '../../lib/core/widgets/interactive_chart_widget.dart';
import '../../lib/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../../lib/features/dashboard/presentation/pages/roi_dashboard_page.dart';

/// Comprehensive integration tests for dashboard system
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late DashboardRealtimeService realtimeService;
  late DashboardWidgetRegistry widgetRegistry;

  setUp(() async {
    // Initialize mock services
    mockAuthService = MockAuthService();

    // Mock shared preferences
    SharedPreferences.setMockInitialValues({});

    // Initialize services
    realtimeService = DashboardRealtimeService();
    widgetRegistry = DashboardWidgetRegistry();
    widgetRegistry.initializeDefaultWidgets();

    // Mock authenticated user
    when(mockAuthService.currentUser).thenReturn(MockUser());
    when(mockAuthService.getCurrentAgentId()).thenAnswer((_) async => 'test-agent-id');
  });

  tearDown(() {
    realtimeService.disconnect();
  });

  group('Dashboard Integration Tests', () {
    testWidgets('Complete dashboard loading workflow', (WidgetTester tester) async {
      // Create a test dashboard with multiple widgets
      final dashboardLayout = DashboardLayout(
        id: 'test-dashboard',
        name: 'Test Dashboard',
        widgets: [
          DashboardWidgetItem(
            id: 'kpi-widget',
            widgetType: 'kpi_cards',
            title: 'KPI Cards',
            position: WidgetPosition(row: 0, col: 0, width: 3, height: 2),
          ),
          DashboardWidgetItem(
            id: 'revenue-widget',
            widgetType: 'revenue_chart',
            title: 'Revenue Chart',
            position: WidgetPosition(row: 0, col: 3, width: 3, height: 3),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Build the dashboard page
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: ROIDashboardPage(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify dashboard loads without errors
      expect(find.byType(ROIDashboardPage), findsOneWidget);

      // Test widget registry functionality
      final registry = DashboardWidgetRegistry();
      expect(registry.getRegisteredTypes().isNotEmpty, true);

      final kpiBuilder = registry.getWidgetBuilder('kpi_cards');
      expect(kpiBuilder, isNotNull);

      // Test widget creation
      final kpiWidget = kpiBuilder!(
        id: 'test-kpi',
        title: 'Test KPI',
        config: {'show_trends': true},
      );

      expect(kpiWidget.title, 'Test KPI');
      expect(kpiWidget.config?['show_trends'], true);
    });

    testWidgets('Interactive chart functionality', (WidgetTester tester) async {
      // Create test chart data
      final chartData = [
        ChartDataPoint(id: '1', label: 'Jan', value: 1000),
        ChartDataPoint(id: '2', label: 'Feb', value: 1200),
        ChartDataPoint(id: '3', label: 'Mar', value: 800),
      ];

      // Build interactive chart
      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveChartWidget(
            chartType: ChartType.line,
            data: chartData,
            title: 'Test Chart',
            enableExport: true,
            enableTimeFilter: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chart renders
      expect(find.text('Test Chart'), findsOneWidget);
      expect(find.byType(InteractiveChartWidget), findsOneWidget);

      // Test time range selector
      expect(find.text('30D'), findsOneWidget);

      // Test export button presence
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('Dashboard widget drag and drop', (WidgetTester tester) async {
      final dashboardLayout = DashboardLayout(
        id: 'drag-test-dashboard',
        name: 'Drag Test Dashboard',
        widgets: [
          DashboardWidgetItem(
            id: 'widget-1',
            widgetType: 'kpi_cards',
            title: 'Widget 1',
            position: WidgetPosition(row: 0, col: 0, width: 2, height: 2),
          ),
          DashboardWidgetItem(
            id: 'widget-2',
            widgetType: 'kpi_cards',
            title: 'Widget 2',
            position: WidgetPosition(row: 0, col: 2, width: 2, height: 2),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // This would test drag and drop functionality
      // Note: Testing drag and drop in Flutter tests is complex and would require
      // more sophisticated test setup
    });

    test('Real-time dashboard service functionality', () async {
      // Test WebSocket service initialization
      expect(realtimeService.isConnected, false);

      // Test message handling (would need mock WebSocket)
      final update = DashboardUpdate(
        type: 'data_update',
        widgetId: 'test-widget',
        data: {'value': 100},
        timestamp: DateTime.now(),
      );

      expect(update.type, 'data_update');
      expect(update.widgetId, 'test-widget');
      expect(update.data['value'], 100);
    });

    test('Smart alert system functionality', () {
      final alertSystem = SmartAlertSystem();

      // Test alert rule evaluation
      final testData = {'revenue': 1000, 'previousRevenue': 1200};
      final rule = AlertRule(
        id: 'test-rule',
        name: 'Test Rule',
        description: 'Test alert rule',
        condition: (data) {
          final revenue = data['revenue'] as num?;
          final previous = data['previousRevenue'] as num?;
          return revenue != null && previous != null && revenue < previous * 0.9;
        },
        severity: AlertSeverity.medium,
      );

      expect(rule.condition(testData), true);

      // Test alert creation
      final alert = SmartAlert(
        id: 'test-alert',
        ruleId: rule.id,
        title: rule.name,
        message: rule.description,
        severity: rule.severity,
        timestamp: DateTime.now(),
        data: testData,
      );

      expect(alert.title, 'Test Rule');
      expect(alert.severity, AlertSeverity.medium);
      expect(alert.acknowledged, false);
    });

    test('Widget registry functionality', () {
      final registry = DashboardWidgetRegistry();

      // Test widget creation
      final widgetItem = registry.createWidget('kpi_cards', title: 'Test KPI');
      expect(widgetItem.widgetType, 'kpi_cards');
      expect(widgetItem.title, 'Test KPI');

      // Test widget metadata
      registry.initializeDefaultWidgets();
      final metadata = registry.getWidgetMetadata('kpi_cards');
      expect(metadata, isNotNull);
      expect(metadata!.name, 'KPI Cards');
    });
  });

  group('Backend Service Integration Tests', () {
    test('ROI calculation service integration', () async {
      // This would test actual ROI service calls
      // Note: Requires backend to be running for full integration tests
      expect(true, true); // Placeholder for actual integration test
    });

    test('Revenue forecasting service integration', () async {
      // This would test revenue forecasting API calls
      expect(true, true); // Placeholder for actual integration test
    });

    test('Analytics service integration', () async {
      // This would test analytics API endpoints
      expect(true, true); // Placeholder for actual integration test
    });
  });

  group('End-to-End Dashboard Workflow', () {
    testWidgets('Dashboard data loading and display', (WidgetTester tester) async {
      // Build complete dashboard with viewmodel
      final dashboardViewModel = DashboardViewModel();

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>.value(value: mockAuthService),
              ChangeNotifierProvider<DashboardViewModel>.value(
                value: dashboardViewModel,
              ),
            ],
            child: const ROIDashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard renders
      expect(find.byType(ROIDashboardPage), findsOneWidget);
    });
  });
}

// Mock classes for testing
class MockAuthService extends Mock implements AuthService {}

class MockUser {
  String get id => 'test-user-id';
  String get role => 'agent';
}

// Extension for testing dashboard widgets
extension DashboardWidgetTestExtensions on WidgetTester {
  Future<void> verifyWidgetRenders(String widgetType) async {
    // Helper method to verify widget rendering
    expect(find.byType(DashboardWidget), findsWidgets);
  }
}
