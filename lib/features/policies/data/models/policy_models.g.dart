// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PolicyImpl _$$PolicyImplFromJson(Map<String, dynamic> json) => _$PolicyImpl(
      policyId: json['policy_id'] as String,
      policyNumber: json['policy_number'] as String,
      planName: json['plan_name'] as String,
      sumAssured: (json['sum_assured'] as num).toDouble(),
      premiumAmount: (json['premium_amount'] as num).toDouble(),
      premiumFrequency: json['premium_frequency'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      maturityDate: json['maturity_date'] == null
          ? null
          : DateTime.parse(json['maturity_date'] as String),
      nextPaymentDate: json['next_payment_date'] == null
          ? null
          : DateTime.parse(json['next_payment_date'] as String),
      status: json['status'] as String,
      policyDocumentUrl: json['policy_document_url'] as String?,
      applicationFormUrl: json['application_form_url'] as String?,
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PolicyImplToJson(_$PolicyImpl instance) =>
    <String, dynamic>{
      'policy_id': instance.policyId,
      'policy_number': instance.policyNumber,
      'plan_name': instance.planName,
      'sum_assured': instance.sumAssured,
      'premium_amount': instance.premiumAmount,
      'premium_frequency': instance.premiumFrequency,
      'start_date': instance.startDate.toIso8601String(),
      'maturity_date': instance.maturityDate?.toIso8601String(),
      'next_payment_date': instance.nextPaymentDate?.toIso8601String(),
      'status': instance.status,
      'policy_document_url': instance.policyDocumentUrl,
      'application_form_url': instance.applicationFormUrl,
      'outstanding_amount': instance.outstandingAmount,
    };

_$PremiumImpl _$$PremiumImplFromJson(Map<String, dynamic> json) =>
    _$PremiumImpl(
      paymentId: json['paymentId'] as String,
      policyId: json['policyId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      status: json['status'] as String,
      receiptUrl: json['receiptUrl'] as String?,
    );

Map<String, dynamic> _$$PremiumImplToJson(_$PremiumImpl instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'policyId': instance.policyId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'dueDate': instance.dueDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'status': instance.status,
      'receiptUrl': instance.receiptUrl,
    };

_$ClaimImpl _$$ClaimImplFromJson(Map<String, dynamic> json) => _$ClaimImpl(
      claimId: json['claimId'] as String,
      policyId: json['policyId'] as String,
      claimType: json['claimType'] as String,
      description: json['description'] as String,
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      claimDate: DateTime.parse(json['claimDate'] as String),
      claimedAmount: (json['claimedAmount'] as num).toDouble(),
      status: json['status'] as String?,
      approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$$ClaimImplToJson(_$ClaimImpl instance) =>
    <String, dynamic>{
      'claimId': instance.claimId,
      'policyId': instance.policyId,
      'claimType': instance.claimType,
      'description': instance.description,
      'incidentDate': instance.incidentDate.toIso8601String(),
      'claimDate': instance.claimDate.toIso8601String(),
      'claimedAmount': instance.claimedAmount,
      'status': instance.status,
      'approvedAmount': instance.approvedAmount,
      'rejectionReason': instance.rejectionReason,
    };

_$CoverageImpl _$$CoverageImplFromJson(Map<String, dynamic> json) =>
    _$CoverageImpl(
      coverageId: json['coverageId'] as String,
      policyId: json['policyId'] as String,
      coverageType: json['coverageType'] as String,
      description: json['description'] as String,
      sumAssured: (json['sumAssured'] as num).toDouble(),
      premium: (json['premium'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$CoverageImplToJson(_$CoverageImpl instance) =>
    <String, dynamic>{
      'coverageId': instance.coverageId,
      'policyId': instance.policyId,
      'coverageType': instance.coverageType,
      'description': instance.description,
      'sumAssured': instance.sumAssured,
      'premium': instance.premium,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'status': instance.status,
    };

_$PolicyFiltersImpl _$$PolicyFiltersImplFromJson(Map<String, dynamic> json) =>
    _$PolicyFiltersImpl(
      status: $enumDecodeNullable(_$PolicyStatusEnumMap, json['status']),
      policyType: $enumDecodeNullable(_$PolicyTypeEnumMap, json['policyType']),
      providerId: json['providerId'] as String?,
      searchQuery: json['searchQuery'] as String?,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$$PolicyFiltersImplToJson(_$PolicyFiltersImpl instance) =>
    <String, dynamic>{
      'status': _$PolicyStatusEnumMap[instance.status],
      'policyType': _$PolicyTypeEnumMap[instance.policyType],
      'providerId': instance.providerId,
      'searchQuery': instance.searchQuery,
      'page': instance.page,
      'limit': instance.limit,
    };

const _$PolicyStatusEnumMap = {
  PolicyStatus.active: 'active',
  PolicyStatus.pendingApproval: 'pending_approval',
  PolicyStatus.lapsed: 'lapsed',
  PolicyStatus.matured: 'matured',
  PolicyStatus.cancelled: 'cancelled',
};

const _$PolicyTypeEnumMap = {
  PolicyType.termLife: 'term_life',
  PolicyType.wholeLife: 'whole_life',
  PolicyType.endowment: 'endowment',
  PolicyType.ulip: 'ulip',
  PolicyType.moneyBack: 'money_back',
  PolicyType.pension: 'pension',
};

_$PolicyListResponseImpl _$$PolicyListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PolicyListResponseImpl(
      policies: (json['policies'] as List<dynamic>)
          .map((e) => Policy.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNextPage: json['hasNextPage'] as bool,
    );

Map<String, dynamic> _$$PolicyListResponseImplToJson(
        _$PolicyListResponseImpl instance) =>
    <String, dynamic>{
      'policies': instance.policies,
      'totalCount': instance.totalCount,
      'page': instance.page,
      'limit': instance.limit,
      'hasNextPage': instance.hasNextPage,
    };

_$PolicyDetailImpl _$$PolicyDetailImplFromJson(Map<String, dynamic> json) =>
    _$PolicyDetailImpl(
      policy: Policy.fromJson(json['policy'] as Map<String, dynamic>),
      premiums: (json['premiums'] as List<dynamic>?)
          ?.map((e) => Premium.fromJson(e as Map<String, dynamic>))
          .toList(),
      claims: (json['claims'] as List<dynamic>?)
          ?.map((e) => Claim.fromJson(e as Map<String, dynamic>))
          .toList(),
      coverages: (json['coverages'] as List<dynamic>?)
          ?.map((e) => Coverage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PolicyDetailImplToJson(_$PolicyDetailImpl instance) =>
    <String, dynamic>{
      'policy': instance.policy,
      'premiums': instance.premiums,
      'claims': instance.claims,
      'coverages': instance.coverages,
    };
