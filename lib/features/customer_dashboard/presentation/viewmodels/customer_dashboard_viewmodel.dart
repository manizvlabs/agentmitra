/// Customer Dashboard ViewModel
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/customer_dashboard_repository.dart';
import '../../data/models/customer_dashboard_data.dart';
import '../../../../core/services/auth_service.dart';

/// Customer Dashboard ViewModel Provider
final customerDashboardViewModelProvider = ChangeNotifierProvider.autoDispose<CustomerDashboardViewModel>(
  (ref) => CustomerDashboardViewModel(),
);

/// Customer Dashboard ViewModel
class CustomerDashboardViewModel extends BaseViewModel {
  final CustomerDashboardRepository _repository;

  CustomerDashboardViewModel({
    CustomerDashboardRepository? repository,
  }) : _repository = repository ?? CustomerDashboardRepository();

  CustomerDashboardData? _dashboardData;
  bool _isRefreshing = false;

  CustomerDashboardData? get dashboardData => _dashboardData;
  bool get isRefreshing => _isRefreshing;

  // Computed properties
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  List<CustomerQuickAction> get quickActions => [
    const CustomerQuickAction(
      id: 'pay_premium',
      title: 'Pay Premium',
      subtitle: 'Make payment',
      icon: Icons.payment,
      color: Colors.blue,
      route: '/premium-payment',
    ),
    const CustomerQuickAction(
      id: 'contact_agent',
      title: 'Contact Agent',
      subtitle: 'Get support',
      icon: Icons.phone,
      color: Colors.green,
      route: '/whatsapp-integration',
    ),
    const CustomerQuickAction(
      id: 'get_quote',
      title: 'Get Quote',
      subtitle: 'New policies',
      icon: Icons.request_quote,
      color: Colors.orange,
      route: '/get-quote',
    ),
  ];

  @override
  Future<void> initialize() async {
    await super.initialize();
    await loadDashboardData();
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    await executeAsync(
      () async {
        // Get customer ID from auth service
        final authService = AuthService();
        final currentUser = await authService.getCurrentUser();
        
        if (currentUser == null || currentUser.userId == null) {
          throw Exception('User not authenticated');
        }

        final customerId = currentUser.userId!;
        _dashboardData = await _repository.getCustomerDashboardData(customerId);
        return true;
      },
      errorMessage: 'Failed to load dashboard data',
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

  /// Format currency
  String formatCurrency(double amount) {
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

  /// Format date
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

