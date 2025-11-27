import 'package:flutter/material.dart';
import '../services/pioneer_service.dart';
import 'error_pages/trial_expired_page.dart';
import 'error_pages/unauthorized_page.dart';

/// Feature Flag Page Builder
/// Conditionally renders pages based on feature flags
class FeatureFlagPageBuilder extends StatelessWidget {
  final String featureFlagName;
  final Widget enabledPage;
  final Widget? disabledPage;
  final Map<String, dynamic>? pageParams;

  const FeatureFlagPageBuilder({
    super.key,
    required this.featureFlagName,
    required this.enabledPage,
    this.disabledPage,
    this.pageParams,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkFeatureFlag(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error checking feature flag',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final isEnabled = snapshot.data ?? false;

        if (!isEnabled) {
          return disabledPage ?? _buildDefaultDisabledPage(context);
        }

        return enabledPage;
      },
    );
  }

  Future<bool> _checkFeatureFlag() async {
    if (!PioneerService.isInitialized) {
      // If Pioneer is not initialized, default to enabled for development
      return true;
    }

    try {
      return await PioneerService.isFeatureEnabled(
        featureFlagName,
        defaultValue: true, // Default to enabled on error
      );
    } catch (e) {
      // On error, default to enabled to prevent blocking users
      return true;
    }
  }

  Widget _buildDefaultDisabledPage(BuildContext context) {
    // Check if it's a trial-related feature
    if (featureFlagName.contains('trial') || featureFlagName.contains('premium')) {
      return const TrialExpiredPage();
    }

    // Check if it's a permission-related feature
    if (featureFlagName.contains('admin') || featureFlagName.contains('management')) {
      return const UnauthorizedPage();
    }

    // Default disabled page
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Unavailable'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Feature Unavailable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is currently disabled.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for easier feature flag checking
extension FeatureFlagExtension on BuildContext {
  /// Check if a feature is enabled
  Future<bool> isFeatureEnabled(
    String flagName, {
    bool defaultValue = true,
  }) async {
    if (!PioneerService.isInitialized) {
      return defaultValue; // Default to enabled if Pioneer not initialized
    }

    try {
      return await PioneerService.isFeatureEnabled(
        flagName,
        defaultValue: defaultValue,
      );
    } catch (e) {
      return defaultValue; // Default to enabled on error
    }
  }

  /// Build a page with feature flag check
  Widget buildWithFeatureFlag({
    required String flagName,
    required Widget enabledPage,
    Widget? disabledPage,
  }) {
    return FeatureFlagPageBuilder(
      featureFlagName: flagName,
      enabledPage: enabledPage,
      disabledPage: disabledPage,
    );
  }
}

