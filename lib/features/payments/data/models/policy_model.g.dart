// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PolicyImpl _$$PolicyImplFromJson(Map<String, dynamic> json) => _$PolicyImpl(
      policyId: json['policy_id'] as String,
      policyNumber: json['policy_number'] as String,
      providerPolicyId: json['provider_policy_id'] as String?,
      policyholderId: json['policyholder_id'] as String,
      agentId: json['agent_id'] as String,
      providerId: json['provider_id'] as String,
      policyType: json['policy_type'] as String,
      planName: json['plan_name'] as String,
      planCode: json['plan_code'] as String?,
      category: json['category'] as String?,
      sumAssured: (json['sum_assured'] as num).toDouble(),
      premiumAmount: (json['premium_amount'] as num).toDouble(),
      premiumFrequency: json['premium_frequency'] as String,
      premiumMode: json['premium_mode'] as String?,
      applicationDate: DateTime.parse(json['application_date'] as String),
      approvalDate: json['approval_date'] == null
          ? null
          : DateTime.parse(json['approval_date'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      maturityDate: json['maturity_date'] == null
          ? null
          : DateTime.parse(json['maturity_date'] as String),
      renewalDate: json['renewal_date'] == null
          ? null
          : DateTime.parse(json['renewal_date'] as String),
      status: json['status'] as String,
      subStatus: json['sub_status'] as String?,
      paymentStatus: json['payment_status'] as String?,
      coverageDetails: json['coverage_details'] as Map<String, dynamic>?,
      exclusions: json['exclusions'] as Map<String, dynamic>?,
      termsAndConditions: json['terms_and_conditions'] as Map<String, dynamic>?,
      policyDocumentUrl: json['policy_document_url'] as String?,
      applicationFormUrl: json['application_form_url'] as String?,
      medicalReports: json['medical_reports'] as Map<String, dynamic>?,
      nomineeDetails: json['nominee_details'] as Map<String, dynamic>?,
      assigneeDetails: json['assignee_details'] as Map<String, dynamic>?,
      lastPaymentDate: json['last_payment_date'] == null
          ? null
          : DateTime.parse(json['last_payment_date'] as String),
      nextPaymentDate: json['next_payment_date'] == null
          ? null
          : DateTime.parse(json['next_payment_date'] as String),
      totalPayments: (json['total_payments'] as num?)?.toInt(),
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble(),
      policyholderInfo: json['policyholder_info'] as Map<String, dynamic>?,
      agentInfo: json['agent_info'] as Map<String, dynamic>?,
      providerInfo: json['provider_info'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PolicyImplToJson(_$PolicyImpl instance) =>
    <String, dynamic>{
      'policy_id': instance.policyId,
      'policy_number': instance.policyNumber,
      'provider_policy_id': instance.providerPolicyId,
      'policyholder_id': instance.policyholderId,
      'agent_id': instance.agentId,
      'provider_id': instance.providerId,
      'policy_type': instance.policyType,
      'plan_name': instance.planName,
      'plan_code': instance.planCode,
      'category': instance.category,
      'sum_assured': instance.sumAssured,
      'premium_amount': instance.premiumAmount,
      'premium_frequency': instance.premiumFrequency,
      'premium_mode': instance.premiumMode,
      'application_date': instance.applicationDate.toIso8601String(),
      'approval_date': instance.approvalDate?.toIso8601String(),
      'start_date': instance.startDate.toIso8601String(),
      'maturity_date': instance.maturityDate?.toIso8601String(),
      'renewal_date': instance.renewalDate?.toIso8601String(),
      'status': instance.status,
      'sub_status': instance.subStatus,
      'payment_status': instance.paymentStatus,
      'coverage_details': instance.coverageDetails,
      'exclusions': instance.exclusions,
      'terms_and_conditions': instance.termsAndConditions,
      'policy_document_url': instance.policyDocumentUrl,
      'application_form_url': instance.applicationFormUrl,
      'medical_reports': instance.medicalReports,
      'nominee_details': instance.nomineeDetails,
      'assignee_details': instance.assigneeDetails,
      'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
      'next_payment_date': instance.nextPaymentDate?.toIso8601String(),
      'total_payments': instance.totalPayments,
      'outstanding_amount': instance.outstandingAmount,
      'policyholder_info': instance.policyholderInfo,
      'agent_info': instance.agentInfo,
      'provider_info': instance.providerInfo,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

_$PolicyholderImpl _$$PolicyholderImplFromJson(Map<String, dynamic> json) =>
    _$PolicyholderImpl(
      policyholderId: json['policyholderId'] as String,
      userId: json['userId'] as String,
      agentId: json['agentId'] as String?,
      customerId: json['customerId'] as String?,
      salutation: json['salutation'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      occupation: json['occupation'] as String?,
      annualIncome: (json['annualIncome'] as num?)?.toDouble(),
      educationLevel: json['educationLevel'] as String?,
      riskProfile: json['riskProfile'] as Map<String, dynamic>?,
      investmentHorizon: json['investmentHorizon'] as String?,
      communicationPreferences:
          json['communicationPreferences'] as Map<String, dynamic>?,
      marketingConsent: json['marketingConsent'] as bool?,
      familyMembers: json['familyMembers'] as Map<String, dynamic>?,
      nomineeDetails: json['nomineeDetails'] as Map<String, dynamic>?,
      bankDetails: json['bankDetails'] as Map<String, dynamic>?,
      investmentPortfolio: json['investmentPortfolio'] as Map<String, dynamic>?,
      preferredContactTime: json['preferredContactTime'] as String?,
      preferredLanguage: json['preferredLanguage'] as String?,
      digitalLiteracyScore: (json['digitalLiteracyScore'] as num?)?.toInt(),
      engagementScore: (json['engagementScore'] as num?)?.toDouble(),
      onboardingStatus: json['onboardingStatus'] as String?,
      churnRiskScore: (json['churnRiskScore'] as num?)?.toDouble(),
      lastInteractionAt: json['lastInteractionAt'] == null
          ? null
          : DateTime.parse(json['lastInteractionAt'] as String),
      totalInteractions: (json['totalInteractions'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$PolicyholderImplToJson(_$PolicyholderImpl instance) =>
    <String, dynamic>{
      'policyholderId': instance.policyholderId,
      'userId': instance.userId,
      'agentId': instance.agentId,
      'customerId': instance.customerId,
      'salutation': instance.salutation,
      'maritalStatus': instance.maritalStatus,
      'occupation': instance.occupation,
      'annualIncome': instance.annualIncome,
      'educationLevel': instance.educationLevel,
      'riskProfile': instance.riskProfile,
      'investmentHorizon': instance.investmentHorizon,
      'communicationPreferences': instance.communicationPreferences,
      'marketingConsent': instance.marketingConsent,
      'familyMembers': instance.familyMembers,
      'nomineeDetails': instance.nomineeDetails,
      'bankDetails': instance.bankDetails,
      'investmentPortfolio': instance.investmentPortfolio,
      'preferredContactTime': instance.preferredContactTime,
      'preferredLanguage': instance.preferredLanguage,
      'digitalLiteracyScore': instance.digitalLiteracyScore,
      'engagementScore': instance.engagementScore,
      'onboardingStatus': instance.onboardingStatus,
      'churnRiskScore': instance.churnRiskScore,
      'lastInteractionAt': instance.lastInteractionAt?.toIso8601String(),
      'totalInteractions': instance.totalInteractions,
    };

_$PremiumImpl _$$PremiumImplFromJson(Map<String, dynamic> json) =>
    _$PremiumImpl(
      paymentId: json['paymentId'] as String,
      policyId: json['policyId'] as String,
      policyholderId: json['policyholderId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      paymentGateway: json['paymentGateway'] as String?,
      status: json['status'] as String,
      failureReason: json['failureReason'] as String?,
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
      receiptUrl: json['receiptUrl'] as String?,
      processedBy: json['processedBy'] as String?,
    );

Map<String, dynamic> _$$PremiumImplToJson(_$PremiumImpl instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'policyId': instance.policyId,
      'policyholderId': instance.policyholderId,
      'amount': instance.amount,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'dueDate': instance.dueDate.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
      'transactionId': instance.transactionId,
      'paymentGateway': instance.paymentGateway,
      'status': instance.status,
      'failureReason': instance.failureReason,
      'paymentDetails': instance.paymentDetails,
      'receiptUrl': instance.receiptUrl,
      'processedBy': instance.processedBy,
    };

_$ClaimImpl _$$ClaimImplFromJson(Map<String, dynamic> json) => _$ClaimImpl(
      claimId: json['claimId'] as String,
      policyId: json['policyId'] as String,
      policyholderId: json['policyholderId'] as String,
      claimType: json['claimType'] as String,
      description: json['description'] as String,
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      claimDate: DateTime.parse(json['claimDate'] as String),
      claimedAmount: (json['claimedAmount'] as num).toDouble(),
      status: json['status'] as String?,
      subStatus: json['subStatus'] as String?,
      documents: json['documents'] as Map<String, dynamic>?,
      claimDetails: json['claimDetails'] as Map<String, dynamic>?,
      approvalDate: json['approvalDate'] == null
          ? null
          : DateTime.parse(json['approvalDate'] as String),
      settlementDate: json['settlementDate'] == null
          ? null
          : DateTime.parse(json['settlementDate'] as String),
      approvedAmount: (json['approvedAmount'] as num?)?.toDouble(),
      rejectionReason: json['rejectionReason'] as String?,
      processedBy: json['processedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
    );

Map<String, dynamic> _$$ClaimImplToJson(_$ClaimImpl instance) =>
    <String, dynamic>{
      'claimId': instance.claimId,
      'policyId': instance.policyId,
      'policyholderId': instance.policyholderId,
      'claimType': instance.claimType,
      'description': instance.description,
      'incidentDate': instance.incidentDate.toIso8601String(),
      'claimDate': instance.claimDate.toIso8601String(),
      'claimedAmount': instance.claimedAmount,
      'status': instance.status,
      'subStatus': instance.subStatus,
      'documents': instance.documents,
      'claimDetails': instance.claimDetails,
      'approvalDate': instance.approvalDate?.toIso8601String(),
      'settlementDate': instance.settlementDate?.toIso8601String(),
      'approvedAmount': instance.approvedAmount,
      'rejectionReason': instance.rejectionReason,
      'processedBy': instance.processedBy,
      'approvedBy': instance.approvedBy,
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
      terms: json['terms'] as Map<String, dynamic>?,
      conditions: json['conditions'] as Map<String, dynamic>?,
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
      'terms': instance.terms,
      'conditions': instance.conditions,
    };
