import 'package:hive/hive.dart';
import '../models/policy_model.dart';

abstract class PolicyLocalDataSource {
  Future<void> cachePolicies(List<Policy> policies);
  Future<List<Policy>> getCachedPolicies();
  Future<void> cachePolicy(Policy policy);
  Future<Policy?> getCachedPolicy(String policyId);
  Future<void> clearCache();
  Future<void> cachePremiums(String policyId, List<Premium> premiums);
  Future<List<Premium>?> getCachedPremiums(String policyId);
  Future<void> cacheClaims(String policyId, List<Claim> claims);
  Future<List<Claim>?> getCachedClaims(String policyId);
}

class PolicyLocalDataSourceImpl implements PolicyLocalDataSource {
  static const String _policiesBoxName = 'policies';
  static const String _premiumsBoxName = 'premiums';
  static const String _claimsBoxName = 'claims';

  late Box<Policy> _policiesBox;
  late Box<List> _premiumsBox;
  late Box<List> _claimsBox;

  Future<void> init() async {
    _policiesBox = await Hive.openBox<Policy>(_policiesBoxName);
    _premiumsBox = await Hive.openBox<List>(_premiumsBoxName);
    _claimsBox = await Hive.openBox<List>(_claimsBoxName);
  }

  @override
  Future<void> cachePolicies(List<Policy> policies) async {
    await _policiesBox.clear();
    for (final policy in policies) {
      await _policiesBox.put(policy.policyId, policy);
    }
  }

  @override
  Future<List<Policy>> getCachedPolicies() async {
    return _policiesBox.values.toList();
  }

  @override
  Future<void> cachePolicy(Policy policy) async {
    await _policiesBox.put(policy.policyId, policy);
  }

  @override
  Future<Policy?> getCachedPolicy(String policyId) async {
    return _policiesBox.get(policyId);
  }

  @override
  Future<void> clearCache() async {
    await _policiesBox.clear();
    await _premiumsBox.clear();
    await _claimsBox.clear();
  }

  @override
  Future<void> cachePremiums(String policyId, List<Premium> premiums) async {
    await _premiumsBox.put(policyId, premiums);
  }

  @override
  Future<List<Premium>?> getCachedPremiums(String policyId) async {
    final cached = _premiumsBox.get(policyId);
    if (cached != null) {
      return List<Premium>.from(cached);
    }
    return null;
  }

  @override
  Future<void> cacheClaims(String policyId, List<Claim> claims) async {
    await _claimsBox.put(policyId, claims);
  }

  @override
  Future<List<Claim>?> getCachedClaims(String policyId) async {
    final cached = _claimsBox.get(policyId);
    if (cached != null) {
      return List<Claim>.from(cached);
    }
    return null;
  }
}
