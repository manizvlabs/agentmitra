/// API Constants and Endpoints
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:8012';
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Health Check
  static const String health = '/health';
  static const String apiHealth = '$apiVersion/health';

  // Authentication Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String verifyOtp = '$apiVersion/auth/verify-otp';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';

  // User Endpoints
  static const String users = '$apiVersion/users';
  static String userProfile(String userId) => '$users/$userId';
  static String userUpdate(String userId) => '$users/$userId';

  // Agent Endpoints
  static const String agents = '$apiVersion/agents';
  static String agentProfile(String agentId) => '$agents/$agentId';

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

  // Chat Endpoints
  static const String chat = '$apiVersion/chat';
  static const String chatbotSessions = '$chat/sessions';
  static String chatbotSession(String sessionId) => '$chatbotSessions/$sessionId';

  // Payment Endpoints
  static const String payments = '$apiVersion/payments';
  static String paymentHistory(String userId) => '$payments/user/$userId';
}

