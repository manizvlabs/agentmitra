/// User data model
class UserModel {
  final String userId;
  final String phoneNumber;
  final String? email;
  final String? fullName;
  final String? agentCode;
  final String? role; // Legacy field for backward compatibility
  final List<String> roles; // RBAC roles
  final List<String> permissions; // RBAC permissions
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.userId,
    required this.phoneNumber,
    this.email,
    this.fullName,
    this.agentCode,
    this.role,
    this.roles = const [],
    this.permissions = const [],
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? json['userId'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      email: json['email'],
      fullName: json['full_name'] ?? json['fullName'],
      agentCode: json['agent_code'] ?? json['agentCode'],
      role: json['role'],
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'email': email,
      'full_name': fullName,
      'agent_code': agentCode,
      'role': role,
      'roles': roles,
      'permissions': permissions,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this UserModel with modified fields
  UserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? agentCode,
    String? role,
    List<String>? roles,
    List<String>? permissions,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      agentCode: agentCode ?? this.agentCode,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

