import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../screens/super_admin_dashboard.dart';
import '../screens/provider_admin_dashboard.dart';
import '../screens/regional_manager_dashboard.dart';
import '../screens/senior_agent_dashboard.dart';
import '../screens/splash_screen.dart';
import '../features/config_portal/presentation/pages/user_management_page.dart';
import '../core/services/navigation_service.dart';
import '../core/services/rbac_service.dart';
import '../shared/theme/app_theme.dart';

/// Admin Navigation Container
/// Adapts navigation based on admin role:
/// - Super Admin: System overview, user management, feature flags, tenants
/// - Provider Admin: Provider overview, user management, regional management
/// - Regional Manager: Regional overview, agent management, performance analytics
/// - Senior Agent: Agent overview, team management
class AdminNavigationContainer extends ConsumerStatefulWidget {
  const AdminNavigationContainer({super.key});

  @override
  ConsumerState<AdminNavigationContainer> createState() => _AdminNavigationContainerState();
}

class _AdminNavigationContainerState extends ConsumerState<AdminNavigationContainer> {
  int _selectedIndex = 0;
  UserRole? _userRole;
  List<String> _tabTitles = ['Dashboard'];
  List<String> _tabRoutes = ['/splash'];
  List<Widget> _tabWidgets = [const SplashScreen()];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default values - will be updated in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize navigation after dependencies are available
    if (!_initialized) {
      _initializeNavigation();
      _initialized = true;
    }
  }

  void _initializeNavigation() {
    try {
      final rbacService = context.read<RbacService>();
      _userRole = rbacService.getCurrentUserRole();
    } catch (e) {
      // RBAC service not available yet, default to guest
      _userRole = UserRole.guestUser;
    }

    switch (_userRole ?? UserRole.guestUser) {
      case UserRole.superAdmin:
        _tabTitles = ['System', 'Users', 'Tenants', 'Analytics', 'Settings'];
        _tabRoutes = ['/super-admin-dashboard', '/user-management', '/tenants', '/system-analytics', '/admin-settings'];
        _tabWidgets = [
          const SuperAdminDashboard(),
          const UserManagementPage(),
          const PlaceholderScreen(title: 'Tenants'), // TODO: Implement Tenants page
          const PlaceholderScreen(title: 'System Analytics'), // TODO: Implement System Analytics page
          const PlaceholderScreen(title: 'Admin Settings'), // TODO: Implement Admin Settings page
        ];
        break;

      case UserRole.providerAdmin:
        _tabTitles = ['Provider', 'Users', 'Regions', 'Analytics', 'Settings'];
        _tabRoutes = ['/provider-admin-dashboard', '/user-management', '/regions', '/provider-analytics', '/admin-settings'];
        _tabWidgets = [
          const ProviderAdminDashboard(),
          const UserManagementPage(),
          const PlaceholderScreen(title: 'Regions'), // TODO: Implement Regions page
          const PlaceholderScreen(title: 'Provider Analytics'), // TODO: Implement Provider Analytics page
          const PlaceholderScreen(title: 'Admin Settings'), // TODO: Implement Admin Settings page
        ];
        break;

      case UserRole.regionalManager:
        _tabTitles = ['Region', 'Agents', 'Analytics', 'Campaigns', 'Settings'];
        _tabRoutes = ['/regional-manager-dashboard', '/agent-management', '/regional-analytics', '/campaigns', '/admin-settings'];
        _tabWidgets = [
          const RegionalManagerDashboard(),
          const PlaceholderScreen(title: 'Agent Management'), // TODO: Implement Agent Management page
          const PlaceholderScreen(title: 'Regional Analytics'), // TODO: Implement Regional Analytics page
          const PlaceholderScreen(title: 'Campaigns'), // TODO: Implement Campaigns page
          const PlaceholderScreen(title: 'Admin Settings'), // TODO: Implement Admin Settings page
        ];
        break;

      case UserRole.seniorAgent:
        _tabTitles = ['Overview', 'Team', 'Analytics', 'Campaigns', 'Profile'];
        _tabRoutes = ['/senior-agent-dashboard', '/team-management', '/agent-analytics', '/campaigns', '/agent-profile'];
        _tabWidgets = [
          const SeniorAgentDashboard(),
          const PlaceholderScreen(title: 'Team Management'), // TODO: Implement Team Management page
          const PlaceholderScreen(title: 'Agent Analytics'), // TODO: Implement Agent Analytics page
          const PlaceholderScreen(title: 'Campaigns'), // TODO: Implement Campaigns page
          const PlaceholderScreen(title: 'Agent Profile'), // TODO: Implement Agent Profile page
        ];
        break;

      default:
        // Fallback for any other admin roles
        _tabTitles = ['Dashboard', 'Management', 'Analytics', 'Settings'];
        _tabRoutes = ['/admin-dashboard', '/management', '/analytics', '/settings'];
        _tabWidgets = [
          const PlaceholderScreen(title: 'Dashboard'),
          const PlaceholderScreen(title: 'Management'),
          const PlaceholderScreen(title: 'Analytics'),
          const PlaceholderScreen(title: 'Settings'),
        ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add breadcrumb navigation
    if (index < _tabTitles.length && index < _tabRoutes.length) {
      NavigationService().addNavigationItem(
        _tabTitles[index],
        _tabRoutes[index],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        title: Text(
          _getRoleDisplayName(_userRole),
          style: const TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: AdminDrawerMenu(userRole: _userRole),
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabWidgets,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(_tabTitles.length, (index) {
          return BottomNavigationBarItem(
            icon: _getTabIcon(index),
            label: _tabTitles[index],
            backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue // Red color from wireframes
          );
        }),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
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

  Icon _getTabIcon(int index) {
    switch (_userRole) {
      case UserRole.superAdmin:
        switch (index) {
          case 0: return const Icon(Icons.admin_panel_settings);
          case 1: return const Icon(Icons.people);
          case 2: return const Icon(Icons.business);
          case 3: return const Icon(Icons.analytics);
          case 4: return const Icon(Icons.settings);
        }
        break;

      case UserRole.providerAdmin:
        switch (index) {
          case 0: return const Icon(Icons.business_center);
          case 1: return const Icon(Icons.people);
          case 2: return const Icon(Icons.location_on);
          case 3: return const Icon(Icons.analytics);
          case 4: return const Icon(Icons.settings);
        }
        break;

      case UserRole.regionalManager:
        switch (index) {
          case 0: return const Icon(Icons.location_city);
          case 1: return const Icon(Icons.group);
          case 2: return const Icon(Icons.analytics);
          case 3: return const Icon(Icons.campaign);
          case 4: return const Icon(Icons.settings);
        }
        break;

      case UserRole.seniorAgent:
        switch (index) {
          case 0: return const Icon(Icons.dashboard);
          case 1: return const Icon(Icons.group_work);
          case 2: return const Icon(Icons.analytics);
          case 3: return const Icon(Icons.campaign);
          case 4: return const Icon(Icons.person);
        }
        break;

      default:
        return const Icon(Icons.dashboard);
    }
    return const Icon(Icons.dashboard);
  }

  String _getRoleDisplayName(UserRole? role) {
    switch (role ?? UserRole.guestUser) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.providerAdmin:
        return 'Provider Admin';
      case UserRole.regionalManager:
        return 'Regional Manager';
      case UserRole.seniorAgent:
        return 'Senior Agent';
      default:
        return 'Admin';
    }
  }
}

/// Drawer menu for admin-specific tools
class AdminDrawerMenu extends StatelessWidget {
  final UserRole? userRole;

  const AdminDrawerMenu({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0083B0), // VyaptIX Blue
            ),
            child: Text(
              'Admin Panel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Role-specific menu items
          if (userRole == UserRole.superAdmin) ...[
            ListTile(
              leading: const Icon(Icons.featured_play_list),
              title: const Text('Feature Flags'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to feature flags
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Tenants'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to tenants
              },
            ),
          ],

          if (userRole == UserRole.providerAdmin || userRole == UserRole.superAdmin) ...[
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Regions'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to regions
              },
            ),
          ],

          // Common admin tools
          ListTile(
            leading: const Icon(Icons.import_export),
            title: const Text('Data Import'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/data-import-dashboard');
            },
          ),

          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/reporting-dashboard');
            },
          ),

          ListTile(
            leading: const Icon(Icons.accessibility),
            title: const Text('Accessibility'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/accessibility-settings');
            },
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/language-selection');
            },
          ),

          const Divider(),

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
