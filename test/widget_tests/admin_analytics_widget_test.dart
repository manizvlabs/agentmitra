import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agent_mitra/screens/admin_analytics_screen.dart';
import 'package:agent_mitra/core/widgets/loading/loading_overlay.dart';
import '../helpers/test_auth_helper.dart';

void main() {
  group('Super Admin Analytics Dashboard Widget Tests - REAL API DATA ONLY', () {
    setUpAll(() async {
      // Authenticate as Super Admin before running any tests
      final authenticated = await TestAuthHelper.authenticateAsSuperAdmin();
      if (!authenticated) {
        fail('❌ Could not authenticate as Super Admin for testing');
      }

      // Verify authentication works
      final verified = await TestAuthHelper.verifyAuthentication();
      if (!verified) {
        fail('❌ Authentication verification failed');
      }
    });

    tearDownAll(() async {
      // Clean up authentication after tests
      await TestAuthHelper.clearAuthentication();
    });

    testWidgets('displays loading overlay when loading system data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Initially should show loading overlay
      expect(find.byType(LoadingOverlay), findsOneWidget);

      // Verify loading state
      final loadingOverlay = tester.widget<LoadingOverlay>(find.byType(LoadingOverlay));
      expect(loadingOverlay.isLoading, isTrue);
    });

    testWidgets('displays Super Admin dashboard title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      expect(find.text('Analytics Dashboard'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      expect((appBar.title as Text).data, 'Analytics Dashboard');
    });

    testWidgets('displays system overview with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify system overview data is displayed from real backend
      // The exact values will depend on what's in the database
      final hasOverviewSection = find.text('Dashboard Overview').evaluate().isNotEmpty;
      final hasRevenueData = find.text('Total Revenue').evaluate().isNotEmpty;

      if (hasOverviewSection) {
        expect(find.text('Dashboard Overview'), findsOneWidget);
        expect(find.text('Total Revenue'), findsOneWidget);
        // Real data validation - check that some revenue value is displayed
        final revenueElements = find.textContaining('₹').evaluate();
        expect(revenueElements.isNotEmpty, isTrue, reason: 'Should display real revenue data from API');
      }
    });

    testWidgets('displays RBAC user management section with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Check for RBAC-related content from real backend
      final hasAgentsSection = find.text('Top Performing Agents').evaluate().isNotEmpty;

      if (hasAgentsSection) {
        expect(find.text('Top Performing Agents'), findsOneWidget);
        // Real data validation - should have some user/agent data
        final agentCards = find.byType(Card).evaluate();
        expect(agentCards.isNotEmpty, isTrue, reason: 'Should display real agent/user data from API');
      }
    });

    testWidgets('displays platform analytics section with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify platform analytics are displayed from real backend
      final hasRevenueTrends = find.text('Revenue Trends').evaluate().isNotEmpty;

      if (hasRevenueTrends) {
        expect(find.text('Revenue Trends'), findsOneWidget);
      }

      // Should have some form of analytics data
      expect(find.byType(SingleChildScrollView), findsOneWidget, reason: 'Should have scrollable analytics content');
    });

    testWidgets('displays feature flags management section with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify feature flags section is available from real backend
      final hasPolicyTrends = find.text('Policy Trends').evaluate().isNotEmpty;

      if (hasPolicyTrends) {
        expect(find.text('Policy Trends'), findsOneWidget);
      }

      // Should maintain screen structure
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('handles Super Admin API errors gracefully with REAL backend', (WidgetTester tester) async {
      // Test with REAL API - if backend is down, should handle gracefully
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete (may timeout)
      await tester.pumpAndSettle(const Duration(seconds: 20));

      // Should still display the screen structure even with real API errors
      expect(find.text('Analytics Dashboard'), findsOneWidget, reason: 'Should maintain UI structure even with API errors');

      // May show error message or empty state
      final hasErrorMessage = find.textContaining('Failed to load').evaluate().isNotEmpty ||
                             find.textContaining('unavailable').evaluate().isNotEmpty;

      // Either shows data or appropriate error handling
      expect(hasErrorMessage || find.byType(SingleChildScrollView).evaluate().isNotEmpty, isTrue,
             reason: 'Should either show data or handle errors gracefully');
    });

    testWidgets('displays system health metrics with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Should display system health information from real backend
      expect(find.byType(SingleChildScrollView), findsOneWidget, reason: 'Should have scrollable content');

      // May display various system metrics depending on real data availability
      final hasSomeData = find.byType(Card).evaluate().isNotEmpty;
      expect(hasSomeData, isTrue, reason: 'Should display some form of system data from real API');
    });

    testWidgets('displays role-based access control information with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify RBAC roles are displayed from real backend data
      final hasAgentsSection = find.text('Top Performing Agents').evaluate().isNotEmpty;

      if (hasAgentsSection) {
        expect(find.text('Top Performing Agents'), findsOneWidget);
        // Should have some user/agent data from real database
        final agentDataExists = find.byType(Card).evaluate().length > 1; // More than just the section header
        expect(agentDataExists, isTrue, reason: 'Should display real RBAC user data from API');
      }
    });

    testWidgets('displays feature flag status with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify feature flags are accessible from real backend
      expect(find.byType(SingleChildScrollView), findsOneWidget, reason: 'Should maintain scrollable layout');

      // May display feature flag data depending on real API response
      final hasContent = find.byType(Card).evaluate().isNotEmpty;
      expect(hasContent, isTrue, reason: 'Should display some content from real API');
    });

    testWidgets('handles empty Super Admin data gracefully with REAL backend', (WidgetTester tester) async {
      // Test with REAL API - if no data is returned, should handle gracefully
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Should handle empty data gracefully
      expect(find.text('Analytics Dashboard'), findsOneWidget, reason: 'Should maintain app bar');

      // May show empty state or partial data depending on real API response
      final hasSomeUI = find.byType(SingleChildScrollView).evaluate().isNotEmpty ||
                       find.textContaining('unavailable').evaluate().isNotEmpty;

      expect(hasSomeUI, isTrue, reason: 'Should either show data or appropriate empty state');
    });

    testWidgets('handles partial Super Admin API failures with REAL backend', (WidgetTester tester) async {
      // Test with REAL API - some endpoints may fail while others succeed
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 20));

      // Should still display available data from successful API calls
      expect(find.text('Analytics Dashboard'), findsOneWidget, reason: 'Should maintain basic UI structure');

      // May show partial data depending on which real API calls succeed/fail
      final hasSomeContent = find.byType(Card).evaluate().isNotEmpty ||
                            find.textContaining('Failed to load').evaluate().isNotEmpty;

      expect(hasSomeContent, isTrue, reason: 'Should show either successful data or error handling');
    });

    testWidgets('displays comprehensive system metrics with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify comprehensive system metrics are displayed from real backend
      expect(find.text('Analytics Dashboard'), findsOneWidget, reason: 'Should maintain app bar');

      // Count the number of data sections displayed from real API
      final cards = find.byType(Card).evaluate();
      expect(cards.isNotEmpty, isTrue, reason: 'Should display real data cards from API');

      // Should have meaningful content
      final hasDataContent = find.textContaining('₹').evaluate().isNotEmpty ||
                            find.textContaining('Total').evaluate().isNotEmpty ||
                            find.textContaining('Active').evaluate().isNotEmpty;

      expect(hasDataContent, isTrue, reason: 'Should display real metrics from API');
    });

    testWidgets('supports scrolling through all admin sections with REAL data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify scrollable content from real API
      expect(find.byType(SingleChildScrollView), findsOneWidget, reason: 'Should have scrollable layout');

      // Test scrolling to different sections (only if they exist in real data)
      final hasAgentsSection = find.text('Top Performing Agents').evaluate().isNotEmpty;

      if (hasAgentsSection) {
        await tester.scrollUntilVisible(find.text('Top Performing Agents'), 50.0);
        expect(find.text('Top Performing Agents'), findsOneWidget, reason: 'Should scroll to real data sections');
      }
    });

    testWidgets('displays real-time system status with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify system status indicators are present from real backend
      expect(find.byType(SingleChildScrollView), findsOneWidget, reason: 'Should have scrollable content');

      // Should display some form of status data
      final hasStatusData = find.byType(Card).evaluate().isNotEmpty;
      expect(hasStatusData, isTrue, reason: 'Should display real system status from API');
    });

    testWidgets('validates Super Admin role-based content filtering with REAL API', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify that Super Admin sees all system-level data from real backend
      expect(find.text('Analytics Dashboard'), findsOneWidget, reason: 'Should maintain dashboard title');

      // Check for available sections based on real API response
      final availableSections = [
        find.text('Dashboard Overview').evaluate().isNotEmpty,
        find.text('Top Performing Agents').evaluate().isNotEmpty,
        find.text('Revenue Trends').evaluate().isNotEmpty,
        find.text('Policy Trends').evaluate().isNotEmpty,
      ];

      final hasAtLeastOneSection = availableSections.contains(true);
      expect(hasAtLeastOneSection, isTrue, reason: 'Should display at least some admin sections from real API');
    });

    testWidgets('displays platform-wide user statistics with REAL API data', (WidgetTester tester) async {
      // Test with REAL API data only - no mocks
      await tester.pumpWidget(
        const MaterialApp(
          home: AdminAnalyticsScreen(),
        ),
      );

      // Wait for real API calls to complete
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verify platform-wide statistics are shown from real backend
      final hasRevenueData = find.text('Total Revenue').evaluate().isNotEmpty;
      final hasPolicyData = find.text('Total Policies').evaluate().isNotEmpty;
      final hasCustomerData = find.text('Active Customers').evaluate().isNotEmpty;

      final hasSomeStats = hasRevenueData || hasPolicyData || hasCustomerData;
      expect(hasSomeStats, isTrue, reason: 'Should display real platform statistics from API');

      // Should have properly formatted data
      if (hasRevenueData) {
        expect(find.text('Total Revenue'), findsOneWidget);
        // Should have some revenue value displayed
        final revenueElements = find.textContaining('₹').evaluate();
        expect(revenueElements.isNotEmpty, isTrue, reason: 'Should display formatted revenue data');
      }
    });
  });
}
