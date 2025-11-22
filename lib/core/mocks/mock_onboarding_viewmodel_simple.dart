import 'package:flutter/material.dart';
import 'package:agent_mitra/features/onboarding/data/models/onboarding_step.dart';

/// Simple Mock OnboardingViewModel for web compatibility
class MockOnboardingViewModel extends ChangeNotifier {
  Map<String, dynamic>? _progress;
  List<OnboardingStep> _steps = [];
  bool _isLoading = false;
  String? _error;
  int _currentStepIndex = 0;

  Map<String, dynamic>? get progress => _progress;
  List<OnboardingStep> get steps => _steps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStepIndex => _currentStepIndex;
  OnboardingStep? get currentStep => _steps.isNotEmpty ? _steps[_currentStepIndex] : null;
  bool get isCompleted => _progress?['isCompleted'] ?? false;
  double get progressPercentage => _progress?['progressPercentage'] ?? 0.0;

  MockOnboardingViewModel() {
    _initializeSteps();
    _loadProgress();
  }

  void _initializeSteps() {
    _steps = [
      OnboardingStep.agentDiscovery,
      OnboardingStep.documentVerification,
      OnboardingStep.kycProcess,
      OnboardingStep.emergencyContacts,
      OnboardingStep.profileSetup,
    ];
  }

  void _loadProgress() {
    _progress = {
      'currentStep': _currentStepIndex,
      'totalSteps': _steps.length,
      'isCompleted': false,
      'progressPercentage': (_currentStepIndex + 1) / _steps.length,
      'completedSteps': [],
    };
  }

  // Required methods from the ViewModel interface
  bool canCompleteCurrentStep() {
    return currentStep != null;
  }

  Future<bool> moveToPreviousStep() async {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _loadProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> completeCurrentStep() async {
    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
      _loadProgress();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> completeStep(String stepId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

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

  Future<void> initialize() async {}
}
