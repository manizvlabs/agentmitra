/// Customer Dashboard Repository
import 'package:flutter/material.dart';
import '../models/customer_dashboard_data.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';

class CustomerDashboardRepository {
  final LoggerService _logger;

  CustomerDashboardRepository({
    LoggerService? logger,
  }) : _logger = logger ?? LoggerService();

  /// Get customer dashboard data from backend API
  Future<CustomerDashboardData> getCustomerDashboardData(String customerId) async {
    try {
      // Fetch policies for the customer
      final policiesResponse = await ApiService.get(
        ApiConstants.policies,
        queryParameters: {
          'policyholder_id': customerId,
          'limit': '100',
          'offset': '0',
        },
      );

      final policies = (policiesResponse['policies'] as List<dynamic>?) ?? [];
      
      // Count policies by status
      int activePolicies = 0;
      int maturingPolicies = 0;
      int lapsedPolicies = 0;
      double totalCoverage = 0.0;
      double? nextPaymentAmount;
      DateTime? nextPaymentDate;

      for (var policy in policies) {
        final status = policy['status'] as String? ?? '';
        final sumAssured = (policy['sum_assured'] ?? 0.0) as num;
        final premiumAmount = (policy['premium_amount'] ?? 0.0) as num;
        final nextPayment = policy['next_payment_date'] as String?;

        totalCoverage += sumAssured.toDouble();

        if (status == 'active') {
          activePolicies++;
        } else if (status == 'maturing' || status == 'matured') {
          maturingPolicies++;
        } else if (status == 'lapsed' || status == 'cancelled') {
          lapsedPolicies++;
        }

        // Find the earliest next payment date
        if (nextPayment != null && status == 'active') {
          try {
            final paymentDate = DateTime.parse(nextPayment);
            if (nextPaymentDate == null || paymentDate.isBefore(nextPaymentDate!)) {
              nextPaymentDate = paymentDate;
              nextPaymentAmount = premiumAmount.toDouble();
            }
          } catch (e) {
            _logger.warning('Failed to parse next payment date: $e');
          }
        }
      }

      // Fetch user profile for customer name
      String customerName = 'Customer';
      try {
        final userResponse = await ApiService.get(ApiConstants.userProfile(customerId));
        customerName = userResponse['full_name'] ?? 
                      userResponse['name'] ?? 
                      userResponse['phone_number'] ?? 
                      'Customer';
      } catch (e) {
        _logger.warning('Failed to fetch user profile: $e');
      }

      // Fetch notifications
      int unreadNotificationsCount = 0;
      List<CriticalNotification> criticalNotifications = [];
      try {
        final notificationsResponse = await ApiService.get(
          '${ApiConstants.apiVersion}/notifications',
          queryParameters: {
            'user_id': customerId,
            'unread_only': 'true',
            'limit': '10',
          },
        );
        final notifications = (notificationsResponse['notifications'] as List<dynamic>?) ?? [];
        unreadNotificationsCount = notifications.length;

        // Filter critical notifications
        for (var notification in notifications) {
          final priority = notification['priority'] as String? ?? '';
          if (priority == 'high' || priority == 'critical') {
            criticalNotifications.add(
              CriticalNotification(
                id: notification['id']?.toString() ?? '',
                title: notification['title'] ?? 'Notification',
                message: notification['message'] ?? '',
                type: priority == 'critical' ? 'error' : 'warning',
                timestamp: notification['created_at'] != null
                    ? DateTime.parse(notification['created_at'])
                    : DateTime.now(),
                actionText: notification['action_text'] as String?,
                actionRoute: notification['action_route'] as String?,
              ),
            );
          }
        }
      } catch (e) {
        _logger.warning('Failed to fetch notifications: $e');
      }

      // Build policy overviews
      final policyOverviews = [
        PolicyOverview(
          status: 'active',
          count: activePolicies,
          color: Colors.green,
          icon: Icons.check_circle,
        ),
        PolicyOverview(
          status: 'maturing',
          count: maturingPolicies,
          color: Colors.orange,
          icon: Icons.schedule,
        ),
        PolicyOverview(
          status: 'lapsed',
          count: lapsedPolicies,
          color: Colors.red,
          icon: Icons.warning,
        ),
      ];

      // Build quick insights
      final quickInsights = <QuickInsight>[
        QuickInsight(
          id: '1',
          title: 'Total Coverage',
          value: _formatCurrency(totalCoverage),
          change: null,
          icon: Icons.trending_up,
          color: Colors.green,
        ),
      ];

      return CustomerDashboardData(
        customerName: customerName,
        activePolicies: activePolicies,
        maturingPolicies: maturingPolicies,
        lapsedPolicies: lapsedPolicies,
        totalCoverage: totalCoverage,
        nextPaymentAmount: nextPaymentAmount ?? 0.0,
        nextPaymentDate: nextPaymentDate,
        policyOverviews: policyOverviews,
        criticalNotifications: criticalNotifications,
        quickInsights: quickInsights,
        unreadNotificationsCount: unreadNotificationsCount,
      );
    } catch (e) {
      _logger.error('Failed to load customer dashboard data: $e');
      return CustomerDashboardData.empty();
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

