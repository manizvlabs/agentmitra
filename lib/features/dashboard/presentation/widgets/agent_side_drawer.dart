import 'package:flutter/material.dart';

/// Agent Side Drawer Menu as per wireframes specification
/// Features red header, navigation items with icons, badges, and logout footer
class AgentSideDrawer extends StatelessWidget {
  const AgentSideDrawer({super.key});

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
    final menuItems = [
      _MenuItem(
        icon: Icons.home,
        title: 'Home',
        route: '/customer-dashboard', // Agent dashboard
        iconColor: Colors.yellow,
        backgroundColor: Colors.yellow.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.lightbulb,
        title: 'Daily Quotes',
        route: '/daily-quotes',
        badge: 'New',
        iconColor: Colors.purple,
        backgroundColor: Colors.purple.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.policy,
        title: 'My Policies',
        route: '/my-policies',
        iconColor: Colors.purple,
        backgroundColor: Colors.purple.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.calendar_today,
        title: 'Premium Calendar',
        route: '/premium-calendar',
        iconColor: Colors.blue,
        backgroundColor: Colors.blue.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.chat_bubble,
        title: 'Agent Chat',
        route: '/agent-chat',
        badge: '3', // Unread messages count
        iconColor: Colors.blue,
        backgroundColor: Colors.blue.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.notifications,
        title: 'Reminders',
        route: '/reminders',
        badge: '1', // Pending reminders count
        iconColor: Colors.orange,
        backgroundColor: Colors.orange.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.slideshow,
        title: 'Presentations',
        route: '/presentations',
        iconColor: Colors.green,
        backgroundColor: Colors.green.withOpacity(0.1),
      ),
      _MenuItem(
        icon: Icons.person,
        title: 'Profile',
        route: '/agent-profile',
        iconColor: Colors.red,
        backgroundColor: Colors.red.withOpacity(0.1),
      ),
    ];

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
