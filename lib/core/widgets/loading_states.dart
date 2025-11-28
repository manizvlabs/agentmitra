import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Loading states and skeleton screens for dashboard widgets
class LoadingStates {
  /// Creates a shimmer effect for loading content
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }

  /// Skeleton for KPI cards
  static Widget kpiCardSkeleton(BuildContext context) {
    return shimmer(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and title row
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              // Value
              Container(
                width: 100,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              // Change indicator
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton for chart widgets
  static Widget chartSkeleton(BuildContext context, {double height = 300}) {
    return shimmer(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Chart area
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: SkeletonGridPainter(),
                        ),
                      ),
                      // Chart bars/lines (simulated)
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 20,
                              height: 40 + (index * 10).toDouble(),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton for table/list widgets
  static Widget tableSkeleton(BuildContext context, {int rows = 5, int columns = 4}) {
    return shimmer(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row
              Row(
                children: List.generate(
                  columns,
                  (index) => Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Data rows
              ...List.generate(
                rows,
                (rowIndex) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: List.generate(
                      columns,
                      (colIndex) => Expanded(
                        child: Container(
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton for dashboard grid layout
  static Widget dashboardSkeleton(BuildContext context) {
    return shimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Progressive loading indicator with custom message
  static Widget progressiveLoader({
    required String message,
    double? progress,
    bool showProgress = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (showProgress && progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  /// Loading overlay for existing content
  static Widget loadingOverlay({
    required Widget child,
    required bool isLoading,
    String? loadingMessage,
    double opacity = 0.7,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: opacity),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(loadingMessage),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pull-to-refresh loading state
  static Widget pullToRefreshLoader({
    required Widget child,
    required bool isRefreshing,
    String? refreshMessage,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        // This would be handled by the parent widget
        await Future.delayed(const Duration(seconds: 1));
      },
      child: Stack(
        children: [
          child,
          if (isRefreshing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          if (refreshMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(refreshMessage),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Skeleton grid painter for chart backgrounds
class SkeletonGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Enhanced dashboard widget base with loading states
abstract class LoadableDashboardWidget extends DashboardWidget {
  const LoadableDashboardWidget({
    super.key,
    super.id,
    super.title,
    super.size,
    super.config,
    super.onRemove,
    super.onConfigure,
  });

  @override
  LoadableDashboardWidgetState createState();
}

abstract class LoadableDashboardWidgetState<T extends LoadableDashboardWidget>
    extends DashboardWidgetState<T> {
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  set isRefreshing(bool value) {
    if (mounted) {
      setState(() => _isRefreshing = value);
    }
  }

  /// Override to provide skeleton loading widget
  Widget buildSkeleton(BuildContext context);

  /// Enhanced build method with loading states
  @override
  Widget build(BuildContext context) {
    return LoadingStates.loadingOverlay(
      child: super.build(context),
      isLoading: _isLoading && !_isRefreshing,
      loadingMessage: 'Loading data...',
    );
  }

  /// Enhanced content building with skeleton support
  @override
  Widget buildContent(BuildContext context) {
    if (_isLoading && !_isRefreshing) {
      return buildSkeleton(context);
    }

    if (_error != null) {
      return buildErrorState(context);
    }

    return LoadingStates.pullToRefreshLoader(
      child: buildWidgetContent(context),
      isRefreshing: _isRefreshing,
      refreshMessage: 'Refreshing data...',
    );
  }

  /// Override this method to build the actual widget content
  Widget buildWidgetContent(BuildContext context);

  /// Enhanced error state with retry
  Widget buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load data',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error?.toString() ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => loadData(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  /// Refresh data method
  Future<void> refreshData() async {
    isRefreshing = true;
    try {
      await loadData();
    } finally {
      isRefreshing = false;
    }
  }
}

/// Loading state builder utility
class LoadingStateBuilder extends StatelessWidget {
  final bool isLoading;
  final bool isRefreshing;
  final Object? error;
  final Widget Function() skeletonBuilder;
  final Widget Function() contentBuilder;
  final Widget Function(Object error)? errorBuilder;
  final String? loadingMessage;
  final String? refreshMessage;

  const LoadingStateBuilder({
    Key? key,
    required this.isLoading,
    required this.isRefreshing,
    required this.error,
    required this.skeletonBuilder,
    required this.contentBuilder,
    this.errorBuilder,
    this.loadingMessage,
    this.refreshMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show skeleton during initial load
    if (isLoading && !isRefreshing) {
      return LoadingStates.loadingOverlay(
        child: skeletonBuilder(),
        isLoading: false, // Skeleton is already shown
      );
    }

    // Show error state
    if (error != null) {
      if (errorBuilder != null) {
        return errorBuilder!(error!);
      }
      return _buildDefaultError(context);
    }

    // Show content with pull-to-refresh
    return LoadingStates.pullToRefreshLoader(
      child: contentBuilder(),
      isRefreshing: isRefreshing,
      refreshMessage: refreshMessage ?? 'Refreshing...',
    );
  }

  Widget _buildDefaultError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              // This would trigger a retry in the parent widget
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
