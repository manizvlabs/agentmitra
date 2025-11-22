import 'package:flutter/material.dart';
import '../core/services/accessibility_service.dart';

/// Accessibility Settings Screen
/// Allows users to configure accessibility preferences
class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();

  late double _fontScale;
  late bool _highContrast;
  late bool _screenReader;
  late bool _reducedMotion;
  late bool _largeTouchTargets;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _accessibilityService.initialize();

    setState(() {
      _fontScale = _accessibilityService.fontScale;
      _highContrast = _accessibilityService.highContrast;
      _screenReader = _accessibilityService.screenReader;
      _reducedMotion = _accessibilityService.reducedMotion;
      _largeTouchTargets = _accessibilityService.largeTouchTargets;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Accessibility Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Text & Display',
                'Customize how text and content appear on screen',
              ),
              const SizedBox(height: 16),
              _buildFontScaleSetting(),
              const SizedBox(height: 16),
              _buildHighContrastSetting(),
              const SizedBox(height: 24),

              _buildSectionHeader(
                'Interaction',
                'Configure how you interact with the app',
              ),
              const SizedBox(height: 16),
              _buildScreenReaderSetting(),
              const SizedBox(height: 16),
              _buildReducedMotionSetting(),
              const SizedBox(height: 16),
              _buildLargeTouchTargetsSetting(),
              const SizedBox(height: 32),

              _buildAccessibilityInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _accessibilityService.getAccessibleTextStyle(
            baseStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            isHeading: true,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: _accessibilityService.getAccessibleTextStyle(
            baseStyle: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontScaleSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Text Size',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${(_fontScale * 100).round()}%',
                  style: _accessibilityService.getAccessibleTextStyle(
                    baseStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _fontScale,
              min: 0.8,
              max: 2.0,
              divisions: 6,
              label: '${(_fontScale * 100).round()}%',
              onChanged: (value) {
                setState(() {
                  _fontScale = value;
                });
                _accessibilityService.setFontScale(value);
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Smaller',
                  style: _accessibilityService.getAccessibleTextStyle(
                    baseStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  'Larger',
                  style: _accessibilityService.getAccessibleTextStyle(
                    baseStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighContrastSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.contrast,
              color: _highContrast ? Colors.yellow.shade700 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High Contrast',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Increase contrast for better visibility',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'High contrast mode',
              hint: _highContrast ? 'Currently enabled' : 'Currently disabled',
              toggled: _highContrast,
              child: Switch(
                value: _highContrast,
                onChanged: (value) {
                  setState(() {
                    _highContrast = value;
                  });
                  _accessibilityService.setHighContrast(value);
                },
                activeColor: Colors.yellow.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenReaderSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.record_voice_over,
              color: _screenReader ? Colors.blue.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Screen Reader',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Enable screen reader announcements',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Screen reader mode',
              hint: _screenReader ? 'Currently enabled' : 'Currently disabled',
              toggled: _screenReader,
              child: Switch(
                value: _screenReader,
                onChanged: (value) {
                  setState(() {
                    _screenReader = value;
                  });
                  _accessibilityService.setScreenReader(value);
                },
                activeColor: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReducedMotionSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.motion_photos_off,
              color: _reducedMotion ? Colors.green.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reduced Motion',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Minimize animations and transitions',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Reduced motion',
              hint: _reducedMotion ? 'Currently enabled' : 'Currently disabled',
              toggled: _reducedMotion,
              child: Switch(
                value: _reducedMotion,
                onChanged: (value) {
                  setState(() {
                    _reducedMotion = value;
                  });
                  _accessibilityService.setReducedMotion(value);
                },
                activeColor: Colors.green.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeTouchTargetsSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.touch_app,
              color: _largeTouchTargets ? Colors.purple.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Large Touch Targets',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Increase button and touch target sizes',
                    style: _accessibilityService.getAccessibleTextStyle(
                      baseStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Large touch targets',
              hint: _largeTouchTargets ? 'Currently enabled' : 'Currently disabled',
              toggled: _largeTouchTargets,
              child: Switch(
                value: _largeTouchTargets,
                onChanged: (value) {
                  setState(() {
                    _largeTouchTargets = value;
                  });
                  _accessibilityService.setLargeTouchTargets(value);
                },
                activeColor: Colors.purple.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibilityInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Text(
                  'Accessibility Information',
                  style: _accessibilityService.getAccessibleTextStyle(
                    baseStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade600,
                    ),
                    isImportant: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These settings help make the app more accessible for users with disabilities. Changes take effect immediately and are saved automatically.',
              style: _accessibilityService.getAccessibleTextStyle(
                baseStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all accessibility settings to their defaults?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _accessibilityService.resetToDefaults();
              await _loadSettings(); // Reload settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Accessibility settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
