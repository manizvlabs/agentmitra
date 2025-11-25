import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import '../models/tenant.dart';

class TenantApiDataSource {
  final ApiService _apiService;

  TenantApiDataSource(this._apiService);

  Future<TenantProvisioningStatus> createTenant(TenantCreationRequest request) async {
    final response = await _apiService.post(
      '/tenants',
      body: request.toJson(),
    );

    return TenantProvisioningStatus.fromJson(response);
  }

  Future<List<Tenant>> getTenants() async {
    final response = await _apiService.get('/tenants') as List<dynamic>;

    return response.map((json) => Tenant.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Tenant> getTenant(String tenantId) async {
    final response = await _apiService.get('/tenants/$tenantId') as Map<String, dynamic>;

    return Tenant.fromJson(response);
  }

  Future<void> deactivateTenant(String tenantId, {String? reason}) async {
    await _apiService.put(
      '/tenants/$tenantId/deactivate',
      body: reason != null ? {'reason': reason} : null,
    );
  }

  Future<void> reactivateTenant(String tenantId) async {
    await _apiService.put('/tenants/$tenantId/reactivate');
  }

  Future<void> updateTenantConfig(String tenantId, String configKey, dynamic configValue, String configType) async {
    await _apiService.post(
      '/tenants/$tenantId/config',
      body: {
        'config_key': configKey,
        'config_value': configValue,
        'config_type': configType,
      },
    );
  }
}
