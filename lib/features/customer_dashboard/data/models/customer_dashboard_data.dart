/// Customer Dashboard data models
import 'package:flutter/material.dart';

/// Customer Dashboard Analytics
class CustomerDashboardData {
  final String customerName;
  final int activePolicies;
  final int maturingPolicies;
  final int lapsedPolicies;
  final double totalCoverage;
  final double nextPaymentAmount;
  final DateTime? nextPaymentDate;
  final List<PolicyOverview> policyOverviews;
  final List<CriticalNotification> criticalNotifications;
  final List<QuickInsight> quickInsights;
  final int unreadNotificationsCount;

  const CustomerDashboardData({
    required this.customerName,
    required this.activePolicies,
    required this.maturingPolicies,
    required this.lapsedPolicies,
    required this.totalCoverage,
    required this.nextPaymentAmount,
    this.nextPaymentDate,
    required this.policyOverviews,
    required this.criticalNotifications,
    required this.quickInsights,
    required this.unreadNotificationsCount,
  });

  factory CustomerDashboardData.empty() => const CustomerDashboardData(
        customerName: '',
        activePolicies: 0,
        maturingPolicies: 0,
        lapsedPolicies: 0,
        totalCoverage: 0.0,
        nextPaymentAmount: 0.0,
        policyOverviews: [],
        criticalNotifications: [],
        quickInsights: [],
        unreadNotificationsCount: 0,
      );
}

/// Policy Overview Card Data
class PolicyOverview {
  final String status; // 'active', 'maturing', 'lapsed'
  final int count;
  final Color color;
  final IconData icon;

  const PolicyOverview({
    required this.status,
    required this.count,
    required this.color,
    required this.icon,
  });
}

/// Critical Notification
class CriticalNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'warning', 'error', 'info'
  final DateTime timestamp;
  final String? actionText;
  final String? actionRoute;

  const CriticalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.actionText,
    this.actionRoute,
  });

  Color get typeColor {
    switch (type) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
      default:
        return Icons.info;
    }
  }
}

/// Quick Insight
class QuickInsight {
  final String id;
  final String title;
  final String value;
  final String? change;
  final IconData icon;
  final Color color;

  const QuickInsight({
    required this.id,
    required this.title,
    required this.value,
    this.change,
    required this.icon,
    required this.color,
  });
}

/// Quick Action
class CustomerQuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const CustomerQuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

