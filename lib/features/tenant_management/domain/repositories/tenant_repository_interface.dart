import '../../data/models/tenant.dart';

abstract class TenantRepositoryInterface {
  Future<TenantProvisioningStatus> createTenant(TenantCreationRequest request);
  Future<List<Tenant>> getTenants();
  Future<Tenant> getTenant(String tenantId);
  Future<void> deactivateTenant(String tenantId, {String? reason});
  Future<void> reactivateTenant(String tenantId);
  Future<void> updateTenantConfig(String tenantId, String configKey, dynamic configValue, String configType);
}
