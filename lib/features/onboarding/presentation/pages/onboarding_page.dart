import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_progress_bar.dart';
import '../widgets/agent_discovery_step.dart';
import '../widgets/document_verification_step.dart';
import '../widgets/kyc_process_step.dart';
import '../widgets/emergency_contacts_step.dart';
import '../widgets/profile_setup_step.dart';
import '../../data/models/onboarding_step.dart';

/// Main onboarding page that manages the 5-step flow
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.progress == null) {
            return const Center(
              child: Text('Failed to load onboarding progress'),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Progress bar
                OnboardingProgressBar(
                  currentStep: viewModel.currentStep!,
                  progress: viewModel.progressPercentage,
                ),

                // Step content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                    if (viewModel.currentStep == OnboardingStep.agentDiscovery) const AgentDiscoveryStep(),
                    if (viewModel.currentStep == OnboardingStep.documentVerification) const DocumentVerificationStep(),
                    if (viewModel.currentStep == OnboardingStep.kycProcess) const KycProcessStep(),
                    if (viewModel.currentStep == OnboardingStep.emergencyContacts) const EmergencyContactsStep(),
                    if (viewModel.currentStep == OnboardingStep.profileSetup) const ProfileSetupStep(),
                  ],
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingViewModel viewModel) {
    final currentStep = viewModel.currentStep!;
    final canComplete = viewModel.canCompleteCurrentStep();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (!currentStep.isFirst)
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final success = await viewModel.moveToPreviousStep();
                  if (success) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),

          if (!currentStep.isFirst) const SizedBox(width: 16),

          // Next/Complete button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canComplete
                  ? () async {
                      if (currentStep.isLast) {
                        // Complete onboarding
                        final success = await viewModel.completeCurrentStep();
                        if (success && mounted) {
                          // Navigate to main app
                          Navigator.of(context).pushReplacementNamed('/customer-dashboard');
                        }
                      } else {
                        // Move to next step
                        final success = await viewModel.completeCurrentStep();
                        if (success) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentStep.isLast ? 'Complete Setup' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
