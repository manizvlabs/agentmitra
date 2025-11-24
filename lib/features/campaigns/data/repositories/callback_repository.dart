/// Repository for callback data operations
import '../datasources/callback_remote_datasource.dart';
import '../models/callback_model.dart';

class CallbackRepository {
  final CallbackRemoteDataSource _remoteDataSource;

  CallbackRepository({CallbackRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CallbackRemoteDataSource();

  /// Create a new callback request
  Future<CallbackRequest> createCallbackRequest(Map<String, dynamic> callbackData) {
    return _remoteDataSource.createCallbackRequest(callbackData);
  }

  /// Get list of callback requests
  Future<List<CallbackRequest>> getCallbackRequests({
    String? status,
    String? priority,
    int limit = 50,
    int offset = 0,
  }) {
    return _remoteDataSource.getCallbackRequests(
      status: status,
      priority: priority,
      limit: limit,
      offset: offset,
    );
  }

  /// Get callback request by ID
  Future<CallbackRequest> getCallbackRequest(String callbackId) {
    return _remoteDataSource.getCallbackRequest(callbackId);
  }

  /// Update callback status
  Future<CallbackRequest> updateCallbackStatus(String callbackId, String status) {
    return _remoteDataSource.updateCallbackStatus(callbackId, status);
  }

  /// Assign callback to agent
  Future<CallbackRequest> assignCallback(String callbackId, {String? agentId}) {
    return _remoteDataSource.assignCallback(callbackId, agentId: agentId);
  }

  /// Complete callback request
  Future<CallbackRequest> completeCallback(
    String callbackId, {
    String? resolution,
    String? resolutionCategory,
    int? satisfactionRating,
  }) {
    return _remoteDataSource.completeCallback(
      callbackId,
      resolution: resolution,
      resolutionCategory: resolutionCategory,
      satisfactionRating: satisfactionRating,
    );
  }
}

