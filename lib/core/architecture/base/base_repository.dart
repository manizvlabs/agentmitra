/// Base Repository interface for data access layer
/// All repositories should implement this interface
abstract class BaseRepository {
  /// Initialize repository
  Future<void> initialize() async {}

  /// Dispose repository resources
  void dispose() {}
}

