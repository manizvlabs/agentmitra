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
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('/api/v1/admin/settings');
      setState(() => _settings = response as Map<String, dynamic>);
    } catch (e) {
      print('Failed to load settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load settings. Please try again.')),
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
      await ApiService.put('/api/v1/admin/settings', {
        'key': key,
        'value': value.toString(),
      });

      setState(() => _settings[key] = value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$key updated successfully')),
        );
      }
    } catch (e) {
      print('Failed to update setting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update setting. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0083B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSettings,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _settings.isEmpty && !_isLoading
            ? const Center(child: Text('No settings available'))
            : _buildSettingsList(),
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('System Configuration'),
        _buildSwitchSetting('Maintenance Mode', 'maintenance_mode'),
        _buildSwitchSetting('Debug Mode', 'debug_mode'),
        _buildSwitchSetting('Rate Limiting', 'rate_limiting'),

        const SizedBox(height: 24),
        _buildSectionHeader('Security Settings'),
        _buildSwitchSetting('Require 2FA', 'require_2fa'),
        _buildSwitchSetting('IP Whitelist', 'ip_whitelist'),
        _buildSwitchSetting('Security Alerts', 'security_alerts'),

        const SizedBox(height: 24),
        _buildSectionHeader('User Management'),
        _buildSwitchSetting('User Registration Alerts', 'user_registration_alerts'),
        _buildNumericSetting('Session Timeout (minutes)', 'session_timeout'),
        _buildNumericSetting('Audit Retention (days)', 'audit_retention_days'),

        const SizedBox(height: 24),
        _buildSectionHeader('System Limits'),
        _buildNumericSetting('Max Upload Size (MB)', 'max_upload_size'),

        const SizedBox(height: 24),
        _buildSectionHeader('Analytics & Monitoring'),
        _buildSwitchSetting('Usage Analytics', 'usage_analytics'),
        _buildSwitchSetting('System Alerts', 'system_alerts'),
        _buildSwitchSetting('Crash Reports', 'crash_reports'),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0083B0),
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(String label, String key) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(label),
        value: _settings[key] ?? false,
        onChanged: (value) => _updateSetting(key, value),
        activeColor: const Color(0xFF0083B0),
      ),
    );
  }

  Widget _buildNumericSetting(String label, String key) {
    final controller = TextEditingController(text: (_settings[key] ?? 0).toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(label),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onSubmitted: (value) {
                  final numValue = int.tryParse(value);
                  if (numValue != null) {
                    _updateSetting(key, numValue);
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
