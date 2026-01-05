import 'dart:async';
import '../datasources/policy_remote_datasource.dart';
import '../models/policy_models.dart';

/// Repository for policy-related data operations
abstract class PolicyRepository {
  /// Get list of policies with optional filters
  Future<PolicyListResponse> getPolicies({PolicyFilters? filters});

  /// Get detailed policy information
  Future<PolicyDetail> getPolicyDetail(String policyId);

  /// Get policy premiums/payment history
  Future<List<Premium>> getPolicyPremiums(String policyId);

  /// Get policy claims history
  Future<List<Claim>> getPolicyClaims(String policyId);

  /// Get policy coverage details
  Future<List<Coverage>> getPolicyCoverages(String policyId);

  /// Download policy document
  Future<String> downloadPolicyDocument(String policyId, String documentType);

  /// Search policies by query
  Future<PolicyListResponse> searchPolicies(String query, {PolicyFilters? filters});
}

class PolicyRepositoryImpl implements PolicyRepository {
  final PolicyRemoteDataSource _remoteDataSource;

  PolicyRepositoryImpl(this._remoteDataSource);

  @override
  Future<PolicyListResponse> getPolicies({PolicyFilters? filters}) async {
    return await _remoteDataSource.getPolicies(filters: filters);
  }

  @override
  Future<PolicyDetail> getPolicyDetail(String policyId) async {
    return await _remoteDataSource.getPolicyDetail(policyId);
  }

  @override
  Future<List<Premium>> getPolicyPremiums(String policyId) async {
    return await _remoteDataSource.getPolicyPremiums(policyId);
  }

  @override
  Future<List<Claim>> getPolicyClaims(String policyId) async {
    return await _remoteDataSource.getPolicyClaims(policyId);
  }

  @override
  Future<List<Coverage>> getPolicyCoverages(String policyId) async {
    return await _remoteDataSource.getPolicyCoverages(policyId);
  }

  @override
  Future<String> downloadPolicyDocument(String policyId, String documentType) async {
    return await _remoteDataSource.downloadPolicyDocument(policyId, documentType);
  }

  @override
  Future<PolicyListResponse> searchPolicies(String query, {PolicyFilters? filters}) async {
    final searchFilters = (filters ?? const PolicyFilters()).copyWith(
      searchQuery: query,
    );
    return await getPolicies(filters: searchFilters);
  }
}


