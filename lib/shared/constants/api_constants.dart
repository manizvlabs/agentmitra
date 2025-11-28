/// API Constants and Endpoints
import '../../core/config/app_config.dart';

class ApiConstants {
  // Base URLs
  static AppConfig get _config => AppConfig();

  static String get baseUrl => _config.apiBaseUrl;
  static String get apiVersion => _config.apiVersion;
  static String get apiBaseUrl => _config.fullApiUrl;

  // Health Check
  static const String health = '/health';
  static const String apiHealth = '$apiVersion/health';

  // Authentication Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String sendOtp = '$apiVersion/auth/send-otp';
  static const String verifyOtp = '$apiVersion/auth/verify-otp';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';

  // User Endpoints (legacy - for backward compatibility)
  static const String userEndpoints = '$apiVersion/users';
  static String userProfile(String userId) => '$userEndpoints/$userId';
  static String userUpdate(String userId) => '$userEndpoints/$userId';

  // Agent Endpoints
  static const String agents = '$apiVersion/agents';
  static const String agentProfile = '$agents/profile'; // Current agent's profile
  static String agentProfileById(String agentId) => '$agents/$agentId';

  // Policy Endpoints
  static const String policies = '$apiVersion/policies';
  static String policyDetails(String policyId) => '$policies/$policyId';

  // Presentation Endpoints
  static const String presentations = '$apiVersion/presentations';
  static String agentPresentations(String agentId) => '$presentations/agent/$agentId';
  static String activePresentation(String agentId) => '$presentations/agent/$agentId/active';
  static String presentationDetails(String presentationId) => '$presentations/$presentationId';
  static const String presentationTemplates = '$presentations/templates';
  static const String mediaUpload = '$presentations/media/upload';

  // Payment Endpoints
  static const String payments = '$apiVersion/payments';
  static String paymentHistory(String userId) => '$payments/user/$userId';

  // Analytics Endpoints
  static const String analytics = '$apiVersion/analytics';
  static const String dashboardAnalytics = '$analytics/dashboard';
  static const String agentAnalytics = '$analytics/agents';
  static const String policyAnalytics = '$analytics/policies';
  static const String revenueAnalytics = '$analytics/revenue';
  static String agentPerformance(String agentId) => '$agentAnalytics/$agentId/performance';
  static String dashboardCharts(String chartType) => '$dashboardAnalytics/charts/$chartType';

  // Chat Endpoints
  static const String chat = '$apiVersion/chat';
  static const String chatSessions = '$chat/sessions';
  static String chatSession(String sessionId) => '$chatSessions/$sessionId';
  static String chatSessionMessages(String sessionId) => '$chatSession/$sessionId/messages';
  static String chatSessionAnalytics(String sessionId) => '$chatSession/$sessionId/analytics';

  // Provider Endpoints
  static const String providers = '$apiVersion/providers';
  static String providerById(String providerId) => '$providers/$providerId';
  static String providerByCode(String providerCode) => '$providers/code/$providerCode';

  // Session Endpoints
  static const String authSessions = '$apiVersion/auth/sessions';
  static String authSession(String sessionId) => '$authSessions/$sessionId';

  // Configuration Portal - Data Import Endpoints
  static const String dataImports = '$apiVersion/import';
  static String importHistory() => '$dataImports/history';
  static String importStatistics() => '$dataImports/statistics';
  static String importUpload() => '$dataImports/upload';
  static String importValidate(String fileId) => '$dataImports/validate/$fileId';
  static String importProcess(String fileId) => '$dataImports/process/$fileId';
  static String importStatus(String fileId) => '$dataImports/status/$fileId';
  static String importTemplates() => '$dataImports/templates';
  static String importTemplate(String templateId) => '$dataImports/templates/$templateId';

  // Configuration Portal - Customer Management Endpoints
  static const String customers = '$apiVersion/customers';
  static String customerById(String customerId) => '$customers/$customerId';

  // Configuration Portal - Reporting Endpoints
  static const String reports = '$apiVersion/reports';
  static String reportGenerate() => '$reports/generate';
  static String reportScheduled() => '$reports/scheduled';
  static String reportHistory() => '$reports/history';
  static String reportDownload(String reportId) => '$reports/$reportId/download';

  // Configuration Portal - User Management Endpoints
  static const String users = '$apiVersion/users';
  static String userById(String userId) => '$users/$userId';
  static String userPermissions(String userId) => '$users/$userId/permissions';
  static String userActivity(String userId) => '$users/$userId/activity';

  // Legacy user endpoints (use 'users' constant above)
  static String get userProfiles => users;
}

