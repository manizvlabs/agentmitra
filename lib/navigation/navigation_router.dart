import 'package:flutter/material.dart';
import '../core/services/rbac_service.dart';
import '../core/widgets/protected_route.dart';
import '../shared/theme/app_theme.dart';
import 'customer_navigation.dart';
import 'agent_navigation.dart';
import 'admin_navigation.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/phone_verification_screen.dart';
import '../screens/policy_details_screen.dart';
import '../screens/my_policies_screen.dart';
import '../screens/campaign_performance_screen.dart';
import '../screens/content_performance_screen.dart';
import '../screens/trial_expiration_screen.dart';
import '../screens/data_pending_screen.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/chatbot/presentation/pages/chatbot_page.dart';
import '../features/notifications/presentation/pages/notification_page.dart';
import '../features/payments/presentation/pages/claims_page.dart';
import '../features/payments/presentation/pages/premium_payment_page.dart';
import '../features/payments/presentation/pages/get_quote_page.dart';
import '../features/presentations/presentation/pages/presentation_list_page.dart';
import '../features/presentations/presentation/pages/presentation_editor_page.dart';
import '../features/config_portal/presentation/pages/data_import_dashboard_page.dart';
import '../features/config_portal/presentation/pages/excel_template_config_page.dart';
import '../features/config_portal/presentation/pages/customer_data_management_page.dart';
import '../features/config_portal/presentation/pages/reporting_dashboard_page.dart';
import '../features/config_portal/presentation/pages/user_management_page.dart';
import '../screens/super_admin_dashboard.dart';
import '../screens/provider_admin_dashboard.dart';
import '../screens/regional_manager_dashboard.dart';
import '../screens/senior_agent_dashboard.dart';
import '../screens/daily_quotes_screen.dart';
import '../screens/premium_calendar_screen.dart';
import '../screens/agent_chat_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/global_search_screen.dart';
import '../screens/accessibility_settings_screen.dart';
import '../screens/language_selection_screen.dart';
import '../screens/pioneer_demo_screen.dart';
import '../features/presentations/data/models/presentation_model.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';

/// Navigation Router - Role-based route generation and protected routes
class NavigationRouter {
  static final NavigationRouter _instance = NavigationRouter._internal();
  factory NavigationRouter() => _instance;
  NavigationRouter._internal();

  /// Get initial route based on user authentication and role
  String getInitialRoute(BuildContext context) {
    // For testing admin portal - force admin route
    return '/admin-portal';
  }

  // Get role-based route for navigation container
  // TODO: Re-enable after authentication flow is properly implemented
  // String _getRoleBasedRoute(UserRole role) {
  //   switch (role) {
  //     case UserRole.policyholder:
  //     case UserRole.regionalManager: // Can access customer portal
  //       return '/customer-portal';
  //
  //     case UserRole.juniorAgent:
  //     case UserRole.seniorAgent:
  //       return '/agent-portal';
  //
  //     case UserRole.superAdmin:
  //     case UserRole.providerAdmin:
  //       return '/admin-portal';
  //
  //     default:
  //       return '/splash'; // Fallback
  //   }
  // }

