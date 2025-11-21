import 'package:flutter/material.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/dashboard_data.dart';

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
