import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../models/analytics_models.dart';

class AnalyticsRepository extends BaseRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepository({
    AnalyticsRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? AnalyticsRemoteDataSource();

  /// Get policy trends data
  Future<List<ChartDataPoint>> getPolicyTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getPolicyTrends(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch policy trends: $e');
    }
  }

  /// Get revenue trends data
  Future<List<ChartDataPoint>> getRevenueTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getRevenueTrends(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch revenue trends: $e');
    }
  }

  /// Get agent performance
  Future<AgentPerformance> getAgentPerformance(String agentId) async {
    try {
      return await _remoteDataSource.getAgentPerformance(agentId);
    } catch (e) {
      throw Exception('Failed to fetch agent performance: $e');
    }
  }

  /// Get top agents report
  Future<TopAgentsReport> getTopAgents({
    int limit = 10,
    String period = 'monthly',
  }) async {
    try {
      return await _remoteDataSource.getTopAgents(
        limit: limit,
        period: period,
      );
    } catch (e) {
      throw Exception('Failed to fetch top agents: $e');
    }
  }

  /// Generate analytics report
  Future<AnalyticsReport> generateReport({
    required String reportType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      return await _remoteDataSource.generateReport(
        reportType: reportType,
        parameters: parameters,
      );
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  /// Get revenue analytics
  Future<Map<String, dynamic>> getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _remoteDataSource.getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to fetch revenue analytics: $e');
    }
  }
}
