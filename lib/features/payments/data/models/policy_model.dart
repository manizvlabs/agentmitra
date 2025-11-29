import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'policy_model.freezed.dart';
part 'policy_model.g.dart';

@freezed
class Policy with _$Policy {
  const factory Policy({
    @JsonKey(name: 'policy_id') required String policyId,
    @JsonKey(name: 'policy_number') required String policyNumber,
    @JsonKey(name: 'provider_policy_id') String? providerPolicyId,
    @JsonKey(name: 'policyholder_id') required String policyholderId,
    @JsonKey(name: 'agent_id') required String agentId,
    @JsonKey(name: 'provider_id') required String providerId,
    @JsonKey(name: 'policy_type') required String policyType,
    @JsonKey(name: 'plan_name') required String planName,
    @JsonKey(name: 'plan_code') String? planCode,
    @JsonKey(name: 'category') String? category,
    @JsonKey(name: 'sum_assured') required double sumAssured,
    @JsonKey(name: 'premium_amount') required double premiumAmount,
    @JsonKey(name: 'premium_frequency') required String premiumFrequency,
    @JsonKey(name: 'premium_mode') String? premiumMode,
    @JsonKey(name: 'application_date') required DateTime applicationDate,
    @JsonKey(name: 'approval_date') DateTime? approvalDate,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'maturity_date') DateTime? maturityDate,
    @JsonKey(name: 'renewal_date') DateTime? renewalDate,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'sub_status') String? subStatus,
    @JsonKey(name: 'payment_status') String? paymentStatus,
    @JsonKey(name: 'coverage_details') Map<String, dynamic>? coverageDetails,
    @JsonKey(name: 'exclusions') Map<String, dynamic>? exclusions,
    @JsonKey(name: 'terms_and_conditions') Map<String, dynamic>? termsAndConditions,
    @JsonKey(name: 'policy_document_url') String? policyDocumentUrl,
    @JsonKey(name: 'application_form_url') String? applicationFormUrl,
    @JsonKey(name: 'medical_reports') Map<String, dynamic>? medicalReports,
    @JsonKey(name: 'nominee_details') Map<String, dynamic>? nomineeDetails,
    @JsonKey(name: 'assignee_details') Map<String, dynamic>? assigneeDetails,
    @JsonKey(name: 'last_payment_date') DateTime? lastPaymentDate,
    @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
    @JsonKey(name: 'total_payments') int? totalPayments,
    @JsonKey(name: 'outstanding_amount') double? outstandingAmount,
    // Additional fields from API response
    @JsonKey(name: 'policyholder_info') Map<String, dynamic>? policyholderInfo,
    @JsonKey(name: 'agent_info') Map<String, dynamic>? agentInfo,
    @JsonKey(name: 'provider_info') Map<String, dynamic>? providerInfo,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Policy;

  factory Policy.fromJson(Map<String, dynamic> json) => _$PolicyFromJson(json);
}

@freezed
class Policyholder with _$Policyholder {
  const factory Policyholder({
    required String policyholderId,
    required String userId,
    String? agentId,
    String? customerId,
    String? salutation,
    String? maritalStatus,
    String? occupation,
    double? annualIncome,
    String? educationLevel,
    Map<String, dynamic>? riskProfile,
    String? investmentHorizon,
    Map<String, dynamic>? communicationPreferences,
    bool? marketingConsent,
    Map<String, dynamic>? familyMembers,
    Map<String, dynamic>? nomineeDetails,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? investmentPortfolio,
    String? preferredContactTime,
    String? preferredLanguage,
    int? digitalLiteracyScore,
    double? engagementScore,
    String? onboardingStatus,
    double? churnRiskScore,
    DateTime? lastInteractionAt,
    int? totalInteractions,
  }) = _Policyholder;

  factory Policyholder.fromJson(Map<String, dynamic> json) => _$PolicyholderFromJson(json);
}

@freezed
class Premium with _$Premium {
  const factory Premium({
    required String paymentId,
    required String policyId,
    required String policyholderId,
    required double amount,
    required DateTime paymentDate,
    required DateTime dueDate,
    String? paymentMethod,
    String? transactionId,
    String? paymentGateway,
    required String status,
    String? failureReason,
    Map<String, dynamic>? paymentDetails,
    String? receiptUrl,
    String? processedBy,
  }) = _Premium;

  factory Premium.fromJson(Map<String, dynamic> json) => _$PremiumFromJson(json);
}

@freezed
class Claim with _$Claim {
  const factory Claim({
    required String claimId,
    required String policyId,
    required String policyholderId,
    required String claimType,
    required String description,
    required DateTime incidentDate,
    required DateTime claimDate,
    required double claimedAmount,
    String? status,
    String? subStatus,
    Map<String, dynamic>? documents,
    Map<String, dynamic>? claimDetails,
    DateTime? approvalDate,
    DateTime? settlementDate,
    double? approvedAmount,
    String? rejectionReason,
    String? processedBy,
    String? approvedBy,
  }) = _Claim;

  factory Claim.fromJson(Map<String, dynamic> json) => _$ClaimFromJson(json);
}

@freezed
class Coverage with _$Coverage {
  const factory Coverage({
    required String coverageId,
    required String policyId,
    required String coverageType,
    required String description,
    required double sumAssured,
    required double premium,
    required DateTime startDate,
    DateTime? endDate,
    String? status,
    Map<String, dynamic>? terms,
    Map<String, dynamic>? conditions,
  }) = _Coverage;

  factory Coverage.fromJson(Map<String, dynamic> json) => _$CoverageFromJson(json);
}
