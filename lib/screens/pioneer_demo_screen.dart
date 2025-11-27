import 'package:flutter/material.dart';
import '../core/services/pioneer_service.dart';

class PioneerDemoScreen extends StatefulWidget {
  const PioneerDemoScreen({super.key});

  @override
  State<PioneerDemoScreen> createState() => _PioneerDemoScreenState();
}

class _PioneerDemoScreenState extends State<PioneerDemoScreen> {
  bool _isInitialized = false;
  Map<String, bool> _featureFlags = {};

  @override
  void initState() {
    super.initState();
    _checkInitialization();
    _loadFeatureFlags();
  }

  void _checkInitialization() {
    setState(() {
      _isInitialized = PioneerService.isInitialized;
    });
  }

  void _loadFeatureFlags() async {
    if (!PioneerService.isInitialized) return;

    // Test common feature flags - these should exist in your Pioneer instance
    final flags = [
      'presentation_carousel_enabled',
      'presentation_editor_enabled',
      'presentation_templates_enabled',
      'presentation_offline_mode_enabled',
      'presentation_analytics_enabled',
      'presentation_branding_enabled',
      'agent_dashboard_enabled',
      'whatsapp_integration_enabled',
      'chatbot_assistance_enabled',
      'roi_analytics_enabled',
    ];

    // Load flags asynchronously
    for (final flag in flags) {
      try {
        _featureFlags[flag] = await PioneerService.isFeatureEnabled(flag);
      } catch (e) {
        _featureFlags[flag] = false;
        debugPrint('Error loading flag $flag: $e');
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshFeatures() async {
    await PioneerService.refreshFeatures();
    _loadFeatureFlags();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pioneer Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshFeatures,
            tooltip: 'Refresh Features',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pioneer Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isInitialized
                          ? 'Pioneer is initialized and connected'
                          : 'Pioneer is not initialized. Check configuration.',
                      style: TextStyle(
                        color: _isInitialized ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Feature Flags List
            Text(
              'Feature Flags',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            if (_featureFlags.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('No feature flags loaded'),
                  ),
                ),
              )
            else
              ..._featureFlags.entries.map((entry) => Card(
                    child: ListTile(
                      title: Text(
                        entry.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(entry.key),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: entry.value ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          entry.value ? 'ENABLED' : 'DISABLED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),

            const SizedBox(height: 24),

            // Test Container Color Feature (from sample)
            Text(
              'Live Feature Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            if (_featureFlags.containsKey('presentation_carousel_enabled'))
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: _featureFlags['presentation_carousel_enabled'] == true ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _featureFlags['presentation_carousel_enabled'] == true
                        ? 'Presentation Carousel Enabled'
                        : 'Presentation Carousel Disabled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Feature Not Found',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            Text(
              'This container shows presentation carousel status based on the "presentation_carousel_enabled" flag in Pioneer.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Feature Details
            if (_isInitialized)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Features Loaded: ${PioneerService.getAllFeatures().length}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      if (PioneerService.getFeatureDetails('presentation_carousel_enabled') != null)
                        Text(
                          'presentation_carousel_enabled: ${PioneerService.getFeatureDetails('presentation_carousel_enabled')!['value']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Test:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Go to your Pioneer admin panel\n'
                      '2. Toggle the "presentation_carousel_enabled" flag\n'
                      '3. The container above should change status in real-time\n'
                      '4. Try toggling other feature flags to see them update',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
