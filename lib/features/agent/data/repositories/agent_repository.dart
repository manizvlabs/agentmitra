import 'package:dartz/dartz.dart';
import '../datasources/agent_remote_datasource.dart';
import '../datasources/agent_local_datasource.dart';
import '../models/agent_model.dart';

class AgentRepository {
  final AgentRemoteDataSource remoteDataSource;
  final AgentLocalDataSource localDataSource;

  AgentRepository(this.remoteDataSource, this.localDataSource);

  // Profile operations
  Future<Either<Exception, AgentProfile>> getAgentProfile(String agentId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedProfile = await localDataSource.getCachedAgentProfile(agentId);
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
      }

      // Fetch from remote
      final profile = await remoteDataSource.getAgentProfile(agentId);

      // Cache the result
      await localDataSource.cacheAgentProfile(profile);

      return Right(profile);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedProfile = await localDataSource.getCachedAgentProfile(agentId);
          if (cachedProfile != null) {
            return Right(cachedProfile);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch agent profile: $e'));
    }
  }

  Future<Either<Exception, AgentProfile>> updateAgentProfile(String agentId, Map<String, dynamic> profileData) async {
    try {
      final profile = await remoteDataSource.updateAgentProfile(agentId, profileData);

      // Update cache
      await localDataSource.cacheAgentProfile(profile);

      return Right(profile);
    } catch (e) {
      return Left(Exception('Failed to update agent profile: $e'));
    }
  }

  // Settings operations
  Future<Either<Exception, AgentSettings>> getAgentSettings(String agentId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedSettings = await localDataSource.getCachedAgentSettings(agentId);
        if (cachedSettings != null) {
          return Right(cachedSettings);
        }
      }

      // Fetch from remote
      final settings = await remoteDataSource.getAgentSettings(agentId);

      // Cache the result
      await localDataSource.cacheAgentSettings(settings);

      return Right(settings);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedSettings = await localDataSource.getCachedAgentSettings(agentId);
          if (cachedSettings != null) {
            return Right(cachedSettings);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch agent settings: $e'));
    }
  }

  Future<Either<Exception, AgentSettings>> updateAgentSettings(String agentId, Map<String, dynamic> settingsData) async {
    try {
      final settings = await remoteDataSource.updateAgentSettings(agentId, settingsData);

      // Update cache
      await localDataSource.cacheAgentSettings(settings);

      return Right(settings);
    } catch (e) {
      return Left(Exception('Failed to update agent settings: $e'));
    }
  }

  // Preferences operations
  Future<Either<Exception, AgentPreferences>> getAgentPreferences(String agentId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedPreferences = await localDataSource.getCachedAgentPreferences(agentId);
        if (cachedPreferences != null) {
          return Right(cachedPreferences);
        }
      }

      // Fetch from remote
      final preferences = await remoteDataSource.getAgentPreferences(agentId);

      // Cache the result
      await localDataSource.cacheAgentPreferences(preferences);

      return Right(preferences);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedPreferences = await localDataSource.getCachedAgentPreferences(agentId);
          if (cachedPreferences != null) {
            return Right(cachedPreferences);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch agent preferences: $e'));
    }
  }

  Future<Either<Exception, AgentPreferences>> updateAgentPreferences(String agentId, Map<String, dynamic> preferencesData) async {
    try {
      final preferences = await remoteDataSource.updateAgentPreferences(agentId, preferencesData);

      // Update cache
      await localDataSource.cacheAgentPreferences(preferences);

      return Right(preferences);
    } catch (e) {
      return Left(Exception('Failed to update agent preferences: $e'));
    }
  }

  // Performance operations
  Future<Either<Exception, AgentPerformance>> getAgentPerformance(String agentId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      final performance = await remoteDataSource.getAgentPerformance(agentId, startDate: startDate, endDate: endDate);

      // Cache the result
      await localDataSource.cacheAgentPerformance(performance);

      return Right(performance);
    } catch (e) {
      // Try cache as fallback
      try {
        final cachedPerformance = await localDataSource.getCachedAgentPerformance(agentId);
        if (cachedPerformance != null) {
          return Right(cachedPerformance);
        }
      } catch (_) {}

      return Left(Exception('Failed to fetch agent performance: $e'));
    }
  }

  // File upload operations
  Future<Either<Exception, String>> uploadProfileImage(String agentId, String imagePath) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(agentId, imagePath);
      return Right(imageUrl);
    } catch (e) {
      return Left(Exception('Failed to upload profile image: $e'));
    }
  }

  Future<Either<Exception, String>> uploadDocument(String agentId, String documentPath, String documentType) async {
    try {
      final documentUrl = await remoteDataSource.uploadDocument(agentId, documentPath, documentType);
      return Right(documentUrl);
    } catch (e) {
      return Left(Exception('Failed to upload document: $e'));
    }
  }

  // Security operations
  Future<Either<Exception, void>> changePassword(String agentId, String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(agentId, currentPassword, newPassword);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to change password: $e'));
    }
  }

  Future<Either<Exception, void>> updateBiometricSetting(String agentId, bool enabled) async {
    try {
      await remoteDataSource.updateBiometricSetting(agentId, enabled);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to update biometric setting: $e'));
    }
  }

  // Cache management
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}
