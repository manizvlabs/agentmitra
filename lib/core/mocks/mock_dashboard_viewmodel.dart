import 'package:flutter/material.dart';
import '../../features/dashboard/data/models/dashboard_data.dart';

/// Mock DashboardViewModel for web compatibility
class MockDashboardViewModel extends ChangeNotifier {
  DashboardAnalytics? _analytics;
  final List<DashboardNotification> _notifications = [];
  bool _isRefreshing = false;

  DashboardAnalytics? get analytics => _analytics ?? const DashboardAnalytics(
    totalPolicies: 42,
    totalPremium: 2500000.0,
    activeClaims: 5,
    monthlyRevenue: 125000.0,
    newCustomers: 8,
    growthRate: 12.5,
    recentPolicies: [],
    upcomingPayments: [],
    recentClaims: [],
  );

  AgentPerformanceData? get agentPerformance => const AgentPerformanceData(
    agentId: 'agent_123',
    agentName: 'John Doe',
    totalCommission: 45000.0,
    policiesSold: 42,
    customersAcquired: 38,
    conversionRate: 85.0,
    averagePolicyValue: 1250.0,
    monthlyData: [],
    commissionByProduct: {},
  );

  BusinessIntelligenceData? get businessIntelligence => const BusinessIntelligenceData(
    revenueTrends: [],
    customerEngagement: [],
    roiMetrics: ROIMetrics(
      marketingROI: 285.0,
      customerAcquisitionCost: 450.0,
      lifetimeValue: 2500.0,
      churnRate: 5.2,
      retentionRate: 94.8,
    ),
    productPerformance: {},
    geographicDistribution: [],
  );

  List<DashboardQuickAction> get quickActions => [
    const DashboardQuickAction(
      id: 'new_policy',
      title: 'New Policy',
      subtitle: 'Create a new insurance policy',
      icon: Icons.add_circle,
      route: '/new-policy',
    ),
    const DashboardQuickAction(
      id: 'view_claims',
      title: 'View Claims',
      subtitle: 'Check pending claims status',
      icon: Icons.assignment,
      route: '/claims',
    ),
    const DashboardQuickAction(
      id: 'customer_support',
      title: 'Customer Support',
      subtitle: 'Contact support team',
      icon: Icons.support_agent,
      route: '/support',
    ),
  ];

  List<Map<String, dynamic>> getTopPriorities() {
    return [
      {
        'type': 'overdue_payments',
        'title': '2 Overdue Payments',
        'message': 'Action required on overdue premium payments',
        'priority': 'high',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'type': 'expiring_policies',
        'title': '3 Policies Expiring Soon',
        'message': 'Renew policies before they expire',
        'priority': 'medium',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
    ];
  }

  Future<void> markAllNotificationsAsRead() async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
  }
  List<DashboardNotification> get notifications => _notifications;
  bool get isRefreshing => _isRefreshing;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Map<String, dynamic> getAnalyticsSummary() {
    return {
      'total_policies': 42,
      'monthly_revenue': 125000.0,
      'growth_rate': 12.5,
    };
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  Future<void> loadAgentPerformanceData() async {
    // Mock implementation
  }

  Future<void> loadBusinessIntelligenceData() async {
    // Mock implementation
  }

  Future<void> refreshDashboard() async {
    _isRefreshing = true;
    notifyListeners();

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    // Mock initialization
    await Future.delayed(const Duration(milliseconds: 500));
  }
}


class DashboardNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  DashboardNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });
}
