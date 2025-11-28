import 'package:flutter/material.dart';
import '../core/services/localization_service.dart';
import '../core/services/auth_service.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _screenReaderEnabled = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();

    // Load current accessibility settings
    _loadAccessibilitySettings();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadAccessibilitySettings() {
    // Load from AccessibilityService (would be implemented with persistent storage)
    setState(() {
      _highContrast = AccessibilityService.highContrast;
      _reduceMotion = AccessibilityService.reduceMotion;
      _screenReaderEnabled = AccessibilityService.screenReaderEnabled;
      _fontSize = AccessibilityService.fontSize;
    });
  }

  void _saveAccessibilitySettings() {
    // Update AccessibilityService
    AccessibilityService.setFontSize(_fontSize);
    AccessibilityService.toggleHighContrast();
    AccessibilityService.toggleReduceMotion();
    AccessibilityService.setScreenReaderEnabled(_screenReaderEnabled);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Accessibility settings saved'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Accessibility Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Customize your experience',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Adjust settings to make the app more accessible for your needs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: 32),

                // Font Size Setting
                _buildSettingCard(
                  title: 'Font Size',
                  subtitle: 'Adjust text size for better readability',
                  child: Column(
                    children: [
                      Slider(
                        value: _fontSize,
                        min: AccessibilityService._minFontSize,
                        max: AccessibilityService._maxFontSize,
                        divisions: 8,
                        label: '${_fontSize.toInt()}px',
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Small',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Sample Text',
                              style: TextStyle(
                                fontSize: _fontSize,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            'Large',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // High Contrast Setting
                _buildSettingCard(
                  title: 'High Contrast',
                  subtitle: 'Increase contrast for better visibility',
                  child: SwitchListTile(
                    title: const Text('Enable high contrast mode'),
                    subtitle: const Text('Makes text and buttons more distinguishable'),
                    value: _highContrast,
                    onChanged: (value) {
                      setState(() {
                        _highContrast = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Reduce Motion Setting
                _buildSettingCard(
                  title: 'Reduce Motion',
                  subtitle: 'Minimize animations and transitions',
                  child: SwitchListTile(
                    title: const Text('Reduce motion and animations'),
                    subtitle: const Text('Helps with motion sensitivity'),
                    value: _reduceMotion,
                    onChanged: (value) {
                      setState(() {
                        _reduceMotion = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Screen Reader Setting
                _buildSettingCard(
                  title: 'Screen Reader',
                  subtitle: 'Enable screen reader support',
                  child: SwitchListTile(
                    title: const Text('Screen reader announcements'),
                    subtitle: const Text('Announce important actions and changes'),
                    value: _screenReaderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _screenReaderEnabled = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Preview Section
                _buildSettingCard(
                  title: 'Preview',
                  subtitle: 'See how your settings will look',
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _highContrast ? Colors.black : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _highContrast ? Colors.white : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This is how text will appear',
                          style: AccessibilityService.getAccessibleTextStyle(
                            baseStyle: TextStyle(
                              color: _highContrast ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            isHeading: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Regular body text with the selected font size and contrast settings.',
                          style: AccessibilityService.getAccessibleTextStyle(
                            baseStyle: TextStyle(
                              color: _highContrast ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: AccessibilityService.getAccessibleButtonStyle(),
                          child: const Text('Sample Button'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveAccessibilitySettings,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Reset to defaults
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _fontSize = AccessibilityService._defaultFontSize;
                        _highContrast = false;
                        _reduceMotion = false;
                        _screenReaderEnabled = false;
                      });
                    },
                    child: Text(
                      'Reset to defaults',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need help?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'If you need assistance with accessibility settings or have questions about app features, contact our support team.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}