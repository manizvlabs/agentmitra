import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/mocks/mock_notification_viewmodel_simple.dart';
import '../widgets/notification_list.dart';
import '../widgets/notification_filters.dart';
import '../widgets/notification_settings_button.dart';

/// Main notification page
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: const [
          NotificationSettingsButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: Consumer<MockNotificationViewModel>(
        builder: (context, viewModel, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // All notifications
              NotificationList(
                notifications: viewModel.notifications,
                onRefresh: viewModel.refreshNotifications,
                isRefreshing: viewModel.isRefreshing,
                emptyMessage: 'No notifications yet',
                onMarkAsRead: viewModel.markNotificationAsRead,
                onDelete: viewModel.deleteNotification,
              ),

              // Unread notifications
              NotificationList(
                notifications: viewModel.unreadNotifications,
                onRefresh: viewModel.refreshNotifications,
                isRefreshing: viewModel.isRefreshing,
                emptyMessage: 'No unread notifications',
                onMarkAsRead: viewModel.markNotificationAsRead,
                onDelete: viewModel.deleteNotification,
              ),

              // Recent notifications
              NotificationList(
                notifications: viewModel.recentNotifications,
                onRefresh: viewModel.refreshNotifications,
                isRefreshing: viewModel.isRefreshing,
                emptyMessage: 'No recent notifications',
                onMarkAsRead: viewModel.markNotificationAsRead,
                onDelete: viewModel.deleteNotification,
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<MockNotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.unreadCount == 0) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: viewModel.markAllNotificationsAsRead,
            icon: const Icon(Icons.done_all),
            label: Text('Mark all read (${viewModel.unreadCount})'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          );
        },
      ),
    );
  }
}

/// Notification filters page
class NotificationFiltersPage extends StatelessWidget {
  const NotificationFiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Notifications'),
        elevation: 0,
      ),
      body: Consumer<MockNotificationViewModel>(
        builder: (context, viewModel, child) {
          return NotificationFilters(
            searchQuery: viewModel.searchQuery,
            selectedType: viewModel.selectedType,
            showOnlyUnread: viewModel.showOnlyUnread,
            onSearchChanged: viewModel.updateSearchQuery,
            onTypeChanged: viewModel.updateTypeFilter,
            onReadFilterChanged: viewModel.updateReadFilter,
            onClearFilters: viewModel.clearFilters,
          );
        },
      ),
    );
  }
}
