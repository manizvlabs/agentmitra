import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'policy_models.freezed.dart';
part 'policy_models.g.dart';

/// Policy model for the policies tab - simplified version focused on display needs
@freezed
class Policy with _$Policy {
  const factory Policy({
    @JsonKey(name: 'policy_id') required String policyId,
    @JsonKey(name: 'policy_number') required String policyNumber,
    @JsonKey(name: 'plan_name') required String planName,
    @JsonKey(name: 'sum_assured') required double sumAssured,
    @JsonKey(name: 'premium_amount') required double premiumAmount,
    @JsonKey(name: 'premium_frequency') required String premiumFrequency,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'maturity_date') DateTime? maturityDate,
    @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'policy_document_url') String? policyDocumentUrl,
    @JsonKey(name: 'application_form_url') String? applicationFormUrl,
    @JsonKey(name: 'outstanding_amount') double? outstandingAmount,
  }) = _Policy;

  factory Policy.fromJson(Map<String, dynamic> json) => _$PolicyFromJson(json);
}

/// Premium payment model for payment history
@freezed
class Premium with _$Premium {
  const factory Premium({
    required String paymentId,
    required String policyId,
    required double amount,
    required DateTime paymentDate,
    required DateTime dueDate,
    String? paymentMethod,
    String? transactionId,
    required String status,
    String? receiptUrl,
  }) = _Premium;

  factory Premium.fromJson(Map<String, dynamic> json) => _$PremiumFromJson(json);
}

/// Claim model for claims history
@freezed
class Claim with _$Claim {
  const factory Claim({
    required String claimId,
    required String policyId,
    required String claimType,
    required String description,
    required DateTime incidentDate,
    required DateTime claimDate,
    required double claimedAmount,
    String? status,
    double? approvedAmount,
    String? rejectionReason,
  }) = _Claim;

  factory Claim.fromJson(Map<String, dynamic> json) => _$ClaimFromJson(json);
}

/// Coverage details model
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
  }) = _Coverage;

  factory Coverage.fromJson(Map<String, dynamic> json) => _$CoverageFromJson(json);
}

/// Policy filter options
enum PolicyStatus {
  @JsonValue('active')
  active,
  @JsonValue('pending_approval')
  pendingApproval,
  @JsonValue('lapsed')
  lapsed,
  @JsonValue('matured')
  matured,
  @JsonValue('cancelled')
  cancelled,
}

enum PolicyType {
  @JsonValue('term_life')
  termLife,
  @JsonValue('whole_life')
  wholeLife,
  @JsonValue('endowment')
  endowment,
  @JsonValue('ulip')
  ulip,
  @JsonValue('money_back')
  moneyBack,
  @JsonValue('pension')
  pension,
}

/// Policy filter model for search and filtering
@freezed
class PolicyFilters with _$PolicyFilters {
  const factory PolicyFilters({
    PolicyStatus? status,
    PolicyType? policyType,
    String? providerId,
    String? searchQuery,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _PolicyFilters;

  factory PolicyFilters.fromJson(Map<String, dynamic> json) =>
      _$PolicyFiltersFromJson(json);
}

/// Policy list response model
@freezed
class PolicyListResponse with _$PolicyListResponse {
  const factory PolicyListResponse({
    required List<Policy> policies,
    required int totalCount,
    required int page,
    required int limit,
    required bool hasNextPage,
  }) = _PolicyListResponse;

  factory PolicyListResponse.fromJson(Map<String, dynamic> json) =>
      _$PolicyListResponseFromJson(json);
}

/// Policy detail response with related data
@freezed
class PolicyDetail with _$PolicyDetail {
  const factory PolicyDetail({
    required Policy policy,
    List<Premium>? premiums,
    List<Claim>? claims,
    List<Coverage>? coverages,
  }) = _PolicyDetail;

  factory PolicyDetail.fromJson(Map<String, dynamic> json) =>
      _$PolicyDetailFromJson(json);
}


