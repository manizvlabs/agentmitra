/// Onboarding step data model
enum OnboardingStep {
  agentDiscovery,
  documentVerification,
  kycProcess,
  emergencyContacts,
  profileSetup,
  completion;

  String get title {
    switch (this) {
      case OnboardingStep.agentDiscovery:
        return 'Agent Discovery';
      case OnboardingStep.documentVerification:
        return 'Document Verification';
      case OnboardingStep.kycProcess:
        return 'KYC Process';
      case OnboardingStep.emergencyContacts:
        return 'Emergency Contacts';
      case OnboardingStep.profileSetup:
        return 'Profile Setup';
      case OnboardingStep.completion:
        return 'Welcome!';
    }
  }

  String get description {
    switch (this) {
      case OnboardingStep.agentDiscovery:
        return 'Find and connect with insurance agents';
      case OnboardingStep.documentVerification:
        return 'Verify your identity documents';
      case OnboardingStep.kycProcess:
        return 'Complete Know Your Customer verification';
      case OnboardingStep.emergencyContacts:
        return 'Add emergency contact information';
      case OnboardingStep.profileSetup:
        return 'Complete your profile setup';
      case OnboardingStep.completion:
        return 'Your account is ready!';
    }
  }

  int get stepIndex {
    switch (this) {
      case OnboardingStep.agentDiscovery:
        return 0;
      case OnboardingStep.documentVerification:
        return 1;
      case OnboardingStep.kycProcess:
        return 2;
      case OnboardingStep.emergencyContacts:
        return 3;
      case OnboardingStep.profileSetup:
        return 4;
      case OnboardingStep.completion:
        return 5;
    }
  }

  bool get isFirst => index == 0;
  bool get isLast => index == OnboardingStep.values.length - 1;

  OnboardingStep? get next {
    final nextIndex = index + 1;
    if (nextIndex >= OnboardingStep.values.length) return null;
    return OnboardingStep.values[nextIndex];
  }

  OnboardingStep? get previous {
    final prevIndex = index - 1;
    if (prevIndex < 0) return null;
    return OnboardingStep.values[prevIndex];
  }
}

/// Onboarding progress data
class OnboardingProgress {
  final OnboardingStep currentStep;
  final Map<OnboardingStep, bool> completedSteps;
  final Map<String, dynamic> formData;

  const OnboardingProgress({
    required this.currentStep,
    required this.completedSteps,
    required this.formData,
  });

  double get progressPercentage {
    final completedCount = completedSteps.values.where((completed) => completed).length;
    return completedCount / OnboardingStep.values.length;
  }

  bool get isCompleted => completedSteps.values.every((completed) => completed);

  OnboardingProgress copyWith({
    OnboardingStep? currentStep,
    Map<OnboardingStep, bool>? completedSteps,
    Map<String, dynamic>? formData,
  }) {
    return OnboardingProgress(
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
      formData: formData ?? this.formData,
    );
  }
}

/// Agent discovery data
class AgentDiscoveryData {
  final String? agentCode;
  final String? agentName;
  final String? agentPhone;
  final String? agentEmail;
  final String? branchName;
  final String? branchAddress;

  const AgentDiscoveryData({
    this.agentCode,
    this.agentName,
    this.agentPhone,
    this.agentEmail,
    this.branchName,
    this.branchAddress,
  });

  bool get isValid => agentCode?.isNotEmpty == true;

  AgentDiscoveryData copyWith({
    String? agentCode,
    String? agentName,
    String? agentPhone,
    String? agentEmail,
    String? branchName,
    String? branchAddress,
  }) {
    return AgentDiscoveryData(
      agentCode: agentCode ?? this.agentCode,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agentEmail: agentEmail ?? this.agentEmail,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
    );
  }
}

/// Document verification data
class DocumentVerificationData {
  final String? aadhaarNumber;
  final String? panNumber;
  final String? aadhaarFrontImage;
  final String? aadhaarBackImage;
  final String? panImage;
  final bool documentsVerified;

  const DocumentVerificationData({
    this.aadhaarNumber,
    this.panNumber,
    this.aadhaarFrontImage,
    this.aadhaarBackImage,
    this.panImage,
    this.documentsVerified = false,
  });

  bool get isValid =>
      aadhaarNumber?.isNotEmpty == true &&
      panNumber?.isNotEmpty == true &&
      aadhaarFrontImage?.isNotEmpty == true &&
      panImage?.isNotEmpty == true;

  DocumentVerificationData copyWith({
    String? aadhaarNumber,
    String? panNumber,
    String? aadhaarFrontImage,
    String? aadhaarBackImage,
    String? panImage,
    bool? documentsVerified,
  }) {
    return DocumentVerificationData(
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      aadhaarFrontImage: aadhaarFrontImage ?? this.aadhaarFrontImage,
      aadhaarBackImage: aadhaarBackImage ?? this.aadhaarBackImage,
      panImage: panImage ?? this.panImage,
      documentsVerified: documentsVerified ?? this.documentsVerified,
    );
  }
}

/// KYC process data
class KycProcessData {
  final String? fullName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? occupation;
  final String? annualIncome;
  final bool kycVerified;

  const KycProcessData({
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.occupation,
    this.annualIncome,
    this.kycVerified = false,
  });

  bool get isValid =>
      fullName?.isNotEmpty == true &&
      dateOfBirth != null &&
      gender?.isNotEmpty == true &&
      address?.isNotEmpty == true &&
      city?.isNotEmpty == true &&
      state?.isNotEmpty == true &&
      pincode?.isNotEmpty == true;

  KycProcessData copyWith({
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? occupation,
    String? annualIncome,
    bool? kycVerified,
  }) {
    return KycProcessData(
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      kycVerified: kycVerified ?? this.kycVerified,
    );
  }
}

/// Emergency contacts data
class EmergencyContactsData {
  final String? primaryContactName;
  final String? primaryContactRelation;
  final String? primaryContactPhone;
  final String? secondaryContactName;
  final String? secondaryContactRelation;
  final String? secondaryContactPhone;

  const EmergencyContactsData({
    this.primaryContactName,
    this.primaryContactRelation,
    this.primaryContactPhone,
    this.secondaryContactName,
    this.secondaryContactRelation,
    this.secondaryContactPhone,
  });

  bool get isValid =>
      primaryContactName?.isNotEmpty == true &&
      primaryContactRelation?.isNotEmpty == true &&
      primaryContactPhone?.isNotEmpty == true;

  EmergencyContactsData copyWith({
    String? primaryContactName,
    String? primaryContactRelation,
    String? primaryContactPhone,
    String? secondaryContactName,
    String? secondaryContactRelation,
    String? secondaryContactPhone,
  }) {
    return EmergencyContactsData(
      primaryContactName: primaryContactName ?? this.primaryContactName,
      primaryContactRelation: primaryContactRelation ?? this.primaryContactRelation,
      primaryContactPhone: primaryContactPhone ?? this.primaryContactPhone,
      secondaryContactName: secondaryContactName ?? this.secondaryContactName,
      secondaryContactRelation: secondaryContactRelation ?? this.secondaryContactRelation,
      secondaryContactPhone: secondaryContactPhone ?? this.secondaryContactPhone,
    );
  }
}
