import 'package:flutter/material.dart';

/// Error boundary widget that catches and handles errors in the widget tree
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final bool showRetryButton;
  final String? fallbackTitle;
  final String? fallbackMessage;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showRetryButton = true,
    this.fallbackTitle,
    this.fallbackMessage,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Reset error state when widget is rebuilt
    _hasError = false;
    _error = null;
    _stackTrace = null;
  }

  void _resetError() {
    setState(() {
      _hasError = false;
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Use custom error builder if provided
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }

      // Default error UI
      return _buildDefaultErrorWidget(context);
    }

    // Wrap child in error boundary
    return _ErrorBoundaryWidget(
      child: widget.child,
      onError: (error, stackTrace) {
        setState(() {
          _hasError = true;
          _error = error;
          _stackTrace = stackTrace;
        });

        // Call custom error handler if provided
        widget.onError?.call(error, stackTrace);

        // Log error for debugging
        debugPrint('Error caught by ErrorBoundary: $error');
        debugPrint('Stack trace: $stackTrace');
      },
    );
  }

  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            widget.fallbackTitle ?? 'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.fallbackMessage ?? 'An unexpected error occurred. Please try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.showRetryButton) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetError,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Internal widget that catches errors using FlutterError.onError
class _ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const _ErrorBoundaryWidget({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<_ErrorBoundaryWidget> {
  @override
  void initState() {
    super.initState();
    // Set up error handling for this subtree
    FlutterError.onError = (FlutterErrorDetails details) {
      widget.onError(details.exception, details.stack);
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Dashboard-specific error boundary with retry functionality
class DashboardErrorBoundary extends ErrorBoundary {
  final VoidCallback? onRetry;

  const DashboardErrorBoundary({
    Key? key,
    required Widget child,
    this.onRetry,
    VoidCallback? onRefresh,
  }) : super(
          key: key,
          child: child,
          fallbackTitle: 'Dashboard Error',
          fallbackMessage: 'Unable to load dashboard content. Please check your connection and try again.',
          onError: onRefresh,
        );

  @override
  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Dashboard Unavailable',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We encountered an issue loading your dashboard. This might be due to a network problem or temporary service interruption.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Report issue functionality could be added here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Issue reported. Thank you for your feedback!')),
                  );
                },
                icon: const Icon(Icons.report_problem),
                label: const Text('Report Issue'),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () {
                  onRetry?.call();
                  // Call parent retry
                  _resetError();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Network-aware error boundary that shows different messages based on connectivity
class NetworkAwareErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error)? offlineBuilder;
  final Widget Function(BuildContext context, Object error)? onlineBuilder;

  const NetworkAwareErrorBoundary({
    Key? key,
    required this.child,
    this.offlineBuilder,
    this.onlineBuilder,
  }) : super(key: key);

  @override
  State<NetworkAwareErrorBoundary> createState() => _NetworkAwareErrorBoundaryState();
}

class _NetworkAwareErrorBoundaryState extends State<NetworkAwareErrorBoundary> {
  bool _isOnline = true;
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (!_isOnline && widget.offlineBuilder != null) {
        return widget.offlineBuilder!(context, _error!);
      }

      if (widget.onlineBuilder != null) {
        return widget.onlineBuilder!(context, _error!);
      }

      // Default network-aware error UI
      return _buildNetworkAwareError(context);
    }

    return ErrorBoundary(
      child: widget.child,
      onError: (error, stackTrace) {
        setState(() {
          _error = error;
          // In a real implementation, check actual network connectivity
          _isOnline = true; // Placeholder
        });
      },
      errorBuilder: (error, stackTrace) {
        if (!_isOnline && widget.offlineBuilder != null) {
          return widget.offlineBuilder!(context, error);
        }

        if (widget.onlineBuilder != null) {
          return widget.onlineBuilder!(context, error);
        }

        return _buildNetworkAwareError(context);
      },
    );
  }

  Widget _buildNetworkAwareError(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOnline ? Icons.cloud_off : Icons.wifi_off,
            size: 64,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _isOnline ? 'Service Unavailable' : 'No Internet Connection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOnline
                ? 'The service is temporarily unavailable. Please try again later.'
                : 'Please check your internet connection and try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _error = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

/// Widget-specific error boundary for charts
class ChartErrorBoundary extends ErrorBoundary {
  const ChartErrorBoundary({
    Key? key,
    required Widget child,
  }) : super(
          key: key,
          child: child,
          fallbackTitle: 'Chart Error',
          fallbackMessage: 'Unable to display chart data. The data might be invalid or unavailable.',
        );

  @override
  Widget _buildDefaultErrorWidget(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Chart Unavailable',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load chart data. This might be due to missing data or a configuration issue.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _resetError,
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Chart'),
          ),
        ],
      ),
    );
  }
}
