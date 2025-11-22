import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../../data/models/notification_model.dart';

/// Notification settings button for app bar
class NotificationSettingsButton extends StatelessWidget {
  const NotificationSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationViewModel>(
      builder: (context, viewModel, child) {
        return IconButton(
          onPressed: () => _showNotificationSettings(context, viewModel),
          icon: const Icon(Icons.settings),
          tooltip: 'Notification Settings',
        );
      },
    );
  }

  void _showNotificationSettings(
    BuildContext context,
    NotificationViewModel viewModel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NotificationSettingsPage(viewModel: viewModel),
      ),
    );
  }
}

/// Notification settings page
class NotificationSettingsPage extends StatefulWidget {
  final NotificationViewModel viewModel;

  const NotificationSettingsPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationSettings _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.viewModel.notificationSettings ?? const NotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGeneralSettings(),
                  const SizedBox(height: 24),
                  _buildTypeSettings(),
                  const SizedBox(height: 24),
                  _buildTimeSettings(),
                  const SizedBox(height: 24),
                  _buildAdvancedSettings(),
                ],
              ),
            ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Enable Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: _settings.enablePushNotifications,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(enablePushNotifications: value);
                });
              },
            ),

            SwitchListTile(
              title: const Text('Sound'),
              subtitle: const Text('Play sound for notifications'),
              value: _settings.enableSound,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enableSound: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Vibrate for notifications'),
              value: _settings.enableVibration,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enableVibration: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Show Badge'),
              subtitle: const Text('Show notification count on app icon'),
              value: _settings.showBadge,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(showBadge: value);
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Types',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Policy Updates'),
              subtitle: const Text('Updates about your insurance policies'),
              value: _settings.enablePolicyNotifications,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enablePolicyNotifications: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Payment Reminders'),
              subtitle: const Text('Reminders for premium payments'),
              value: _settings.enablePaymentReminders,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enablePaymentReminders: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Claim Updates'),
              subtitle: const Text('Updates on claim status'),
              value: _settings.enableClaimUpdates,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enableClaimUpdates: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Renewal Notices'),
              subtitle: const Text('Policy renewal reminders'),
              value: _settings.enableRenewalNotices,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enableRenewalNotices: value);
                      });
                    }
                  : null,
            ),

            SwitchListTile(
              title: const Text('Marketing'),
              subtitle: const Text('Promotional offers and updates'),
              value: _settings.enableMarketingNotifications,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(enableMarketingNotifications: value);
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiet Hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Disable notifications during specified hours',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Enable Quiet Hours'),
              value: _settings.quietHoursEnabled,
              onChanged: _settings.enablePushNotifications
                  ? (value) {
                      setState(() {
                        _settings = _settings.copyWith(quietHoursEnabled: value);
                      });
                    }
                  : null,
            ),

            if (_settings.quietHoursEnabled) ...[
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Time'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _settings.quietHoursStart ?? 'Select time',
                                ),
                                const Spacer(),
                                const Icon(Icons.access_time, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Time'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _settings.quietHoursEnd ?? 'Select time',
                                ),
                                const Spacer(),
                                const Icon(Icons.access_time, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            ListTile(
              title: const Text('Subscribed Topics'),
              subtitle: Text('${_settings.enabledTopics.length} topics'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to topic management page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Topic management coming soon')),
                );
              },
            ),

            const Divider(),

            ListTile(
              title: const Text('Notification History'),
              subtitle: const Text('View and manage past notifications'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to notification history page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification history coming soon')),
                );
              },
            ),

            const Divider(),

            ListTile(
              title: const Text('Test Notification'),
              subtitle: const Text('Send a test notification to this device'),
              trailing: const Icon(Icons.send),
              onTap: () => _sendTestNotification(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime
        ? (_settings.quietHoursStart != null
            ? _parseTimeOfDay(_settings.quietHoursStart!)
            : TimeOfDay.now())
        : (_settings.quietHoursEnd != null
            ? _parseTimeOfDay(_settings.quietHoursEnd!)
            : TimeOfDay.now());

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final timeString = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _settings = _settings.copyWith(quietHoursStart: timeString);
        } else {
          _settings = _settings.copyWith(quietHoursEnd: timeString);
        }
      });
    }
  }

  Future<void> _sendTestNotification() async {
    // TODO: Implement test notification sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification sent')),
    );
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final success = await widget.viewModel.updateNotificationSettings(_settings);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved successfully')),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save settings')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
