import '../../../../core/services/api_service.dart';
import '../models/dashboard_data.dart';

/// Remote data source for dashboard analytics and data
class DashboardRemoteDataSource {

  /// Fetch dashboard analytics
  Future<DashboardAnalytics> fetchDashboardAnalytics({
    required String agentId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await ApiService.get('/api/v1/dashboard/analytics');

      return DashboardAnalytics(
        totalPolicies: response['policiesCount'] ?? 0,
        totalPremium: (response['totalPremium'] ?? 0.0).toDouble(),
        activeClaims: response['claimsCount'] ?? 0,
        monthlyRevenue: (response['totalPremium'] ?? 0.0).toDouble(),
        newCustomers: 0, // Not available in current API
        growthRate: 0.0, // Not available in current API
        recentPolicies: (response['recentPolicies'] as List<dynamic>?)
            ?.map((policy) => PolicySummary(
              id: policy['id'],
              policyNumber: policy['policyNumber'],
              customerName: 'Customer', // Not available in current API
              policyType: 'Policy', // Not available in current API
              premium: (policy['premium'] ?? 0.0).toDouble(),
              expiryDate: DateTime.now().add(const Duration(days: 365)), // Default
              status: 'active',
            ))
            .toList() ?? [],
        upcomingPayments: [], // Not available in current API
        recentClaims: (response['recentClaims'] as List<dynamic>?)
            ?.map((claim) => ClaimUpdate(
              id: claim['id'],
              claimNumber: 'CLM${claim['id']}',
              customerName: 'Customer', // Not available in current API
              policyType: 'Policy', // Not available in current API
              claimAmount: (claim['amount'] ?? 0.0).toDouble(),
              submittedDate: DateTime.now().subtract(const Duration(days: 7)), // Default
              status: claim['status'] ?? 'pending',
              statusDescription: 'Claim ${claim['status']}',
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
      final response = await ApiService.get(
        '/api/v1/notifications/',
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
      await ApiService.put(
        '/api/v1/notifications/$notificationId/read',
        {},
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Refresh dashboard cache
  Future<void> refreshDashboardCache(String agentId) async {
    try {
      await ApiService.post(
        '/api/v1/dashboard/cache/refresh/$agentId',
        {},
      );
    } catch (e) {
      throw Exception('Failed to refresh dashboard cache: $e');
    }
  }
}
