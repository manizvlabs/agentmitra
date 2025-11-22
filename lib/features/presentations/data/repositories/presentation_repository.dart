import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/presentation_remote_datasource.dart';
import '../models/presentation_models.dart';

class PresentationRepository extends BaseRepository {
  final PresentationRemoteDataSource _remoteDataSource;

  PresentationRepository({
    PresentationRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PresentationRemoteDataSource();

  /// Get all presentation templates
  Future<List<PresentationTemplate>> getTemplates() async {
    try {
      return await _remoteDataSource.getTemplates();
    } catch (e) {
      throw Exception('Failed to fetch presentation templates: $e');
    }
  }

  /// Get presentations for an agent
  Future<List<Presentation>> getAgentPresentations(String agentId) async {
    try {
      return await _remoteDataSource.getAgentPresentations(agentId);
    } catch (e) {
      throw Exception('Failed to fetch agent presentations: $e');
    }
  }

  /// Get active presentation for an agent
  Future<Presentation?> getActivePresentation(String agentId) async {
    try {
      return await _remoteDataSource.getActivePresentation(agentId);
    } catch (e) {
      // No active presentation is not an error
      return null;
    }
  }

  /// Get presentation by ID
  Future<Presentation> getPresentationById(String presentationId) async {
    try {
      return await _remoteDataSource.getPresentationById(presentationId);
    } catch (e) {
      throw Exception('Failed to fetch presentation: $e');
    }
  }

  /// Create new presentation
  Future<Presentation> createPresentation({
    required String agentId,
    required String title,
    String? description,
    List<PresentationSlide>? slides,
  }) async {
    try {
      final presentationData = {
        'agent_id': agentId,
        'title': title,
        if (description != null) 'description': description,
        'slides': slides?.map((slide) => slide.toJson()).toList() ?? [],
      };

      return await _remoteDataSource.createPresentation(presentationData);
    } catch (e) {
      throw Exception('Failed to create presentation: $e');
    }
  }

  /// Update presentation
  Future<Presentation> updatePresentation({
    required String presentationId,
    String? title,
    String? description,
    List<PresentationSlide>? slides,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (slides != null) updateData['slides'] = slides.map((slide) => slide.toJson()).toList();
      if (status != null) updateData['status'] = status;

      return await _remoteDataSource.updatePresentation(presentationId, updateData);
    } catch (e) {
      throw Exception('Failed to update presentation: $e');
    }
  }

  /// Delete presentation
  Future<void> deletePresentation(String presentationId) async {
    try {
      await _remoteDataSource.deletePresentation(presentationId);
    } catch (e) {
      throw Exception('Failed to delete presentation: $e');
    }
  }

  /// Get presentation analytics
  Future<PresentationAnalytics> getPresentationAnalytics(String presentationId) async {
    try {
      return await _remoteDataSource.getPresentationAnalytics(presentationId);
    } catch (e) {
      throw Exception('Failed to fetch presentation analytics: $e');
    }
  }

  /// Upload media file
  Future<Map<String, dynamic>> uploadMedia(String filePath, List<int> fileBytes) async {
    try {
      return await _remoteDataSource.uploadMedia(filePath, fileBytes);
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }
}