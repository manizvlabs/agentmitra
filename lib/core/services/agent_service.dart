import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../shared/constants/api_constants.dart';
import 'api_service.dart';
import 'logger_service.dart';

/// Service to get current agent ID from authentication
class AgentService {
  static final AgentService _instance = AgentService._internal();
  factory AgentService() => _instance;
  AgentService._internal();

  static const String _agentIdKey = 'cached_agent_id';
  String? _cachedAgentId;
  bool _isLoading = false;

  /// Get current agent ID
  /// First checks cache, then fetches from backend if needed
  Future<String?> getCurrentAgentId() async {
    // Return cached value if available
    if (_cachedAgentId != null) {
      return _cachedAgentId;
    }

    // Check SharedPreferences cache
    final prefs = await SharedPreferences.getInstance();
    final cachedId = prefs.getString(_agentIdKey);
    if (cachedId != null && cachedId.isNotEmpty) {
      _cachedAgentId = cachedId;
      return cachedId;
    }

    // Fetch from backend
    return await _fetchAgentIdFromBackend();
  }

  /// Fetch agent ID from backend
  Future<String?> _fetchAgentIdFromBackend() async {
    if (_isLoading) {
      // Wait for ongoing request
      await Future.delayed(const Duration(milliseconds: 100));
      return _cachedAgentId;
    }

    _isLoading = true;
    try {
      // Check if user is authenticated
      final authRepo = AuthRepository();
      if (!authRepo.isLoggedIn()) {
        LoggerService().warning('User not authenticated, cannot get agent ID');
        return null;
      }

      // Fetch agent profile from backend
      final response = await ApiService.get(ApiConstants.agentProfile);
      
      if (response['agent_id'] != null) {
        final agentId = response['agent_id'].toString();
        _cachedAgentId = agentId;
        
        // Cache in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_agentIdKey, agentId);
        
        LoggerService().info('Agent ID fetched and cached: $agentId');
        return agentId;
      } else {
        LoggerService().warning('Agent profile not found or user is not an agent');
        return null;
      }
    } catch (e) {
      LoggerService().error('Failed to fetch agent ID: $e');
      return null;
    } finally {
      _isLoading = false;
    }
  }

  /// Clear cached agent ID (e.g., on logout)
  Future<void> clearCache() async {
    _cachedAgentId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_agentIdKey);
  }

  /// Force refresh agent ID from backend
  Future<String?> refreshAgentId() async {
    await clearCache();
    return await _fetchAgentIdFromBackend();
  }
}

