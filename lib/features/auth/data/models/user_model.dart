/// User data model
class UserModel {
  final String userId;
  final String phoneNumber;
  final String? email;
  final String? fullName;
  final String? agentCode;
  final String? role; // 'agent', 'customer', 'admin'
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
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

