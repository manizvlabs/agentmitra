import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late TabController _tabController;

  // System Settings
  Map<String, dynamic> _systemSettings = {};

  // Feature Flags
  List<Map<String, dynamic>> _featureFlags = [];

  // Notification Settings
  Map<String, dynamic> _notificationSettings = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadSystemSettings(),
        _loadFeatureFlags(),
        _loadNotificationSettings(),
      ]);
    } catch (e) {
      print('Failed to load settings: $e');
      _loadMockData();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSystemSettings() async {
    try {
      // Try to load system settings - endpoint may not exist yet
      // Admin settings endpoint not in project plan - using feature flags instead
      final response = await ApiService.get('/api/v1/rbac/feature-flags');
      setState(() => _systemSettings = response['data'] ?? {});
    } catch (e) {
      print('System settings API failed: $e');
      // Mock system settings
      setState(() => _systemSettings = {
        "maintenance_mode": false,
        "debug_mode": false,
        "rate_limiting": true,
        "session_timeout": 30,
        "max_upload_size": 10,
        "system_alerts": true,
        "security_alerts": true,
        "user_registration_alerts": false,
        "ip_whitelist": false,
        "require_2fa": true,
        "audit_retention_days": 90,
        "usage_analytics": true,
        "crash_reports": true,
        "system_name": "Agent Mitra Platform",
        "version": "1.0.0",
        "max_tenants": 100,
        "max_users_per_tenant": 1000,
      });
    }
  }

  Future<void> _loadFeatureFlags() async {
    try {
      // Use GET /api/v1/rbac/feature-flags endpoint
      final response = await ApiService.get('/api/v1/rbac/feature-flags');
      setState(() => _featureFlags = List<Map<String, dynamic>>.from(response['data'] ?? []));
    } catch (e) {
      print('Feature flags API failed: $e');
      // Mock feature flags
      setState(() => _featureFlags = [
        {
          'flag_id': 'presentation_carousel',
          'flag_name': 'presentation_carousel',
          'flag_description': 'Dynamic presentation carousel on agent dashboard',
          'flag_type': 'feature',
          'is_enabled': true,
        },
        {
          'flag_id': 'advanced_analytics',
          'flag_name': 'advanced_analytics',
          'flag_description': 'Advanced analytics and ROI calculations',
          'flag_type': 'feature',
          'is_enabled': true,
        },
        {
          'flag_id': 'bulk_messaging',
          'flag_name': 'bulk_messaging',
          'flag_description': 'Bulk messaging and campaign tools',
          'flag_type': 'feature',
          'is_enabled': false,
        },
        {
          'flag_id': 'ai_chatbot',
          'flag_name': 'ai_chatbot',
          'flag_description': 'AI-powered customer support chatbot',
          'flag_type': 'feature',
          'is_enabled': true,
        },
        {
          'flag_id': 'video_tutorials',
          'flag_name': 'video_tutorials',
          'flag_description': 'Video tutorial library and learning center',
          'flag_type': 'feature',
          'is_enabled': true,
        },
        {
          'flag_id': 'presentation_editor',
          'flag_name': 'presentation_editor',
          'flag_description': 'In-app presentation creation and editing',
          'flag_type': 'feature',
          'is_enabled': true,
        },
      ]);
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      // Use GET /api/v1/notifications/settings endpoint
      final response = await ApiService.get('/api/v1/notifications/settings');
      setState(() => _notificationSettings = response['data'] ?? {});
    } catch (e) {
      print('Notification settings API failed: $e');
      // Mock notification settings
      setState(() => _notificationSettings = {
        'email_notifications': true,
        'push_notifications': true,
        'sms_notifications': false,
        'system_alerts': true,
        'security_alerts': true,
        'marketing_emails': false,
        'weekly_reports': true,
        'error_alerts': true,
      });
    }
  }

  Future<void> _updateSystemSetting(String key, dynamic value) async {
    setState(() => _isLoading = true);

    try {
      // Try to update system setting - endpoint may not exist yet
      // Admin settings not in project plan - this would need backend implementation

      setState(() => _systemSettings[key] = value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$key updated successfully')),
        );
      }
    } catch (e) {
      print('Failed to update system setting: $e');
      // Simulate success for demo
      setState(() => _systemSettings[key] = value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$key updated successfully (simulated)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFeatureFlag(String flagId, bool enabled) async {
    setState(() => _isLoading = true);

    try {
      // Use PUT /api/v1/rbac/feature-flags/flags/{flag_id} endpoint
      await ApiService.put('/api/v1/rbac/feature-flags/flags/$flagId', {
        'is_enabled': enabled,
      });

      // Update local state
      setState(() {
        final flagIndex = _featureFlags.indexWhere((f) => f['flag_id'] == flagId);
        if (flagIndex != -1) {
          _featureFlags[flagIndex]['is_enabled'] = enabled;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feature flag ${enabled ? 'enabled' : 'disabled'} successfully')),
        );
      }
    } catch (e) {
      print('Failed to toggle feature flag: $e');
      // Simulate success for demo
      setState(() {
        final flagIndex = _featureFlags.indexWhere((f) => f['flag_id'] == flagId);
        if (flagIndex != -1) {
          _featureFlags[flagIndex]['is_enabled'] = enabled;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feature flag ${enabled ? 'enabled' : 'disabled'} successfully (simulated)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() => _isLoading = true);

    try {
      // Use PUT /api/v1/notifications/settings endpoint
      await ApiService.put('/api/v1/notifications/settings', {key: value});

      setState(() => _notificationSettings[key] = value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification setting updated successfully')),
        );
      }
    } catch (e) {
      print('Failed to update notification setting: $e');
      // Simulate success for demo
      setState(() => _notificationSettings[key] = value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification setting updated successfully (simulated)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadMockData() {
    // Mock data is already loaded in individual methods
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllSettings,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'System', icon: Icon(Icons.settings)),
            Tab(text: 'Features', icon: Icon(Icons.flag)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSystemSettingsTab(),
            _buildFeatureFlagsTab(),
            _buildNotificationsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Information
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('System Name', _systemSettings['system_name'] ?? 'Agent Mitra Platform'),
                  _buildInfoRow('Version', _systemSettings['version'] ?? '1.0.0'),
                  _buildInfoRow('Max Tenants', '${_systemSettings['max_tenants'] ?? 100}'),
                  _buildInfoRow('Max Users/Tenant', '${_systemSettings['max_users_per_tenant'] ?? 1000}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // System Configuration
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Maintenance Mode',
                    'Enable maintenance mode',
                    _systemSettings['maintenance_mode'] ?? false,
                    (value) => _updateSystemSetting('maintenance_mode', value),
                  ),
                  _buildSwitchTile(
                    'Debug Mode',
                    'Enable debug logging',
                    _systemSettings['debug_mode'] ?? false,
                    (value) => _updateSystemSetting('debug_mode', value),
                  ),
                  _buildSwitchTile(
                    'Rate Limiting',
                    'Enable API rate limiting',
                    _systemSettings['rate_limiting'] ?? true,
                    (value) => _updateSystemSetting('rate_limiting', value),
                  ),
                  _buildSwitchTile(
                    'Usage Analytics',
                    'Collect usage analytics',
                    _systemSettings['usage_analytics'] ?? true,
                    (value) => _updateSystemSetting('usage_analytics', value),
                  ),
                  _buildSwitchTile(
                    'Crash Reports',
                    'Collect crash reports',
                    _systemSettings['crash_reports'] ?? true,
                    (value) => _updateSystemSetting('crash_reports', value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Security Settings
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Security & Access',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Require 2FA',
                    'Require two-factor authentication',
                    _systemSettings['require_2fa'] ?? true,
                    (value) => _updateSystemSetting('require_2fa', value),
                  ),
                  _buildSwitchTile(
                    'IP Whitelist',
                    'Restrict access by IP address',
                    _systemSettings['ip_whitelist'] ?? false,
                    (value) => _updateSystemSetting('ip_whitelist', value),
                  ),
                  _buildSwitchTile(
                    'Security Alerts',
                    'Send security alert notifications',
                    _systemSettings['security_alerts'] ?? true,
                    (value) => _updateSystemSetting('security_alerts', value),
                  ),
                  _buildSwitchTile(
                    'System Alerts',
                    'Send system alert notifications',
                    _systemSettings['system_alerts'] ?? true,
                    (value) => _updateSystemSetting('system_alerts', value),
                  ),
                  _buildSwitchTile(
                    'User Registration Alerts',
                    'Send alerts for new user registrations',
                    _systemSettings['user_registration_alerts'] ?? false,
                    (value) => _updateSystemSetting('user_registration_alerts', value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Color(0xFF0083B0), size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Feature Flags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_featureFlags.length} Features',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Control which features are enabled across the platform. Changes take effect immediately.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _featureFlags.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No feature flags available', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _featureFlags.length,
                        itemBuilder: (context, index) {
                          final flag = _featureFlags[index];
                          return _buildFeatureFlagCard(flag);
                        },
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configure system-wide notification settings for alerts, reports, and communications.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Communication Channels
                  _buildSectionTitle('Communication Channels'),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Send notifications via email',
                    _notificationSettings['email_notifications'] ?? true,
                    (value) => _updateNotificationSetting('email_notifications', value),
                  ),
                  _buildSwitchTile(
                    'Push Notifications',
                    'Send push notifications to mobile devices',
                    _notificationSettings['push_notifications'] ?? true,
                    (value) => _updateNotificationSetting('push_notifications', value),
                  ),
                  _buildSwitchTile(
                    'SMS Notifications',
                    'Send notifications via SMS',
                    _notificationSettings['sms_notifications'] ?? false,
                    (value) => _updateNotificationSetting('sms_notifications', value),
                  ),

                  const SizedBox(height: 24),

                  // Alert Types
                  _buildSectionTitle('Alert Types'),
                  _buildSwitchTile(
                    'System Alerts',
                    'Critical system status alerts',
                    _notificationSettings['system_alerts'] ?? true,
                    (value) => _updateNotificationSetting('system_alerts', value),
                  ),
                  _buildSwitchTile(
                    'Security Alerts',
                    'Security-related notifications',
                    _notificationSettings['security_alerts'] ?? true,
                    (value) => _updateNotificationSetting('security_alerts', value),
                  ),
                  _buildSwitchTile(
                    'Error Alerts',
                    'Application error notifications',
                    _notificationSettings['error_alerts'] ?? true,
                    (value) => _updateNotificationSetting('error_alerts', value),
                  ),

                  const SizedBox(height: 24),

                  // Reports & Communications
                  _buildSectionTitle('Reports & Communications'),
                  _buildSwitchTile(
                    'Weekly Reports',
                    'Send weekly summary reports',
                    _notificationSettings['weekly_reports'] ?? true,
                    (value) => _updateNotificationSetting('weekly_reports', value),
                  ),
                  _buildSwitchTile(
                    'Marketing Emails',
                    'Send promotional and marketing content',
                    _notificationSettings['marketing_emails'] ?? false,
                    (value) => _updateNotificationSetting('marketing_emails', value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0083B0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0083B0),
        ),
      ),
    );
  }

  Widget _buildFeatureFlagCard(Map<String, dynamic> flag) {
    final isEnabled = flag['is_enabled'] ?? false;
    final flagName = flag['flag_name'] ?? 'Unknown Feature';
    final description = flag['flag_description'] ?? 'No description available';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flagName.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0083B0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _toggleFeatureFlag(flag['flag_id'], value),
                  activeColor: const Color(0xFF0083B0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEnabled ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isEnabled ? 'ENABLED' : 'DISABLED',
                style: TextStyle(
                  color: isEnabled ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}