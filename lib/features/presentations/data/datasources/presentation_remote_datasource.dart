import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/presentation_models.dart';

class PresentationRemoteDataSource {
  /// Get presentation templates
  Future<List<PresentationTemplate>> getTemplates() async {
    final response = await ApiService.get(ApiConstants.presentationTemplates);

    final templates = response['templates'] as List<dynamic>;
    return templates.map((json) => PresentationTemplate.fromJson(json)).toList();
  }

  /// Get presentations for an agent
  Future<List<Presentation>> getAgentPresentations(String agentId) async {
    final response = await ApiService.get(ApiConstants.agentPresentations(agentId));

    return (response as List<dynamic>)
        .map((json) => Presentation.fromJson(json))
        .toList();
  }

  /// Get active presentation for an agent
  Future<Presentation?> getActivePresentation(String agentId) async {
    try {
      final response = await ApiService.get(ApiConstants.activePresentation(agentId));
      return Presentation.fromJson(response);
    } catch (e) {
      // No active presentation found
      return null;
    }
  }

  /// Get presentation by ID
  Future<Presentation> getPresentationById(String presentationId) async {
    final response = await ApiService.get(ApiConstants.presentationDetails(presentationId));
    return Presentation.fromJson(response);
  }

  /// Create new presentation
  Future<Presentation> createPresentation(Map<String, dynamic> presentationData) async {
    final response = await ApiService.post(ApiConstants.presentations, presentationData);
    return Presentation.fromJson(response);
  }

  /// Update presentation
  Future<Presentation> updatePresentation(String presentationId, Map<String, dynamic> presentationData) async {
    final response = await ApiService.put(
        ApiConstants.presentationDetails(presentationId),
      presentationData,
    );
    return Presentation.fromJson(response);
  }

  /// Delete presentation
  Future<void> deletePresentation(String presentationId) async {
    await ApiService.delete(ApiConstants.presentationDetails(presentationId));
  }

  /// Get presentation analytics
  Future<PresentationAnalytics> getPresentationAnalytics(String presentationId) async {
    final response = await ApiService.get('${ApiConstants.analytics}/presentations/$presentationId/analytics');
    return PresentationAnalytics.fromJson(response);
  }

  /// Upload media file
  Future<Map<String, dynamic>> uploadMedia(String filePath, List<int> fileBytes) async {
    // Note: This would need to be implemented with proper multipart upload
    // For now, returning a mock response
    final response = await ApiService.post(ApiConstants.mediaUpload, {
      'file_name': filePath.split('/').last,
      'file_size': fileBytes.length,
    });
    return response;
  }
}