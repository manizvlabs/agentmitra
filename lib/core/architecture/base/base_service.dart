/// Base Service class for business logic services
abstract class BaseService {
  /// Initialize service
  Future<void> initialize() async {}

  /// Dispose service resources
  void dispose() {}
}

