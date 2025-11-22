import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'logger_service.dart';
import 'api_service.dart';

/// Types of operations that can be queued for offline execution
enum OfflineOperationType {
  apiPost,
  apiPut,
  apiPatch,
  apiDelete,
  localDataUpdate,
  notificationAction,
}

/// Represents a queued operation
class QueuedOperation {
  final String id;
  final OfflineOperationType type;
  final String endpoint;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? headers;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;
  final Duration retryDelay;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    this.data,
    this.headers,
    required this.createdAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 30),
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'endpoint': endpoint,
    'data': data,
    'headers': headers,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
    'maxRetries': maxRetries,
    'retryDelaySeconds': retryDelay.inSeconds,
  };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) => QueuedOperation(
    id: json['id'],
    type: OfflineOperationType.values.firstWhere((e) => e.name == json['type']),
    endpoint: json['endpoint'],
    data: json['data'],
    headers: json['headers'],
    createdAt: DateTime.parse(json['createdAt']),
    retryCount: json['retryCount'] ?? 0,
    maxRetries: json['maxRetries'] ?? 3,
    retryDelay: Duration(seconds: json['retryDelaySeconds'] ?? 30),
  );

  bool get canRetry => retryCount < maxRetries;
  bool get isExpired => DateTime.now().difference(createdAt) > const Duration(hours: 24);

  QueuedOperation incrementRetry() => QueuedOperation(
    id: id,
    type: type,
    endpoint: endpoint,
    data: data,
    headers: headers,
    createdAt: createdAt,
    retryCount: retryCount + 1,
    maxRetries: maxRetries,
    retryDelay: retryDelay,
  );
}

/// Service for managing offline operations queue
class OfflineQueueService {
  static const String _queueKey = 'offline_operations_queue';
  static const String _syncStatusKey = 'offline_sync_status';

  final LoggerService _logger;
  final Connectivity _connectivity;

  final StreamController<List<QueuedOperation>> _queueController = StreamController.broadcast();
  final StreamController<SyncStatus> _syncController = StreamController.broadcast();

  Timer? _syncTimer;
  bool _isProcessing = false;

  OfflineQueueService(this._logger, this._connectivity) {
    _initialize();
  }

  Stream<List<QueuedOperation>> get queueStream => _queueController.stream;
  Stream<SyncStatus> get syncStream => _syncController.stream;

