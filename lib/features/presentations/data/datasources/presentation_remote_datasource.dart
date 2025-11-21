/// Remote data source for presentation API calls
import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/presentation_model.dart';

class PresentationRemoteDataSource {
  /// Get active presentation for an agent
  Future<PresentationModel> getActivePresentation(String agentId) async {
    final response = await ApiService.get(
      ApiConstants.activePresentation(agentId),
    );
    return PresentationModel.fromJson(response);
  }

  /// Get all presentations for an agent
  Future<Map<String, dynamic>> getAgentPresentations(
    String agentId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (status != null) {
      queryParams['status'] = status;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await ApiService.get(
      '${ApiConstants.agentPresentations(agentId)}?$queryString',
    );

    return {
      'presentations': (response['presentations'] as List<dynamic>?)
              ?.map((p) => PresentationModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      'total': response['total'] ?? 0,
      'limit': response['limit'] ?? limit,
      'offset': response['offset'] ?? offset,
    };
  }

  /// Create a new presentation
  Future<PresentationModel> createPresentation(
    String agentId,
    PresentationModel presentation,
  ) async {
    final response = await ApiService.post(
      ApiConstants.agentPresentations(agentId),
      presentation.toJson(),
    );
    return PresentationModel.fromJson(response);
  }

  /// Update an existing presentation
  Future<PresentationModel> updatePresentation(
    String agentId,
    String presentationId,
    PresentationModel presentation,
  ) async {
    final response = await ApiService.put(
      '${ApiConstants.agentPresentations(agentId)}/$presentationId',
      presentation.toJson(),
    );
    return PresentationModel.fromJson(response);
  }

  /// Get presentation templates
  Future<List<Map<String, dynamic>>> getTemplates({
    String? category,
    bool isPublic = true,
  }) async {
    final queryParams = <String, String>{
      'is_public': isPublic.toString(),
    };
    if (category != null) {
      queryParams['category'] = category;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    final response = await ApiService.get(
      '${ApiConstants.presentationTemplates}?$queryString',
    );
    return (response['templates'] as List<dynamic>?)
            ?.map((t) => t as Map<String, dynamic>)
            .toList() ??
        [];
  }

  /// Upload media file
  Future<Map<String, dynamic>> uploadMedia(
    List<int> fileBytes,
    String fileName,
    String type, // 'image' or 'video'
  ) async {
    // Note: This is a simplified version. In production, you'd use multipart/form-data
    final response = await ApiService.post(
      ApiConstants.mediaUpload,
      {
        'file': fileBytes,
        'filename': fileName,
        'type': type,
      },
    );
    return response;
  }
}

