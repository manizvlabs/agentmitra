import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../data/models/policy_models.dart';

/// ViewModel for individual policy details
class PolicyDetailViewModel extends ChangeNotifier {
  final String policyId;
  Policy? _policy;
  bool _isLoading = false;
  String? _error;

  PolicyDetailViewModel(this.policyId) {
    loadPolicyDetails();
  }

  Policy? get policy => _policy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Premium> get premiums => []; // TODO: Implement premium loading
  List<Claim> get claims => []; // TODO: Implement claim loading

  Future<void> loadPolicyDetails() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load policy details from API
      final response = await ApiService.get('/api/v1/policies/$policyId');
      _policy = Policy.fromJson(response);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadPolicyDetails();
  }
}
