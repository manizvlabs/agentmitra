import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

/// Context-aware back button that considers navigation history
class ContextAwareBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const ContextAwareBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NavigationItem>>(
      stream: NavigationService().historyStream,
      builder: (context, snapshot) {
        final history = snapshot.data ?? NavigationService().getHistory();
        final hasHistory = history.length > 1; // More than just current screen

        return IconButton(
          icon: Icon(
            hasHistory ? Icons.arrow_back : Icons.close,
            color: color ?? Theme.of(context).appBarTheme.foregroundColor,
            size: size,
          ),
          tooltip: hasHistory ? 'Go Back' : 'Close',
          onPressed: onPressed ?? () {
            if (hasHistory) {
              // Use breadcrumb-aware back navigation
              NavigationService().popWithBreadcrumb(context);
            } else {
              // Regular back navigation
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }
}

/// Enhanced AppBar with context-aware navigation
class ContextAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBreadcrumbs;

  const ContextAwareAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.showBreadcrumbs = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    showBreadcrumbs ? kToolbarHeight + 50.0 : kToolbarHeight
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: automaticallyImplyLeading ? const ContextAwareBackButton() : null,
      actions: actions,
      bottom: showBreadcrumbs
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: BreadcrumbNavigation(maxItems: 3),
                ),
              ),
            )
          : null,
    );
  }
}

/// Workflow step indicator for multi-step processes
class WorkflowStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;

  const WorkflowStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? Theme.of(context).primaryColor;
    final inactive = inactiveColor ?? Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Step indicator
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      // Circle indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? active : inactive,
                          border: isCurrent
                              ? Border.all(color: active, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Label
                      Text(
                        stepLabels.length > index ? stepLabels[index] : 'Step ${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? active : Colors.grey,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: inactive,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentStep + 1) / totalSteps,
              child: Container(
                decoration: BoxDecoration(
                  color: active,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Workflow navigation buttons
class WorkflowNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onCancel;
  final String? previousLabel;
  final String? nextLabel;
  final String? cancelLabel;
  final bool showCancel;

  const WorkflowNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.onCancel,
    this.previousLabel,
    this.nextLabel,
    this.cancelLabel,
    this.showCancel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showCancel)
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                child: Text(cancelLabel ?? 'Cancel'),
              ),
            ),
          if (showCancel) const SizedBox(width: 8),
          if (onPrevious != null)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: onPrevious,
                child: Text(previousLabel ?? 'Previous'),
              ),
            ),
          if (onPrevious != null) const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              child: Text(nextLabel ?? 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
