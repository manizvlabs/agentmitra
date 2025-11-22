/// Session management data models

class UserSession {
  final String sessionId;
  final String userId;
  final String deviceInfo;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? lastActivityAt;
  final String status;
  final Map<String, dynamic>? metadata;

  UserSession({
    required this.sessionId,
    required this.userId,
    required this.deviceInfo,
    required this.ipAddress,
    required this.createdAt,
    this.expiresAt,
    this.lastActivityAt,
    required this.status,
    this.metadata,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      sessionId: json['session_id'] ?? '',
      userId: json['user_id'] ?? '',
      deviceInfo: json['device_info'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      lastActivityAt: json['last_activity_at'] != null ? DateTime.parse(json['last_activity_at']) : null,
      status: json['status'] ?? 'active',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'device_info': deviceInfo,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt!.toIso8601String(),
      'status': status,
      if (metadata != null) 'metadata': metadata,
    };
  }

  bool get isActive => status == 'active';
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class SessionAnalytics {
  final String userId;
  final int totalSessions;
  final int activeSessions;
  final double averageSessionDuration;
  final Map<String, int> deviceBreakdown;
  final List<UserSession> recentSessions;
  final DateTime lastLogin;

  SessionAnalytics({
    required this.userId,
    required this.totalSessions,
    required this.activeSessions,
    required this.averageSessionDuration,
    required this.deviceBreakdown,
    required this.recentSessions,
    required this.lastLogin,
  });

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      userId: json['user_id'] ?? '',
      totalSessions: json['total_sessions'] ?? 0,
      activeSessions: json['active_sessions'] ?? 0,
      averageSessionDuration: (json['average_session_duration'] ?? 0.0).toDouble(),
      deviceBreakdown: Map<String, int>.from(json['device_breakdown'] ?? {}),
      recentSessions: (json['recent_sessions'] as List<dynamic>?)
          ?.map((session) => UserSession.fromJson(session))
          .toList() ?? [],
      lastLogin: DateTime.parse(json['last_login'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class SessionSettings {
  final String userId;
  final bool rememberMe;
  final Duration sessionTimeout;
  final bool allowMultipleSessions;
  final int maxConcurrentSessions;
  final List<String> allowedDevices;
  final bool requireMfa;
  final DateTime updatedAt;

  SessionSettings({
    required this.userId,
    required this.rememberMe,
    required this.sessionTimeout,
    required this.allowMultipleSessions,
    required this.maxConcurrentSessions,
    required this.allowedDevices,
    required this.requireMfa,
    required this.updatedAt,
  });

  factory SessionSettings.fromJson(Map<String, dynamic> json) {
    return SessionSettings(
      userId: json['user_id'] ?? '',
      rememberMe: json['remember_me'] ?? true,
      sessionTimeout: Duration(minutes: json['session_timeout_minutes'] ?? 30),
      allowMultipleSessions: json['allow_multiple_sessions'] ?? true,
      maxConcurrentSessions: json['max_concurrent_sessions'] ?? 5,
      allowedDevices: List<String>.from(json['allowed_devices'] ?? []),
      requireMfa: json['require_mfa'] ?? false,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'remember_me': rememberMe,
      'session_timeout_minutes': sessionTimeout.inMinutes,
      'allow_multiple_sessions': allowMultipleSessions,
      'max_concurrent_sessions': maxConcurrentSessions,
      'allowed_devices': allowedDevices,
      'require_mfa': requireMfa,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
