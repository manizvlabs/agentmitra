import '../repositories/tenant_repository_interface.dart';
import '../../data/models/tenant.dart';

class GetTenantsUseCase {
  final TenantRepositoryInterface _repository;

  GetTenantsUseCase(this._repository);

  Future<List<Tenant>> execute() async {
    return await _repository.getTenants();
  }
}
