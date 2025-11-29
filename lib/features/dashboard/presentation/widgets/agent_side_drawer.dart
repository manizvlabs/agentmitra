import 'package:flutter/material.dart';
import '../../../../core/services/feature_flag_service.dart';
import '../../../../core/services/badge_service.dart';

/// Agent Side Drawer Menu as per wireframes specification
/// Features red header, navigation items with icons, badges, and logout footer
class AgentSideDrawer extends StatefulWidget {
  const AgentSideDrawer({super.key});

  @override
  State<AgentSideDrawer> createState() => _AgentSideDrawerState();
}

class _AgentSideDrawerState extends State<AgentSideDrawer> {
  final FeatureFlagService _featureFlagService = FeatureFlagService();
  final BadgeService _badgeService = BadgeService();
  Map<String, bool> _featureFlags = {};
  Map<String, String?> _badges = {};

  @override
  void initState() {
    super.initState();
    _loadFeatureFlags();
    _loadBadges();
  }

  Future<void> _loadFeatureFlags() async {
    await _featureFlagService.initialize();
    setState(() {
      _featureFlags = {
        'daily_quotes_enabled': _featureFlagService.isFeatureEnabledSync('daily_quotes_enabled') ?? true,
        'policies_enabled': _featureFlagService.isFeatureEnabledSync('policies_enabled') ?? true,
        'premium_calendar_enabled': _featureFlagService.isFeatureEnabledSync('premium_calendar_enabled') ?? false,
        'agent_chat_enabled': _featureFlagService.isFeatureEnabledSync('agent_chat_enabled') ?? true,
        'reminders_enabled': _featureFlagService.isFeatureEnabledSync('reminders_enabled') ?? true,
        'presentations_enabled': _featureFlagService.isFeatureEnabledSync('presentations_enabled') ?? true,
        'accessibility_enabled': _featureFlagService.isFeatureEnabledSync('accessibility_enabled') ?? true,
        'language_enabled': _featureFlagService.isFeatureEnabledSync('language_enabled') ?? true,
      };
    });
  }

  Future<void> _loadBadges() async {
    await _badgeService.initialize();
    _badges = _badgeService.getAllBadges();

    // Listen to badge updates
    _badgeService.badgeStream.listen((badges) {
      setState(() {
        _badges = badges;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Red Header Section
            _buildHeaderSection(context),

            // Menu Items
            Expanded(
              child: _buildMenuItems(context),
            ),

            // Footer - Logout
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  /// Red header section with agent details
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Agent Avatar Placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Agent Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'B.Sridhar', // TODO: Get from user profile
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '9246883365', // TODO: Get from user profile
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Menu items list with icons and badges
  Widget _buildMenuItems(BuildContext context) {
    final menuItems = <_MenuItem>[];

    // Business Operations
    menuItems.add(_MenuItem(
      icon: Icons.home,
      title: 'Dashboard',
      route: '/agent-dashboard',
      iconColor: Colors.yellow,
      backgroundColor: Colors.yellow.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.business,
      title: 'My Business',
      route: '/agent-dashboard',
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.withOpacity(0.1),
    ));

    // Customer Management
    menuItems.add(_MenuItem(
      icon: Icons.people,
      title: 'Customers',
      route: '/customers',
      iconColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.home,
      title: 'Customer Dashboard',
      route: '/customer-dashboard',
      iconColor: Colors.teal,
      backgroundColor: Colors.teal.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.policy,
      title: 'My Policies',
      route: '/policies',
      iconColor: Colors.purple,
      backgroundColor: Colors.purple.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.description,
      title: 'Policy Details',
      route: '/policy-details',
      iconColor: Colors.indigo,
      backgroundColor: Colors.indigo.withOpacity(0.1),
    ));

    // Marketing & Sales
    menuItems.add(_MenuItem(
      icon: Icons.campaign,
      title: 'Campaign Builder',
      route: '/campaign-builder',
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.slideshow,
      title: 'Presentations',
      route: '/presentations',
      iconColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
    ));

    // Communication
    menuItems.add(_MenuItem(
      icon: Icons.chat,
      title: 'WhatsApp Integration',
      route: '/whatsapp-integration',
      iconColor: Colors.green,
      backgroundColor: Colors.green.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.smart_toy,
      title: 'Smart Chatbot',
      route: '/smart-chatbot',
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.notifications,
      title: 'Notifications',
      route: '/notifications',
      iconColor: Colors.amber,
      backgroundColor: Colors.amber.withOpacity(0.1),
    ));

    // Agent Tools
    menuItems.add(_MenuItem(
      icon: Icons.format_quote,
      title: 'Daily Quotes',
      route: '/daily-quotes',
      badge: _badges[BadgeService.dailyQuotes],
      iconColor: Colors.purple,
      backgroundColor: Colors.purple.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.calendar_today,
      title: 'Premium Calendar',
      route: '/premium-calendar',
      iconColor: Colors.cyan,
      backgroundColor: Colors.cyan.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.chat_bubble,
      title: 'Agent Chat',
      route: '/agent-chat',
      badge: _badges[BadgeService.agentChat],
      iconColor: Colors.lightBlue,
      backgroundColor: Colors.lightBlue.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.notifications_active,
      title: 'Reminders',
      route: '/reminders',
      badge: _badges[BadgeService.reminders],
      iconColor: Colors.orange,
      backgroundColor: Colors.orange.withOpacity(0.1),
    ));

    // Learning & Support
    menuItems.add(_MenuItem(
      icon: Icons.library_books,
      title: 'Learning Center',
      route: '/learning-center',
      iconColor: Colors.brown,
      backgroundColor: Colors.brown.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.report,
      title: 'Reports',
      route: '/reports',
      iconColor: Colors.grey,
      backgroundColor: Colors.grey.withOpacity(0.1),
    ));

    // Policy Management
    menuItems.add(_MenuItem(
      icon: Icons.add_circle,
      title: 'New Policy',
      route: '/new-policy',
      iconColor: Colors.lightGreen,
      backgroundColor: Colors.lightGreen.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.report_problem,
      title: 'New Claim',
      route: '/new-claim',
      iconColor: Colors.redAccent,
      backgroundColor: Colors.redAccent.withOpacity(0.1),
    ));

    // Profile & Settings
    menuItems.add(_MenuItem(
      icon: Icons.person,
      title: 'Profile',
      route: '/agent-profile',
      iconColor: Colors.red,
      backgroundColor: Colors.red.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.accessibility,
      title: 'Accessibility',
      route: '/accessibility-settings',
      iconColor: Colors.blue,
      backgroundColor: Colors.blue.withOpacity(0.1),
    ));

    menuItems.add(_MenuItem(
      icon: Icons.language,
      title: 'Language',
      route: '/language-selection',
      iconColor: Colors.teal,
      backgroundColor: Colors.teal.withOpacity(0.1),
    ));

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(context, item);
      },
    );
  }

  /// Individual menu item widget
  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: item.iconColor,
          size: 24,
        ),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: item.badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        Navigator.of(context).pushNamed(item.route);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  /// Footer section with logout
  Widget _buildFooterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.grey,
            size: 24,
          ),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          // TODO: Implement logout functionality
          Navigator.of(context).pop(); // Close drawer
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout functionality coming soon!')),
          );
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

/// Menu item data class
class _MenuItem {
  final IconData icon;
  final String title;
  final String route;
  final String? badge;
  final Color iconColor;
  final Color backgroundColor;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.route,
    this.badge,
    required this.iconColor,
    required this.backgroundColor,
  });
}
