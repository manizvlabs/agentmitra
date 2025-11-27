import '../services/logger_service.dart';
import '../services/rbac_service.dart';
import '../services/api_service.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../../features/notifications/presentation/viewmodels/notification_viewmodel.dart';
import '../../features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import '../../features/agent/presentation/viewmodels/agent_profile_viewmodel.dart';
import '../../features/payments/presentation/viewmodels/claims_viewmodel.dart';
import '../../features/payments/presentation/viewmodels/policies_viewmodel.dart';
import '../../features/chatbot/presentation/viewmodels/chatbot_viewmodel.dart';
import '../../features/chatbot/data/repositories/chatbot_repository.dart';
import '../../features/chatbot/data/datasources/chatbot_remote_datasource.dart';
import '../../features/analytics/presentation/viewmodels/analytics_viewmodel.dart';

/// Service Locator for Dependency Injection
/// Provides centralized access to all services, repositories, and ViewModels
class ServiceLocator {
  // ===========================================================================
  // CORE SERVICES (Single instances)
  // ===========================================================================

  static final LoggerService _logger = LoggerService();

  // ===========================================================================
  // VIEWMODELS (New instances each time - state management)
  // ===========================================================================

  /// Authentication ViewModel - connects to real backend
  static AuthViewModel get authViewModel =>
    AuthViewModel();

  /// Dashboard ViewModel - connects to real analytics APIs
  static DashboardViewModel get dashboardViewModel =>
    DashboardViewModel();

  /// Notification ViewModel - connects to real notification APIs
  static NotificationViewModel get notificationViewModel =>
    NotificationViewModel();

  /// Onboarding ViewModel - uses local persistence (may connect to backend later)
  static OnboardingViewModel get onboardingViewModel =>
    OnboardingViewModel();

  /// Agent Profile ViewModel - connects to real agent APIs
  static AgentProfileViewModel get agentProfileViewModel =>
    AgentProfileViewModel();

  /// Claims ViewModel - connects to real claims APIs
  static ClaimsViewModel get claimsViewModel =>
    ClaimsViewModel();

  /// Policies ViewModel - connects to real policy APIs
  static PoliciesViewModel get policiesViewModel =>
    PoliciesViewModel();

  /// Chatbot ViewModel factory - requires agentId parameter
  static ChatbotViewModel createChatbotViewModel(String agentId) {
    return ChatbotViewModel(ChatbotRepository(ChatbotRemoteDataSourceImpl()), agentId);
  }

  /// Analytics ViewModel - connects to advanced analytics APIs
  static AnalyticsViewModel get analyticsViewModel =>
    AnalyticsViewModel();

  /// RBAC Service - Role-Based Access Control
  static RbacService? _rbacService;
  static RbacService get rbacService =>
    _rbacService ??= RbacService(ApiService(), LoggerService());

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Initialize services that need startup (call in main.dart)
  static Future<void> initialize() async {
    await _logger.initialize();
  }
}
