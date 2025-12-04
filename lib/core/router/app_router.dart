import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/phone_verification_screen.dart';
// import '../../screens/trial_setup_screen.dart'; // Temporarily disabled
import '../../screens/trial_expiration_screen.dart';
import '../../screens/policy_details_screen.dart';
import '../../screens/customer_dashboard.dart';
import '../../features/payments/presentation/pages/premium_payment_page.dart';
import '../../features/payments/presentation/pages/get_quote_page.dart';
import '../../screens/whatsapp_integration_screen.dart';
import '../../screens/learning_center_screen.dart';
import '../../screens/agent_config_dashboard.dart';
import '../../screens/roi_analytics_dashboard.dart';
import '../../screens/marketing_campaign_builder.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/payments/presentation/pages/new_policy_page.dart';
import '../../features/payments/presentation/pages/new_claim_page.dart';
import '../../features/analytics/presentation/pages/reports_page.dart';
import '../../screens/my_policies_screen.dart';
import '../../features/agent/presentation/pages/agent_profile_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../screens/tenant_onboarding_screen.dart';
import '../../screens/role_assignment_screen.dart';
import '../../screens/compliance_reporting_screen.dart';
import '../../screens/onboarding_completion_page.dart';
import '../../screens/agent_discovery_screen.dart';
import '../../screens/document_upload_screen.dart';
import '../../screens/kyc_verification_screen.dart';
import '../../screens/emergency_contact_screen.dart';
import '../../features/onboarding/presentation/pages/enhanced_agent_discovery_page.dart';
// Configuration Portal Pages
import '../../features/config_portal/presentation/pages/data_import_dashboard_page.dart';
import '../../features/config_portal/presentation/pages/excel_template_config_page.dart';
import '../../features/config_portal/presentation/pages/customer_data_management_page.dart';
import '../../features/config_portal/presentation/pages/reporting_dashboard_page.dart';
import '../../features/config_portal/presentation/pages/user_management_page.dart';
// Admin Portal Pages
import '../../screens/system_dashboard_screen.dart';
import '../../screens/users_management_screen.dart';
import '../../screens/tenant_list_screen.dart';
import '../../screens/admin_analytics_screen.dart';
import '../../screens/admin_settings_screen.dart';
import '../../screens/super_admin_dashboard.dart';
import '../../screens/provider_admin_dashboard.dart';
import '../../screens/regional_manager_dashboard.dart';
import '../../screens/senior_agent_dashboard.dart';
// Additional screens for comprehensive navigation
import '../../screens/daily_quotes_screen.dart';
import '../../screens/premium_calendar_screen.dart';
import '../../screens/agent_chat_screen.dart';
import '../../screens/reminders_screen.dart';
import '../../screens/presentations_screen.dart';
import '../../screens/campaign_performance_screen.dart';
import '../../screens/content_performance_screen.dart';
import '../../screens/global_search_screen.dart';
import '../../screens/data_pending_screen.dart';
import '../../screens/smart_chatbot_screen.dart';
import '../../screens/agent_verification_screen.dart';
import '../../screens/customer_dashboard.dart';
import '../../screens/payments_screen.dart';
import '../../screens/file_new_claim_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/accessibility_settings_screen.dart';
import '../../screens/language_selection_screen.dart';
import '../../screens/excel_upload_screen.dart';
import '../../screens/data_import_progress_screen.dart';
import '../../screens/reports_screen.dart';
// Protected Route Widget
import '../../core/widgets/protected_route.dart';
import '../../core/services/rbac_service.dart';

