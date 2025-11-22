import '../../../../core/services/api_service.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  });
  Future<Customer> getCustomerById(String customerId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  @override
  Future<List<Customer>> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': ((page - 1) * limit).toString(),
        'role': 'policyholder', // Only get policyholders as customers
      };
      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await ApiService.get('/api/v1/users', queryParameters: queryParams);
      
      if (response is Map<String, dynamic> && response['data'] is List) {
        final data = response['data'] as List<dynamic>;
        return data.map((json) => Customer.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  @override
  Future<Customer> getCustomerById(String customerId) async {
    try {
      final response = await ApiService.get('/api/v1/users/$customerId');
      return Customer.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }
}

