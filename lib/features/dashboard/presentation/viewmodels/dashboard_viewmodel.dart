import 'package:flutter/material.dart';
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../../../core/services/agent_service.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/models/dashboard_data.dart';

/// ViewModel for dashboard screen management
class DashboardViewModel extends BaseViewModel {
  final DashboardRepository _repository;

  DashboardViewModel({
    DashboardRepository? repository,
  })  : _repository = repository ?? DashboardRepository(DashboardRemoteDataSource());

  DashboardAnalytics? _analytics;
  List<DashboardNotification> _notifications = [];
  bool _isRefreshing = false;

  AgentPerformanceData? _agentPerformance;
  BusinessIntelligenceData? _businessIntelligence;
  Map<String, dynamic>? _roiData;
  Map<String, dynamic>? _forecastData;
  Map<String, dynamic>? _leadsData;
  Map<String, dynamic>? _riskCustomersData;

  DashboardAnalytics? get analytics => _analytics;
  List<DashboardNotification> get notifications => _notifications;
  bool get isRefreshing => _isRefreshing;

  AgentPerformanceData? get agentPerformance => _agentPerformance;
  BusinessIntelligenceData? get businessIntelligence => _businessIntelligence;
  Map<String, dynamic>? get roiData => _roiData;
  Map<String, dynamic>? get forecastData => _forecastData;
  Map<String, dynamic>? get leadsData => _leadsData;
  Map<String, dynamic>? get riskCustomersData => _riskCustomersData;

  // Computed properties
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  List<DashboardQuickAction> get quickActions => _repository.getQuickActions();

  List<PolicySummary> get expiringPolicies =>
      _analytics?.recentPolicies.where((policy) => policy.isExpiringSoon).toList() ?? [];

  List<PaymentDue> get overduePayments =>
      _analytics?.upcomingPayments.where((payment) => payment.isOverdue).toList() ?? [];

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadDashboardData();
  }

  /// Load dashboard data from real API
  Future<void> loadDashboardData() async {
    await executeAsync(
      () async {
        // TODO: Get agent ID from user session/current user context
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _analytics = await _repository.getDashboardAnalytics(agentId: agentId);
        _notifications = await _repository.getNotifications(userId: agentId);
        return true;
      },
      errorMessage: 'Failed to load dashboard data from server',
    );

    notifyListeners();
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    notifyListeners();

    try {
      await loadDashboardData();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Load agent performance data
  Future<void> loadAgentPerformanceData() async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _agentPerformance = await _repository.getAgentPerformanceData(agentId);
        return true;
      },
      errorMessage: 'Failed to load agent performance data',
    );
    notifyListeners();
  }

  /// Load ROI dashboard data
  Future<void> loadROIDashboardData(String timeframe) async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _roiData = await _repository.getROIDashboardData(
          agentId: agentId,
          timeframe: timeframe,
        );
        return true;
      },
      errorMessage: 'Failed to load ROI dashboard data',
    );
    notifyListeners();
  }

  /// Load revenue forecast data
  Future<void> loadRevenueForecastData(String period) async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _forecastData = await _repository.getRevenueForecastData(
          agentId: agentId,
          period: period,
        );
        return true;
      },
      errorMessage: 'Failed to load revenue forecast data',
    );
    notifyListeners();
  }

  /// Load hot leads data
  Future<void> loadHotLeadsData({
    String priority = 'all',
    String source = 'all'
  }) async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _leadsData = await _repository.getHotLeadsData(
          agentId: agentId,
          priority: priority,
          source: source,
        );
        return true;
      },
      errorMessage: 'Failed to load hot leads data',
    );
    notifyListeners();
  }

  /// Load at-risk customers data
  Future<void> loadAtRiskCustomersData({
    String riskLevel = 'all',
    String priority = 'all'
  }) async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _riskCustomersData = await _repository.getAtRiskCustomersData(
          agentId: agentId,
          riskLevel: riskLevel,
          priority: priority,
        );
        return true;
      },
      errorMessage: 'Failed to load at-risk customers data',
    );
    notifyListeners();
  }

  /// Load business intelligence data
  Future<void> loadBusinessIntelligenceData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await executeAsync(
      () async {
        final agentId = await AgentService().getCurrentAgentId();
        if (agentId == null) {
          throw Exception('Agent ID not available');
        }
        _businessIntelligence = await _repository.getBusinessIntelligenceData(
          agentId: agentId,
          startDate: startDate,
          endDate: endDate,
        );
        return true;
      },
      errorMessage: 'Failed to load business intelligence data',
    );
    notifyListeners();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final notificationIndex = _notifications.indexWhere((n) => n.id == notificationId);
    if (notificationIndex != -1) {
      final updatedNotification = _notifications[notificationIndex].copyWith(isRead: true);
      _notifications[notificationIndex] = updatedNotification;

      // Try to update on server (don't fail if offline)
      try {
        await _repository.markNotificationAsRead(notificationId);
      } catch (e) {
        // Ignore server errors for read status
      }

      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }

    // Try to update on server
    try {
      for (final notification in _notifications) {
        if (notification.isRead) {
          await _repository.markNotificationAsRead(notification.id);
        }
      }
    } catch (e) {
      // Ignore server errors for read status
    }

    notifyListeners();
  }

  /// Get analytics summary for display
  Map<String, dynamic> getAnalyticsSummary() {
    if (_analytics == null) return {};

    return {
      'total_policies': _analytics!.totalPolicies,
      'total_premium': _analytics!.totalPremium,
      'active_claims': _analytics!.activeClaims,
      'monthly_revenue': _analytics!.monthlyRevenue,
      'new_customers': _analytics!.newCustomers,
      'growth_rate': _analytics!.growthRate,
      'expiring_policies_count': expiringPolicies.length,
      'overdue_payments_count': overduePayments.length,
      'unread_notifications': unreadNotificationsCount,
    };
  }

  /// Get top priorities for dashboard alerts
  List<Map<String, dynamic>> getTopPriorities() {
    final priorities = <Map<String, dynamic>>[];

    // Overdue payments
    if (overduePayments.isNotEmpty) {
      priorities.add({
        'type': 'overdue_payments',
        'title': '${overduePayments.length} Overdue Payments',
        'message': 'Action required on overdue premium payments',
        'priority': 'high',
        'icon': Icons.warning,
        'color': Colors.red,
      });
    }

    // Expiring policies
    if (expiringPolicies.isNotEmpty) {
      priorities.add({
        'type': 'expiring_policies',
        'title': '${expiringPolicies.length} Policies Expiring Soon',
        'message': 'Renew policies before they expire',
        'priority': 'medium',
        'icon': Icons.schedule,
        'color': Colors.orange,
      });
    }

    // Active claims
    if ((_analytics?.activeClaims ?? 0) > 0) {
      priorities.add({
        'type': 'active_claims',
        'title': '${_analytics!.activeClaims} Active Claims',
        'message': 'Claims currently being processed',
        'priority': 'low',
        'icon': Icons.assignment,
        'color': Colors.blue,
      });
    }

    return priorities;
  }

  /// Format currency for display
  String formatCurrency(double amount) {
    if (amount >= 10000000) { // 1 crore
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) { // 1 lakh
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) { // 1 thousand
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  /// Format percentage for display
  String formatPercentage(double percentage) {
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(1)}%';
  }

  /// Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