/// Application Router Configuration
/// Uses GoRouter for declarative routing with deep linking support
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash & Welcome Flow
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Authentication Flow
      GoRoute(
        path: '/phone-verification',
        name: 'phone-verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),

      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final phoneNumber = state.extra as String?;
          return OtpVerificationPage(phoneNumber: phoneNumber ?? '');
        },
      ),

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Onboarding Flow
      // GoRoute( // Temporarily disabled - TrialSetupScreen has syntax issues
      //   path: '/trial-setup',
      //   name: 'trial-setup',
      //   builder: (context, state) => const TrialSetupScreen(),
      // ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: '/onboarding-completion',
        name: 'onboarding-completion',
        builder: (context, state) => const OnboardingCompletionPage(),
      ),

      GoRoute(
        path: '/agent-discovery',
        name: 'agent-discovery',
        builder: (context, state) => const EnhancedAgentDiscoveryPage(),
      ),

      GoRoute(
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadScreen(),
      ),

      GoRoute(
        path: '/kyc-verification',
        name: 'kyc-verification',
        builder: (context, state) => const KycVerificationScreen(),
      ),

      GoRoute(
        path: '/emergency-contact',
        name: 'emergency-contact',
        builder: (context, state) => const EmergencyContactScreen(),
      ),

      GoRoute(
        path: '/trial-expiration',
        name: 'trial-expiration',
        builder: (context, state) => const TrialExpirationScreen(),
      ),

      // Customer Portal
      GoRoute(
        path: '/customer-dashboard',
        name: 'customer-dashboard',
        builder: (context, state) => const CustomerDashboard(),
      ),

      GoRoute(
        path: '/policy-details',
        name: 'policy-details',
        builder: (context, state) => const PolicyDetailsScreen(),
      ),

      GoRoute(
        path: '/premium-payment',
        name: 'premium-payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PremiumPaymentPage(
            policyId: extra?['policyId'],
            amount: extra?['amount']?.toDouble(),
          );
        },
      ),

      GoRoute(
        path: '/get-quote',
        name: 'get-quote',
        builder: (context, state) => const GetQuotePage(),
      ),

      GoRoute(
        path: '/whatsapp-integration',
        name: 'whatsapp-integration',
        builder: (context, state) => const WhatsappIntegrationScreen(),
      ),

      GoRoute(
        path: '/smart-chatbot',
        name: 'smart-chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationPage(),
      ),

      GoRoute(
        path: '/learning-center',
        name: 'learning-center',
        builder: (context, state) => const LearningCenterScreen(),
      ),

      // Agent Portal
      GoRoute(
        path: '/agent-config-dashboard',
        name: 'agent-config-dashboard',
        builder: (context, state) => const AgentConfigDashboard(),
      ),

      GoRoute(
        path: '/roi-analytics',
        name: 'roi-analytics',
        builder: (context, state) => const RoiAnalyticsDashboard(),
      ),

      GoRoute(
        path: '/campaign-builder',
        name: 'campaign-builder',
        builder: (context, state) => const MarketingCampaignBuilder(),
      ),

      // Policy Management Routes
      GoRoute(
        path: '/new-policy',
        name: 'new-policy',
        builder: (context, state) => const NewPolicyPage(),
      ),

      GoRoute(
        path: '/new-claim',
        name: 'new-claim',
        builder: (context, state) => const NewClaimPage(),
      ),

      GoRoute(
        path: '/policies',
        name: 'policies',
        builder: (context, state) => const MyPoliciesScreen(),
      ),

      GoRoute(
        path: '/policy/create',
        name: 'policy-create',
        builder: (context, state) => const NewPolicyPage(),
      ),

      // Reports Route
      GoRoute(
        path: '/reports',
        name: 'reports',
        builder: (context, state) => const ReportsPage(),
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const AgentProfilePage(),
      ),

      // Customers Route
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) => const CustomersPage(),
      ),

      // Tenant Onboarding Route (Super Admin only)
      GoRoute(
        path: '/tenant-onboarding',
        name: 'tenant-onboarding',
        builder: (context, state) => const TenantOnboardingScreen(),
      ),

      // Role Assignment Route (Admin only)
      GoRoute(
        path: '/role-assignment/:userId',
        name: 'role-assignment',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final extra = state.extra as Map<String, dynamic>?;
          return RoleAssignmentScreen(
            userId: userId,
            userName: extra?['userName'] ?? 'Unknown User',
            userEmail: extra?['userEmail'] ?? '',
          );
        },
      ),

      // Compliance Reporting Route (Admin only)
      GoRoute(
        path: '/compliance-reports',
        name: 'compliance-reports',
        builder: (context, state) => const ComplianceReportingScreen(),
      ),

      // Demo route (for development)
      GoRoute(
        path: '/demo',
        name: 'demo',
        builder: (context, state) => const _DemoNavigation(),
      ),


      // Configuration Portal Routes (Protected with RBAC)
      GoRoute(
        path: '/data-import-dashboard',
        name: 'data-import-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredPermissions: ['data_import.read'],
          child: const DataImportDashboardPage(),
        ),
      ),

      GoRoute(
        path: '/excel-template-config',
        name: 'excel-template-config',
        builder: (context, state) => ProtectedRoute(
          requiredPermissions: ['data_import.create'],
          child: const ExcelTemplateConfigPage(),
        ),
      ),

      GoRoute(
        path: '/customer-data-management',
        name: 'customer-data-management',
        builder: (context, state) => ProtectedRoute(
          requiredPermissions: ['customers.read'],
          child: const CustomerDataManagementPage(),
        ),
      ),

      GoRoute(
        path: '/reporting-dashboard',
        name: 'reporting-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredPermissions: ['reports.read'],
          child: const ReportingDashboardPage(),
        ),
      ),

      GoRoute(
        path: '/user-management',
        name: 'user-management',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [
            UserRole.superAdmin,
            UserRole.providerAdmin,
          ],
          requiredPermissions: ['users.read'],
          child: const UserManagementPage(),
        ),
      ),

      // Admin Portal Routes - Super Admin
      GoRoute(
        path: '/super-admin-dashboard',
        name: 'super-admin-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin],
          requiredPermissions: ['system.admin'],
          child: const SystemDashboardScreen(),
        ),
      ),

      GoRoute(
        path: '/tenants',
        name: 'tenants',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin],
          requiredPermissions: ['tenants.read'],
          child: const TenantListScreen(),
        ),
      ),

      GoRoute(
        path: '/system-analytics',
        name: 'system-analytics',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin],
          requiredPermissions: ['analytics.read'],
          child: const AdminAnalyticsScreen(),
        ),
      ),

      GoRoute(
        path: '/admin-settings',
        name: 'admin-settings',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin],
          requiredPermissions: ['system.config'],
          child: const AdminSettingsScreen(),
        ),
      ),

      // Admin Portal Routes - Provider Admin
      GoRoute(
        path: '/provider-admin-dashboard',
        name: 'provider-admin-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.providerAdmin],
          requiredPermissions: ['providers.read'],
          child: const ProviderAdminDashboard(),
        ),
      ),

      GoRoute(
        path: '/regions',
        name: 'regions',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.providerAdmin],
          requiredPermissions: ['regions.read'],
          child: const ReportsScreen(),
        ),
      ),

      GoRoute(
        path: '/provider-analytics',
        name: 'provider-analytics',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.providerAdmin],
          requiredPermissions: ['analytics.read'],
          child: const ReportsScreen(),
        ),
      ),

      // Admin Portal Routes - Regional Manager
      GoRoute(
        path: '/regional-manager-dashboard',
        name: 'regional-manager-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.regionalManager],
          requiredPermissions: ['regions.admin'],
          child: const RegionalManagerDashboard(),
        ),
      ),

      GoRoute(
        path: '/agent-management',
        name: 'agent-management',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.regionalManager],
          requiredPermissions: ['agents.manage'],
          child: const ReportsScreen(),
        ),
      ),

      GoRoute(
        path: '/regional-analytics',
        name: 'regional-analytics',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.regionalManager],
          requiredPermissions: ['analytics.read'],
          child: const ReportsScreen(),
        ),
      ),

      GoRoute(
        path: '/campaigns',
        name: 'campaigns',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [
            UserRole.regionalManager,
            UserRole.seniorAgent,
          ],
          requiredPermissions: ['campaigns.read'],
          child: const ReportsScreen(),
        ),
      ),

      // Admin Portal Routes - Senior Agent
      GoRoute(
        path: '/senior-agent-dashboard',
        name: 'senior-agent-dashboard',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.seniorAgent],
          requiredPermissions: ['agents.read'],
          child: const SeniorAgentDashboard(),
        ),
      ),

      GoRoute(
        path: '/team-management',
        name: 'team-management',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.seniorAgent],
          requiredPermissions: ['agents.manage'],
          child: const ReportsScreen(),
        ),
      ),

      GoRoute(
        path: '/agent-analytics',
        name: 'agent-analytics',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.seniorAgent],
          requiredPermissions: ['analytics.read'],
          child: const ReportsScreen(),
        ),
      ),

      GoRoute(
        path: '/agent-profile',
        name: 'agent-profile',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.seniorAgent],
          requiredPermissions: ['users.profile'],
          child: const AgentProfilePage(),
        ),
      ),

      // Additional Agent Portal Routes for Deep Linking
      GoRoute(
        path: '/daily-quotes',
        name: 'daily-quotes',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['content.create'],
          child: const DailyQuotesScreen(),
        ),
      ),

      GoRoute(
        path: '/premium-calendar',
        name: 'premium-calendar',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['policies.read'],
          child: const PremiumCalendarScreen(),
        ),
      ),

      GoRoute(
        path: '/agent-chat',
        name: 'agent-chat',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['communication.read'],
          child: const AgentChatScreen(),
        ),
      ),

      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['reminders.read'],
          child: const RemindersScreen(),
        ),
      ),

      GoRoute(
        path: '/presentations',
        name: 'presentations',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['presentations.read'],
          child: const PresentationsScreen(),
        ),
      ),

      GoRoute(
        path: '/campaign-performance',
        name: 'campaign-performance',
        builder: (context, state) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProtectedRoute(
            requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
            requiredPermissions: ['campaigns.read'],
            child: CampaignPerformanceScreen(campaignId: args as String?),
          );
        },
      ),

      GoRoute(
        path: '/content-performance',
        name: 'content-performance',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent],
          requiredPermissions: ['content.read'],
          child: const ContentPerformanceScreen(),
        ),
      ),

      GoRoute(
        path: '/global-search',
        name: 'global-search',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.juniorAgent, UserRole.seniorAgent, UserRole.policyholder],
          requiredPermissions: ['search.read'],
          child: const GlobalSearchScreen(),
        ),
      ),

      // Customer Portal Additional Routes
      GoRoute(
        path: '/data-pending',
        name: 'data-pending',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.policyholder, UserRole.juniorAgent, UserRole.seniorAgent],
          child: const DataPendingScreen(),
        ),
      ),

      GoRoute(
        path: '/smart-chatbot',
        name: 'smart-chatbot',
        builder: (context, state) => const ChatbotPage(),
      ),

      GoRoute(
        path: '/payments',
        name: 'payments',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.policyholder],
          requiredPermissions: ['payments.read'],
          child: const PaymentsScreen(),
        ),
      ),

      GoRoute(
        path: '/file-new-claim',
        name: 'file-new-claim',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.policyholder],
          requiredPermissions: ['claims.create'],
          child: const FileNewClaimScreen(),
        ),
      ),

      // Additional Admin Routes for Deep Linking
      GoRoute(
        path: '/users-management',
        name: 'users-management',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin, UserRole.providerAdmin],
          requiredPermissions: ['users.read'],
          child: const UsersManagementScreen(),
        ),
      ),

      GoRoute(
        path: '/admin-analytics',
        name: 'admin-analytics',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin, UserRole.providerAdmin, UserRole.regionalManager],
          requiredPermissions: ['analytics.read'],
          child: const AdminAnalyticsScreen(),
        ),
      ),

      GoRoute(
        path: '/admin-settings',
        name: 'admin-settings',
        builder: (context, state) => ProtectedRoute(
          requiredRoles: [UserRole.superAdmin, UserRole.providerAdmin, UserRole.regionalManager],
          requiredPermissions: ['system.config'],
          child: const AdminSettingsScreen(),
        ),
      ),

      // Config Portal Routes for Deep Linking
      GoRoute(
        path: '/excel-upload',
        name: 'excel-upload',
        builder: (context, state) => ProtectedRoute(
          requiredPermissions: ['data_import.create'],
          child: const ExcelUploadScreen(),
        ),
      ),

      GoRoute(
        path: '/data-import-progress',
        name: 'data-import-progress',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProtectedRoute(
            requiredPermissions: ['data_import.read'],
            child: DataImportProgressScreen(
              importId: extra?['importId'] ?? '',
              fileName: extra?['fileName'] ?? 'Unknown File',
              totalRecords: extra?['totalRecords'] ?? 0,
            ),
          );
        },
      ),

      // Settings and Utility Routes
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: '/accessibility-settings',
        name: 'accessibility-settings',
        builder: (context, state) => const AccessibilitySettingsScreen(),
      ),

      GoRoute(
        path: '/language-selection',
        name: 'language-selection',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
}

