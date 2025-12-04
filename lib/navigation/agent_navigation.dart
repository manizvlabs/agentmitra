import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../screens/customers_screen.dart';
import '../screens/roi_analytics_dashboard.dart';
import '../screens/marketing_campaign_builder.dart';
import '../features/agent/presentation/pages/agent_profile_page.dart';
import '../core/services/navigation_service.dart';
import 'package:go_router/go_router.dart';

/// Agent Navigation Container
/// Implements tab-based navigation with 5 bottom tabs as per wireframes:
/// - Dashboard: Agent Dashboard (with Presentation Carousel)
/// - Customers: Customer Management (CRM)
/// - Analytics: ROI Analytics & Performance
/// - Campaigns: Marketing Campaign Builder
/// - Profile: Agent Profile & Settings
class AgentNavigationContainer extends ConsumerStatefulWidget {
  const AgentNavigationContainer({super.key});

  @override
  ConsumerState<AgentNavigationContainer> createState() => _AgentNavigationContainerState();
}

class _AgentNavigationContainerState extends ConsumerState<AgentNavigationContainer> {
  int _selectedIndex = 0;

  static const List<String> _tabTitles = [
    'Dashboard',
    'Customers',
    'Analytics',
    'Campaigns',
    'Profile',
  ];

  static const List<String> _tabRoutes = [
    '/agent-dashboard',
    '/customers',
    '/roi-analytics',
    '/campaign-builder',
    '/agent-profile',
  ];

  // Tab content widgets
  final List<Widget> _tabWidgets = [
    const DashboardPage(),
    const CustomersScreen(),
    const RoiAnalyticsDashboard(),
    const MarketingCampaignBuilder(),
    const AgentProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add breadcrumb navigation
    NavigationService().addNavigationItem(
      _tabTitles[index],
      _tabRoutes[index],
    );
  }

  // Navigate to specific agent screens via deep linking
  void _navigateToScreen(String routeName, {Map<String, dynamic>? extra}) {
    // Use GoRouter for deep linking
    GoRouter.of(context).goNamed(routeName, extra: extra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabWidgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Campaigns',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue background
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

/// Hamburger menu (drawer) for advanced tools (per wireframe navigation-hierarchy.md)
class AgentDrawerMenu extends StatelessWidget {
  const AgentDrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0083B0), // VyaptIX Blue
            ),
            child: Text(
              'Agent Mitra',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Content Creation & Management
          ListTile(
            leading: const Icon(Icons.format_quote),
            title: const Text('Daily Quotes'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('daily-quotes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.present_to_all),
            title: const Text('Presentations'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('presentations');
            },
          ),

          // Business Tools
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Premium Calendar'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('premium-calendar');
            },
          ),
          ListTile(
            leading: const Icon(Icons.my_library_books),
            title: const Text('My Policies'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('policies');
            },
          ),

          // Communication
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Agent Chat'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('agent-chat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Reminders'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('reminders');
            },
          ),

          // Analytics & Performance
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Content Performance'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('content-performance');
            },
          ),

          // Search & Discovery
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Global Search'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('global-search');
            },
          ),

          const Divider(),

          // Settings & Preferences
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessibility),
            title: const Text('Accessibility'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('accessibility-settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).goNamed('language-selection');
            },
          ),

          // Support & Account
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help - implement when available
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Handle logout - implement authentication flow
            },
          ),
        ],
      ),
    );
  }
}
