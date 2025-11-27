import 'package:flutter/material.dart';
import '../../data/models/onboarding_step.dart';

/// Progress bar widget for onboarding flow
class OnboardingProgressBar extends StatelessWidget {
  final OnboardingStep currentStep;
  final double progress;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: OnboardingStep.values.map((step) {
              final isCompleted = step.stepIndex < currentStep.stepIndex;
              final isCurrent = step == currentStep;
              final isUpcoming = step.stepIndex > currentStep.stepIndex;

              return _buildStepIndicator(
                context,
                step: step,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isUpcoming: isUpcoming,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          Text(
            '${(progress * 100).round()}% Complete',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Current step title and description
          Text(
            currentStep.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            currentStep.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required OnboardingStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isUpcoming,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCompleted) {
      backgroundColor = Theme.of(context).primaryColor;
      borderColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    } else if (isCurrent) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
      borderColor = Theme.of(context).primaryColor;
      textColor = Theme.of(context).primaryColor;
    } else {
      backgroundColor = Colors.grey.shade200;
      borderColor = Colors.grey.shade400;
      textColor = Colors.grey.shade400;
    }

    return Column(
      children: [
                // Step circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            '${step.stepIndex + 1}',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

        const SizedBox(height: 8),

        // Step label
        Text(
          _getStepShortLabel(step),
          style: TextStyle(
            fontSize: 12,
            color: isCompleted || isCurrent
                ? Theme.of(context).primaryColor
                : Colors.grey.shade500,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),

        // Connection line (except for last step)
        if (step != OnboardingStep.values.last)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 2,
            width: 40,
            color: step.index < currentStep.index
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
          ),
      ],
    );
  }

  String _getStepShortLabel(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.agentDiscovery:
        return 'Agent';
      case OnboardingStep.documentVerification:
        return 'Documents';
      case OnboardingStep.kycProcess:
        return 'KYC';
      case OnboardingStep.emergencyContacts:
        return 'Contacts';
      case OnboardingStep.profileSetup:
        return 'Profile';
      case OnboardingStep.completion:
        return 'Complete';
    }
  }
}
