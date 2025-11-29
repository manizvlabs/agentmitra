import 'package:flutter/foundation.dart';
import '../../shared/constants/api_constants.dart';
import 'api_service.dart';
import '../models/dashboard_models.dart';

/// Dashboard Service - Handles dashboard data fetching from backend APIs
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final ApiService _apiService = ApiService();

  /// Fetch system overview data for Super Admin dashboard
  Future<SystemOverviewData> getSystemOverview() async {
    try {
      final data = await ApiService.get('/dashboard/system-overview');
      return SystemOverviewData.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching system overview: $e');
      // Return default/empty data instead of throwing
      return SystemOverviewData.empty();
    }
  }

  /// Fetch provider overview data for Provider Admin dashboard
  Future<ProviderOverviewData> getProviderOverview() async {
    try {
      final data = await ApiService.get('/dashboard/provider-overview');
      return ProviderOverviewData.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching provider overview: $e');
      return ProviderOverviewData.empty();
    }
  }

  /// Fetch regional overview data for Regional Manager dashboard
  Future<RegionalOverviewData> getRegionalOverview(String region) async {
    try {
      final data = await ApiService.get('/dashboard/regional-overview?region=$region');
      return RegionalOverviewData.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching regional overview: $e');
      return RegionalOverviewData.empty();
    }
  }

  /// Fetch senior agent overview data for Senior Agent dashboard
  Future<SeniorAgentOverviewData> getSeniorAgentOverview() async {
    try {
      final data = await ApiService.get('/dashboard/senior-agent-overview');
      return SeniorAgentOverviewData.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching senior agent overview: $e');
      return SeniorAgentOverviewData.empty();
    }
  }
}
