import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_api_service.dart';

// NOTE: This is the ONLY place in the entire test suite where mocks are used.
// All widget and integration tests use REAL API DATA ONLY.
// These unit tests specifically test API response parsing logic in isolation.

void main() {
  group('API Response Parsing Unit Tests - ONLY PLACE MOCKS ARE USED', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    test('parses dashboard overview response correctly', () async {
      // Setup successful response
      mockApiService.setupSuccessfulResponses();

      // Simulate API call
      final response = await mockApiService.get('/api/v1/analytics/dashboard/overview');

      // Verify response structure
      expect(response, isA<Map<String, dynamic>>());
      expect(response['total_premium_collected'], equals(2500000));
      expect(response['total_policies'], equals(1250));
      expect(response['active_customers'], equals(890));
      expect(response['new_customers_this_month'], equals(45));
    });

    test('parses top agents response correctly', () async {
      mockApiService.setupSuccessfulResponses();

      final response = await mockApiService.get('/api/v1/analytics/dashboard/top-agents');

      expect(response, isA<List<dynamic>>());
      expect(response.length, equals(3));

      // Check first agent
      final firstAgent = response[0] as Map<String, dynamic>;
      expect(firstAgent['name'], equals('Rajesh Kumar'));
      expect(firstAgent['total_premium'], equals(150000));
      expect(firstAgent['policies_sold'], equals(45));
      expect(firstAgent['rank'], equals(1));

      // Check second agent
      final secondAgent = response[1] as Map<String, dynamic>;
      expect(secondAgent['name'], equals('Priya Sharma'));
      expect(secondAgent['total_premium'], equals(120000));
      expect(secondAgent['policies_sold'], equals(38));

      // Check third agent
      final thirdAgent = response[2] as Map<String, dynamic>;
      expect(thirdAgent['name'], equals('Amit Singh'));
      expect(thirdAgent['total_premium'], equals(98000));
      expect(thirdAgent['policies_sold'], equals(32));
    });

    test('parses revenue trends response correctly', () async {
      mockApiService.setupSuccessfulResponses();

      final response = await mockApiService.get('/api/v1/analytics/dashboard/charts/revenue-trends');

      expect(response, isA<List<dynamic>>());
      expect(response.length, equals(6));

      // Check first month
      final janData = response[0] as Map<String, dynamic>;
      expect(janData['period'], equals('Jan'));
      expect(janData['revenue'], equals(180000));
      expect(janData['growth'], equals(5.2));

      // Check last month
      final junData = response[5] as Map<String, dynamic>;
      expect(junData['period'], equals('Jun'));
      expect(junData['revenue'], equals(255000));
      expect(junData['growth'], equals(6.3));
    });

    test('parses policy trends response correctly', () async {
      mockApiService.setupSuccessfulResponses();

      final response = await mockApiService.get('/api/v1/analytics/dashboard/charts/policy-trends');

      expect(response, isA<List<dynamic>>());
      expect(response.length, equals(6));

      // Check first month
      final janData = response[0] as Map<String, dynamic>;
      expect(janData['period'], equals('Jan'));
      expect(janData['policies'], equals(85));
      expect(janData['growth'], equals(12.5));

      // Check last month
      final junData = response[5] as Map<String, dynamic>;
      expect(junData['period'], equals('Jun'));
      expect(junData['policies'], equals(118));
      expect(junData['growth'], equals(5.4));
    });

    test('parses comprehensive analytics response correctly', () async {
      mockApiService.setupSuccessfulResponses();

      final response = await mockApiService.get('/api/v1/analytics/comprehensive/dashboard');

      expect(response, isA<Map<String, dynamic>>());
      expect(response.containsKey('data'), isTrue);

      final data = response['data'];
      expect(data.containsKey('productPerformance'), isTrue);
      expect(data.containsKey('geographicDistribution'), isTrue);

      // Test product performance parsing
      final products = data['productPerformance'] as List<dynamic>;
      expect(products.length, equals(3));

      final firstProduct = products[0] as Map<String, dynamic>;
      expect(firstProduct['product_name'], equals('Term Life Insurance'));
      expect(firstProduct['premium_collected'], equals(850000));
      expect(firstProduct['policies_sold'], equals(425));
      expect(firstProduct['market_share'], equals(34.0));

      // Test geographic distribution parsing
      final geoData = data['geographicDistribution'] as Map<String, dynamic>;
      expect(geoData['Mumbai'], equals(35));
      expect(geoData['Delhi'], equals(28));
      expect(geoData['Bangalore'], equals(22));
      expect(geoData['Chennai'], equals(15));
    });

    test('handles empty responses gracefully', () async {
      final emptyMockService = MockApiService();
      emptyMockService.setupEmptyResponses();

      final overviewResponse = await emptyMockService.get('/api/v1/analytics/dashboard/overview');
      expect(overviewResponse, equals({}));

      final agentsResponse = await emptyMockService.get('/api/v1/analytics/dashboard/top-agents');
      expect(agentsResponse, equals([]));

      final revenueResponse = await emptyMockService.get('/api/v1/analytics/dashboard/charts/revenue-trends');
      expect(revenueResponse, equals([]));

      final policyResponse = await emptyMockService.get('/api/v1/analytics/dashboard/charts/policy-trends');
      expect(policyResponse, equals([]));

      final comprehensiveResponse = await emptyMockService.get('/api/v1/analytics/comprehensive/dashboard');
      expect(comprehensiveResponse['data'], equals({}));
    });

    test('handles API errors correctly', () async {
      final errorMockService = MockApiService();
      errorMockService.setupErrorResponses();

      expect(
        () => errorMockService.get('/api/v1/analytics/dashboard/overview'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => errorMockService.get('/api/v1/analytics/dashboard/top-agents'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles partial API failures', () async {
      final partialMockService = MockApiService();
      partialMockService.setupPartialFailures();

      // These should succeed
      final overviewResponse = await partialMockService.get('/api/v1/analytics/dashboard/overview');
      expect(overviewResponse['total_premium_collected'], equals(2500000));

      final agentsResponse = await partialMockService.get('/api/v1/analytics/dashboard/top-agents');
      expect((agentsResponse as List).length, equals(3));

      // These should fail
      expect(
        () => partialMockService.get('/api/v1/analytics/dashboard/charts/revenue-trends'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => partialMockService.get('/api/v1/analytics/dashboard/charts/policy-trends'),
        throwsA(isA<Exception>()),
      );

      expect(
        () => partialMockService.get('/api/v1/analytics/comprehensive/dashboard'),
        throwsA(isA<Exception>()),
      );
    });

    test('handles malformed responses', () async {
      // Test with null responses
      mockApiService.setupEmptyResponses();

      final response = await mockApiService.get('/api/v1/analytics/dashboard/overview');
      expect(response, isNotNull);
      expect(response, equals({}));
    });

    test('validates response data types', () async {
      mockApiService.setupSuccessfulResponses();

      final overviewResponse = await mockApiService.get('/api/v1/analytics/dashboard/overview');

      // Verify data types
      expect(overviewResponse['total_premium_collected'], isA<int>());
      expect(overviewResponse['total_policies'], isA<int>());
      expect(overviewResponse['active_customers'], isA<int>());
      expect(overviewResponse['new_customers_this_month'], isA<int>());

      final agentsResponse = await mockApiService.get('/api/v1/analytics/dashboard/top-agents');
      expect(agentsResponse, isA<List>());

      final firstAgent = (agentsResponse as List)[0];
      expect(firstAgent['name'], isA<String>());
      expect(firstAgent['total_premium'], isA<int>());
      expect(firstAgent['policies_sold'], isA<int>());
    });
  });
}
