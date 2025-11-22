import 'package:flutter/material.dart';
import '../../features/onboarding/data/models/onboarding_step.dart';
import '../../features/onboarding/data/models/onboarding_progress.dart';

/// Mock OnboardingViewModel for web compatibility
class MockOnboardingViewModel extends ChangeNotifier {
  OnboardingProgress? _progress;
  List<OnboardingStep> _steps = [];
  bool _isLoading = false;
  String? _error;
  int _currentStepIndex = 0;

  OnboardingProgress? get progress => _progress;
  List<OnboardingStep> get steps => _steps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStepIndex => _currentStepIndex;
  OnboardingStep? get currentStep => _steps.isNotEmpty ? _steps[_currentStepIndex] : null;
  bool get isCompleted => _progress?.isCompleted ?? false;
  double get progressPercentage => _progress?.progressPercentage ?? 0.0;

  MockOnboardingViewModel() {
    _initializeSteps();
    _loadProgress();
  }

  void _initializeSteps() {
    _steps = [
      OnboardingStep(
        id: 'agent_discovery',
        title: 'Agent Discovery',
        description: 'Find and connect with insurance agents',
        isCompleted: false,
        isRequired: true,
        order: 1,
      ),
      OnboardingStep(
        id: 'profile_setup',
        title: 'Profile Setup',
        description: 'Complete your profile information',
        isCompleted: false,
        isRequired: true,
        order: 2,
      ),
      OnboardingStep(
        id: 'document_verification',
        title: 'Document Verification',
        description: 'Verify your identity documents',
        isCompleted: false,
        isRequired: true,
        order: 3,
      ),
      OnboardingStep(
        id: 'kyc_process',
        title: 'KYC Process',
        description: 'Complete Know Your Customer verification',
        isCompleted: false,
        isRequired: true,
        order: 4,
      ),
      OnboardingStep(
        id: 'emergency_contacts',
        title: 'Emergency Contacts',
        description: 'Add emergency contact information',
        isCompleted: false,
        isRequired: false,
        order: 5,
      ),
    ];
  }

  void _loadProgress() {
    _progress = OnboardingProgress(
      userId: 'user_123',
      completedSteps: [],
      currentStepId: 'agent_discovery',
      startedAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );
  }

  Future<void> startOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _progress = _progress?.copyWith(
      startedAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeStep(String stepId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final stepIndex = _steps.indexWhere((s) => s.id == stepId);
    if (stepIndex != -1) {
      _steps[stepIndex] = _steps[stepIndex].copyWith(isCompleted: true);
    }

    _progress = _progress?.copyWith(
      completedSteps: [..._progress!.completedSteps, stepId],
      lastUpdatedAt: DateTime.now(),
    );

    // Move to next step if available
    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> skipStep(String stepId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Move to next step if available
    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
    }

    _isLoading = false;
    notifyListeners();
  }

  void goToStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _currentStepIndex = index;
      notifyListeners();
    }
  }

  Future<void> saveProgress() async {
    // Mock save operation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> resetOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentStepIndex = 0;
    _initializeSteps();
    _loadProgress();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initialize() async {
    // Already initialized in constructor
  }
}
