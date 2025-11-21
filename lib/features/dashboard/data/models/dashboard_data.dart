/// Dashboard data models for analytics and widgets

class DashboardAnalytics {
  final int totalPolicies;
  final double totalPremium;
  final int activeClaims;
  final double monthlyRevenue;
  final int newCustomers;
  final double growthRate;
  final List<PolicySummary> recentPolicies;
  final List<PaymentDue> upcomingPayments;
  final List<ClaimUpdate> recentClaims;

  const DashboardAnalytics({
    required this.totalPolicies,
    required this.totalPremium,
    required this.activeClaims,
    required this.monthlyRevenue,
    required this.newCustomers,
    required this.growthRate,
    required this.recentPolicies,
    required this.upcomingPayments,
    required this.recentClaims,
  });

  factory DashboardAnalytics.empty() => const DashboardAnalytics(
    totalPolicies: 0,
    totalPremium: 0.0,
    activeClaims: 0,
    monthlyRevenue: 0.0,
    newCustomers: 0,
    growthRate: 0.0,
    recentPolicies: [],
    upcomingPayments: [],
    recentClaims: [],
  );
}

class PolicySummary {
  final String id;
  final String policyNumber;
  final String customerName;
  final String policyType;
  final double premium;
  final DateTime expiryDate;
  final String status; // 'active', 'expired', 'cancelled'

  const PolicySummary({
    required this.id,
    required this.policyNumber,
    required this.customerName,
    required this.policyType,
    required this.premium,
    required this.expiryDate,
    required this.status,
  });

  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30;
  bool get isExpired => expiryDate.isBefore(DateTime.now());
}

class PaymentDue {
  final String id;
  final String policyNumber;
  final String customerName;
  final double amount;
  final DateTime dueDate;
  final String paymentMethod;

  const PaymentDue({
    required this.id,
    required this.policyNumber,
    required this.customerName,
    required this.amount,
    required this.dueDate,
    required this.paymentMethod,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now());
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class ClaimUpdate {
  final String id;
  final String claimNumber;
  final String customerName;
  final String policyType;
  final double claimAmount;
  final DateTime submittedDate;
  final String status; // 'pending', 'approved', 'rejected', 'processing'
  final String? statusDescription;

  const ClaimUpdate({
    required this.id,
    required this.claimNumber,
    required this.customerName,
    required this.policyType,
    required this.claimAmount,
    required this.submittedDate,
    required this.status,
    this.statusDescription,
  });
}

class DashboardQuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Map<String, dynamic>? arguments;

  const DashboardQuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.arguments,
  });
}

class DashboardNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'info', 'warning', 'success', 'error'
  final bool isRead;
  final String? actionText;
  final String? actionRoute;

  const DashboardNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionText,
    this.actionRoute,
  });

  Color get typeColor {
    switch (type) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'warning':
        return const Color(0xFFFF9800);
      case 'error':
        return const Color(0xFFF44336);
      case 'info':
      default:
        return const Color(0xFF2196F3);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
      default:
        return Icons.info;
    }
  }
}
