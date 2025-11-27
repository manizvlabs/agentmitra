import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/widgets/onboarding_completion_step.dart';

/// Standalone Onboarding Completion Page
/// Full-screen page version of the onboarding completion widget
class OnboardingCompletionPage extends StatelessWidget {
  const OnboardingCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: OnboardingCompletionStep(),
      ),
    );
  }
}

