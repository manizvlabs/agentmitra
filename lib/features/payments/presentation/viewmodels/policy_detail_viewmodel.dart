import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import '../../data/repositories/policy_repository.dart';
import '../../data/models/policy_model.dart';

class PolicyDetailViewModel extends ChangeNotifier {
  final PolicyRepository _policyRepository;
  final String policyId;

  PolicyDetailViewModel(this._policyRepository, this.policyId);

  // State
  Policy? _policy;
  List<Premium> _premiums = [];
  List<Claim> _claims = [];
  List<Coverage> _coverage = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Policy? get policy => _policy;
  List<Premium> get premiums => _premiums;
  List<Claim> get claims => _claims;
  List<Coverage> get coverage => _coverage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  bool get isActive => _policy?.status == 'active';
  bool get isLapsed => _policy?.status == 'lapsed';
  bool get hasOutstandingPayment => (_policy?.outstandingAmount ?? 0) > 0;
  bool get hasPendingClaims => _claims.any((claim) => claim.status == 'pending');

  Premium? get nextDuePayment {
    final now = DateTime.now();
    return _premiums
        .where((premium) =>
            premium.status == 'pending' &&
            premium.dueDate.isAfter(now))
        .cast<Premium?>()
        .firstWhere((_) => true, orElse: () => null);
  }

  double get totalPaidAmount =>
      _premiums.where((p) => p.status == 'completed').fold(0.0, (sum, p) => sum + p.amount);

  // Actions
  Future<void> loadPolicyDetails({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load policy details
      final policyResult = await _policyRepository.getPolicyById(policyId, forceRefresh: forceRefresh);
      policyResult.fold(
        (error) => _error = error.toString(),
        (policy) => _policy = policy,
      );

      if (_policy != null) {
        // Load related data in parallel
        await Future.wait([
          _loadPremiums(forceRefresh),
          _loadClaims(forceRefresh),
          _loadCoverage(),
        ]);
      }
    } catch (e) {
      _error = 'Failed to load policy details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPremiums(bool forceRefresh) async {
    final result = await _policyRepository.getPremiumsByPolicyId(policyId, forceRefresh: forceRefresh);
    result.fold(
      (error) => _error = error.toString(),
      (premiums) => _premiums = premiums,
    );
  }

  Future<void> _loadClaims(bool forceRefresh) async {
    final result = await _policyRepository.getClaimsByPolicyId(policyId, forceRefresh: forceRefresh);
    result.fold(
      (error) => _error = error.toString(),
      (claims) => _claims = claims,
    );
  }

  Future<void> _loadCoverage() async {
    final result = await _policyRepository.getCoverageByPolicyId(policyId);
    result.fold(
      (error) => _error = error.toString(),
      (coverage) => _coverage = coverage,
    );
  }

  Future<void> refresh() async {
    await loadPolicyDetails(forceRefresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Policy actions
  Future<Either<Exception, Policy>> updatePolicy(Map<String, dynamic> updates) async {
    final result = await _policyRepository.updatePolicy(policyId, updates);

    result.fold(
      (error) => _error = error.toString(),
      (updatedPolicy) {
        _policy = updatedPolicy;
      },
    );

    notifyListeners();
    return result;
  }

  Future<Either<Exception, void>> deletePolicy() async {
    final result = await _policyRepository.deletePolicy(policyId);
    return result;
  }
}
