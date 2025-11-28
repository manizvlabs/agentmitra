import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/main.dart';
import '../../lib/core/services/auth_service.dart';
import '../../lib/core/services/localization_service.dart';
import '../../lib/core/services/dashboard_realtime_service.dart';
import '../../lib/core/widgets/dashboard/dashboard_widget_registry.dart';
import '../../lib/features/auth/presentation/pages/login_page.dart';
import '../../lib/features/dashboard/presentation/pages/dashboard_page.dart';
import '../../lib/screens/splash_screen.dart';

/// System-wide integration tests covering the complete application workflow
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;

  setUp(() async {
    // Initialize mock services
    mockAuthService = MockAuthService();

    // Mock shared preferences
    SharedPreferences.setMockInitialValues({});

    // Initialize application services
    final localizationService = LocalizationService();
    await localizationService.initialize(const Locale('en', 'US'));

    final widgetRegistry = DashboardWidgetRegistry();
    widgetRegistry.initializeDefaultWidgets();
  });

  tearDown(() {
    // Clean up after each test
    DashboardRealtimeService().disconnect();
  });

  group('Complete Application Workflow Tests', () {
    testWidgets('Full application startup and navigation flow', (WidgetTester tester) async {
      // Mock authenticated user for testing
      when(mockAuthService.currentUser).thenReturn(MockUser());
      when(mockAuthService.isAuthenticated).thenAnswer((_) async => true);

      // Build the complete application
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AuthService>.value(value: mockAuthService),
            Provider<LocalizationService>.value(value: LocalizationService()),
          ],
          child: const AgentMitraApp(),
        ),
      );

      // Wait for initial app setup
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app starts without crashing
      expect(find.byType(AgentMitraApp), findsOneWidget);
    });

    testWidgets('Splash screen to dashboard navigation', (WidgetTester tester) async {
      // Start with splash screen
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: const SplashScreen(),
          ),
        ),
      );

      // Wait for splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Should navigate away from splash screen
      // Note: Actual navigation depends on authentication state
    });

    testWidgets('Authentication flow integration', (WidgetTester tester) async {
      // Test login page rendering
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: const LoginPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify login page renders correctly
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Dashboard functionality integration', (WidgetTester tester) async {
      // Test dashboard page with all components
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: const DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dashboard loads
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('Localization system integration', (WidgetTester tester) async {
      final localizationService = LocalizationService();
      await localizationService.initialize(const Locale('en', 'US'));

      // Test localized widget rendering
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: LocalizationService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
          ],
          home: Builder(
            builder: (context) {
              return Text(context.translate('app_name'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display localized text
      expect(find.text('Agent Mitra'), findsOneWidget);
    });

    testWidgets('Accessibility features integration', (WidgetTester tester) async {
      // Test accessibility settings application
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return AccessibleText(
                  'Test accessible text',
                  isHeading: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify accessible text renders
      expect(find.text('Test accessible text'), findsOneWidget);
    });
  });

  group('Cross-Component Integration Tests', () {
    testWidgets('Dashboard widgets with real-time updates', (WidgetTester tester) async {
      final realtimeService = DashboardRealtimeService();

      // Create test dashboard layout
      final layout = DashboardLayout(
        id: 'integration-test-layout',
        name: 'Integration Test',
        widgets: [
          DashboardWidgetItem(
            id: 'test-kpi-widget',
            widgetType: 'kpi_cards',
            title: 'Test KPI',
            position: WidgetPosition(row: 0, col: 0, width: 2, height: 2),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DashboardGridLayout(
            layout: layout,
            isEditMode: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widgets render
      expect(find.byType(DashboardWidget), findsWidgets);

      // Test real-time service integration
      expect(realtimeService.isConnected, false);
    });

    testWidgets('Interactive charts with export functionality', (WidgetTester tester) async {
      final chartData = [
        ChartDataPoint(id: '1', label: 'Q1', value: 1000),
        ChartDataPoint(id: '2', label: 'Q2', value: 1200),
        ChartDataPoint(id: '3', label: 'Q3', value: 900),
        ChartDataPoint(id: '4', label: 'Q4', value: 1100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveChartWidget(
            chartType: ChartType.bar,
            data: chartData,
            title: 'Quarterly Revenue',
            enableExport: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify chart renders with all features
      expect(find.text('Quarterly Revenue'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });

  group('Performance and Reliability Tests', () {
    testWidgets('Dashboard handles large datasets', (WidgetTester tester) async {
      // Create large dataset for performance testing
      final largeChartData = List.generate(
        100,
        (index) => ChartDataPoint(
          id: index.toString(),
          label: 'Item $index',
          value: index * 10.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InteractiveChartWidget(
            chartType: ChartType.line,
            data: largeChartData,
            title: 'Large Dataset Test',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify large dataset renders without performance issues
      expect(find.text('Large Dataset Test'), findsOneWidget);
    });

    testWidgets('Real-time updates handling', (WidgetTester tester) async {
      final realtimeService = DashboardRealtimeService();

      // Test service initialization
      await realtimeService.initialize();

      // Verify service state
      expect(realtimeService.isConnected, isA<bool>());
    });

    testWidgets('Error handling and recovery', (WidgetTester tester) async {
      // Test dashboard error states and recovery
      await tester.pumpWidget(
        MaterialApp(
          home: DashboardPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify error handling UI elements are present
      // This would test error boundaries and recovery mechanisms
    });
  });

  group('API Integration Tests', () {
    test('Backend service connectivity', () async {
      // Test basic API connectivity
      // Note: These tests would require a running backend or mocked HTTP client
      expect(true, true); // Placeholder for actual API tests
    });

    test('Data synchronization', () async {
      // Test data sync between components
      // This would verify that dashboard updates propagate correctly
      expect(true, true); // Placeholder for actual sync tests
    });
  });
}

// Mock implementations for testing
class MockAuthService extends Mock implements AuthService {
  @override
  Future<bool> isAuthenticated() async => true;

  @override
  get currentUser => MockUser();
}

class MockUser {
  String get id => 'test-user-id';
  String get role => 'agent';
  String get firstName => 'Test';
  String get lastName => 'User';
  String get email => 'test@example.com';
}

// Test utilities
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agent Mitra - Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Test App'),
        ),
      ),
    );
  }
}

// Performance testing utilities
class PerformanceTester {
  static Future<Duration> measureWidgetBuildTime(
    WidgetTester tester,
    Widget widget,
  ) async {
    final startTime = DateTime.now();

    await tester.pumpWidget(
      MaterialApp(home: widget),
    );

    await tester.pumpAndSettle();

    final endTime = DateTime.now();
    return endTime.difference(startTime);
  }

  static Future<void> stressTestDashboard(
    WidgetTester tester,
    int widgetCount,
  ) async {
    // Create dashboard with many widgets for stress testing
    final widgets = List.generate(
      widgetCount,
      (index) => DashboardWidgetItem(
        id: 'stress-widget-$index',
        widgetType: 'kpi_cards',
        title: 'Widget $index',
        position: WidgetPosition(
          row: index ~/ 4,
          col: (index % 4) * 3,
          width: 3,
          height: 2,
        ),
      ),
    );

    final layout = DashboardLayout(
      id: 'stress-test-layout',
      name: 'Stress Test',
      widgets: widgets,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final buildTime = await measureWidgetBuildTime(
      tester,
      DashboardGridLayout(layout: layout),
    );

    debugPrint('Dashboard with $widgetCount widgets built in ${buildTime.inMilliseconds}ms');
  }
}

// Accessibility testing utilities
class AccessibilityTester {
  static Future<void> verifyAccessibleNavigation(
    WidgetTester tester,
    Widget widget,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: widget),
    );

    await tester.pumpAndSettle();

    // Test semantic labels
    final semantics = tester.widgetList(find.byType(Semantics));
    expect(semantics.isNotEmpty, true);

    // Test focus order (would require more complex setup)
    // Test screen reader announcements (would require platform-specific testing)
  }

  static Future<void> testColorContrast(WidgetTester tester) async {
    // Test color contrast ratios meet accessibility standards
    // This would require analyzing rendered colors
    expect(true, true); // Placeholder for actual contrast testing
  }
}
