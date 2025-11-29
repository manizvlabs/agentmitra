import 'package:dartz/dartz.dart';
import '../datasources/policy_remote_datasource.dart';
import '../datasources/policy_local_datasource.dart';
import '../models/policy_model.dart';

class PolicyRepository {
  final PolicyRemoteDataSource remoteDataSource;
  final PolicyLocalDataSource localDataSource;

  PolicyRepository(this.remoteDataSource, this.localDataSource);

  Future<Either<Exception, List<Policy>>> getPolicies({
    int page = 1,
    int limit = 20,
    String? status,
    String? providerId,
    String? policyType,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool forceRefresh = false,
  }) async {
    try {
      // Try to get cached data first (unless force refresh is requested)
      if (!forceRefresh) {
        final cachedPolicies = await localDataSource.getCachedPolicies();
        if (cachedPolicies.isNotEmpty) {
          return Right(cachedPolicies);
        }
      }

      // Fetch from remote
      final policies = await remoteDataSource.getPolicies(
        page: page,
        limit: limit,
        status: status,
        providerId: providerId,
        policyType: policyType,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // Cache the result
      await localDataSource.cachePolicies(policies);

      return Right(policies);
    } catch (e) {
      // If remote fails and we have cache, return cached data
      if (!forceRefresh) {
        try {
          final cachedPolicies = await localDataSource.getCachedPolicies();
          if (cachedPolicies.isNotEmpty) {
            return Right(cachedPolicies);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch policies: $e'));
    }
  }

  Future<Either<Exception, Policy>> getPolicyById(String policyId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedPolicy = await localDataSource.getCachedPolicy(policyId);
        if (cachedPolicy != null) {
          return Right(cachedPolicy);
        }
      }

      // Fetch from remote
      final policy = await remoteDataSource.getPolicyById(policyId);

      // Cache the result
      await localDataSource.cachePolicy(policy);

      return Right(policy);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedPolicy = await localDataSource.getCachedPolicy(policyId);
          if (cachedPolicy != null) {
            return Right(cachedPolicy);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch policy: $e'));
    }
  }

  Future<Either<Exception, List<Premium>>> getPremiumsByPolicyId(String policyId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedPremiums = await localDataSource.getCachedPremiums(policyId);
        if (cachedPremiums != null && cachedPremiums.isNotEmpty) {
          return Right(cachedPremiums);
        }
      }

      // Fetch from remote
      final premiums = await remoteDataSource.getPremiumsByPolicyId(policyId);

      // Cache the result
      await localDataSource.cachePremiums(policyId, premiums);

      return Right(premiums);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedPremiums = await localDataSource.getCachedPremiums(policyId);
          if (cachedPremiums != null && cachedPremiums.isNotEmpty) {
            return Right(cachedPremiums);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch premiums: $e'));
    }
  }

  Future<Either<Exception, List<Claim>>> getClaimsByPolicyId(String policyId, {bool forceRefresh = false}) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cachedClaims = await localDataSource.getCachedClaims(policyId);
        if (cachedClaims != null && cachedClaims.isNotEmpty) {
          return Right(cachedClaims);
        }
      }

      // Fetch from remote
      final claims = await remoteDataSource.getClaimsByPolicyId(policyId);

      // Cache the result
      await localDataSource.cacheClaims(policyId, claims);

      return Right(claims);
    } catch (e) {
      // Try cache as fallback
      if (!forceRefresh) {
        try {
          final cachedClaims = await localDataSource.getCachedClaims(policyId);
          if (cachedClaims != null && cachedClaims.isNotEmpty) {
            return Right(cachedClaims);
          }
        } catch (_) {}
      }

      return Left(Exception('Failed to fetch claims: $e'));
    }
  }

  Future<Either<Exception, List<Coverage>>> getCoverageByPolicyId(String policyId) async {
    try {
      return Right(await remoteDataSource.getCoverageByPolicyId(policyId));
    } catch (e) {
      return Left(Exception('Failed to fetch coverage: $e'));
    }
  }

  Future<Either<Exception, Policy>> createPolicy(Map<String, dynamic> policyData) async {
    try {
      final policy = await remoteDataSource.createPolicy(policyData);

      // Update cache
      await localDataSource.cachePolicy(policy);

      return Right(policy);
    } catch (e) {
      return Left(Exception('Failed to create policy: $e'));
    }
  }

  Future<Either<Exception, Policy>> updatePolicy(String policyId, Map<String, dynamic> policyData) async {
    try {
      final policy = await remoteDataSource.updatePolicy(policyId, policyData);

      // Update cache
      await localDataSource.cachePolicy(policy);

      return Right(policy);
    } catch (e) {
      return Left(Exception('Failed to update policy: $e'));
    }
  }

  Future<Either<Exception, void>> deletePolicy(String policyId) async {
    try {
      await remoteDataSource.deletePolicy(policyId);

      // Remove from cache
      await localDataSource.clearCache(); // Or implement selective removal

      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete policy: $e'));
    }
  }

  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
}
