import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  Box<Policy>? _policiesBox;
  Box<List>? _premiumsBox;
  Box<List>? _claimsBox;
  
  // Web-compatible storage using SharedPreferences
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    if (kIsWeb) {
      // Use SharedPreferences for web
      _prefs = await SharedPreferences.getInstance();
    } else {
      // Use Hive for mobile platforms
      try {
        _policiesBox = await Hive.openBox<Policy>(_policiesBoxName);
        _premiumsBox = await Hive.openBox<List>(_premiumsBoxName);
        _claimsBox = await Hive.openBox<List>(_claimsBoxName);
      } catch (e) {
        // Fallback to SharedPreferences if Hive fails
        _prefs = await SharedPreferences.getInstance();
      }
    }
    _isInitialized = true;
  }

  // Helper method to ensure initialization
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  @override
  Future<void> cachePolicies(List<Policy> policies) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _policiesBox == null)) {
      // Use SharedPreferences
      final policiesJson = policies.map((p) => p.toJson()).toList();
      await _prefs!.setString('cached_policies', jsonEncode(policiesJson));
    } else {
      // Use Hive
      await _policiesBox!.clear();
      for (final policy in policies) {
        await _policiesBox!.put(policy.policyId, policy);
      }
    }
  }

  @override
  Future<List<Policy>> getCachedPolicies() async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _policiesBox == null)) {
      // Use SharedPreferences
      final cached = _prefs!.getString('cached_policies');
      if (cached != null) {
        try {
          final List<dynamic> policiesJson = jsonDecode(cached);
          return policiesJson.map((json) => Policy.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          return [];
        }
      }
      return [];
    } else {
      // Use Hive
      return _policiesBox!.values.toList();
    }
  }

  @override
  Future<void> cachePolicy(Policy policy) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _policiesBox == null)) {
      // Use SharedPreferences - update the cached list
      final cached = await getCachedPolicies();
      final updated = cached.where((p) => p.policyId != policy.policyId).toList();
      updated.add(policy);
      await cachePolicies(updated);
    } else {
      // Use Hive
      await _policiesBox!.put(policy.policyId, policy);
    }
  }

  @override
  Future<Policy?> getCachedPolicy(String policyId) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _policiesBox == null)) {
      // Use SharedPreferences
      final cached = await getCachedPolicies();
      try {
        return cached.firstWhere((p) => p.policyId == policyId);
      } catch (e) {
        return null;
      }
    } else {
      // Use Hive
      return _policiesBox!.get(policyId);
    }
  }

  @override
  Future<void> clearCache() async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _policiesBox == null)) {
      // Use SharedPreferences
      await _prefs!.remove('cached_policies');
      await _prefs!.remove('cached_premiums');
      await _prefs!.remove('cached_claims');
    } else {
      // Use Hive
      await _policiesBox!.clear();
      await _premiumsBox!.clear();
      await _claimsBox!.clear();
    }
  }

  @override
  Future<void> cachePremiums(String policyId, List<Premium> premiums) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _premiumsBox == null)) {
      // Use SharedPreferences
      final premiumsJson = premiums.map((p) => p.toJson()).toList();
      await _prefs!.setString('premiums_$policyId', jsonEncode(premiumsJson));
    } else {
      // Use Hive
      await _premiumsBox!.put(policyId, premiums);
    }
  }

  @override
  Future<List<Premium>?> getCachedPremiums(String policyId) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _premiumsBox == null)) {
      // Use SharedPreferences
      final cached = _prefs!.getString('premiums_$policyId');
      if (cached != null) {
        try {
          final List<dynamic> premiumsJson = jsonDecode(cached);
          return premiumsJson.map((json) => Premium.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          return null;
        }
      }
      return null;
    } else {
      // Use Hive
      final cached = _premiumsBox!.get(policyId);
      if (cached != null) {
        return List<Premium>.from(cached);
      }
      return null;
    }
  }

  @override
  Future<void> cacheClaims(String policyId, List<Claim> claims) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _claimsBox == null)) {
      // Use SharedPreferences
      final claimsJson = claims.map((c) => c.toJson()).toList();
      await _prefs!.setString('claims_$policyId', jsonEncode(claimsJson));
    } else {
      // Use Hive
      await _claimsBox!.put(policyId, claims);
    }
  }

  @override
  Future<List<Claim>?> getCachedClaims(String policyId) async {
    await _ensureInitialized();
    
    if (kIsWeb || (_prefs != null && _claimsBox == null)) {
      // Use SharedPreferences
      final cached = _prefs!.getString('claims_$policyId');
      if (cached != null) {
        try {
          final List<dynamic> claimsJson = jsonDecode(cached);
          return claimsJson.map((json) => Claim.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          return null;
        }
      }
      return null;
    } else {
      // Use Hive
      final cached = _claimsBox!.get(policyId);
      if (cached != null) {
        return List<Claim>.from(cached);
      }
      return null;
    }
  }
}
