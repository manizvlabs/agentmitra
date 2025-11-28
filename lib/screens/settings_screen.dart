import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/api_service.dart';
import '../shared/widgets/loading_overlay.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _settings = {};
  Map<String, dynamic> _userProfile = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      // Load user settings
      final settingsResponse = await ApiService.get('/api/v1/users/settings');
      final profileResponse = await ApiService.get('/api/v1/users/profile');

      setState(() {
        _settings = settingsResponse['data'] ?? {};
        _userProfile = profileResponse['data'] ?? {};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load settings: $e')),
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
      await ApiService.put('/api/v1/users/settings', {
        key: value,
      });

      setState(() {
        _settings[key] = value;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: ListView(
          children: [
            // Profile Section
            _buildSectionHeader('Profile', Icons.person),
            _buildProfileTile(),

            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications),
            _buildNotificationSettings(),

            const SizedBox(height: 16),

            // Privacy Section
            _buildSectionHeader('Privacy & Security', Icons.security),
            _buildPrivacySettings(),

            const SizedBox(height: 16),

            // App Preferences Section
            _buildSectionHeader('App Preferences', Icons.settings),
            _buildAppPreferences(),

            const SizedBox(height: 16),

            // Support Section
            _buildSectionHeader('Support & Help', Icons.help),
            _buildSupportSection(),

            const SizedBox(height: 16),

            // Account Section
            _buildSectionHeader('Account', Icons.account_circle),
            _buildAccountSection(),

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
          Icon(icon, color: Colors.red, size: 20),
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

  Widget _buildProfileTile() {
    final user = AuthService().currentUser;
    final profileName = _userProfile['name'] ?? user?.name ?? 'Unknown User';
    final profileEmail = _userProfile['email'] ?? user?.email ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.shade100,
        child: Text(
          profileName.isNotEmpty ? profileName[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(profileName),
      subtitle: Text(profileEmail),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showProfileDialog(),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        _buildSwitchTile(
          'Push Notifications',
          'Receive push notifications for important updates',
          _settings['push_notifications'] ?? true,
          (value) => _updateSetting('push_notifications', value),
        ),
        _buildSwitchTile(
          'Email Notifications',
          'Receive email notifications for policy updates',
          _settings['email_notifications'] ?? true,
          (value) => _updateSetting('email_notifications', value),
        ),
        _buildSwitchTile(
          'SMS Notifications',
          'Receive SMS alerts for critical updates',
          _settings['sms_notifications'] ?? false,
          (value) => _updateSetting('sms_notifications', value),
        ),
        _buildSwitchTile(
          'Payment Reminders',
          'Get reminded about upcoming premium payments',
          _settings['payment_reminders'] ?? true,
          (value) => _updateSetting('payment_reminders', value),
        ),
        _buildSwitchTile(
          'Marketing Communications',
          'Receive offers and promotional content',
          _settings['marketing_communications'] ?? false,
          (value) => _updateSetting('marketing_communications', value),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      children: [
        ListTile(
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showChangePasswordDialog(),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          subtitle: const Text('Read our privacy policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showPrivacyPolicy(),
        ),
        ListTile(
          title: const Text('Data Usage'),
          subtitle: const Text('Control how your data is used'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDataUsageDialog(),
        ),
        _buildSwitchTile(
          'Biometric Authentication',
          'Use fingerprint or face unlock',
          _settings['biometric_auth'] ?? false,
          (value) => _updateSetting('biometric_auth', value),
        ),
        _buildSwitchTile(
          'Data Analytics',
          'Help improve the app by sharing usage data',
          _settings['data_analytics'] ?? true,
          (value) => _updateSetting('data_analytics', value),
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return Column(
      children: [
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_settings['language'] ?? 'English'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(),
        ),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_getThemeName(_settings['theme'] ?? 'system')),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showThemeDialog(),
        ),
        _buildSwitchTile(
          'Auto-lock',
          'Automatically lock the app after inactivity',
          _settings['auto_lock'] ?? true,
          (value) => _updateSetting('auto_lock', value),
        ),
        ListTile(
          title: const Text('Cache Management'),
          subtitle: const Text('Clear app cache and temporary files'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showCacheManagementDialog(),
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Help & Support'),
          subtitle: const Text('Get help and contact support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showHelpDialog(),
        ),
        ListTile(
          title: const Text('FAQ'),
          subtitle: const Text('Frequently asked questions'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showFAQDialog(),
        ),
        ListTile(
          title: const Text('Contact Us'),
          subtitle: const Text('Reach out to our support team'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showContactDialog(),
        ),
        ListTile(
          title: const Text('Rate App'),
          subtitle: const Text('Rate us on the app store'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _rateApp(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      children: [
        ListTile(
          title: const Text('Account Information'),
          subtitle: const Text('View and manage your account details'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAccountInfoDialog(),
        ),
        ListTile(
          title: const Text('Subscription'),
          subtitle: Text(_getSubscriptionStatus()),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSubscriptionDialog(),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Sign out of your account'),
          trailing: const Icon(Icons.logout, color: Colors.red),
          onTap: () => _confirmLogout(),
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
      activeColor: Colors.red,
    );
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  String _getSubscriptionStatus() {
    final trialEndDate = _userProfile['trial_end_date'];
    final isSubscribed = _userProfile['is_subscribed'] ?? false;

    if (isSubscribed) {
      return 'Active Subscription';
    } else if (trialEndDate != null) {
      final endDate = DateTime.parse(trialEndDate);
      final daysLeft = endDate.difference(DateTime.now()).inDays;
      if (daysLeft > 0) {
        return 'Trial - $daysLeft days left';
      } else {
        return 'Trial Expired';
      }
    } else {
      return 'Free Plan';
    }
  }

  void _showProfileDialog() {
    final nameController = TextEditingController(text: _userProfile['name'] ?? '');
    final emailController = TextEditingController(text: _userProfile['email'] ?? '');
    final phoneController = TextEditingController(text: _userProfile['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.put('/api/v1/users/profile', {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                });

                setState(() {
                  _userProfile['name'] = nameController.text;
                  _userProfile['email'] = emailController.text;
                  _userProfile['phone'] = phoneController.text;
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update profile: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }

              try {
                await ApiService.put('/api/v1/users/change-password', {
                  'current_password': currentPasswordController.text,
                  'new_password': newPasswordController.text,
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to change password: $e')),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Hindi', 'Telugu'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _settings['language'] ?? 'English',
              onChanged: (value) async {
                await _updateSetting('language', value);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final themes = [
      {'value': 'system', 'label': 'System Default'},
      {'value': 'light', 'label': 'Light Theme'},
      {'value': 'dark', 'label': 'Dark Theme'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return RadioListTile<String>(
              title: Text(theme['label']!),
              value: theme['value'],
              groupValue: _settings['theme'] ?? 'system',
              onChanged: (value) async {
                await _updateSetting('theme', value);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content would go here...\n\n'
            'We are committed to protecting your privacy and ensuring the security of your personal information...',
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

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage Preferences'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose what data you want to share:'),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Usage Analytics',
              'Help us improve by sharing app usage data',
              _settings['usage_analytics'] ?? true,
              (value) => _updateSetting('usage_analytics', value),
            ),
            _buildSwitchTile(
              'Crash Reports',
              'Automatically send crash reports to help fix issues',
              _settings['crash_reports'] ?? true,
              (value) => _updateSetting('crash_reports', value),
            ),
          ],
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

  void _showCacheManagementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Management'),
        content: const Text(
          'Clearing cache will remove temporary files and may improve app performance. '
          'You will need to re-download some content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement cache clearing
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Text(
            'Need help? Here are some ways we can assist you:\n\n'
            '• Check our FAQ section for common questions\n'
            '• Contact our support team for personalized help\n'
            '• Visit our help center for detailed guides\n\n'
            'Support Hours: Mon-Fri 9 AM - 6 PM IST',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _showContactDialog(),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showFAQDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: const SingleChildScrollView(
          child: Text(
            'Q: How do I file a claim?\n'
            'A: Go to the Claims section and select "File New Claim"\n\n'
            'Q: How do I update my profile?\n'
            'A: Tap on your profile in Settings to edit your information\n\n'
            'Q: How do I change my password?\n'
            'A: Go to Privacy & Security > Change Password\n\n'
            'For more FAQs, visit our help center.',
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

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Email Support'),
              subtitle: const Text('support@agentmitra.com'),
              onTap: () {
                // Implement email functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email client would open here')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Support'),
              subtitle: const Text('+91-1800-XXX-XXXX'),
              onTap: () {
                // Implement phone call functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone dialer would open here')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 9 AM - 6 PM IST'),
              onTap: () {
                // Implement live chat
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live chat would open here')),
                );
              },
            ),
          ],
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

  void _rateApp() {
    // Implement app rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('App Store would open for rating')),
    );
  }

  void _showAccountInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ID: ${_userProfile['user_id'] ?? 'N/A'}'),
              Text('Agent Code: ${_userProfile['agent_code'] ?? 'N/A'}'),
              Text('Account Status: ${_userProfile['status'] ?? 'Active'}'),
              Text('Member Since: ${_userProfile['created_at'] ?? 'N/A'}'),
              Text('Last Login: ${_userProfile['last_login'] ?? 'N/A'}'),
            ],
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

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan: ${_userProfile['subscription_plan'] ?? 'Free Trial'}'),
              Text('Status: ${_getSubscriptionStatus()}'),
              if (_userProfile['trial_end_date'] != null)
                Text('Trial Ends: ${_userProfile['trial_end_date']}'),
              Text('Customers: ${_userProfile['customer_count'] ?? 0}'),
              Text('Policies: ${_userProfile['policy_count'] ?? 0}'),
            ],
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
              // Navigate to subscription upgrade screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscription upgrade coming soon')),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService().logout();
              Navigator.of(context).pop(); // Close dialog
              // Navigate to login screen would happen here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
