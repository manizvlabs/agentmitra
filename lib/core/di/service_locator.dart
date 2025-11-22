import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../services/feature_flag_service.dart';
import '../services/offline_queue_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
// Temporarily commented out problematic ViewModels
// import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
// import '../../features/dashboard/data/repositories/dashboard_repository.dart';
// import '../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
// import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
// import '../../features/notifications/data/repositories/notification_repository.dart';
// import '../../features/notifications/presentation/viewmodels/notification_viewmodel.dart';
// import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
// import '../../features/onboarding/data/repositories/onboarding_repository.dart';
// import '../../features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
// import '../../features/agent/data/datasources/agent_remote_datasource.dart';
// import '../../features/agent/data/datasources/agent_local_datasource.dart';
// import '../../features/agent/data/repositories/agent_repository.dart';
// import '../../features/agent/presentation/viewmodels/agent_profile_viewmodel.dart';
// import '../../features/payments/data/datasources/policy_remote_datasource.dart';
// import '../../features/payments/data/datasources/policy_local_datasource.dart';
// import '../../features/payments/data/repositories/policy_repository.dart';
// import '../../features/payments/presentation/viewmodels/claims_viewmodel.dart';
// import '../../features/payments/presentation/viewmodels/policies_viewmodel.dart';

/// Service Locator for Dependency Injection
/// Provides centralized access to all services, repositories, and ViewModels
class ServiceLocator {
  // ===========================================================================
  // CORE SERVICES (Single instances)
  // ===========================================================================

  static final ApiService _apiService = ApiService();
  static final LoggerService _logger = LoggerService();

  // ===========================================================================
  // VIEWMODELS (New instances each time - state management)
  // ===========================================================================

  /// Authentication ViewModel - connects to real backend
  static AuthViewModel get authViewModel =>
    AuthViewModel();

  // /// Dashboard ViewModel - connects to real analytics APIs
  // static DashboardViewModel get dashboardViewModel =>
  //   DashboardViewModel();

  // Temporarily commented out problematic ViewModels
  // /// Dashboard ViewModel - connects to real analytics APIs
  // static DashboardViewModel get dashboardViewModel =>
  //   DashboardViewModel();

  // /// Notification ViewModel - connects to real notification APIs
  // static NotificationViewModel get notificationViewModel =>
  //   NotificationViewModel();

  // /// Onboarding ViewModel - uses local persistence (may connect to backend later)
  // static OnboardingViewModel get onboardingViewModel =>
  //   OnboardingViewModel();

  // /// Agent Profile ViewModel - connects to real agent APIs
  // static AgentProfileViewModel get agentProfileViewModel =>
  //   AgentProfileViewModel(); // Uses default constructor with fallback agent ID

  // /// Claims ViewModel - connects to real claims APIs
  // static ClaimsViewModel get claimsViewModel =>
  //   ClaimsViewModel();

  // /// Policies ViewModel - connects to real policy APIs
  // static PoliciesViewModel get policiesViewModel =>
  //   PoliciesViewModel();

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Initialize services that need startup (call in main.dart)
  static Future<void> initialize() async {
    await _logger.initialize();
  }
}
