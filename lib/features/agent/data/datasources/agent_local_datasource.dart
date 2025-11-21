import 'package:hive/hive.dart';
import '../models/agent_model.dart';

abstract class AgentLocalDataSource {
  Future<void> cacheAgentProfile(AgentProfile profile);
  Future<AgentProfile?> getCachedAgentProfile(String agentId);
  Future<void> cacheAgentSettings(AgentSettings settings);
  Future<AgentSettings?> getCachedAgentSettings(String agentId);
  Future<void> cacheAgentPreferences(AgentPreferences preferences);
  Future<AgentPreferences?> getCachedAgentPreferences(String agentId);
  Future<void> cacheAgentPerformance(AgentPerformance performance);
  Future<AgentPerformance?> getCachedAgentPerformance(String agentId);
  Future<void> clearCache();
}

class AgentLocalDataSourceImpl implements AgentLocalDataSource {
  static const String _profileBoxName = 'agent_profiles';
  static const String _settingsBoxName = 'agent_settings';
  static const String _preferencesBoxName = 'agent_preferences';
  static const String _performanceBoxName = 'agent_performance';

  late Box<AgentProfile> _profileBox;
  late Box<AgentSettings> _settingsBox;
  late Box<AgentPreferences> _preferencesBox;
  late Box<AgentPerformance> _performanceBox;

  Future<void> init() async {
    _profileBox = await Hive.openBox<AgentProfile>(_profileBoxName);
    _settingsBox = await Hive.openBox<AgentSettings>(_settingsBoxName);
    _preferencesBox = await Hive.openBox<AgentPreferences>(_preferencesBoxName);
    _performanceBox = await Hive.openBox<AgentPerformance>(_performanceBoxName);
  }

  @override
  Future<void> cacheAgentProfile(AgentProfile profile) async {
    await _profileBox.put(profile.agentId, profile);
  }

  @override
  Future<AgentProfile?> getCachedAgentProfile(String agentId) async {
    return _profileBox.get(agentId);
  }

  @override
  Future<void> cacheAgentSettings(AgentSettings settings) async {
    await _settingsBox.put(settings.agentId, settings);
  }

  @override
  Future<AgentSettings?> getCachedAgentSettings(String agentId) async {
    return _settingsBox.get(agentId);
  }

  @override
  Future<void> cacheAgentPreferences(AgentPreferences preferences) async {
    await _preferencesBox.put(preferences.agentId, preferences);
  }

  @override
  Future<AgentPreferences?> getCachedAgentPreferences(String agentId) async {
    return _preferencesBox.get(agentId);
  }

  @override
  Future<void> cacheAgentPerformance(AgentPerformance performance) async {
    await _performanceBox.put(performance.agentId, performance);
  }

  @override
  Future<AgentPerformance?> getCachedAgentPerformance(String agentId) async {
    return _performanceBox.get(agentId);
  }

  @override
  Future<void> clearCache() async {
    await _profileBox.clear();
    await _settingsBox.clear();
    await _preferencesBox.clear();
    await _performanceBox.clear();
  }
}
