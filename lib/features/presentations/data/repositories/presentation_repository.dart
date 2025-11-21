/// Presentation repository - combines remote and local data sources
import 'package:dartz/dartz.dart';
import '../../../../core/architecture/base/base_repository.dart';
import '../datasources/presentation_remote_datasource.dart';
import '../datasources/presentation_local_datasource.dart';
import '../models/presentation_model.dart';

class PresentationRepository extends BaseRepository {
  final PresentationRemoteDataSource _remoteDataSource;
  final PresentationLocalDataSource _localDataSource;

  PresentationRepository({
    PresentationRemoteDataSource? remoteDataSource,
    PresentationLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? PresentationRemoteDataSource(),
       _localDataSource = localDataSource ?? PresentationLocalDataSourceImpl() {
    // Initialize local datasource
    if (_localDataSource is PresentationLocalDataSourceImpl) {
      (_localDataSource as PresentationLocalDataSourceImpl).init();
    }
  }

  /// Get active presentation for an agent with offline caching
  Future<Either<Exception, PresentationModel>> getActivePresentation(
    String agentId, {
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get cached data first (unless force refresh is requested)
      if (!forceRefresh) {
        final cachedPresentation = await _localDataSource.getCachedActivePresentation(agentId);
        if (cachedPresentation != null) {
          // Try to refresh in background if we have cached data
          _refreshFromRemote(agentId);
          return Right(cachedPresentation);
        }
      }

      // Fetch from remote
      final presentation = await _remoteDataSource.getActivePresentation(agentId);

      // Cache the result
      await _localDataSource.cacheActivePresentation(agentId, presentation);

      return Right(presentation);
    } catch (e) {
      // If remote fails and we have cache, return cached data
      if (!forceRefresh) {
        try {
          final cachedPresentation = await _localDataSource.getCachedActivePresentation(agentId);
          if (cachedPresentation != null) {
            return Right(cachedPresentation);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch active presentation: $e'));
    }
  }

  /// Refresh presentation data from remote in background
  Future<void> _refreshFromRemote(String agentId) async {
    try {
      final presentation = await _remoteDataSource.getActivePresentation(agentId);
      await _localDataSource.cacheActivePresentation(agentId, presentation);
    } catch (e) {
      // Silently fail background refresh
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

