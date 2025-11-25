import '../../domain/repositories/tenant_repository_interface.dart';
import '../datasources/tenant_api_datasource.dart';
import '../models/tenant.dart';

class TenantRepository implements TenantRepositoryInterface {
  final TenantApiDataSource _apiDataSource;

  TenantRepository(this._apiDataSource);

  @override
  Future<TenantProvisioningStatus> createTenant(TenantCreationRequest request) async {
    return await _apiDataSource.createTenant(request);
  }

  @override
  Future<List<Tenant>> getTenants() async {
    return await _apiDataSource.getTenants();
  }

  @override
  Future<Tenant> getTenant(String tenantId) async {
    return await _apiDataSource.getTenant(tenantId);
  }

  @override
  Future<void> deactivateTenant(String tenantId, {String? reason}) async {
    return await _apiDataSource.deactivateTenant(tenantId, reason: reason);
  }

  @override
  Future<void> reactivateTenant(String tenantId) async {
    return await _apiDataSource.reactivateTenant(tenantId);
  }

  @override
  Future<void> updateTenantConfig(String tenantId, String configKey, dynamic configValue, String configType) async {
    return await _apiDataSource.updateTenantConfig(tenantId, configKey, configValue, configType);
  }
}
