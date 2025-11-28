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
  static String get apiHealth => '$apiVersion/health';

  // Authentication Endpoints
  static String get login => '$apiVersion/auth/login';
  static String get register => '$apiVersion/auth/register';
  static String get sendOtp => '$apiVersion/auth/send-otp';
  static String get verifyOtp => '$apiVersion/auth/verify-otp';
  static String get refreshToken => '$apiVersion/auth/refresh';
  static String get logout => '$apiVersion/auth/logout';

  // User Endpoints (legacy - for backward compatibility)
  static String get userEndpoints => '$apiVersion/users';
  static String userProfile(String userId) => '$userEndpoints/$userId';
  static String userUpdate(String userId) => '$userEndpoints/$userId';

  // Agent Endpoints
  static String get agents => '$apiVersion/agents';
  static String get agentProfile => '$agents/profile'; // Current agent's profile
  static String agentProfileById(String agentId) => '$agents/$agentId';

  // Policy Endpoints
  static String get policies => '$apiVersion/policies';
  static String policyDetails(String policyId) => '$policies/$policyId';

  // Presentation Endpoints
  static String get presentations => '$apiVersion/presentations';
  static String agentPresentations(String agentId) => '$presentations/agent/$agentId';
  static String activePresentation(String agentId) => '$presentations/agent/$agentId/active';
  static String presentationDetails(String presentationId) => '$presentations/$presentationId';
  static String get presentationTemplates => '$presentations/templates';
  static String get mediaUpload => '$presentations/media/upload';

  // Payment Endpoints
  static String get payments => '$apiVersion/payments';
  static String paymentHistory(String userId) => '$payments/user/$userId';

  // Analytics Endpoints
  static String get analytics => '$apiVersion/analytics';
  static String get dashboardAnalytics => '$analytics/dashboard';
  static String get agentAnalytics => '$analytics/agents';
  static String get policyAnalytics => '$analytics/policies';
  static String get revenueAnalytics => '$analytics/revenue';
  static String agentPerformance(String agentId) => '$agentAnalytics/$agentId/performance';
  static String dashboardCharts(String chartType) => '$dashboardAnalytics/charts/$chartType';

  // Chat Endpoints
  static String get chat => '$apiVersion/chat';
  static String get chatSessions => '$chat/sessions';
  static String chatSession(String sessionId) => '$chatSessions/$sessionId';
  static String chatSessionMessages(String sessionId) => '$chatSession/$sessionId/messages';
  static String chatSessionAnalytics(String sessionId) => '$chatSession/$sessionId/analytics';

  // Provider Endpoints
  static String get providers => '$apiVersion/providers';
  static String providerById(String providerId) => '$providers/$providerId';
  static String providerByCode(String providerCode) => '$providers/code/$providerCode';

  // Session Endpoints
  static String get authSessions => '$apiVersion/auth/sessions';
  static String authSession(String sessionId) => '$authSessions/$sessionId';

  // Configuration Portal - Data Import Endpoints
  static String get dataImports => '$apiVersion/import';
  static String importHistory() => '$dataImports/history';
  static String importStatistics() => '$dataImports/statistics';
  static String importUpload() => '$dataImports/upload';
  static String importValidate(String fileId) => '$dataImports/validate/$fileId';
  static String importProcess(String fileId) => '$dataImports/process/$fileId';
  static String importStatus(String fileId) => '$dataImports/status/$fileId';
  static String importTemplates() => '$dataImports/templates';
  static String importTemplate(String templateId) => '$dataImports/templates/$templateId';

  // Configuration Portal - Customer Management Endpoints
  static String get customers => '$apiVersion/customers';
  static String customerById(String customerId) => '$customers/$customerId';

  // Configuration Portal - Reporting Endpoints
  static String get reports => '$apiVersion/reports';
  static String reportGenerate() => '$reports/generate';
  static String reportScheduled() => '$reports/scheduled';
  static String reportHistory() => '$reports/history';
  static String reportDownload(String reportId) => '$reports/$reportId/download';

  // Configuration Portal - User Management Endpoints
  static String get users => '$apiVersion/users';
  static String userById(String userId) => '$users/$userId';
  static String userPermissions(String userId) => '$users/$userId/permissions';
  static String userActivity(String userId) => '$users/$userId/activity';

  // Legacy user endpoints (use 'users' constant above)
  static String get userProfiles => users;
}

