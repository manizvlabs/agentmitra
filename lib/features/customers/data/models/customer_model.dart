class Customer {
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String role;
  final String? status;
  final bool? phoneVerified;
  final bool? emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    required this.userId,
    this.firstName,
    this.lastName,
    this.displayName,
    this.email,
    this.phoneNumber,
    required this.role,
    this.status,
    this.phoneVerified,
    this.emailVerified,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return phoneNumber ?? 'Unknown';
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'],
      lastName: json['last_name'] ?? json['lastName'],
      displayName: json['display_name'] ?? json['displayName'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      role: json['role'] ?? 'policyholder',
      status: json['status'],
      phoneVerified: json['phone_verified'] ?? json['phoneVerified'],
      emailVerified: json['email_verified'] ?? json['emailVerified'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'display_name': displayName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'status': status,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

