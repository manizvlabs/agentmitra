import 'package:flutter/foundation.dart';
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/models/analytics_models.dart';

class AnalyticsViewModel extends BaseViewModel {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsViewModel({
    AnalyticsRepository? analyticsRepository,
  }) : _analyticsRepository = analyticsRepository ?? AnalyticsRepository();

  // State
  List<ChartDataPoint> _policyTrends = [];
  List<ChartDataPoint> _revenueTrends = [];
  AgentPerformance? _agentPerformance;
  TopAgentsReport? _topAgentsReport;
  Map<String, dynamic> _revenueAnalytics = {};
  bool _isLoadingCharts = false;
  bool _isLoadingReports = false;

  // Getters
  List<ChartDataPoint> get policyTrends => _policyTrends;
  List<ChartDataPoint> get revenueTrends => _revenueTrends;
  AgentPerformance? get agentPerformance => _agentPerformance;
  TopAgentsReport? get topAgentsReport => _topAgentsReport;
  Map<String, dynamic> get revenueAnalytics => _revenueAnalytics;
  bool get isLoadingCharts => _isLoadingCharts;
  bool get isLoadingReports => _isLoadingReports;

  /// Load policy trends data
  Future<void> loadPolicyTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingCharts = true;
    notifyListeners();

    try {
      _policyTrends = await _analyticsRepository.getPolicyTrends(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      setError('Failed to load policy trends: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  /// Load revenue trends data
  Future<void> loadRevenueTrends({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingCharts = true;
    notifyListeners();

    try {
      _revenueTrends = await _analyticsRepository.getRevenueTrends(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      setError('Failed to load revenue trends: $e');
    } finally {
      _isLoadingCharts = false;
      notifyListeners();
    }
  }

  /// Load agent performance
  Future<void> loadAgentPerformance(String agentId) async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      _agentPerformance = await _analyticsRepository.getAgentPerformance(agentId);
    } catch (e) {
      setError('Failed to load agent performance: $e');
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  /// Load top agents report
  Future<void> loadTopAgents({
    int limit = 10,
    String period = 'monthly',
  }) async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      _topAgentsReport = await _analyticsRepository.getTopAgents(
        limit: limit,
        period: period,
      );
    } catch (e) {
      setError('Failed to load top agents report: $e');
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  /// Load revenue analytics
  Future<void> loadRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoadingReports = true;
    notifyListeners();

    try {
      _revenueAnalytics = await _analyticsRepository.getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      setError('Failed to load revenue analytics: $e');
    } finally {
      _isLoadingReports = false;
      notifyListeners();
    }
  }

  /// Generate analytics report
  Future<AnalyticsReport?> generateReport({
    required String reportType,
    Map<String, dynamic>? parameters,
  }) async {
    setLoading(true);
    clearError();

    try {
      final report = await _analyticsRepository.generateReport(
        reportType: reportType,
        parameters: parameters,
      );
      return report;
    } catch (e) {
      setError('Failed to generate report: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadPolicyTrends(),
      loadRevenueTrends(),
      loadRevenueAnalytics(),
    ]);
  }
}
