import '../../../../core/services/api_service.dart';
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
  PolicyRemoteDataSourceImpl();

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
      final response = await ApiService.get(
        '/api/v1/policies',
        queryParameters: {
          'offset': ((page - 1) * limit).toString(),
          'limit': limit.toString(),
          if (status != null) 'status': status,
          if (search != null) 'policy_number': search,
        },
      );

      if (response is Map<String, dynamic> && response['data'] is List) {
        final data = response['data'] as List<dynamic>;
        return data.map((json) => Policy.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch policies: $e');
    }
  }

  @override
  Future<Policy> getPolicyById(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId');
      final data = response is Map ? response : (response['data'] ?? response);
      return Policy.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch policy: $e');
    }
  }

  @override
  Future<List<Premium>> getPremiumsByPolicyId(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/premiums');
      if (response is Map<String, dynamic>) {
        List<dynamic> data = [];
        if (response['premiums'] is List<dynamic>) {
          data = response['premiums'] as List<dynamic>;
        } else if (response['data'] is List<dynamic>) {
          data = response['data'] as List<dynamic>;
        }
        return data.map((json) => Premium.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch premiums: $e');
    }
  }

  @override
  Future<List<Claim>> getClaimsByPolicyId(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/claims');
      final List<dynamic> data = response['claims'] ?? [];
      return data.map((json) => Claim.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch claims: $e');
    }
  }

  @override
  Future<Policy> createPolicy(Map<String, dynamic> policyData) async {
    try {
      final response = await ApiService.post('/api/v1/policies', policyData);
      return Policy.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create policy: $e');
    }
  }

  @override
  Future<Policy> updatePolicy(String policyId, Map<String, dynamic> policyData) async {
    try {
      final response = await ApiService.put('/api/v1/policies/$policyId', policyData);
      final data = response is Map ? response : (response['data'] ?? response);
      return Policy.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update policy: $e');
    }
  }

  @override
  Future<void> deletePolicy(String policyId) async {
    try {
      await ApiService.delete('/api/v1/policies/$policyId');
    } catch (e) {
      throw Exception('Failed to delete policy: $e');
    }
  }

  @override
  Future<List<Coverage>> getCoverageByPolicyId(String policyId) async {
    try {
      final response = await ApiService.get('/api/v1/policies/$policyId/coverage');
      if (response is Map<String, dynamic>) {
        List<dynamic> data = [];
        if (response['coverage'] is List<dynamic>) {
          data = response['coverage'] as List<dynamic>;
        } else if (response['data'] is List<dynamic>) {
          data = response['data'] as List<dynamic>;
        }
        return data.map((json) => Coverage.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch coverage: $e');
    }
  }
}
