/// Authentication response model
import 'user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel? user;
  final List<String>? permissions;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
    this.expiresIn = 1800,
    this.user,
    this.permissions,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 1800,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'])
          : null,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      if (user != null) 'user': user!.toJson(),
      if (permissions != null) 'permissions': permissions,
    };
  }
}

