import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_model.freezed.dart';
part 'agent_model.g.dart';

@freezed
class AgentProfile with _$AgentProfile {
  const factory AgentProfile({
    required String agentId,
    required String userId,
    required String agentCode,
    String? licenseNumber,
    String? licenseExpiryDate,
    String? licenseIssuingAuthority,
    String? companyName,
    String? branchName,
    String? branchCode,
    String? designation,
    String? department,
    DateTime? joiningDate,
    String? employmentStatus,
    String? managerId,
    String? managerName,
    Map<String, dynamic>? contactDetails,
    Map<String, dynamic>? addressDetails,
    Map<String, dynamic>? bankDetails,
    Map<String, dynamic>? emergencyContacts,
    Map<String, dynamic>? documents,
    String? verificationStatus,
    DateTime? lastVerificationDate,
    String? profileImageUrl,
    String? signatureUrl,
    Map<String, dynamic>? performanceMetrics,
    DateTime? lastLoginAt,
    int? loginCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AgentProfile;

  factory AgentProfile.fromJson(Map<String, dynamic> json) => _$AgentProfileFromJson(json);
}

@freezed
class AgentSettings with _$AgentSettings {
  const factory AgentSettings({
    required String agentId,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    String? language,
    String? theme,
    String? dateFormat,
    String? timeFormat,
    String? timezone,
    bool? biometricEnabled,
    bool? autoBackupEnabled,
    int? sessionTimeoutMinutes,
    bool? twoFactorEnabled,
    Map<String, dynamic>? customSettings,
  }) = _AgentSettings;

  factory AgentSettings.fromJson(Map<String, dynamic> json) => _$AgentSettingsFromJson(json);
}

@freezed
class AgentPreferences with _$AgentPreferences {
  const factory AgentPreferences({
    required String agentId,
    List<String>? favoriteProducts,
    List<String>? preferredPaymentMethods,
    String? defaultCurrency,
    Map<String, dynamic>? dashboardLayout,
    Map<String, dynamic>? quickActions,
    bool? showWelcomeMessage,
    bool? autoRefreshData,
    int? itemsPerPage,
    String? defaultSortBy,
    String? defaultSortOrder,
    Map<String, dynamic>? reportPreferences,
    Map<String, dynamic>? notificationPreferences,
  }) = _AgentPreferences;

  factory AgentPreferences.fromJson(Map<String, dynamic> json) => _$AgentPreferencesFromJson(json);
}

@freezed
class AgentPerformance with _$AgentPerformance {
  const factory AgentPerformance({
    required String agentId,
    required DateTime periodStart,
    required DateTime periodEnd,
    int? policiesSold,
    double? premiumCollected,
    double? commissionEarned,
    int? customersAcquired,
    int? claimsProcessed,
    double? customerSatisfactionScore,
    Map<String, dynamic>? monthlyTargets,
    Map<String, dynamic>? achievements,
    String? performanceGrade,
    List<String>? badges,
    DateTime? lastUpdated,
  }) = _AgentPerformance;

  factory AgentPerformance.fromJson(Map<String, dynamic> json) => _$AgentPerformanceFromJson(json);
}
