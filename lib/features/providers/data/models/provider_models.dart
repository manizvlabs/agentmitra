/// Insurance provider data models

class InsuranceProvider {
  final String providerId;
  final String providerCode;
  final String providerName;
  final String providerType;
  final String? description;
  final String? licenseNumber;
  final String? regulatoryAuthority;
  final int? establishedYear;
  final ProviderHeadquarters? headquarters;
  final List<String> supportedLanguages;
  final String status;
  final String? integrationStatus;
  final DateTime? lastSyncAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  InsuranceProvider({
    required this.providerId,
    required this.providerCode,
    required this.providerName,
    required this.providerType,
    this.description,
    this.licenseNumber,
    this.regulatoryAuthority,
    this.establishedYear,
    this.headquarters,
    required this.supportedLanguages,
    required this.status,
    this.integrationStatus,
    this.lastSyncAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InsuranceProvider.fromJson(Map<String, dynamic> json) {
    return InsuranceProvider(
      providerId: json['provider_id'] ?? '',
      providerCode: json['provider_code'] ?? '',
      providerName: json['provider_name'] ?? '',
      providerType: json['provider_type'] ?? '',
      description: json['description'],
      licenseNumber: json['license_number'],
      regulatoryAuthority: json['regulatory_authority'],
      establishedYear: json['established_year'],
      headquarters: json['headquarters'] != null
          ? ProviderHeadquarters.fromJson(json['headquarters'])
          : null,
      supportedLanguages: List<String>.from(json['supported_languages'] ?? []),
      status: json['status'] ?? 'active',
      integrationStatus: json['integration_status'],
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ProviderHeadquarters {
  final String city;
  final String state;
  final String country;

  ProviderHeadquarters({
    required this.city,
    required this.state,
    required this.country,
  });

  factory ProviderHeadquarters.fromJson(Map<String, dynamic> json) {
    return ProviderHeadquarters(
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'state': state,
      'country': country,
    };
  }
}

class ProviderIntegrationStatus {
  final String providerId;
  final String status;
  final String? errorMessage;
  final DateTime? lastAttempted;
  final Map<String, dynamic>? integrationDetails;

  ProviderIntegrationStatus({
    required this.providerId,
    required this.status,
    this.errorMessage,
    this.lastAttempted,
    this.integrationDetails,
  });

  factory ProviderIntegrationStatus.fromJson(Map<String, dynamic> json) {
    return ProviderIntegrationStatus(
      providerId: json['provider_id'] ?? '',
      status: json['status'] ?? '',
      errorMessage: json['error_message'],
      lastAttempted: json['last_attempted'] != null
          ? DateTime.parse(json['last_attempted'])
          : null,
      integrationDetails: json['integration_details'],
    );
  }
}
