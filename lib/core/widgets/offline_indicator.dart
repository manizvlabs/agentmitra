import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/global_providers.dart';

/// Offline indicator widget that shows connectivity and sync status
class OfflineIndicator extends ConsumerWidget {
  final bool showWhenOnline;
  final EdgeInsetsGeometry? margin;
  final double? height;

  const OfflineIndicator({
    super.key,
    this.showWhenOnline = false,
    this.margin,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityResult = ref.watch(connectivityProvider);
    final isOffline = connectivityResult == ConnectivityResult.none;

    // Don't show anything if online and showWhenOnline is false
    if (!isOffline && !showWhenOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      height: height ?? 32,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isOffline ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isOffline ? () => _showOfflineDialog(context, ref) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline ? Icons.wifi_off : Icons.wifi,
                  size: 16,
                  color: isOffline ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  isOffline ? 'Offline Mode' : 'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOffline ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
                if (isOffline) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.red.shade700,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOfflineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const OfflineStatusDialog(),
    );
  }
}

/// Detailed offline status dialog
class OfflineStatusDialog extends ConsumerWidget {
  const OfflineStatusDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityResult = ref.watch(connectivityProvider);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.wifi_off,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          const Text('Offline Mode'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are currently offline. Some features may be limited.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Connectivity status
          _buildStatusItem(
            context,
            'Connection Status',
            _getConnectivityDescription(connectivityResult),
            connectivityResult == ConnectivityResult.none ? Colors.red : Colors.orange,
          ),

          const SizedBox(height: 12),

          // Available features
          Text(
            'Available Features:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureList(context, connectivityResult),

          const SizedBox(height: 16),

          // Sync status note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sync,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Changes will be synced automatically when you reconnect.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  String _getConnectivityDescription(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Connected via WiFi';
      case ConnectivityResult.mobile:
        return 'Connected via Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected via Ethernet';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.none:
        return 'No internet connection';
      default:
        return 'Unknown connection';
    }
  }

  Widget _buildStatusItem(BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, ConnectivityResult result) {
    final features = _getAvailableFeatures(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              feature,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )).toList(),
    );
  }

  List<String> _getAvailableFeatures(ConnectivityResult result) {
    // Features available in offline mode
    final offlineFeatures = [
      'View cached data',
      'Read saved notifications',
      'Access downloaded presentations',
      'Use offline forms',
      'View agent profiles',
    ];

    if (result != ConnectivityResult.none) {
      // Additional features when partially connected
      offlineFeatures.addAll([
        'Send messages (queued)',
        'Update data (queued for sync)',
        'Receive notifications',
      ]);
    }

    return offlineFeatures;
  }
}

/// Sync status indicator widget
class SyncStatusIndicator extends ConsumerWidget {
  final bool showOnlyWhenSyncing;

  const SyncStatusIndicator({
    super.key,
    this.showOnlyWhenSyncing = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, we'll show a simple implementation
    // TODO: Connect to actual OfflineQueueService when implemented
    final isOnline = ref.watch(connectivityProvider) != ConnectivityResult.none;

    if (!isOnline && showOnlyWhenSyncing) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 12,
            color: isOnline ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Synced' : 'Offline',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Combined connectivity and sync indicator for app bar
class AppBarConnectivityIndicator extends ConsumerWidget {
  const AppBarConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityResult = ref.watch(connectivityProvider);
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (!isOffline) {
      return const SyncStatusIndicator();
    }

    return InkWell(
      onTap: () => _showOfflineDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 12,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'Offline',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineStatusDialog(),
    );
  }
}
