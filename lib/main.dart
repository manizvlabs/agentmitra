import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/presentations/presentation/viewmodels/presentation_viewmodel.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/phone_verification_screen.dart';
import 'screens/trial_setup_screen.dart';
import 'screens/trial_expiration_screen.dart';
import 'screens/customer_dashboard.dart';
import 'screens/policy_details_screen.dart';
import 'screens/whatsapp_integration_screen.dart';
import 'screens/smart_chatbot_screen.dart';
import 'screens/learning_center_screen.dart';
import 'screens/agent_config_dashboard.dart';
import 'screens/roi_analytics_dashboard.dart';
import 'screens/marketing_campaign_builder.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';

// Demo navigation widget
class DemoNavigation extends StatelessWidget {
  const DemoNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            () => Navigator.pushNamed(context, '/'),
          ),

          _buildDemoButton(
            context,
            'Welcome Screen',
            'Trial onboarding with CTA buttons',
            () => Navigator.pushNamed(context, '/welcome'),
          ),

          _buildDemoButton(
            context,
            'Phone Verification',
            'Mobile number input with validation',
            () => Navigator.pushNamed(context, '/phone-verification'),
          ),

          _buildDemoButton(
            context,
            'OTP Verification',
            '6-digit OTP input with timer',
            () => Navigator.pushNamed(context, '/otp-verification'),
          ),

          _buildDemoButton(
            context,
            'Login Page (New)',
            'New architecture login page',
            () => Navigator.pushNamed(context, '/login'),
          ),

          _buildDemoButton(
            context,
            'Trial Setup',
            'Profile setup with insurance preferences',
            () => Navigator.pushNamed(context, '/trial-setup'),
          ),

          _buildDemoButton(
            context,
            'Trial Expiration',
            'Subscription upgrade screen',
            () => Navigator.pushNamed(context, '/trial-expiration'),
          ),

          _buildDemoButton(
            context,
            'Customer Dashboard',
            'Home screen with policy overview',
            () => Navigator.pushNamed(context, '/customer-dashboard'),
          ),

          _buildDemoButton(
            context,
            'Policy Details',
            'Individual policy information & actions',
            () => Navigator.pushNamed(context, '/policy-details'),
          ),

          _buildDemoButton(
            context,
            'WhatsApp Integration',
            'Agent communication via WhatsApp',
            () => Navigator.pushNamed(context, '/whatsapp-integration'),
          ),

          _buildDemoButton(
            context,
            'Smart Chatbot',
            'AI assistant for policy queries',
            () => Navigator.pushNamed(context, '/smart-chatbot'),
          ),

          _buildDemoButton(
            context,
            'Learning Center',
            'Educational videos & tutorials',
            () => Navigator.pushNamed(context, '/learning-center'),
          ),

          _buildDemoButton(
            context,
            'Agent Config Dashboard',
            'Data import & management portal',
            () => Navigator.pushNamed(context, '/agent-config-dashboard'),
          ),

          _buildDemoButton(
            context,
            'ROI Analytics',
            'Revenue & performance analytics',
            () => Navigator.pushNamed(context, '/roi-analytics'),
          ),

          _buildDemoButton(
            context,
            'Campaign Builder',
            'Marketing campaign creation tool',
            () => Navigator.pushNamed(context, '/campaign-builder'),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.initialize();
  
  runApp(const AgentMitraApp());
}

class AgentMitraApp extends StatelessWidget {
  const AgentMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X/XS dimensions
      minTextAdapt: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
            ChangeNotifierProvider(create: (_) => PresentationViewModel()),
          ],
          child: MaterialApp(
            title: 'Agent Mitra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/demo': (context) => const DemoNavigation(),
              '/welcome': (context) => const WelcomeScreen(),
              '/phone-verification': (context) => const PhoneVerificationScreen(),
              '/otp-verification': (context) {
                final args = ModalRoute.of(context)!.settings.arguments;
                return OtpVerificationPage(
                  phoneNumber: args is String ? args : '',
                );
              },
              '/login': (context) => const LoginPage(),
              '/trial-setup': (context) => const TrialSetupScreen(),
              '/trial-expiration': (context) => const TrialExpirationScreen(),
              '/customer-dashboard': (context) => const CustomerDashboard(),
              '/policy-details': (context) => const PolicyDetailsScreen(),
              '/whatsapp-integration': (context) => const WhatsappIntegrationScreen(),
              '/smart-chatbot': (context) => const SmartChatbotScreen(),
              '/learning-center': (context) => const LearningCenterScreen(),
              '/agent-config-dashboard': (context) => const AgentConfigDashboard(),
              '/roi-analytics': (context) => const RoiAnalyticsDashboard(),
              '/campaign-builder': (context) => const MarketingCampaignBuilder(),
            },
          ),
        );
      },
    );
  }
}
