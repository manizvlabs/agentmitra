/// Customer Dashboard Repository
import 'package:flutter/material.dart';
import '../models/customer_dashboard_data.dart';
import '../../../../core/services/logger_service.dart';

class CustomerDashboardRepository {
  final LoggerService _logger;

  CustomerDashboardRepository({
    LoggerService? logger,
  }) : _logger = logger ?? LoggerService();

  /// Get customer dashboard data
  Future<CustomerDashboardData> getCustomerDashboardData(String customerId) async {
    try {
      // TODO: Replace with actual API call
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 500));

      return CustomerDashboardData(
        customerName: 'Amit',
        activePolicies: 3,
        maturingPolicies: 1,
        lapsedPolicies: 0,
        totalCoverage: 1500000.0,
        nextPaymentAmount: 25000.0,
        nextPaymentDate: DateTime.now().add(const Duration(days: 3)),
        policyOverviews: [
          const PolicyOverview(
            status: 'active',
            count: 3,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const PolicyOverview(
            status: 'maturing',
            count: 1,
            color: Colors.orange,
            icon: Icons.schedule,
          ),
          const PolicyOverview(
            status: 'lapsed',
            count: 0,
            color: Colors.red,
            icon: Icons.warning,
          ),
        ],
        criticalNotifications: [
          CriticalNotification(
            id: '1',
            title: 'Premium due in 3 days',
            message: 'Your premium payment of ₹25,000 is due on ${DateTime.now().add(const Duration(days: 3)).day}/${DateTime.now().month}/${DateTime.now().year}',
            type: 'warning',
            timestamp: DateTime.now(),
            actionText: 'Pay Now',
            actionRoute: '/premium-payment',
          ),
          CriticalNotification(
            id: '2',
            title: 'Policy renewal reminder',
            message: 'Your policy renewal is coming up next month',
            type: 'info',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            actionText: 'View Details',
            actionRoute: '/policies',
          ),
        ],
        quickInsights: [
          const QuickInsight(
            id: '1',
            title: 'Total Coverage',
            value: '₹15,00,000',
            change: '+5%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          const QuickInsight(
            id: '2',
            title: 'Claims This Year',
            value: '2',
            change: null,
            icon: Icons.assignment,
            color: Colors.blue,
          ),
        ],
        unreadNotificationsCount: 3,
      );
    } catch (e) {
      _logger.error('Failed to load customer dashboard data: $e');
      return CustomerDashboardData.empty();
    }
  }
}

