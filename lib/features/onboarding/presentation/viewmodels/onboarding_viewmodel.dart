import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/models/onboarding_step.dart';

/// ViewModel for onboarding flow management
class OnboardingViewModel extends BaseViewModel {
  final OnboardingRepository _repository;

  OnboardingViewModel([OnboardingRepository? repository])
      : _repository = repository ?? OnboardingRepository(OnboardingLocalDataSource());

  // State variables
  OnboardingProgress? _progress;
  AgentDiscoveryData? _agentDiscoveryData;
  DocumentVerificationData? _documentVerificationData;
  KycProcessData? _kycProcessData;
  EmergencyContactsData? _emergencyContactsData;

  // Getters
  OnboardingProgress? get progress => _progress;
  OnboardingStep? get currentStep => _progress?.currentStep;
  double get progressPercentage => _progress?.progressPercentage ?? 0.0;
  bool get isCompleted => _progress?.isCompleted ?? false;

  // Navigation helpers
  bool get isFirst => currentStep == OnboardingStep.agentDiscovery;
  bool get isLast => currentStep == OnboardingStep.profileSetup;

  AgentDiscoveryData? get agentDiscoveryData => _agentDiscoveryData;
  DocumentVerificationData? get documentVerificationData => _documentVerificationData;
  KycProcessData? get kycProcessData => _kycProcessData;
  EmergencyContactsData? get emergencyContactsData => _emergencyContactsData;

  /// Initialize onboarding
  @override
  Future<void> initialize() async {
    await super.initialize();

    final progress = await executeAsync(
      () async {
        final result = await _repository.getOnboardingProgress();
        _progress = result ?? _createDefaultProgress();
        await _loadAllStepData();
        return _progress;
      },
      errorMessage: 'Failed to initialize onboarding',
    );

    if (progress != null) {
      notifyListeners();
    }
  }

  /// Load all step data
  Future<void> _loadAllStepData() async {
    await Future.wait([
      _loadAgentDiscoveryData(),
      _loadDocumentVerificationData(),
      _loadKycProcessData(),
      _loadEmergencyContactsData(),
    ]);
  }

  Future<void> _loadAgentDiscoveryData() async {
    _agentDiscoveryData = await _repository.getAgentDiscoveryData();
  }

  Future<void> _loadDocumentVerificationData() async {
    _documentVerificationData = await _repository.getDocumentVerificationData();
  }

  Future<void> _loadKycProcessData() async {
    _kycProcessData = await _repository.getKycProcessData();
  }

  Future<void> _loadEmergencyContactsData() async {
    _emergencyContactsData = await _repository.getEmergencyContactsData();
  }

  /// Move to next step
  Future<bool> moveToNextStep() async {
    if (_progress == null) return false;

    final nextStep = _progress!.currentStep.next;
    if (nextStep == null) return false;

    await _repository.updateCurrentStep(nextStep);
    _progress = _progress!.copyWith(currentStep: nextStep);
    notifyListeners();
    return true;
  }

  /// Move to previous step
  Future<bool> moveToPreviousStep() async {
    if (_progress == null) return false;

    final prevStep = _progress!.currentStep.previous;
    if (prevStep == null) return false;

    await _repository.updateCurrentStep(prevStep);
    _progress = _progress!.copyWith(currentStep: prevStep);
    notifyListeners();
    return true;
  }

  /// Complete current step
  Future<bool> completeCurrentStep() async {
    if (_progress == null) return false;

    try {
      final nextStep = await _repository.completeCurrentStep();
      if (nextStep != null) {
        _progress = _progress!.copyWith(currentStep: nextStep);
      } else {
        // Onboarding completed
        _progress = _progress!.copyWith(
          completedSteps: {
            for (var step in OnboardingStep.values) step: true,
          },
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to complete step: $e');
      return false;
    }
  }

  /// Update agent discovery data
  Future<bool> updateAgentDiscoveryData(AgentDiscoveryData data) async {
    final result = await executeAsync(
      () async {
        // Validate data first
        final isValid = await _repository.validateAgentDiscoveryData(data);
        if (!isValid) {
          throw Exception('Invalid agent discovery data');
        }

        await _repository.saveAgentDiscoveryData(data);
        _agentDiscoveryData = data;
        return true;
      },
      errorMessage: 'Failed to update agent discovery data',
    );

    return result ?? false;
  }

  /// Update document verification data
  Future<bool> updateDocumentVerificationData(DocumentVerificationData data) async {
    try {
      // Validate data first
      final isValid = await _repository.validateDocumentVerificationData(data);
      if (!isValid) {
        setError('Invalid document verification data');
        return false;
      }

      await _repository.saveDocumentVerificationData(data);
      _documentVerificationData = data;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update document verification data: $e');
      return false;
    }
  }

  /// Update KYC process data
  Future<bool> updateKycProcessData(KycProcessData data) async {
    try {
      // Validate data first
      final isValid = await _repository.validateKycProcessData(data);
      if (!isValid) {
        setError('Invalid KYC process data');
        return false;
      }

      await _repository.saveKycProcessData(data);
      _kycProcessData = data;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update KYC process data: $e');
      return false;
    }
  }

  /// Update emergency contacts data
  Future<bool> updateEmergencyContactsData(EmergencyContactsData data) async {
    try {
      // Validate data first
      final isValid = await _repository.validateEmergencyContactsData(data);
      if (!isValid) {
        setError('Invalid emergency contacts data');
        return false;
      }

      await _repository.saveEmergencyContactsData(data);
      _emergencyContactsData = data;
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to update emergency contacts data: $e');
      return false;
    }
  }

  /// Check if current step can be completed
  bool canCompleteCurrentStep() {
    if (_progress == null) return false;

    switch (_progress!.currentStep) {
      case OnboardingStep.agentDiscovery:
        return _agentDiscoveryData?.isValid ?? false;
      case OnboardingStep.documentVerification:
        return _documentVerificationData?.isValid ?? false;
      case OnboardingStep.kycProcess:
        return _kycProcessData?.isValid ?? false;
      case OnboardingStep.emergencyContacts:
        return _emergencyContactsData?.isValid ?? false;
      case OnboardingStep.profileSetup:
        return true; // Profile setup is always valid once reached
    }
  }

  /// Reset onboarding
  Future<void> resetOnboarding() async {
    try {
      await _repository.resetOnboardingProgress();
      _progress = _createDefaultProgress();
      _agentDiscoveryData = null;
      _documentVerificationData = null;
      _kycProcessData = null;
      _emergencyContactsData = null;
      notifyListeners();
    } catch (e) {
      setError('Failed to reset onboarding: $e');
    }
  }

  OnboardingProgress _createDefaultProgress() {
    return OnboardingProgress(
      currentStep: OnboardingStep.agentDiscovery,
      completedSteps: {
        for (var step in OnboardingStep.values) step: false,
      },
      formData: {},
    );
  }
}
