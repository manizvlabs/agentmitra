import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/provider_models.dart';

class ProviderRemoteDataSource {
  /// Get all insurance providers
  Future<List<InsuranceProvider>> getProviders({
    String? type,
    String? status,
    int limit = 50,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    queryParams['limit'] = limit.toString();

    final response = await ApiService.get(
      ApiConstants.providers,
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => InsuranceProvider.fromJson(json))
        .toList();
  }

  /// Get provider by ID
  Future<InsuranceProvider> getProviderById(String providerId) async {
    final response = await ApiService.get(ApiConstants.providerById(providerId));
    return InsuranceProvider.fromJson(response);
  }

  /// Get provider by code
  Future<InsuranceProvider> getProviderByCode(String providerCode) async {
    final response = await ApiService.get(ApiConstants.providerByCode(providerCode));
    return InsuranceProvider.fromJson(response);
  }

  /// Create new provider
  Future<InsuranceProvider> createProvider(Map<String, dynamic> providerData) async {
    final response = await ApiService.post(ApiConstants.providers, providerData);
    return InsuranceProvider.fromJson(response);
  }

  /// Update provider
  Future<InsuranceProvider> updateProvider(String providerId, Map<String, dynamic> providerData) async {
    final response = await ApiService.put(
      ApiConstants.providerById(providerId),
      providerData,
    );
    return InsuranceProvider.fromJson(response);
  }

  /// Delete provider
  Future<void> deleteProvider(String providerId) async {
    await ApiService.delete(ApiConstants.providerById(providerId));
  }

  /// Get provider integration status
  Future<ProviderIntegrationStatus> getProviderIntegrationStatus(String providerId) async {
    final response = await ApiService.get('${ApiConstants.providerById(providerId)}/integration');
    return ProviderIntegrationStatus.fromJson(response);
  }

  /// Test provider integration
  Future<Map<String, dynamic>> testProviderIntegration(String providerId) async {
    final response = await ApiService.post(
      '${ApiConstants.providerById(providerId)}/test-integration',
      {},
    );
    return response;
  }

  /// Sync provider data
  Future<Map<String, dynamic>> syncProviderData(String providerId) async {
    final response = await ApiService.post(
      '${ApiConstants.providerById(providerId)}/sync',
      {},
    );
    return response;
  }
}