/// Demo Navigation Widget for Development
class _DemoNavigation extends StatelessWidget {
  const _DemoNavigation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Mitra UI Demo'),
        backgroundColor: const Color(0xFF1a237e),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '🎨 Agent Mitra Unauthenticated UI Demo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a237e),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Click any button below to view the corresponding screen:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Navigation buttons for each screen
          _buildDemoButton(
            context,
            'Splash Screen',
            'Animated logo with loading indicator',
            () => context.go('/'),
          ),

          _buildDemoButton(
            context,
            'Welcome Screen',
            'Trial onboarding with CTA buttons',
            () => context.go('/welcome'),
          ),

          _buildDemoButton(
            context,
            'Phone Verification',
            'Mobile number input with validation',
            () => context.go('/phone-verification'),
          ),

          _buildDemoButton(
            context,
            'OTP Verification',
            '6-digit OTP input with timer',
            () => context.go('/otp-verification', extra: '+91 9876543210'),
          ),

          _buildDemoButton(
            context,
            'Login Page (New)',
            'New architecture login page',
            () => context.go('/login'),
          ),

          _buildDemoButton(
            context,
            'Trial Setup',
            'Profile setup with insurance preferences',
            () => context.go('/trial-setup'),
          ),

          _buildDemoButton(
            context,
            'Trial Expiration',
            'Subscription upgrade screen',
            () => context.go('/trial-expiration'),
          ),

