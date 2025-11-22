import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/analytics_models.dart';

class AnalyticsRemoteDataSource {
  /// Get policy trends chart data
  Future<List<ChartDataPoint>> getPolicyTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await ApiService.get(
      ApiConstants.dashboardCharts('policy-trends'),
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => ChartDataPoint.fromJson(json))
        .toList();
  }

  /// Get revenue trends chart data
  Future<List<ChartDataPoint>> getRevenueTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await ApiService.get(
      ApiConstants.dashboardCharts('revenue-trends'),
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => ChartDataPoint.fromJson(json))
        .toList();
  }

  /// Get agent performance data
  Future<AgentPerformance> getAgentPerformance(String agentId) async {
    final response = await ApiService.get(
      ApiConstants.agentPerformance(agentId),
    );

    return AgentPerformance.fromJson(response);
  }

  /// Get top agents report
  Future<TopAgentsReport> getTopAgents({
    int limit = 10,
    String period = 'monthly',
  }) async {
    final response = await ApiService.get(
      ApiConstants.dashboardAnalytics,
      queryParameters: {
        'limit': limit.toString(),
        'period': period,
      },
    );

    return TopAgentsReport.fromJson(response);
  }

  /// Generate analytics report
  Future<AnalyticsReport> generateReport({
    required String reportType,
    Map<String, dynamic>? parameters,
  }) async {
    final response = await ApiService.post(
      '${ApiConstants.analytics}/reports/generate',
      {
        'report_type': reportType,
        'parameters': parameters ?? {},
      },
    );

    return AnalyticsReport.fromJson(response);
  }

  /// Get revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await ApiService.get(
      ApiConstants.revenueAnalytics,
      queryParameters: queryParams,
    );

    return response;
  }
}
