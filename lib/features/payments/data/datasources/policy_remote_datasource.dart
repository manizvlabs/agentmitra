import 'package:dio/dio.dart';
import '../models/policy_model.dart';

abstract class PolicyRemoteDataSource {
  Future<List<Policy>> getPolicies({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<Policy> getPolicyById(String policyId);

  Future<List<Premium>> getPremiumsByPolicyId(String policyId);

  Future<List<Claim>> getClaimsByPolicyId(String policyId);

  Future<Policy> createPolicy(Map<String, dynamic> policyData);

  Future<Policy> updatePolicy(String policyId, Map<String, dynamic> policyData);

  Future<void> deletePolicy(String policyId);

  Future<List<Coverage>> getCoverageByPolicyId(String policyId);
}

class PolicyRemoteDataSourceImpl implements PolicyRemoteDataSource {
  final Dio dio;

  PolicyRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Policy>> getPolicies({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final response = await dio.get(
        '/api/v1/policies',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
          if (search != null) 'search': search,
          if (sortBy != null) 'sort_by': sortBy,
          if (sortOrder != null) 'sort_order': sortOrder,
        },
      );

      final List<dynamic> data = response.data['policies'] ?? [];
      return data.map((json) => Policy.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch policies: $e');
    }
  }

  @override
  Future<Policy> getPolicyById(String policyId) async {
    try {
      final response = await dio.get('/api/v1/policies/$policyId');
      return Policy.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch policy: $e');
    }
  }

  @override
  Future<List<Premium>> getPremiumsByPolicyId(String policyId) async {
    try {
      final response = await dio.get('/api/v1/policies/$policyId/premiums');
      final List<dynamic> data = response.data['premiums'] ?? [];
      return data.map((json) => Premium.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch premiums: $e');
    }
  }

  @override
  Future<List<Claim>> getClaimsByPolicyId(String policyId) async {
    try {
      final response = await dio.get('/api/v1/policies/$policyId/claims');
      final List<dynamic> data = response.data['claims'] ?? [];
      return data.map((json) => Claim.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch claims: $e');
    }
  }

  @override
  Future<Policy> createPolicy(Map<String, dynamic> policyData) async {
    try {
      final response = await dio.post('/api/v1/policies', data: policyData);
      return Policy.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create policy: $e');
    }
  }

  @override
  Future<Policy> updatePolicy(String policyId, Map<String, dynamic> policyData) async {
    try {
      final response = await dio.put('/api/v1/policies/$policyId', data: policyData);
      return Policy.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update policy: $e');
    }
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    try {
      await dio.delete('/api/v1/policies/$policyId');
    } catch (e) {
      throw Exception('Failed to delete policy: $e');
    }
  }

  @override
  Future<List<Coverage>> getCoverageByPolicyId(String policyId) async {
    try {
      final response = await dio.get('/api/v1/policies/$policyId/coverage');
      final List<dynamic> data = response.data['coverage'] ?? [];
      return data.map((json) => Coverage.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch coverage: $e');
    }
  }
}
