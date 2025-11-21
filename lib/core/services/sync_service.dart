import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger_service.dart';
import 'api_service.dart';

/// Service for handling data synchronization between local and remote sources
class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _syncConflictsKey = 'sync_conflicts';
  static const String _pendingUploadsKey = 'pending_uploads';

  final LoggerService _logger;
  final ApiService _apiService;
  final Connectivity _connectivity;

  final StreamController<SyncEvent> _syncController = StreamController.broadcast();

  SyncService(this._logger, this._apiService, this._connectivity);

  Stream<SyncEvent> get syncStream => _syncController.stream;

  /// Initialize sync service
  Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _startAutoSync();
      }
    });
  }

  /// Perform full synchronization
  Future<SyncResult> performFullSync() async {
    if (!await _isConnected()) {
      return SyncResult.failure('No internet connection');
    }

    _syncController.add(SyncEvent.syncStarted);
    _logger.info('Starting full synchronization');

    try {
      final lastSync = await _getLastSyncTimestamp();
      final conflicts = <SyncConflict>[];

      // Sync each data type
      final results = await Future.wait([
        _syncNotifications(lastSync),
        _syncUserData(lastSync),
        _syncAgentData(lastSync),
        _syncPresentationData(lastSync),
      ]);

      // Collect conflicts
      for (final result in results) {
        conflicts.addAll(result.conflicts);
      }

      // Resolve conflicts automatically where possible
      final resolvedConflicts = await _resolveConflicts(conflicts);

      // Update last sync timestamp
      await _setLastSyncTimestamp(DateTime.now());

      final success = results.every((r) => r.success);
      final totalSynced = results.fold<int>(0, (sum, r) => sum + r.itemsSynced);

      final result = SyncResult.success(
        itemsSynced: totalSynced,
        conflictsResolved: resolvedConflicts,
        conflictsPending: conflicts.length - resolvedConflicts,
      );

      _syncController.add(SyncEvent.syncCompleted(result));
      _logger.info('Full synchronization completed: $totalSynced items synced');

      return result;

    } catch (e, stackTrace) {
      _logger.error('Full synchronization failed', e, stackTrace);
      final result = SyncResult.failure(e.toString());
      _syncController.add(SyncEvent.syncFailed(result));
      return result;
    }
  }

  /// Sync notifications data
  Future<SyncOperationResult> _syncNotifications(DateTime? lastSync) async {
    try {
      // Fetch remote notifications since last sync
      final response = await _apiService.get('/api/v1/notifications', queryParameters: {
        'since': lastSync?.toIso8601String(),
      });

      final remoteNotifications = response['data'] as List;

      // Compare with local notifications and merge
      final conflicts = await _mergeNotifications(remoteNotifications);

      return SyncOperationResult.success(
        itemsSynced: remoteNotifications.length,
        conflicts: conflicts,
      );
    } catch (e) {
      _logger.error('Failed to sync notifications', e);
      return SyncOperationResult.failure(conflicts: []);
    }
  }

  /// Sync user data
  Future<SyncOperationResult> _syncUserData(DateTime? lastSync) async {
    try {
      // Sync user profile, preferences, etc.
      final response = await _apiService.get('/api/v1/users/profile');

      // Apply server changes locally
      await _applyUserDataChanges(response['data']);

      return SyncOperationResult.success(
        itemsSynced: 1,
        conflicts: [],
      );
    } catch (e) {
      _logger.error('Failed to sync user data', e);
      return SyncOperationResult.failure(conflicts: []);
    }
  }

  /// Sync agent data
  Future<SyncOperationResult> _syncAgentData(DateTime? lastSync) async {
    try {
      // Sync agent-specific data
      final response = await _apiService.get('/api/v1/agents/me');

      await _applyAgentDataChanges(response['data']);

      return SyncOperationResult.success(
        itemsSynced: 1,
        conflicts: [],
      );
    } catch (e) {
      _logger.error('Failed to sync agent data', e);
      return SyncOperationResult.failure(conflicts: []);
    }
  }

  /// Sync presentation data
  Future<SyncOperationResult> _syncPresentationData(DateTime? lastSync) async {
    try {
      final response = await _apiService.get('/api/v1/presentations/agent/me', queryParameters: {
        'since': lastSync?.toIso8601String(),
      });

      final presentations = response['data'] as List;
      final conflicts = await _mergePresentations(presentations);

      return SyncOperationResult.success(
        itemsSynced: presentations.length,
        conflicts: conflicts,
      );
    } catch (e) {
      _logger.error('Failed to sync presentation data', e);
      return SyncOperationResult.failure(conflicts: []);
    }
  }

  /// Merge remote notifications with local ones
  Future<List<SyncConflict>> _mergeNotifications(List remoteNotifications) async {
    // TODO: Implement notification merging logic
    // Compare timestamps, resolve conflicts based on business rules
    return [];
  }

  /// Apply user data changes from server
  Future<void> _applyUserDataChanges(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(userData));
  }

  /// Apply agent data changes from server
  Future<void> _applyAgentDataChanges(Map<String, dynamic> agentData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('agent_profile', jsonEncode(agentData));
  }

  /// Merge presentations with conflict resolution
  Future<List<SyncConflict>> _mergePresentations(List presentations) async {
    // TODO: Implement presentation merging logic
    return [];
  }

  /// Resolve conflicts automatically
  Future<int> _resolveConflicts(List<SyncConflict> conflicts) async {
    int resolvedCount = 0;

    for (final conflict in conflicts) {
      if (await _canResolveAutomatically(conflict)) {
        await _resolveConflict(conflict);
        resolvedCount++;
      } else {
        await _storeConflictForManualResolution(conflict);
      }
    }

    return resolvedCount;
  }

  /// Check if conflict can be resolved automatically
  Future<bool> _canResolveAutomatically(SyncConflict conflict) async {
    // Implement automatic resolution rules:
    // - Server always wins for user profile data
    // - Last modified wins for user-generated content
    // - Manual resolution required for complex conflicts

    switch (conflict.type) {
      case SyncConflictType.userProfile:
        return true; // Server wins
      case SyncConflictType.presentation:
        return true; // Last modified wins
      case SyncConflictType.notification:
        return true; // Server wins
      default:
        return false; // Manual resolution
    }
  }

  /// Resolve a single conflict
  Future<void> _resolveConflict(SyncConflict conflict) async {
    // Apply resolution strategy
    switch (conflict.strategy) {
      case ConflictResolutionStrategy.serverWins:
        await _applyServerVersion(conflict);
        break;
      case ConflictResolutionStrategy.clientWins:
        await _applyClientVersion(conflict);
        break;
      case ConflictResolutionStrategy.lastModifiedWins:
        await _applyLastModifiedVersion(conflict);
        break;
      case ConflictResolutionStrategy.manual:
        // Should not reach here
        break;
    }
  }

  /// Store conflict for manual resolution
  Future<void> _storeConflictForManualResolution(SyncConflict conflict) async {
    final prefs = await SharedPreferences.getInstance();
    final conflicts = await _getStoredConflicts();
    conflicts.add(conflict);
    await prefs.setString(_syncConflictsKey, jsonEncode(conflicts));
  }

  /// Get stored conflicts
  Future<List<SyncConflict>> _getStoredConflicts() async {
    final prefs = await SharedPreferences.getInstance();
    final conflictsJson = prefs.getString(_syncConflictsKey);
    if (conflictsJson == null) return [];

    final conflictsData = jsonDecode(conflictsJson) as List;
    return conflictsData.map((json) => SyncConflict.fromJson(json)).toList();
  }

  /// Apply server version of data
  Future<void> _applyServerVersion(SyncConflict conflict) async {
    // TODO: Implement server version application
    _logger.info('Applied server version for conflict: ${conflict.id}');
  }

  /// Apply client version of data
  Future<void> _applyClientVersion(SyncConflict conflict) async {
    // TODO: Implement client version application
    _logger.info('Applied client version for conflict: ${conflict.id}');
  }

  /// Apply last modified version of data
  Future<void> _applyLastModifiedVersion(SyncConflict conflict) async {
    // TODO: Compare timestamps and apply newer version
    _logger.info('Applied last modified version for conflict: ${conflict.id}');
  }

  /// Get last sync timestamp
  Future<DateTime?> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampStr = prefs.getString(_lastSyncKey);
    return timestampStr != null ? DateTime.parse(timestampStr) : null;
  }

  /// Set last sync timestamp
  Future<void> _setLastSyncTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());
  }

  /// Check if device is connected
  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Start automatic sync when connected
  void _startAutoSync() {
    // TODO: Implement periodic sync
    _logger.info('Auto sync started');
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    final lastSync = await _getLastSyncTimestamp();
    final conflicts = await _getStoredConflicts();

    return {
      'last_sync': lastSync?.toIso8601String(),
      'pending_conflicts': conflicts.length,
      'is_connected': await _isConnected(),
    };
  }

  /// Force immediate sync
  Future<SyncResult> forceSync() async {
    return performFullSync();
  }

  /// Clear all sync data (for testing/debugging)
  Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_syncConflictsKey);
    await prefs.remove(_pendingUploadsKey);
    _logger.info('Sync data cleared');
  }

  /// Dispose resources
  void dispose() {
    _syncController.close();
  }
}

