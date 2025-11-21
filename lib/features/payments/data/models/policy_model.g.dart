// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PolicyImpl _$$PolicyImplFromJson(Map<String, dynamic> json) => _$PolicyImpl(
      policyId: json['policyId'] as String,
      policyNumber: json['policyNumber'] as String,
      providerPolicyId: json['providerPolicyId'] as String,
      policyholderId: json['policyholderId'] as String,
      agentId: json['agentId'] as String,
      providerId: json['providerId'] as String,
      policyType: json['policyType'] as String,
      planName: json['planName'] as String,
      planCode: json['planCode'] as String,
      category: json['category'] as String,
      sumAssured: (json['sumAssured'] as num).toDouble(),
      premiumAmount: (json['premiumAmount'] as num).toDouble(),
      premiumFrequency: json['premiumFrequency'] as String,
      premiumMode: json['premiumMode'] as String,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      approvalDate: json['approvalDate'] == null
          ? null
          : DateTime.parse(json['approvalDate'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      maturityDate: json['maturityDate'] == null
          ? null
          : DateTime.parse(json['maturityDate'] as String),
      renewalDate: json['renewalDate'] == null
          ? null
          : DateTime.parse(json['renewalDate'] as String),
      status: json['status'] as String,
      subStatus: json['subStatus'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      coverageDetails: json['coverageDetails'] as Map<String, dynamic>?,
      exclusions: json['exclusions'] as Map<String, dynamic>?,
      termsAndConditions: json['termsAndConditions'] as Map<String, dynamic>?,
      policyDocumentUrl: json['policyDocumentUrl'] as String?,
      applicationFormUrl: json['applicationFormUrl'] as String?,
      medicalReports: json['medicalReports'] as Map<String, dynamic>?,
      nomineeDetails: json['nomineeDetails'] as Map<String, dynamic>?,
      assigneeDetails: json['assigneeDetails'] as Map<String, dynamic>?,
      lastPaymentDate: json['lastPaymentDate'] == null
          ? null
          : DateTime.parse(json['lastPaymentDate'] as String),
      nextPaymentDate: json['nextPaymentDate'] == null
          ? null
          : DateTime.parse(json['nextPaymentDate'] as String),
      totalPayments: (json['totalPayments'] as num?)?.toInt(),
      outstandingAmount: (json['outstandingAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PolicyImplToJson(_$PolicyImpl instance) =>
    <String, dynamic>{
      'policyId': instance.policyId,
      'policyNumber': instance.policyNumber,
      'providerPolicyId': instance.providerPolicyId,
      'policyholderId': instance.policyholderId,
      'agentId': instance.agentId,
      'providerId': instance.providerId,
      'policyType': instance.policyType,
      'planName': instance.planName,
      'planCode': instance.planCode,
      'category': instance.category,
      'sumAssured': instance.sumAssured,
      'premiumAmount': instance.premiumAmount,
      'premiumFrequency': instance.premiumFrequency,
      'premiumMode': instance.premiumMode,
      'applicationDate': instance.applicationDate.toIso8601String(),
      'approvalDate': instance.approvalDate?.toIso8601String(),
      'startDate': instance.startDate.toIso8601String(),
      'maturityDate': instance.maturityDate?.toIso8601String(),
      'renewalDate': instance.renewalDate?.toIso8601String(),
      'status': instance.status,
      'subStatus': instance.subStatus,
      'paymentStatus': instance.paymentStatus,
      'coverageDetails': instance.coverageDetails,
      'exclusions': instance.exclusions,
      'termsAndConditions': instance.termsAndConditions,
      'policyDocumentUrl': instance.policyDocumentUrl,
      'applicationFormUrl': instance.applicationFormUrl,
      'medicalReports': instance.medicalReports,
      'nomineeDetails': instance.nomineeDetails,
      'assigneeDetails': instance.assigneeDetails,
      'lastPaymentDate': instance.lastPaymentDate?.toIso8601String(),
      'nextPaymentDate': instance.nextPaymentDate?.toIso8601String(),
      'totalPayments': instance.totalPayments,
      'outstandingAmount': instance.outstandingAmount,
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
