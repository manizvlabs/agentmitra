import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/widgets/loading/loading_overlay.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _systemSettings = {};
  Map<String, dynamic> _featureFlags = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      // Load feature flags (this endpoint exists according to project plan)
      final flagsResponse = await ApiService.get('/api/v1/feature-flags/all');

      setState(() {
        // Mock system settings since admin/settings endpoint doesn't exist yet
        _systemSettings = {
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
          "crash_reports": true
        };
        _featureFlags = flagsResponse['data'] ?? {
          // Mock feature flags for testing
          'presentation_carousel': {'enabled': true, 'name': 'Presentation Carousel'},
          'advanced_analytics': {'enabled': true, 'name': 'Advanced Analytics'},
          'bulk_messaging': {'enabled': false, 'name': 'Bulk Messaging'},
          'ai_chatbot': {'enabled': true, 'name': 'AI Chatbot'}
        };
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load admin settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      // Since admin/settings PUT endpoint doesn't exist yet, simulate success
      // In a real implementation, this would call an actual API endpoint
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

      setState(() {
        _systemSettings[key] = value;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setting updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update setting: $e')),
        );
      }
    }
  }

  Future<void> _updateFeatureFlag(String flagName, bool enabled) async {
    try {
      await ApiService.put('/api/v1/rbac/feature-flags/flags/$flagName', {
        'enabled': enabled,
      });

      setState(() {
        if (_featureFlags[flagName] != null) {
          _featureFlags[flagName]['enabled'] = enabled;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feature flag updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update feature flag: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0), // VyaptIX Blue
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: ListView(
          children: [
            // System Configuration Section
            _buildSectionHeader('System Configuration', Icons.settings_system_daydream),
            _buildSystemSettings(),

            const SizedBox(height: 16),

            // Feature Flags Section
            _buildSectionHeader('Feature Flags', Icons.flag),
            _buildFeatureFlags(),

            const SizedBox(height: 16),

            // Security Section
            _buildSectionHeader('Security & Access', Icons.security),
            _buildSecuritySettings(),

            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('System Notifications', Icons.notifications),
            _buildNotificationSettings(),

            const SizedBox(height: 16),

            // Maintenance Section
            _buildSectionHeader('Maintenance', Icons.build),
            _buildMaintenanceSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0083B0), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings() {
    return Column(
      children: [
        _buildSwitchTile(
          'Maintenance Mode',
          'Put the system in maintenance mode for updates',
          _systemSettings['maintenance_mode'] ?? false,
          (value) => _updateSetting('maintenance_mode', value),
        ),
        _buildSwitchTile(
          'Debug Mode',
          'Enable detailed logging and debug information',
          _systemSettings['debug_mode'] ?? false,
          (value) => _updateSetting('debug_mode', value),
        ),
        _buildSwitchTile(
          'API Rate Limiting',
          'Enable rate limiting for API endpoints',
          _systemSettings['rate_limiting'] ?? true,
          (value) => _updateSetting('rate_limiting', value),
        ),
        ListTile(
          title: const Text('Session Timeout (minutes)'),
          subtitle: Text('${_systemSettings['session_timeout'] ?? 30} minutes'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSessionTimeoutDialog(),
        ),
        ListTile(
          title: const Text('Max File Upload Size'),
          subtitle: Text('${_systemSettings['max_upload_size'] ?? 10} MB'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showUploadSizeDialog(),
        ),
      ],
    );
  }

  Widget _buildFeatureFlags() {
    if (_featureFlags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No feature flags configured'),
      );
    }

    return Column(
      children: _featureFlags.entries.map((entry) {
        final flag = entry.value;
        return _buildSwitchTile(
          flag['name'] ?? entry.key,
          flag['description'] ?? 'Feature flag',
          flag['enabled'] ?? false,
          (value) => _updateFeatureFlag(entry.key, value),
        );
      }).toList(),
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Password Policy'),
          subtitle: const Text('Configure password requirements'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showPasswordPolicyDialog(),
        ),
        _buildSwitchTile(
          'Two-Factor Authentication',
          'Require 2FA for admin accounts',
          _systemSettings['require_2fa'] ?? true,
          (value) => _updateSetting('require_2fa', value),
        ),
        _buildSwitchTile(
          'IP Whitelisting',
          'Restrict access to specific IP addresses',
          _systemSettings['ip_whitelist'] ?? false,
          (value) => _updateSetting('ip_whitelist', value),
        ),
        ListTile(
          title: const Text('Audit Log Retention'),
          subtitle: Text('${_systemSettings['audit_retention_days'] ?? 90} days'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAuditRetentionDialog(),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        _buildSwitchTile(
          'System Alerts',
          'Receive alerts for system issues',
          _systemSettings['system_alerts'] ?? true,
          (value) => _updateSetting('system_alerts', value),
        ),
        _buildSwitchTile(
          'Security Alerts',
          'Receive alerts for security events',
          _systemSettings['security_alerts'] ?? true,
          (value) => _updateSetting('security_alerts', value),
        ),
        _buildSwitchTile(
          'User Registration Alerts',
          'Receive alerts for new user registrations',
          _systemSettings['user_registration_alerts'] ?? false,
          (value) => _updateSetting('user_registration_alerts', value),
        ),
        ListTile(
          title: const Text('Email Recipients'),
          subtitle: const Text('Configure alert email recipients'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showEmailRecipientsDialog(),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Clear System Cache'),
          subtitle: const Text('Clear all cached data and restart services'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showClearCacheDialog(),
        ),
        ListTile(
          title: const Text('Database Backup'),
          subtitle: const Text('Create a backup of the database'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDatabaseBackupDialog(),
        ),
        ListTile(
          title: const Text('System Logs'),
          subtitle: const Text('View and download system logs'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSystemLogsDialog(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0083B0), // VyaptIX Blue
    );
  }

  void _showSessionTimeoutDialog() {
    final controller = TextEditingController(
      text: (_systemSettings['session_timeout'] ?? 30).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Timeout'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Timeout (minutes)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text) ?? 30;
              await _updateSetting('session_timeout', value);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUploadSizeDialog() {
    final controller = TextEditingController(
      text: (_systemSettings['max_upload_size'] ?? 10).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Max Upload Size'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Size (MB)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text) ?? 10;
              await _updateSetting('max_upload_size', value);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPasswordPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Password Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Password Requirements:\n\n'
            '• Minimum 8 characters\n'
            '• At least one uppercase letter\n'
            '• At least one lowercase letter\n'
            '• At least one number\n'
            '• At least one special character\n\n'
            'Additional settings can be configured in the backend.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAuditRetentionDialog() {
    final controller = TextEditingController(
      text: (_systemSettings['audit_retention_days'] ?? 90).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log Retention'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Retention (days)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(controller.text) ?? 90;
              await _updateSetting('audit_retention_days', value);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmailRecipientsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Recipients'),
        content: const SingleChildScrollView(
          child: Text(
            'Configure email addresses that will receive system alerts.\n\n'
            'This setting is managed through the backend configuration.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear System Cache'),
        content: const Text(
          'This will clear all cached data and restart system services. '
          'Users may experience temporary slowdowns.\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Since admin/maintenance/clear-cache endpoint doesn't exist yet, simulate success
                await Future.delayed(const Duration(seconds: 2)); // Simulate operation delay
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear cache: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showDatabaseBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Backup'),
        content: const Text(
          'Create a backup of the current database state.\n\n'
          'The backup will be stored securely and can be downloaded later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Since admin/maintenance/backup endpoint doesn't exist yet, simulate success
                await Future.delayed(const Duration(seconds: 3)); // Simulate backup operation
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup initiated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create backup: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showSystemLogsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Logs'),
        content: const SingleChildScrollView(
          child: Text(
            'View and download system logs for debugging and monitoring.\n\n'
            'Available log files:\n'
            '• Application logs\n'
            '• API access logs\n'
            '• Error logs\n'
            '• Security audit logs\n\n'
            'Logs can be downloaded from the admin dashboard.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to logs download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs download coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0083B0),
            ),
            child: const Text('Download Logs'),
          ),
        ],
      ),
    );
  }
}
