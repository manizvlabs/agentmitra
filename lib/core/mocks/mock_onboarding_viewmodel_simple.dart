import 'package:flutter/material.dart';

/// Simple Mock OnboardingViewModel for web compatibility
class MockOnboardingViewModel extends ChangeNotifier {
  Map<String, dynamic>? _progress;
  List<Map<String, dynamic>> _steps = [];
  bool _isLoading = false;
  String? _error;
  int _currentStepIndex = 0;

  Map<String, dynamic>? get progress => _progress;
  List<Map<String, dynamic>> get steps => _steps;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStepIndex => _currentStepIndex;
  Map<String, dynamic>? get currentStep => _steps.isNotEmpty ? _steps[_currentStepIndex] : null;
  bool get isCompleted => _progress?['isCompleted'] ?? false;
  double get progressPercentage => _progress?['progressPercentage'] ?? 0.0;

  MockOnboardingViewModel() {
    _initializeSteps();
    _loadProgress();
  }

  void _initializeSteps() {
    _steps = [
      {
        'id': 'agent_discovery',
        'title': 'Agent Discovery',
        'description': 'Find and connect with insurance agents',
        'isCompleted': false,
        'isRequired': true,
        'order': 1,
      },
      {
        'id': 'profile_setup',
        'title': 'Profile Setup',
        'description': 'Complete your profile information',
        'isCompleted': false,
        'isRequired': true,
        'order': 2,
      },
      {
        'id': 'document_verification',
        'title': 'Document Verification',
        'description': 'Verify your identity documents',
        'isCompleted': false,
        'isRequired': true,
        'order': 3,
      },
      {
        'id': 'kyc_process',
        'title': 'KYC Process',
        'description': 'Complete Know Your Customer verification',
        'isCompleted': false,
        'isRequired': true,
        'order': 4,
      },
      {
        'id': 'emergency_contacts',
        'title': 'Emergency Contacts',
        'description': 'Add emergency contact information',
        'isCompleted': false,
        'isRequired': false,
        'order': 5,
      },
    ];
  }

  void _loadProgress() {
    _progress = {
      'currentStepId': 'agent_discovery',
      'completedSteps': <String>[],
      'isCompleted': false,
      'progressPercentage': 0.0,
    };
  }

  Future<void> startOnboarding() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _progress = {
      ..._progress!,
      'startedAt': DateTime.now(),
    };

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeStep(String stepId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final stepIndex = _steps.indexWhere((s) => s['id'] == stepId);
    if (stepIndex != -1) {
      _steps[stepIndex]['isCompleted'] = true;
    }

    final completedSteps = List<String>.from(_progress!['completedSteps'] ?? []);
    completedSteps.add(stepId);

    _progress = {
      ..._progress!,
      'completedSteps': completedSteps,
      'progressPercentage': completedSteps.length / _steps.length,
    };

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
