/// Presentation repository - combines remote and local data sources
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/presentation_remote_datasource.dart';
import '../models/presentation_model.dart';

class PresentationRepository extends BaseRepository {
  final PresentationRemoteDataSource _remoteDataSource;

  PresentationRepository({
    PresentationRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PresentationRemoteDataSource();

  /// Get active presentation for an agent
  Future<PresentationModel> getActivePresentation(String agentId) async {
    try {
      return await _remoteDataSource.getActivePresentation(agentId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all presentations for an agent
  Future<Map<String, dynamic>> getAgentPresentations(
    String agentId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _remoteDataSource.getAgentPresentations(
        agentId,
        status: status,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new presentation
  Future<PresentationModel> createPresentation(
    String agentId,
    PresentationModel presentation,
  ) async {
    try {
      return await _remoteDataSource.createPresentation(agentId, presentation);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing presentation
  Future<PresentationModel> updatePresentation(
    String agentId,
    String presentationId,
    PresentationModel presentation,
  ) async {
    try {
      return await _remoteDataSource.updatePresentation(
        agentId,
        presentationId,
        presentation,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get presentation templates
  Future<List<Map<String, dynamic>>> getTemplates({
    String? category,
    bool isPublic = true,
  }) async {
    try {
      return await _remoteDataSource.getTemplates(
        category: category,
        isPublic: isPublic,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload media file
  Future<Map<String, dynamic>> uploadMedia(
    List<int> fileBytes,
    String fileName,
    String type,
  ) async {
    try {
      return await _remoteDataSource.uploadMedia(fileBytes, fileName, type);
    } catch (e) {
      rethrow;
    }
  }
}

