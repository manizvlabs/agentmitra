import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/api_service.dart';
import '../models/policy_models.dart';

/// Remote datasource for policy-related API calls
abstract class PolicyRemoteDataSource {
  /// Get list of policies with optional filters
  Future<PolicyListResponse> getPolicies({
    PolicyFilters? filters,
  });

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
}

class PolicyRemoteDataSourceImpl implements PolicyRemoteDataSource {
  PolicyRemoteDataSourceImpl();

  @override
  Future<PolicyListResponse> getPolicies({PolicyFilters? filters}) async {
    try {
      final queryParams = <String, dynamic>{};

      if (filters != null) {
        if (filters.status != null) {
          queryParams['status'] = filters.status.toString().split('.').last;
        }
        if (filters.policyType != null) {
          queryParams['policy_type'] = filters.policyType.toString().split('.').last;
        }
        if (filters.providerId != null) {
          queryParams['provider_id'] = filters.providerId;
        }
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          queryParams['search'] = filters.searchQuery;
        }
        if (filters.page > 1) {
          queryParams['page'] = filters.page;
        }
        if (filters.limit != 20) {
          queryParams['limit'] = filters.limit;
        }
      }

      final response = await ApiService.get('/api/v1/policies', queryParameters: queryParams);

      // Transform the response to match our model
      final data = response;
      final policies = (data['policies'] as List<dynamic>?)
          ?.map((policy) => Policy.fromJson(policy as Map<String, dynamic>))
          .toList() ?? [];

      return PolicyListResponse(
        policies: policies,
        totalCount: data['total_count'] as int? ?? policies.length,
        page: data['page'] as int? ?? 1,
        limit: data['limit'] as int? ?? 20,
        hasNextPage: data['has_next_page'] as bool? ?? false,
      );
    } catch (e) {
      throw Exception('Failed to load policies: $e');
    }
  }

  @override
  Future<PolicyDetail> getPolicyDetail(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId');

      final policy = Policy.fromJson(response);

      // Load related data in parallel
      final futures = await Future.wait([
        getPolicyPremiums(policyId),
        getPolicyClaims(policyId),
        getPolicyCoverages(policyId),
      ]);

      return PolicyDetail(
        policy: policy,
        premiums: futures[0] as List<Premium>,
        claims: futures[1] as List<Claim>,
        coverages: futures[2] as List<Coverage>,
      );
    } catch (e) {
      throw Exception('Failed to load policy details: $e');
    }
  }

  @override
  Future<List<Premium>> getPolicyPremiums(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/premiums');

      final premiums = (response['premiums'] as List<dynamic>?)
          ?.map((premium) => Premium.fromJson(premium as Map<String, dynamic>))
          .toList() ?? [];

      return premiums;
    } catch (e) {
      // Return empty list if premiums endpoint fails
      return [];
    }
  }

  @override
  Future<List<Claim>> getPolicyClaims(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/claims');

      final claims = (response['claims'] as List<dynamic>?)
          ?.map((claim) => Claim.fromJson(claim as Map<String, dynamic>))
          .toList() ?? [];

      return claims;
    } catch (e) {
      // Return empty list if claims endpoint fails
      return [];
    }
  }

  @override
  Future<List<Coverage>> getPolicyCoverages(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/coverage');

      final coverages = (response['coverages'] as List<dynamic>?)
          ?.map((coverage) => Coverage.fromJson(coverage as Map<String, dynamic>))
          .toList() ?? [];

      return coverages;
    } catch (e) {
      // Return empty list if coverage endpoint fails
      return [];
    }
  }

  @override
  Future<String> downloadPolicyDocument(String policyId, String documentType) async {
    try {
      // This would typically trigger a download, but for now we'll return the URL
      final response = await ApiService.get('/api/v1/policies/$policyId/documents');

      final documents = response['documents'] as Map<String, dynamic>?;
      if (documents != null && documents.containsKey(documentType)) {
        return documents[documentType] as String;
      }

      throw Exception('Document not found');
    } catch (e) {
      throw Exception('Failed to get document URL: $e');
    }
  }
}