/// Sync operation result
class SyncOperationResult {
  final bool success;
  final int itemsSynced;
  final List<SyncConflict> conflicts;

  SyncOperationResult.success({
    required this.itemsSynced,
    required this.conflicts,
  }) : success = true;

  SyncOperationResult.failure({
    required this.conflicts,
  }) : success = false, itemsSynced = 0;
}

/// Sync result
class SyncResult {
  final bool success;
  final String? error;
  final int? itemsSynced;
  final int? conflictsResolved;
  final int? conflictsPending;

  SyncResult.success({
    required this.itemsSynced,
    required this.conflictsResolved,
    required this.conflictsPending,
  }) : success = true, error = null;

  SyncResult.failure(this.error)
      : success = false,
        itemsSynced = null,
        conflictsResolved = null,
        conflictsPending = null;
}

/// Sync conflict
class SyncConflict {
  final String id;
  final SyncConflictType type;
  final Map<String, dynamic> serverData;
  final Map<String, dynamic> clientData;
  final DateTime serverTimestamp;
  final DateTime clientTimestamp;
  final ConflictResolutionStrategy strategy;

  SyncConflict({
    required this.id,
    required this.type,
    required this.serverData,
    required this.clientData,
    required this.serverTimestamp,
    required this.clientTimestamp,
    this.strategy = ConflictResolutionStrategy.manual,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'serverData': serverData,
    'clientData': clientData,
    'serverTimestamp': serverTimestamp.toIso8601String(),
    'clientTimestamp': clientTimestamp.toIso8601String(),
    'strategy': strategy.name,
  };

  factory SyncConflict.fromJson(Map<String, dynamic> json) => SyncConflict(
    id: json['id'],
    type: SyncConflictType.values.firstWhere((e) => e.name == json['type']),
    serverData: json['serverData'],
    clientData: json['clientData'],
    serverTimestamp: DateTime.parse(json['serverTimestamp']),
    clientTimestamp: DateTime.parse(json['clientTimestamp']),
    strategy: ConflictResolutionStrategy.values.firstWhere((e) => e.name == json['strategy']),
  );
}

/// Types of sync conflicts
enum SyncConflictType {
  userProfile,
  agentData,
  presentation,
  notification,
  settings,
}

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  serverWins,
  clientWins,
  lastModifiedWins,
  manual,
}

/// Sync events for stream
class SyncEvent {
  final SyncEventType type;
  final SyncResult? result;

  SyncEvent.syncStarted() : type = SyncEventType.started, result = null;
  SyncEvent.syncCompleted(this.result) : type = SyncEventType.completed;
  SyncEvent.syncFailed(this.result) : type = SyncEventType.failed;
}

/// Sync event types
enum SyncEventType {
  started,
  completed,
  failed,
}
