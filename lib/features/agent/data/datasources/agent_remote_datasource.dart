import 'package:dio/dio.dart';
import '../models/agent_model.dart';

abstract class AgentRemoteDataSource {
  Future<AgentProfile> getAgentProfile(String agentId);
  Future<AgentProfile> updateAgentProfile(String agentId, Map<String, dynamic> profileData);
  Future<AgentSettings> getAgentSettings(String agentId);
  Future<AgentSettings> updateAgentSettings(String agentId, Map<String, dynamic> settingsData);
  Future<AgentPreferences> getAgentPreferences(String agentId);
  Future<AgentPreferences> updateAgentPreferences(String agentId, Map<String, dynamic> preferencesData);
  Future<AgentPerformance> getAgentPerformance(String agentId, {DateTime? startDate, DateTime? endDate});
  Future<String> uploadProfileImage(String agentId, String imagePath);
  Future<String> uploadDocument(String agentId, String documentPath, String documentType);
  Future<void> changePassword(String agentId, String currentPassword, String newPassword);
  Future<void> updateBiometricSetting(String agentId, bool enabled);
}

class AgentRemoteDataSourceImpl implements AgentRemoteDataSource {
  final Dio dio;

  AgentRemoteDataSourceImpl(this.dio);

  @override
  Future<AgentProfile> getAgentProfile(String agentId) async {
    try {
      final response = await dio.get('/api/v1/agents/$agentId/profile');
      return AgentProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch agent profile: $e');
    }
  }

  @override
  Future<AgentProfile> updateAgentProfile(String agentId, Map<String, dynamic> profileData) async {
    try {
      final response = await dio.put('/api/v1/agents/$agentId/profile', data: profileData);
      return AgentProfile.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update agent profile: $e');
    }
  }

  @override
  Future<AgentSettings> getAgentSettings(String agentId) async {
    try {
      final response = await dio.get('/api/v1/agents/$agentId/settings');
      return AgentSettings.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch agent settings: $e');
    }
  }

  @override
  Future<AgentSettings> updateAgentSettings(String agentId, Map<String, dynamic> settingsData) async {
    try {
      final response = await dio.put('/api/v1/agents/$agentId/settings', data: settingsData);
      return AgentSettings.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update agent settings: $e');
    }
  }

  @override
  Future<AgentPreferences> getAgentPreferences(String agentId) async {
    try {
      final response = await dio.get('/api/v1/agents/$agentId/preferences');
      return AgentPreferences.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch agent preferences: $e');
    }
  }

  @override
  Future<AgentPreferences> updateAgentPreferences(String agentId, Map<String, dynamic> preferencesData) async {
    try {
      final response = await dio.put('/api/v1/agents/$agentId/preferences', data: preferencesData);
      return AgentPreferences.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update agent preferences: $e');
    }
  }

  @override
  Future<AgentPerformance> getAgentPerformance(String agentId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await dio.get(
        '/api/v1/agents/$agentId/performance',
        queryParameters: queryParams,
      );
      return AgentPerformance.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch agent performance: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String agentId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'profile_image.jpg'),
      });

      final response = await dio.post('/api/v1/agents/$agentId/upload-profile-image', data: formData);
      return response.data['image_url'];
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<String> uploadDocument(String agentId, String documentPath, String documentType) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(documentPath),
        'document_type': documentType,
      });

      final response = await dio.post('/api/v1/agents/$agentId/upload-document', data: formData);
      return response.data['document_url'];
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  @override
  Future<void> changePassword(String agentId, String currentPassword, String newPassword) async {
    try {
      await dio.post('/api/v1/agents/$agentId/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  @override
  Future<void> updateBiometricSetting(String agentId, bool enabled) async {
    try {
      await dio.put('/api/v1/agents/$agentId/biometric', data: {
        'enabled': enabled,
      });
    } catch (e) {
      throw Exception('Failed to update biometric setting: $e');
    }
  }
}
