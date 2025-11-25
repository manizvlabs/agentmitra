import '../repositories/tenant_repository_interface.dart';
import '../../data/models/tenant.dart';

class CreateTenantUseCase {
  final TenantRepositoryInterface _repository;

  CreateTenantUseCase(this._repository);

  Future<TenantProvisioningStatus> execute(TenantCreationRequest request) async {
    // Validate tenant code format
    if (!RegExp(r'^[A-Z][A-Z0-9_]*$').hasMatch(request.tenantCode)) {
      throw Exception('Tenant code must start with a letter and contain only uppercase letters, numbers, and underscores');
    }

    if (request.tenantCode.length < 2 || request.tenantCode.length > 20) {
      throw Exception('Tenant code must be between 2 and 20 characters');
    }

    // Validate tenant type
    const validTypes = ['insurance_provider', 'independent_agent', 'agent_network'];
    if (!validTypes.contains(request.tenantType)) {
      throw Exception('Invalid tenant type. Must be one of: ${validTypes.join(', ')}');
    }

    // Validate admin phone
    if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(request.adminPhone)) {
      throw Exception('Invalid admin phone number format');
    }

    return await _repository.createTenant(request);
  }
}
