import 'package:flutter/material.dart';
import '../../features/onboarding/data/models/onboarding_step.dart';

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
    _steps = OnboardingStep.values;
  }

  void _loadProgress() {
    _progress = OnboardingProgress(
      currentStep: OnboardingStep.agentDiscovery,
      completedSteps: {},
      formData: {},
    );
  }

  Future<void> startOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // Progress already initialized in _loadProgress()

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeStep(String stepId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Find the step by name
    OnboardingStep? stepToComplete;
    try {
      stepToComplete = OnboardingStep.values.firstWhere(
        (step) => step.name == stepId,
      );
    } catch (e) {
      // Step not found
    }

    if (stepToComplete != null && _progress != null) {
      final updatedCompletedSteps = Map<OnboardingStep, bool>.from(_progress!.completedSteps);
      updatedCompletedSteps[stepToComplete] = true;

      _progress = _progress!.copyWith(
        completedSteps: updatedCompletedSteps,
      );
    }

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
