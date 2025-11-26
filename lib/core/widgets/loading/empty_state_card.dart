import 'package:flutter/material.dart';
import '../../../core/services/localization_service.dart';

/// Empty State Card Widget
/// Displays when there's no data to show
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    final defaultMessage = message ?? 'No data available';
    final defaultActionLabel = actionLabel ?? localizationService.getString('retry');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                defaultMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(defaultActionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State with Retry Widget
/// Displays empty state with retry functionality
class EmptyStateWithRetry extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback onRetry;
  final Color? iconColor;

  const EmptyStateWithRetry({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    required this.onRetry,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: icon,
      title: title,
      message: message,
      actionLabel: LocalizationService().getString('retry'),
      onAction: onRetry,
      iconColor: iconColor,
    );
  }
}

