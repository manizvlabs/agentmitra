import 'package:flutter/material.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_data.dart';
import '../../../../core/services/api_service.dart';

/// Repository for dashboard data management
class DashboardRepository extends BaseRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepository(this._remoteDataSource);

  /// Get dashboard analytics
  Future<DashboardAnalytics> getDashboardAnalytics({
    required String agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _remoteDataSource.fetchDashboardAnalytics(
      agentId: agentId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get dashboard notifications
  Future<List<DashboardNotification>> getNotifications({
    required String userId,
    int limit = 10,
  }) async {
    return await _remoteDataSource.fetchNotifications(
      userId: userId,
      limit: limit,
    );
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _remoteDataSource.markNotificationAsRead(notificationId);
  }

  /// Refresh dashboard cache
  Future<void> refreshDashboardCache(String agentId) async {
    await _remoteDataSource.refreshDashboardCache(agentId);
  }

  /// Get agent performance data from analytics API
  Future<AgentPerformanceData> getAgentPerformanceData(String agentId) async {
    try {
      final response = await ApiService.get('/analytics/agents/$agentId/performance');
      return AgentPerformanceData(
        agentId: response['agent_id'] ?? agentId,
        agentName: response['agent_name'] ?? 'Agent',
        totalCommission: (response['total_premium_collected'] ?? 0.0).toDouble(),
        policiesSold: response['total_policies_sold'] ?? 0,
        customersAcquired: response['active_policyholders'] ?? 0,
        conversionRate: (response['conversion_rate'] ?? 0.0).toDouble() * 100,
        averagePolicyValue: (response['average_policy_value'] ?? 0.0).toDouble(),
        monthlyData: [], // TODO: Fetch from trends API
        commissionByProduct: {}, // TODO: Calculate from revenue analytics
      );
    } catch (e) {
      throw Exception('Failed to fetch agent performance data: $e');
    }
  }

  /// Get business intelligence data
  Future<BusinessIntelligenceData> getBusinessIntelligenceData({
    String? agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dateParams = <String, String>{};
      if (startDate != null) dateParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) dateParams['end_date'] = endDate.toIso8601String().split('T')[0];

      final queryString = dateParams.isNotEmpty
          ? '?${dateParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
          : '';

      final endpoint = agentId != null
          ? '/analytics/dashboard/$agentId$queryString'
          : '/analytics/dashboard/overview$queryString';

      final response = await ApiService.get(endpoint);

      // Fetch revenue trends
      final revenueQuery = agentId != null ? '?agent_id=$agentId' : '';
      final revenueTrendsResponse = await ApiService.get(
        '/analytics/dashboard/charts/revenue-trends$revenueQuery',
      );

      final revenueTrends = (revenueTrendsResponse as List<dynamic>).map((trend) {
        return RevenueTrend(
          date: DateTime.parse(trend['date']),
          revenue: (trend['value'] ?? 0.0).toDouble(),
          target: (trend['target'] ?? trend['value'] ?? 0.0).toDouble() * 1.1, // Mock target as 10% above actual
          growth: trend['growth'] != null ? (trend['growth'] as num).toDouble() : 0.0,
        );
      }).toList();

      // Mock customer engagement data - in real app, fetch from separate API
      final customerEngagement = [
        CustomerEngagement(
          metric: 'App Sessions',
          value: response['total_customers'] ?? 0,
          change: 8.2,
          period: 'vs last month',
        ),
        CustomerEngagement(
          metric: 'Policy Views',
          value: response['total_policies'] ?? 0,
          change: 12.5,
          period: 'vs last month',
        ),
        CustomerEngagement(
          metric: 'Support Queries',
          value: (response['active_customers'] ?? 0) ~/ 10, // Mock data
          change: -5.1,
          period: 'vs last month',
        ),
      ];

      return BusinessIntelligenceData(
        revenueTrends: revenueTrends,
        customerEngagement: customerEngagement,
        roiMetrics: ROIMetrics(
          marketingROI: 245.0,
          customerAcquisitionCost: (response['average_policy_value'] ?? 850.0).toDouble(),
          lifetimeValue: (response['average_policy_value'] ?? 850.0).toDouble() * 14.7,
          churnRate: 3.2,
          retentionRate: 96.8,
        ),
        productPerformance: {
          'Life Insurance': response['total_policies'] ?? 0,
          'Health Insurance': (response['total_policies'] ?? 0) ~/ 4,
          'Motor Insurance': (response['total_policies'] ?? 0) ~/ 6,
          'Investment Plans': (response['total_policies'] ?? 0) ~/ 8,
        },
        geographicDistribution: [], // TODO: Fetch from separate API
      );
    } catch (e) {
      throw Exception('Failed to fetch business intelligence data: $e');
    }
  }

  /// Get quick actions for dashboard
  List<DashboardQuickAction> getQuickActions() {
    return [
      const DashboardQuickAction(
        id: 'new_policy',
        title: 'New Policy',
        subtitle: 'Create insurance policy',
        icon: Icons.add_circle_outline,
        route: '/policy/create',
      ),
      const DashboardQuickAction(
        id: 'view_policies',
        title: 'My Policies',
        subtitle: 'View all policies',
        icon: Icons.policy_outlined,
        route: '/policies',
      ),
      const DashboardQuickAction(
        id: 'claims',
        title: 'File Claim',
        subtitle: 'Submit insurance claim',
        icon: Icons.assignment_outlined,
        route: '/claims/new',
      ),
      const DashboardQuickAction(
        id: 'payments',
        title: 'Payments',
        subtitle: 'View payment history',
        icon: Icons.payment_outlined,
        route: '/payments',
      ),
      const DashboardQuickAction(
        id: 'customers',
        title: 'Customers',
        subtitle: 'Manage customers',
        icon: Icons.people_outline,
        route: '/customers',
      ),
      const DashboardQuickAction(
        id: 'reports',
        title: 'Reports',
        subtitle: 'View analytics',
        icon: Icons.analytics_outlined,
        route: '/reports',
      ),
      const DashboardQuickAction(
        id: 'chatbot',
        title: 'AI Assistant',
        subtitle: 'Get instant help',
        icon: Icons.smart_toy_outlined,
        route: '/smart-chatbot',
      ),
    ];
  }
}