          _buildDemoButton(
            context,
            'Customer Dashboard',
            'Home screen with policy overview',
            () => context.go('/customer-dashboard'),
          ),

          _buildDemoButton(
            context,
            'Policy Details',
            'Individual policy information & actions',
            () => context.go('/policy-details'),
          ),

          _buildDemoButton(
            context,
            'WhatsApp Integration',
            'Agent communication via WhatsApp',
            () => context.go('/whatsapp-integration'),
          ),

          _buildDemoButton(
            context,
            'Smart Chatbot',
            'AI assistant for policy queries',
            () => context.go('/smart-chatbot'),
          ),

          _buildDemoButton(
            context,
            'Learning Center',
            'Educational videos & tutorials',
            () => context.go('/learning-center'),
          ),

          _buildDemoButton(
            context,
            'Agent Config Dashboard',
            'Data import & management portal',
            () => context.go('/agent-config-dashboard'),
          ),

          _buildDemoButton(
            context,
            'ROI Analytics',
            'Revenue & performance analytics',
            () => context.go('/roi-analytics'),
          ),

          _buildDemoButton(
            context,
            'Campaign Builder',
            'Marketing campaign creation tool',
            () => context.go('/campaign-builder'),
          ),

          _buildDemoButton(
            context,
            '🏗️ Tenant Onboarding',
            'Super Admin tenant provisioning & management',
            () => context.go('/tenant-onboarding'),
          ),

          _buildDemoButton(
            context,
            '👥 Role Assignment',
            'Assign roles and permissions to users',
            () => context.go('/role-assignment/demo-user-123'),
          ),

          _buildDemoButton(
            context,
            '📊 Compliance Reports',
            'RBAC audit logs and access reports',
            () => context.go('/compliance-reports'),
          ),

          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📱 Normal Flow:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a237e),
                  ),
                ),
                SizedBox(height: 8),
                Text('Unauthenticated: Splash → Welcome → Phone → OTP → Trial Setup → Trial Expiration'),
                SizedBox(height: 8),
                Text('Customer Portal: Dashboard → Policy Details → WhatsApp → Chatbot → Learning'),
                SizedBox(height: 8),
                Text('Agent Portal: Config Dashboard → ROI Analytics → Campaign Builder'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String title, String subtitle, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1a237e),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1a237e), width: 1),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
