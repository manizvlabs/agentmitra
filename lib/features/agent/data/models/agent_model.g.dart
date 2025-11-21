// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentProfileImpl _$$AgentProfileImplFromJson(Map<String, dynamic> json) =>
    _$AgentProfileImpl(
      agentId: json['agentId'] as String,
      userId: json['userId'] as String,
      agentCode: json['agentCode'] as String,
      licenseNumber: json['licenseNumber'] as String?,
      licenseExpiryDate: json['licenseExpiryDate'] as String?,
      licenseIssuingAuthority: json['licenseIssuingAuthority'] as String?,
      companyName: json['companyName'] as String?,
      branchName: json['branchName'] as String?,
      branchCode: json['branchCode'] as String?,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      joiningDate: json['joiningDate'] == null
          ? null
          : DateTime.parse(json['joiningDate'] as String),
      employmentStatus: json['employmentStatus'] as String?,
      managerId: json['managerId'] as String?,
      managerName: json['managerName'] as String?,
      contactDetails: json['contactDetails'] as Map<String, dynamic>?,
      addressDetails: json['addressDetails'] as Map<String, dynamic>?,
      bankDetails: json['bankDetails'] as Map<String, dynamic>?,
      emergencyContacts: json['emergencyContacts'] as Map<String, dynamic>?,
      documents: json['documents'] as Map<String, dynamic>?,
      verificationStatus: json['verificationStatus'] as String?,
      lastVerificationDate: json['lastVerificationDate'] == null
          ? null
          : DateTime.parse(json['lastVerificationDate'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      performanceMetrics: json['performanceMetrics'] as Map<String, dynamic>?,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      loginCount: (json['loginCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AgentProfileImplToJson(_$AgentProfileImpl instance) =>
    <String, dynamic>{
      'agentId': instance.agentId,
      'userId': instance.userId,
      'agentCode': instance.agentCode,
      'licenseNumber': instance.licenseNumber,
      'licenseExpiryDate': instance.licenseExpiryDate,
      'licenseIssuingAuthority': instance.licenseIssuingAuthority,
      'companyName': instance.companyName,
      'branchName': instance.branchName,
      'branchCode': instance.branchCode,
      'designation': instance.designation,
      'department': instance.department,
      'joiningDate': instance.joiningDate?.toIso8601String(),
      'employmentStatus': instance.employmentStatus,
      'managerId': instance.managerId,
      'managerName': instance.managerName,
      'contactDetails': instance.contactDetails,
      'addressDetails': instance.addressDetails,
      'bankDetails': instance.bankDetails,
      'emergencyContacts': instance.emergencyContacts,
      'documents': instance.documents,
      'verificationStatus': instance.verificationStatus,
      'lastVerificationDate': instance.lastVerificationDate?.toIso8601String(),
      'profileImageUrl': instance.profileImageUrl,
      'signatureUrl': instance.signatureUrl,
      'performanceMetrics': instance.performanceMetrics,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'loginCount': instance.loginCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$AgentSettingsImpl _$$AgentSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AgentSettingsImpl(
      agentId: json['agentId'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      emailNotifications: json['emailNotifications'] as bool?,
      smsNotifications: json['smsNotifications'] as bool?,
      pushNotifications: json['pushNotifications'] as bool?,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      dateFormat: json['dateFormat'] as String?,
      timeFormat: json['timeFormat'] as String?,
      timezone: json['timezone'] as String?,
      biometricEnabled: json['biometricEnabled'] as bool?,
      autoBackupEnabled: json['autoBackupEnabled'] as bool?,
      sessionTimeoutMinutes: (json['sessionTimeoutMinutes'] as num?)?.toInt(),
      twoFactorEnabled: json['twoFactorEnabled'] as bool?,
      customSettings: json['customSettings'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AgentSettingsImplToJson(_$AgentSettingsImpl instance) =>
    <String, dynamic>{
      'agentId': instance.agentId,
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotifications': instance.emailNotifications,
      'smsNotifications': instance.smsNotifications,
      'pushNotifications': instance.pushNotifications,
      'language': instance.language,
      'theme': instance.theme,
      'dateFormat': instance.dateFormat,
      'timeFormat': instance.timeFormat,
      'timezone': instance.timezone,
      'biometricEnabled': instance.biometricEnabled,
      'autoBackupEnabled': instance.autoBackupEnabled,
      'sessionTimeoutMinutes': instance.sessionTimeoutMinutes,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'customSettings': instance.customSettings,
    };

_$AgentPreferencesImpl _$$AgentPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$AgentPreferencesImpl(
      agentId: json['agentId'] as String,
      favoriteProducts: (json['favoriteProducts'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      preferredPaymentMethods:
          (json['preferredPaymentMethods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      defaultCurrency: json['defaultCurrency'] as String?,
      dashboardLayout: json['dashboardLayout'] as Map<String, dynamic>?,
      quickActions: json['quickActions'] as Map<String, dynamic>?,
      showWelcomeMessage: json['showWelcomeMessage'] as bool?,
      autoRefreshData: json['autoRefreshData'] as bool?,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt(),
      defaultSortBy: json['defaultSortBy'] as String?,
      defaultSortOrder: json['defaultSortOrder'] as String?,
      reportPreferences: json['reportPreferences'] as Map<String, dynamic>?,
      notificationPreferences:
          json['notificationPreferences'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AgentPreferencesImplToJson(
        _$AgentPreferencesImpl instance) =>
    <String, dynamic>{
      'agentId': instance.agentId,
      'favoriteProducts': instance.favoriteProducts,
      'preferredPaymentMethods': instance.preferredPaymentMethods,
      'defaultCurrency': instance.defaultCurrency,
      'dashboardLayout': instance.dashboardLayout,
      'quickActions': instance.quickActions,
      'showWelcomeMessage': instance.showWelcomeMessage,
      'autoRefreshData': instance.autoRefreshData,
      'itemsPerPage': instance.itemsPerPage,
      'defaultSortBy': instance.defaultSortBy,
      'defaultSortOrder': instance.defaultSortOrder,
      'reportPreferences': instance.reportPreferences,
      'notificationPreferences': instance.notificationPreferences,
    };

_$AgentPerformanceImpl _$$AgentPerformanceImplFromJson(
        Map<String, dynamic> json) =>
    _$AgentPerformanceImpl(
      agentId: json['agentId'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      policiesSold: (json['policiesSold'] as num?)?.toInt(),
      premiumCollected: (json['premiumCollected'] as num?)?.toDouble(),
      commissionEarned: (json['commissionEarned'] as num?)?.toDouble(),
      customersAcquired: (json['customersAcquired'] as num?)?.toInt(),
      claimsProcessed: (json['claimsProcessed'] as num?)?.toInt(),
      customerSatisfactionScore:
          (json['customerSatisfactionScore'] as num?)?.toDouble(),
      monthlyTargets: json['monthlyTargets'] as Map<String, dynamic>?,
      achievements: json['achievements'] as Map<String, dynamic>?,
      performanceGrade: json['performanceGrade'] as String?,
      badges:
          (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$$AgentPerformanceImplToJson(
        _$AgentPerformanceImpl instance) =>
    <String, dynamic>{
      'agentId': instance.agentId,
      'periodStart': instance.periodStart.toIso8601String(),
      'periodEnd': instance.periodEnd.toIso8601String(),
      'policiesSold': instance.policiesSold,
      'premiumCollected': instance.premiumCollected,
      'commissionEarned': instance.commissionEarned,
      'customersAcquired': instance.customersAcquired,
      'claimsProcessed': instance.claimsProcessed,
      'customerSatisfactionScore': instance.customerSatisfactionScore,
      'monthlyTargets': instance.monthlyTargets,
      'achievements': instance.achievements,
      'performanceGrade': instance.performanceGrade,
      'badges': instance.badges,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
    };
