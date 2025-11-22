import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/session_models.dart';

class SessionRemoteDataSource {
  /// Get user sessions
  Future<List<UserSession>> getUserSessions({
    String? userId,
    String? status,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['user_id'] = userId;
    if (status != null) queryParams['status'] = status;
    queryParams['limit'] = limit.toString();

    final response = await ApiService.get(
      ApiConstants.authSessions,
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => UserSession.fromJson(json))
        .toList();
  }

  /// Get session by ID
  Future<UserSession> getSessionById(String sessionId) async {
    final response = await ApiService.get(ApiConstants.authSession(sessionId));
    return UserSession.fromJson(response);
  }

  /// Create new session
  Future<UserSession> createSession(Map<String, dynamic> sessionData) async {
    final response = await ApiService.post(ApiConstants.authSessions, sessionData);
    return UserSession.fromJson(response);
  }

  /// Update session
  Future<UserSession> updateSession(String sessionId, Map<String, dynamic> sessionData) async {
    final response = await ApiService.put(
      ApiConstants.authSession(sessionId),
      sessionData,
    );
    return UserSession.fromJson(response);
  }

  /// Delete session (logout)
  Future<void> deleteSession(String sessionId) async {
    await ApiService.delete(ApiConstants.authSession(sessionId));
  }

  /// Get session analytics
  Future<SessionAnalytics> getSessionAnalytics(String userId) async {
    final response = await ApiService.get(
      '${ApiConstants.authSessions}/analytics',
      queryParameters: {'user_id': userId},
    );
    return SessionAnalytics.fromJson(response);
  }

  /// Get session settings
  Future<SessionSettings> getSessionSettings(String userId) async {
    final response = await ApiService.get(
      '${ApiConstants.authSessions}/settings',
      queryParameters: {'user_id': userId},
    );
    return SessionSettings.fromJson(response);
  }

  /// Update session settings
  Future<SessionSettings> updateSessionSettings(String userId, Map<String, dynamic> settings) async {
    final response = await ApiService.put(
      '${ApiConstants.authSessions}/settings',
      {'user_id': userId, ...settings},
    );
    return SessionSettings.fromJson(response);
  }

  /// Terminate all user sessions except current
  Future<void> terminateAllSessions(String userId, {String? excludeSessionId}) async {
    final queryParams = <String, String>{'user_id': userId};
    if (excludeSessionId != null) queryParams['exclude_session_id'] = excludeSessionId;

    await ApiService.post(
      '${ApiConstants.authSessions}/terminate-all',
      queryParams,
    );
  }

  /// Extend session expiry
  Future<UserSession> extendSession(String sessionId, Duration extension) async {
    final response = await ApiService.post(
      '${ApiConstants.authSession(sessionId)}/extend',
      {'extension_minutes': extension.inMinutes},
    );
    return UserSession.fromJson(response);
  }
}
