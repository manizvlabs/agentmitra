import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/architecture/base/base_viewmodel.dart';
import '../../domain/usecases/create_tenant_usecase.dart';
import '../../domain/usecases/get_tenants_usecase.dart';
import '../../data/models/tenant.dart';
import '../../data/repositories/tenant_repository.dart';
import '../../data/datasources/tenant_api_datasource.dart';

class TenantManagementViewModel extends BaseViewModel {
  final CreateTenantUseCase _createTenantUseCase;
  final GetTenantsUseCase _getTenantsUseCase;

  // State
  List<Tenant> _tenants = [];
  bool _isLoadingTenants = false;
  bool _isCreatingTenant = false;
  String? _errorMessage;

  // Getters
  List<Tenant> get tenants => _tenants;
  bool get isLoadingTenants => _isLoadingTenants;
  bool get isCreatingTenant => _isCreatingTenant;
  String? get errorMessage => _errorMessage;

  // Form state
  final tenantCodeController = TextEditingController();
  final tenantNameController = TextEditingController();
  final adminPhoneController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminFirstNameController = TextEditingController();
  final adminLastNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final contactPhoneController = TextEditingController();

  String _selectedTenantType = 'insurance_provider';
  String _selectedSubscriptionPlan = 'trial';
  int _maxUsers = 100;
  int _storageLimitGb = 5;
  int _apiRateLimit = 1000;

  // Getters for form state
  String get selectedTenantType => _selectedTenantType;
  String get selectedSubscriptionPlan => _selectedSubscriptionPlan;
  int get maxUsers => _maxUsers;
  int get storageLimitGb => _storageLimitGb;
  int get apiRateLimit => _apiRateLimit;

  // Tenant type options
  final tenantTypeOptions = [
    {'value': 'insurance_provider', 'label': 'Insurance Provider'},
    {'value': 'independent_agent', 'label': 'Independent Agent'},
    {'value': 'agent_network', 'label': 'Agent Network'},
  ];

  // Subscription plan options
  final subscriptionPlanOptions = [
    {'value': 'trial', 'label': 'Trial'},
    {'value': 'basic', 'label': 'Basic'},
    {'value': 'professional', 'label': 'Professional'},
    {'value': 'enterprise', 'label': 'Enterprise'},
  ];

  TenantManagementViewModel(
    this._createTenantUseCase,
    this._getTenantsUseCase,
  );

  // Factory constructor for simple instantiation
  factory TenantManagementViewModel.simple() {
    // TODO: Implement proper dependency injection
    // Create stub repositories for now
    final repository = TenantRepository(TenantApiDataSource(ApiService()));
    return TenantManagementViewModel(
      CreateTenantUseCase(repository),
      GetTenantsUseCase(repository),
    );
  }

  @override
  void dispose() {
    tenantCodeController.dispose();
    tenantNameController.dispose();
    adminPhoneController.dispose();
    adminEmailController.dispose();
    adminFirstNameController.dispose();
    adminLastNameController.dispose();
    contactEmailController.dispose();
    contactPhoneController.dispose();
    super.dispose();
  }

  // Actions
  void updateTenantType(String value) {
    _selectedTenantType = value;
    notifyListeners();
  }

  void updateSubscriptionPlan(String value) {
    _selectedSubscriptionPlan = value;
    notifyListeners();
  }

  void updateMaxUsers(int value) {
    _maxUsers = value;
    notifyListeners();
  }

  void updateStorageLimit(int value) {
    _storageLimitGb = value;
    notifyListeners();
  }

  void updateApiRateLimit(int value) {
    _apiRateLimit = value;
    notifyListeners();
  }

  Future<void> loadTenants() async {
    _isLoadingTenants = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tenants = await _getTenantsUseCase.execute();
    } catch (e) {
      _errorMessage = 'Failed to load tenants: ${e.toString()}';
    } finally {
      _isLoadingTenants = false;
      notifyListeners();
    }
  }

  Future<TenantProvisioningStatus?> createTenant() async {
    // Validate form
    if (tenantCodeController.text.isEmpty ||
        tenantNameController.text.isEmpty ||
        adminPhoneController.text.isEmpty) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return null;
    }

    _isCreatingTenant = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = TenantCreationRequest(
        tenantCode: tenantCodeController.text.toUpperCase(),
        tenantName: tenantNameController.text,
        tenantType: _selectedTenantType,
        subscriptionPlan: _selectedSubscriptionPlan,
        maxUsers: _maxUsers,
        storageLimitGb: _storageLimitGb,
        apiRateLimit: _apiRateLimit,
        contactEmail: contactEmailController.text.isNotEmpty ? contactEmailController.text : null,
        contactPhone: contactPhoneController.text.isNotEmpty ? contactPhoneController.text : null,
        adminPhone: adminPhoneController.text,
        adminEmail: adminEmailController.text.isNotEmpty ? adminEmailController.text : null,
        adminFirstName: adminFirstNameController.text.isNotEmpty ? adminFirstNameController.text : null,
        adminLastName: adminLastNameController.text.isNotEmpty ? adminLastNameController.text : null,
      );

      final result = await _createTenantUseCase.execute(request);

      // Clear form on success
      _clearForm();

      // Reload tenants list
      await loadTenants();

      return result;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isCreatingTenant = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    tenantCodeController.clear();
    tenantNameController.clear();
    adminPhoneController.clear();
    adminEmailController.clear();
    adminFirstNameController.clear();
    adminLastNameController.clear();
    contactEmailController.clear();
    contactPhoneController.clear();

    _selectedTenantType = 'insurance_provider';
    _selectedSubscriptionPlan = 'trial';
    _maxUsers = 100;
    _storageLimitGb = 5;
    _apiRateLimit = 1000;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
