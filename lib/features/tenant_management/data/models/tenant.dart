class Tenant {
  final String tenantId;
  final String tenantCode;
  final String tenantName;
  final String tenantType;
  final String status;
  final String? subscriptionPlan;
  final int? maxUsers;
  final int? storageLimitGb;
  final int? apiRateLimit;
  final String? contactEmail;
  final String? contactPhone;
  final Map<String, dynamic>? businessAddress;
  final DateTime? createdAt;
  final Map<String, dynamic>? complianceStatus;
  final Map<String, dynamic>? regulatoryApprovals;

  const Tenant({
    required this.tenantId,
    required this.tenantCode,
    required this.tenantName,
    required this.tenantType,
    required this.status,
    this.subscriptionPlan,
    this.maxUsers,
    this.storageLimitGb,
    this.apiRateLimit,
    this.contactEmail,
    this.contactPhone,
    this.businessAddress,
    this.createdAt,
    this.complianceStatus,
    this.regulatoryApprovals,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      tenantId: json['tenant_id'] as String,
      tenantCode: json['tenant_code'] as String,
      tenantName: json['tenant_name'] as String,
      tenantType: json['tenant_type'] as String,
      status: json['status'] as String,
      subscriptionPlan: json['subscription_plan'] as String?,
      maxUsers: json['max_users'] as int?,
      storageLimitGb: json['storage_limit_gb'] as int?,
      apiRateLimit: json['api_rate_limit'] as int?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      businessAddress: json['business_address'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      complianceStatus: json['compliance_status'] as Map<String, dynamic>?,
      regulatoryApprovals: json['regulatory_approvals'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'tenant_code': tenantCode,
      'tenant_name': tenantName,
      'tenant_type': tenantType,
      'status': status,
      'subscription_plan': subscriptionPlan,
      'max_users': maxUsers,
      'storage_limit_gb': storageLimitGb,
      'api_rate_limit': apiRateLimit,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'business_address': businessAddress,
      'created_at': createdAt?.toIso8601String(),
      'compliance_status': complianceStatus,
      'regulatory_approvals': regulatoryApprovals,
    };
  }
}

class TenantCreationRequest {
  final String tenantCode;
  final String tenantName;
  final String tenantType;
  final String? subscriptionPlan;
  final int? maxUsers;
  final int? storageLimitGb;
  final int? apiRateLimit;
  final String? contactEmail;
  final String? contactPhone;
  final Map<String, dynamic>? businessAddress;
  final String adminPhone;
  final String? adminEmail;
  final String? adminFirstName;
  final String? adminLastName;
  final Map<String, dynamic>? regulatoryApprovals;
  final Map<String, dynamic>? metadata;

  const TenantCreationRequest({
    required this.tenantCode,
    required this.tenantName,
    required this.tenantType,
    this.subscriptionPlan = 'trial',
    this.maxUsers = 100,
    this.storageLimitGb = 5,
    this.apiRateLimit = 1000,
    this.contactEmail,
    this.contactPhone,
    required this.adminPhone,
    this.adminEmail,
    this.adminFirstName,
    this.adminLastName,
    this.regulatoryApprovals,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenant_code': tenantCode,
      'tenant_name': tenantName,
      'tenant_type': tenantType,
      'subscription_plan': subscriptionPlan,
      'max_users': maxUsers,
      'storage_limit_gb': storageLimitGb,
      'api_rate_limit': apiRateLimit,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'business_address': businessAddress,
      'admin_phone': adminPhone,
      'admin_email': adminEmail,
      'admin_first_name': adminFirstName,
      'admin_last_name': adminLastName,
      'regulatory_approvals': regulatoryApprovals,
      'metadata': metadata,
    };
  }
}

class TenantProvisioningStatus {
  final String tenantId;
  final String status;
  final String? adminUserId;
  final String? adminTenantUserId;
  final DateTime provisionedAt;
  final String? errorMessage;

  const TenantProvisioningStatus({
    required this.tenantId,
    required this.status,
    this.adminUserId,
    this.adminTenantUserId,
    required this.provisionedAt,
    this.errorMessage,
  });

  factory TenantProvisioningStatus.fromJson(Map<String, dynamic> json) {
    return TenantProvisioningStatus(
      tenantId: json['tenant_id'] as String,
      status: json['status'] as String,
      adminUserId: json['admin_user_id'] as String?,
      adminTenantUserId: json['admin_tenant_user_id'] as String?,
      provisionedAt: DateTime.parse(json['provisioned_at'] as String),
      errorMessage: json['error_message'] as String?,
    );
  }
}
