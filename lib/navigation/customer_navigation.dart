import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/customer_dashboard.dart';
import '../features/payments/presentation/pages/policies_list_page.dart';
import '../screens/whatsapp_integration_screen.dart';
import '../screens/learning_center_screen.dart';
import '../features/agent/presentation/pages/agent_profile_page.dart';
import '../core/services/navigation_service.dart';

/// Customer Navigation Container
/// Implements tab-based navigation with 5 bottom tabs as per wireframes:
/// - Home: Customer Dashboard
/// - Policies: Policies management
/// - Chat: WhatsApp Integration & Smart Chatbot
/// - Learning: Learning Center
/// - Profile: User Profile & Settings
class CustomerNavigationContainer extends ConsumerStatefulWidget {
  const CustomerNavigationContainer({super.key});

  @override
  ConsumerState<CustomerNavigationContainer> createState() => _CustomerNavigationContainerState();
}

class _CustomerNavigationContainerState extends ConsumerState<CustomerNavigationContainer> {
  int _selectedIndex = 0;

  static const List<String> _tabTitles = [
    'Home',
    'Policies',
    'Chat',
    'Learning',
    'Profile',
  ];

  static const List<String> _tabRoutes = [
    '/customer-dashboard',
    '/policies',
    '/whatsapp-integration',
    '/learning-center',
    '/agent-profile', // Reusing agent profile page for customer profile
  ];

  // Tab content widgets
  final List<Widget> _tabWidgets = [
    const CustomerDashboard(),
    const PoliciesListPage(),
    const WhatsappIntegrationScreen(),
    const LearningCenterScreen(),
    const AgentProfilePage(), // Reusing agent profile page for customer profile
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
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Policies',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Color(0xFF0083B0), // VyaptIX Blue
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learning',
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

/// Drawer menu for secondary navigation (optional - per wireframe navigation-hierarchy.md)
class CustomerDrawerMenu extends StatelessWidget {
  const CustomerDrawerMenu({super.key});

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
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to help
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}
