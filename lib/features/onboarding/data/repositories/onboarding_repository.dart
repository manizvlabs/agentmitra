import '../datasources/onboarding_local_datasource.dart';
import '../models/onboarding_step.dart';

/// Repository for onboarding data management
class OnboardingRepository {
  final OnboardingLocalDataSource _localDataSource;

  OnboardingRepository(this._localDataSource);

  /// Initialize default onboarding progress
  OnboardingProgress _createDefaultProgress() {
    return OnboardingProgress(
      currentStep: OnboardingStep.agentDiscovery,
      completedSteps: {
        for (var step in OnboardingStep.values) step: false,
      },
      formData: {},
    );
  }

  /// Get onboarding progress
  Future<OnboardingProgress> getOnboardingProgress() async {
    try {
      final progress = await _localDataSource.loadOnboardingProgress();
      return progress ?? _createDefaultProgress();
    } catch (e) {
      return _createDefaultProgress();
    }
  }

  /// Save onboarding progress
  Future<void> saveOnboardingProgress(OnboardingProgress progress) async {
    await _localDataSource.saveOnboardingProgress(progress);
  }

  /// Update current step
  Future<void> updateCurrentStep(OnboardingStep step) async {
    final progress = await getOnboardingProgress();
    final updatedProgress = progress.copyWith(currentStep: step);
    await saveOnboardingProgress(updatedProgress);
  }

  /// Mark step as completed
  Future<void> markStepCompleted(OnboardingStep step, bool completed) async {
    final progress = await getOnboardingProgress();
    final updatedCompletedSteps = Map<OnboardingStep, bool>.from(progress.completedSteps);
    updatedCompletedSteps[step] = completed;

    final updatedProgress = progress.copyWith(completedSteps: updatedCompletedSteps);
    await saveOnboardingProgress(updatedProgress);
  }

  /// Complete current step and move to next
  Future<OnboardingStep?> completeCurrentStep() async {
    final progress = await getOnboardingProgress();

    // Mark current step as completed
    await markStepCompleted(progress.currentStep, true);

    // Move to next step
    final nextStep = progress.currentStep.next;
    if (nextStep != null) {
      await updateCurrentStep(nextStep);
    }

    return nextStep;
  }

  /// Reset onboarding progress
  Future<void> resetOnboardingProgress() async {
    await _localDataSource.clearOnboardingProgress();
  }

  /// Get agent discovery data
  Future<AgentDiscoveryData?> getAgentDiscoveryData() async {
    return await _localDataSource.loadAgentDiscoveryData();
  }

  /// Save agent discovery data
  Future<void> saveAgentDiscoveryData(AgentDiscoveryData data) async {
    await _localDataSource.saveAgentDiscoveryData(data);
  }

  /// Get document verification data
  Future<DocumentVerificationData?> getDocumentVerificationData() async {
    return await _localDataSource.loadDocumentVerificationData();
  }

  /// Save document verification data
  Future<void> saveDocumentVerificationData(DocumentVerificationData data) async {
    await _localDataSource.saveDocumentVerificationData(data);
  }

  /// Get KYC process data
  Future<KycProcessData?> getKycProcessData() async {
    return await _localDataSource.loadKycProcessData();
  }

  /// Save KYC process data
  Future<void> saveKycProcessData(KycProcessData data) async {
    await _localDataSource.saveKycProcessData(data);
  }

  /// Get emergency contacts data
  Future<EmergencyContactsData?> getEmergencyContactsData() async {
    return await _localDataSource.loadEmergencyContactsData();
  }

  /// Save emergency contacts data
  Future<void> saveEmergencyContactsData(EmergencyContactsData data) async {
    await _localDataSource.saveEmergencyContactsData(data);
  }

  /// Validate agent discovery data
  Future<bool> validateAgentDiscoveryData(AgentDiscoveryData data) async {
    // In a real app, this would validate against backend
    // For now, just check if agent code is provided
    return data.isValid;
  }

  /// Validate document verification data
  Future<bool> validateDocumentVerificationData(DocumentVerificationData data) async {
    // In a real app, this would validate documents against backend
    // For now, just check if required fields are filled
    return data.isValid;
  }

  /// Validate KYC process data
  Future<bool> validateKycProcessData(KycProcessData data) async {
    // In a real app, this would perform KYC verification
    // For now, just check if required fields are filled
    return data.isValid;
  }

  /// Validate emergency contacts data
  Future<bool> validateEmergencyContactsData(EmergencyContactsData data) async {
    // Check if primary contact is provided
    return data.isValid;
  }
}
