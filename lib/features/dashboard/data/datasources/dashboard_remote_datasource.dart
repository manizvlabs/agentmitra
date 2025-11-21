import 'dart:convert';
import '../../../../core/services/api_service.dart';
import '../models/dashboard_data.dart';

/// Remote data source for dashboard analytics and data
class DashboardRemoteDataSource {
  final ApiService _apiService;

  DashboardRemoteDataSource(this._apiService);

  /// Fetch dashboard analytics
  Future<DashboardAnalytics> fetchDashboardAnalytics({
    required String agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '/api/v1/dashboard/analytics/$agentId',
        queryParameters: queryParams,
      );

      return DashboardAnalytics(
        totalPolicies: response['total_policies'] ?? 0,
        totalPremium: (response['total_premium'] ?? 0.0).toDouble(),
        activeClaims: response['active_claims'] ?? 0,
        monthlyRevenue: (response['monthly_revenue'] ?? 0.0).toDouble(),
        newCustomers: response['new_customers'] ?? 0,
        growthRate: (response['growth_rate'] ?? 0.0).toDouble(),
        recentPolicies: (response['recent_policies'] as List<dynamic>?)
            ?.map((policy) => PolicySummary(
              id: policy['id'],
              policyNumber: policy['policy_number'],
              customerName: policy['customer_name'],
              policyType: policy['policy_type'],
              premium: (policy['premium'] ?? 0.0).toDouble(),
              expiryDate: DateTime.parse(policy['expiry_date']),
              status: policy['status'] ?? 'active',
            ))
            .toList() ?? [],
        upcomingPayments: (response['upcoming_payments'] as List<dynamic>?)
            ?.map((payment) => PaymentDue(
              id: payment['id'],
              policyNumber: payment['policy_number'],
              customerName: payment['customer_name'],
              amount: (payment['amount'] ?? 0.0).toDouble(),
              dueDate: DateTime.parse(payment['due_date']),
              paymentMethod: payment['payment_method'] ?? 'online',
            ))
            .toList() ?? [],
        recentClaims: (response['recent_claims'] as List<dynamic>?)
            ?.map((claim) => ClaimUpdate(
              id: claim['id'],
              claimNumber: claim['claim_number'],
              customerName: claim['customer_name'],
              policyType: claim['policy_type'],
              claimAmount: (claim['claim_amount'] ?? 0.0).toDouble(),
              submittedDate: DateTime.parse(claim['submitted_date']),
              status: claim['status'] ?? 'pending',
              statusDescription: claim['status_description'],
            ))
            .toList() ?? [],
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard analytics: $e');
    }
  }

  /// Fetch dashboard notifications
  Future<List<DashboardNotification>> fetchNotifications({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/v1/dashboard/notifications/$userId',
        queryParameters: {'limit': limit.toString()},
      );

      return (response as List<dynamic>).map((notification) => DashboardNotification(
        id: notification['id'],
        title: notification['title'],
        message: notification['message'],
        timestamp: DateTime.parse(notification['timestamp']),
        type: notification['type'] ?? 'info',
        isRead: notification['is_read'] ?? false,
        actionText: notification['action_text'],
        actionRoute: notification['action_route'],
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.put(
        '/api/v1/dashboard/notifications/$notificationId/read',
        data: {},
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Refresh dashboard cache
  Future<void> refreshDashboardCache(String agentId) async {
    try {
      await _apiService.post(
        '/api/v1/dashboard/cache/refresh/$agentId',
        data: {},
      );
    } catch (e) {
      throw Exception('Failed to refresh dashboard cache: $e');
    }
  }
}