  /// Generate routes map with role-based navigation containers
  Map<String, WidgetBuilder> generateRoutes(BuildContext context) {
    return {
      // Splash & Welcome Flow (Public)
      '/splash': (context) => const SplashScreen(),
      '/welcome': (context) => const WelcomeScreen(),

      // Authentication Flow (Public)
      '/phone-verification': (context) => const PhoneVerificationScreen(),
    '/otp-verification': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final phoneNumber = args is String ? args : '+91 9876543210';
      return OtpVerificationPage(phoneNumber: phoneNumber);
    },
    '/login': (context) => const LoginPage(),

      // Onboarding Flow (Protected - requires authentication)
      '/onboarding': _protectedRoute(
        (context) => const OnboardingPage(),
        requiredRoles: [UserRole.policyholder, UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/trial-expiration': _protectedRoute(
        (context) => const TrialExpirationScreen(),
        requiredRoles: [UserRole.policyholder, UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/data-pending': _protectedRoute(
        (context) => const DataPendingScreen(),
      ),

      // Navigation Containers (Role-based entry points)
      '/customer-portal': _roleBasedRoute(
        (context) => const CustomerNavigationContainer(),
        allowedRoles: [UserRole.policyholder, UserRole.regionalManager],
      ),
      '/agent-portal': _roleBasedRoute(
        (context) => const AgentNavigationContainer(),
        allowedRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/admin-portal': _roleBasedRoute(
        (context) => const AdminNavigationContainer(),
        allowedRoles: [UserRole.superAdmin, UserRole.providerAdmin, UserRole.regionalManager, UserRole.seniorAgent],
      ),

      // Legacy Routes (for backward compatibility - redirect to containers)
      '/customer-dashboard': _protectedRoute(
        (context) => const CustomerNavigationContainer(),
        requiredRoles: [UserRole.policyholder, UserRole.regionalManager],
      ),
      '/agent-dashboard': _protectedRoute(
        (context) => const AgentNavigationContainer(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/dashboard': _protectedRoute(
        (context) => const AgentNavigationContainer(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),

      // Deep-linking routes (accessible from within containers)
      '/policies': _protectedRoute(
        (context) => const CustomerNavigationContainer(),
        requiredPermissions: ['policies.read'],
      ),
      '/claims': _protectedRoute(
        (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ClaimsPage(policyId: args as String?);
        },
        requiredPermissions: ['policies.read'],
      ),
      '/claims/new': _protectedRoute(
        (context) => const PlaceholderScreen(title: 'File New Claim'),
        requiredPermissions: ['policies.create'],
      ),
      '/policy-details': _protectedRoute(
        (context) => const PolicyDetailsScreen(),
        requiredPermissions: ['policies.read'],
      ),
      '/premium-payment': _protectedRoute(
        (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final map = args is Map<String, dynamic> ? args : {};
          return PremiumPaymentPage(
            policyId: map['policyId'],
            amount: map['amount']?.toDouble(),
          );
        },
        requiredPermissions: ['policies.update'],
      ),
      '/get-quote': _protectedRoute(
        (context) => const GetQuotePage(),
        requiredPermissions: ['policies.create'],
      ),
      '/whatsapp-integration': _protectedRoute(
        (context) => const CustomerNavigationContainer(),
      ),
      '/smart-chatbot': _protectedRoute(
        (context) => const ChatbotPage(),
      ),
      '/notifications': _protectedRoute(
        (context) => const NotificationPage(),
      ),
      '/learning-center': _protectedRoute(
        (context) => const CustomerNavigationContainer(),
      ),
      '/agent-profile': _protectedRoute(
        (context) => const CustomerNavigationContainer(), // Redirect to appropriate container
        requiredRoles: [UserRole.policyholder, UserRole.juniorAgent, UserRole.seniorAgent],
      ),

      // Agent-specific routes
      '/daily-quotes': _protectedRoute(
        (context) => const DailyQuotesScreen(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/my-policies': _protectedRoute(
        (context) => const MyPoliciesScreen(),
        requiredPermissions: ['policies.read'],
      ),
      '/premium-calendar': _protectedRoute(
        (context) => const PremiumCalendarScreen(),
        requiredPermissions: ['policies.read'],
      ),
      '/agent-chat': _protectedRoute(
        (context) => const AgentChatScreen(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/reminders': _protectedRoute(
        (context) => const RemindersScreen(),
      ),
      '/presentations': _protectedRoute(
        (context) => const PresentationListPage(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/presentation-list': _protectedRoute(
        (context) => const PresentationListPage(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/presentation-editor': _protectedRoute(
        (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final presentation = args is PresentationModel ? args : null;
          return PresentationEditorPage(presentation: presentation);
        },
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),

      // Analytics and Reports
      '/roi-analytics': _protectedRoute(
        (context) => const AgentNavigationContainer(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent, UserRole.regionalManager],
      ),
      '/campaign-performance': _protectedRoute(
        (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return CampaignPerformanceScreen(campaignId: args is String ? args : null);
        },
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),
      '/content-performance': _protectedRoute(
        (context) => const ContentPerformanceScreen(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
      ),

      // Campaigns
      '/campaign-builder': _protectedRoute(
        (context) => const AgentNavigationContainer(),
        requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent, UserRole.regionalManager],
      ),

      // Settings and Utilities
      '/accessibility-settings': _protectedRoute(
        (context) => const AccessibilitySettingsScreen(),
      ),
      '/language-selection': _protectedRoute(
        (context) => const LanguageSelectionScreen(),
      ),
      '/global-search': _protectedRoute(
        (context) => const GlobalSearchScreen(),
      ),

      // Configuration Portal Routes (Protected with RBAC)
      '/data-import-dashboard': _protectedRoute(
        (context) => const DataImportDashboardPage(),
        requiredPermissions: ['data_import.read'],
      ),
      '/excel-template-config': _protectedRoute(
        (context) => const ExcelTemplateConfigPage(),
        requiredPermissions: ['data_import.create'],
      ),
      '/customer-data-management': _protectedRoute(
        (context) => const CustomerDataManagementPage(),
        requiredPermissions: ['customers.read'],
      ),
      '/reporting-dashboard': _protectedRoute(
        (context) => const ReportingDashboardPage(),
        requiredPermissions: ['reports.read'],
      ),
      '/user-management': _protectedRoute(
        (context) => const UserManagementPage(),
        requiredRoles: [UserRole.superAdmin, UserRole.providerAdmin, UserRole.regionalManager],
        requiredPermissions: ['users.read'],
      ),

      // Admin Dashboard Routes
      '/super-admin-dashboard': _protectedRoute(
        (context) => const SuperAdminDashboard(),
        requiredRoles: [UserRole.superAdmin],
      ),
      '/provider-admin-dashboard': _protectedRoute(
        (context) => const ProviderAdminDashboard(),
        requiredRoles: [UserRole.providerAdmin],
      ),
      '/regional-manager-dashboard': _protectedRoute(
        (context) => const RegionalManagerDashboard(),
        requiredRoles: [UserRole.regionalManager],
      ),
      '/senior-agent-dashboard': _protectedRoute(
        (context) => const SeniorAgentDashboard(),
        requiredRoles: [UserRole.seniorAgent],
      ),

      // Demo and Testing Routes
      '/pioneer-demo': (context) => const PioneerDemoScreen(),
    };
  }

  /// Create protected route wrapper
  WidgetBuilder _protectedRoute(
    WidgetBuilder builder, {
    List<UserRole>? requiredRoles,
    List<String>? requiredPermissions,
  }) {
    return (context) => ProtectedRoute(
      requiredRoles: requiredRoles,
      requiredPermissions: requiredPermissions,
      child: builder(context),
    );
  }

  /// Create role-based route that redirects to appropriate navigation container
  WidgetBuilder _roleBasedRoute(
    WidgetBuilder builder, {
    required List<UserRole> allowedRoles,
  }) {
    return (context) => ProtectedRoute(
      requiredRoles: allowedRoles,
      child: builder(context),
    );
  }

  /// Handle unknown routes with fallback to appropriate container
  Route<dynamic>? onUnknownRoute(RouteSettings settings, BuildContext context) {
    // Default to splash screen - don't try to access RBAC service here
    // as it may not be initialized during app startup
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: AppTheme.vyaptixBlue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Page not found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Route: ${settings.name}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/splash'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for routes that are not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.vyaptixBlue,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '$title - Coming Soon!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is currently under development.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