  Future<void> _initialize() async {
    await _loadQueue();
    await _loadSyncStatus();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _startSyncTimer();
      } else {
        _stopSyncTimer();
      }
    });

    // Start sync timer if connected
    if (await _isConnected()) {
      _startSyncTimer();
    }
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final queueData = jsonDecode(queueJson) as List;
        final queue = queueData.map((json) => QueuedOperation.fromJson(json)).toList();
        _queueController.add(queue);
      } else {
        _queueController.add([]);
      }
    } catch (e) {
      _logger.error('Failed to load offline queue: $e');
      _queueController.add([]);
    }
  }

  Future<bool> _isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void _startSyncTimer() {
    _stopSyncTimer();
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) => _processQueue());
  }

  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Add operation to queue
  Future<void> addOperation(
    OfflineOperationType type,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      endpoint: endpoint,
      data: data,
      headers: headers,
      createdAt: DateTime.now(),
    );

    final queue = await _getQueue();
    queue.add(operation);
    await _saveQueue(queue);

    _queueController.add(queue);
    _logger.info('Added operation to offline queue: ${operation.type.name} ${operation.endpoint}');

    // Try to process immediately if connected
    if (await _isConnected()) {
      _processQueue();
    }
  }

  /// Remove operation from queue
  Future<void> removeOperation(String operationId) async {
    final queue = await _getQueue();
    queue.removeWhere((op) => op.id == operationId);
    await _saveQueue(queue);

    _queueController.add(queue);
    _logger.info('Removed operation from offline queue: $operationId');
  }

  /// Get current queue
  Future<List<QueuedOperation>> getQueue() async {
    return await _getQueue();
  }

  /// Clear expired operations
  Future<void> clearExpired() async {
    final queue = await _getQueue();
    final beforeCount = queue.length;
    queue.removeWhere((op) => op.isExpired);
    final afterCount = queue.length;

    if (beforeCount != afterCount) {
      await _saveQueue(queue);
      _queueController.add(queue);
      _logger.info('Cleared ${beforeCount - afterCount} expired operations from queue');
    }
  }

  /// Process the offline queue
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    if (!(await _isConnected())) return;

    _isProcessing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      final queue = await _getQueue();
      if (queue.isEmpty) {
        _syncController.add(SyncStatus.idle);
        _isProcessing = false;
        return;
      }

      final operationsToProcess = queue.where((op) => op.canRetry).toList();
      final processedIds = <String>[];
      final failedIds = <String>[];

      for (final operation in operationsToProcess) {
        try {
          final success = await _executeOperation(operation);
          if (success) {
            processedIds.add(operation.id);
          } else {
            failedIds.add(operation.id);
          }
        } catch (e) {
          _logger.error('Failed to execute operation ${operation.id}: $e');
          failedIds.add(operation.id);
        }
      }

      // Update queue
      queue.removeWhere((op) => processedIds.contains(op.id));

      // Increment retry count for failed operations
      for (final failedId in failedIds) {
        final index = queue.indexWhere((op) => op.id == failedId);
        if (index != -1) {
          queue[index] = queue[index].incrementRetry();
        }
      }

      await _saveQueue(queue);
      _queueController.add(queue);

      if (processedIds.isNotEmpty) {
        _logger.info('Successfully processed ${processedIds.length} offline operations');
      }

      if (failedIds.isNotEmpty) {
        _logger.warning('${failedIds.length} operations failed and will be retried later');
      }

      _syncController.add(SyncStatus.idle);

    } catch (e) {
      _logger.error('Failed to process offline queue: $e');
      _syncController.add(SyncStatus.error);
    } finally {
      _isProcessing = false;
    }
  }

  /// Execute a single operation
  Future<bool> _executeOperation(QueuedOperation operation) async {
    try {
      switch (operation.type) {
        case OfflineOperationType.apiPost:
          await ApiService.post(operation.endpoint, operation.data ?? {});
          break;
        case OfflineOperationType.apiPut:
          await ApiService.put(operation.endpoint, operation.data ?? {});
          break;
        case OfflineOperationType.apiPatch:
          await ApiService.patch(operation.endpoint, operation.data ?? {});
          break;
        case OfflineOperationType.apiDelete:
          await ApiService.delete(operation.endpoint);
          break;
        case OfflineOperationType.localDataUpdate:
          // Handle local data updates
          await _handleLocalDataUpdate(operation);
          break;
        case OfflineOperationType.notificationAction:
          // Handle notification actions
          await _handleNotificationAction(operation);
          break;
      }

      return true;
    } catch (e) {
      _logger.error('Failed to execute offline operation: ${operation.id}', error: e);
      return false;
    }
  }

  /// Handle local data update operations
  Future<void> _handleLocalDataUpdate(QueuedOperation operation) async {
    final prefs = await SharedPreferences.getInstance();
    if (operation.data != null) {
      await prefs.setString(operation.endpoint, jsonEncode(operation.data));
    }
  }

  /// Handle notification action operations
  Future<void> _handleNotificationAction(QueuedOperation operation) async {
    // Handle notification-related operations
    _logger.info('Handling notification action: ${operation.endpoint}');
  }

  /// Get queue from storage
  Future<List<QueuedOperation>> _getQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson == null) return [];

      final queueData = jsonDecode(queueJson) as List;
      return queueData.map((json) => QueuedOperation.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Failed to load offline queue: $e');
      return [];
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue(List<QueuedOperation> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(queue.map((op) => op.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      _logger.error('Failed to save offline queue: $e');
    }
  }

  /// Load sync status
  Future<void> _loadSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusStr = prefs.getString(_syncStatusKey);
      if (statusStr != null) {
        _syncController.add(SyncStatus.values.firstWhere((s) => s.name == statusStr));
      } else {
        _syncController.add(SyncStatus.idle);
      }
    } catch (e) {
      _syncController.add(SyncStatus.idle);
    }
  }

  /// Save sync status
  Future<void> _saveSyncStatus(SyncStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_syncStatusKey, status.name);
    } catch (e) {
      _logger.error('Failed to save sync status: $e');
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStatistics() async {
    final queue = await _getQueue();

    return {
      'total_operations': queue.length,
      'pending_operations': queue.where((op) => op.canRetry).length,
      'failed_operations': queue.where((op) => !op.canRetry).length,
      'expired_operations': queue.where((op) => op.isExpired).length,
      'oldest_operation': queue.isNotEmpty
          ? queue.map((op) => op.createdAt).reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
    };
  }

  /// Force immediate sync
  Future<void> forceSync() async {
    if (await _isConnected()) {
      await _processQueue();
    }
  }

  /// Dispose resources
  void dispose() {
    _stopSyncTimer();
    _queueController.close();
    _syncController.close();
  }
}

/// Sync status enum
enum SyncStatus {
  idle,
  syncing,
  error,
}

/// Extension to get display name for sync status
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }

  Color get color {
    switch (this) {
      case SyncStatus.idle:
        return Colors.green;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.error:
        return Colors.red;
    }
  }
}
