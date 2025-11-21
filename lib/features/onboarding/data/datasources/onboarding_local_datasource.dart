import 'dart:convert';
import '../../../../core/services/storage_service.dart';
import '../models/onboarding_step.dart';

/// Local data source for onboarding data persistence
class OnboardingLocalDataSource {
  static const String _onboardingProgressKey = 'onboarding_progress';
  static const String _agentDiscoveryKey = 'agent_discovery_data';
  static const String _documentVerificationKey = 'document_verification_data';
  static const String _kycProcessKey = 'kyc_process_data';
  static const String _emergencyContactsKey = 'emergency_contacts_data';

  const OnboardingLocalDataSource();

  /// Save onboarding progress
  Future<void> saveOnboardingProgress(OnboardingProgress progress) async {
    try {
      final progressMap = {
        'currentStep': progress.currentStep.index,
        'completedSteps': progress.completedSteps.map(
          (key, value) => MapEntry(key.index.toString(), value),
        ),
        'formData': progress.formData,
      };

      await StorageService.setString(_onboardingProgressKey, jsonEncode(progressMap));
    } catch (e) {
      throw Exception('Failed to save onboarding progress: $e');
    }
  }

  /// Load onboarding progress
  Future<OnboardingProgress?> loadOnboardingProgress() async {
    try {
      final progressJson = StorageService.getString(_onboardingProgressKey);
      if (progressJson == null) return null;

      final progressMap = jsonDecode(progressJson) as Map<String, dynamic>;

      final currentStepIndex = progressMap['currentStep'] as int;
      final completedStepsMap = (progressMap['completedSteps'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
                OnboardingStep.values[int.parse(key)],
                value as bool,
              ));

      return OnboardingProgress(
        currentStep: OnboardingStep.values[currentStepIndex],
        completedSteps: completedStepsMap,
        formData: progressMap['formData'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to load onboarding progress: $e');
    }
  }

  /// Clear onboarding progress
  Future<void> clearOnboardingProgress() async {
    try {
      await StorageService.remove(_onboardingProgressKey);
    } catch (e) {
      throw Exception('Failed to clear onboarding progress: $e');
    }
  }

  /// Save agent discovery data
  Future<void> saveAgentDiscoveryData(AgentDiscoveryData data) async {
    try {
      final dataMap = {
        'agentCode': data.agentCode,
        'agentName': data.agentName,
        'agentPhone': data.agentPhone,
        'agentEmail': data.agentEmail,
        'branchName': data.branchName,
        'branchAddress': data.branchAddress,
      };

      await StorageService.setString(_agentDiscoveryKey, jsonEncode(dataMap));
    } catch (e) {
      throw Exception('Failed to save agent discovery data: $e');
    }
  }

  /// Load agent discovery data
  Future<AgentDiscoveryData?> loadAgentDiscoveryData() async {
    try {
      final dataJson = StorageService.getString(_agentDiscoveryKey);
      if (dataJson == null) return null;

      final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;

      return AgentDiscoveryData(
        agentCode: dataMap['agentCode'] as String?,
        agentName: dataMap['agentName'] as String?,
        agentPhone: dataMap['agentPhone'] as String?,
        agentEmail: dataMap['agentEmail'] as String?,
        branchName: dataMap['branchName'] as String?,
        branchAddress: dataMap['branchAddress'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to load agent discovery data: $e');
    }
  }

  /// Save document verification data
  Future<void> saveDocumentVerificationData(DocumentVerificationData data) async {
    try {
      final dataMap = {
        'aadhaarNumber': data.aadhaarNumber,
        'panNumber': data.panNumber,
        'aadhaarFrontImage': data.aadhaarFrontImage,
        'aadhaarBackImage': data.aadhaarBackImage,
        'panImage': data.panImage,
        'documentsVerified': data.documentsVerified,
      };

      await StorageService.setString(_documentVerificationKey, jsonEncode(dataMap));
    } catch (e) {
      throw Exception('Failed to save document verification data: $e');
    }
  }

  /// Load document verification data
  Future<DocumentVerificationData?> loadDocumentVerificationData() async {
    try {
      final dataJson = StorageService.getString(_documentVerificationKey);
      if (dataJson == null) return null;

      final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;

      return DocumentVerificationData(
        aadhaarNumber: dataMap['aadhaarNumber'] as String?,
        panNumber: dataMap['panNumber'] as String?,
        aadhaarFrontImage: dataMap['aadhaarFrontImage'] as String?,
        aadhaarBackImage: dataMap['aadhaarBackImage'] as String?,
        panImage: dataMap['panImage'] as String?,
        documentsVerified: dataMap['documentsVerified'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception('Failed to load document verification data: $e');
    }
  }

  /// Save KYC process data
  Future<void> saveKycProcessData(KycProcessData data) async {
    try {
      final dataMap = {
        'fullName': data.fullName,
        'dateOfBirth': data.dateOfBirth?.toIso8601String(),
        'gender': data.gender,
        'address': data.address,
        'city': data.city,
        'state': data.state,
        'pincode': data.pincode,
        'occupation': data.occupation,
        'annualIncome': data.annualIncome,
        'kycVerified': data.kycVerified,
      };

      await StorageService.setString(_kycProcessKey, jsonEncode(dataMap));
    } catch (e) {
      throw Exception('Failed to save KYC process data: $e');
    }
  }

  /// Load KYC process data
  Future<KycProcessData?> loadKycProcessData() async {
    try {
      final dataJson = StorageService.getString(_kycProcessKey);
      if (dataJson == null) return null;

      final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;

      return KycProcessData(
        fullName: dataMap['fullName'] as String?,
        dateOfBirth: dataMap['dateOfBirth'] != null
            ? DateTime.parse(dataMap['dateOfBirth'] as String)
            : null,
        gender: dataMap['gender'] as String?,
        address: dataMap['address'] as String?,
        city: dataMap['city'] as String?,
        state: dataMap['state'] as String?,
        pincode: dataMap['pincode'] as String?,
        occupation: dataMap['occupation'] as String?,
        annualIncome: dataMap['annualIncome'] as String?,
        kycVerified: dataMap['kycVerified'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception('Failed to load KYC process data: $e');
    }
  }

  /// Save emergency contacts data
  Future<void> saveEmergencyContactsData(EmergencyContactsData data) async {
    try {
      final dataMap = {
        'primaryContactName': data.primaryContactName,
        'primaryContactRelation': data.primaryContactRelation,
        'primaryContactPhone': data.primaryContactPhone,
        'secondaryContactName': data.secondaryContactName,
        'secondaryContactRelation': data.secondaryContactRelation,
        'secondaryContactPhone': data.secondaryContactPhone,
      };

      await StorageService.setString(_emergencyContactsKey, jsonEncode(dataMap));
    } catch (e) {
      throw Exception('Failed to save emergency contacts data: $e');
    }
  }

  /// Load emergency contacts data
  Future<EmergencyContactsData?> loadEmergencyContactsData() async {
    try {
      final dataJson = StorageService.getString(_emergencyContactsKey);
      if (dataJson == null) return null;

      final dataMap = jsonDecode(dataJson) as Map<String, dynamic>;

      return EmergencyContactsData(
        primaryContactName: dataMap['primaryContactName'] as String?,
        primaryContactRelation: dataMap['primaryContactRelation'] as String?,
        primaryContactPhone: dataMap['primaryContactPhone'] as String?,
        secondaryContactName: dataMap['secondaryContactName'] as String?,
        secondaryContactRelation: dataMap['secondaryContactRelation'] as String?,
        secondaryContactPhone: dataMap['secondaryContactPhone'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to load emergency contacts data: $e');
    }
  }
}
