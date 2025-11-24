/// Remote data source for callback API calls
import '../../../../core/services/api_service.dart';
import '../models/callback_model.dart';

class CallbackRemoteDataSource {
  /// Create a new callback request
  Future<CallbackRequest> createCallbackRequest(Map<String, dynamic> callbackData) async {
    final response = await ApiService.post('/callbacks', callbackData);
    if (response['success'] == true && response['data'] != null) {
      // Need to fetch full details
      final callbackId = response['data']['callback_request_id'];
      return await getCallbackRequest(callbackId);
    }
    throw Exception(response['message'] ?? 'Failed to create callback request');
  }

  /// Get list of callback requests
  Future<List<CallbackRequest>> getCallbackRequests({
    String? status,
    String? priority,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;

    final response = await ApiService.get('/callbacks', queryParameters: queryParams);
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> callbacksJson = response['data'];
      return callbacksJson.map((json) => CallbackRequest.fromJson(json)).toList();
    }
    return [];
  }

  /// Get callback request by ID
  Future<CallbackRequest> getCallbackRequest(String callbackId) async {
    final response = await ApiService.get('/callbacks/$callbackId');
    if (response['success'] == true && response['data'] != null) {
      return CallbackRequest.fromJson(response['data']);
    }
    throw Exception(response['message'] ?? 'Callback request not found');
  }

  /// Update callback status
  Future<CallbackRequest> updateCallbackStatus(String callbackId, String status) async {
    final response = await ApiService.put(
      '/callbacks/$callbackId/status',
      {'status': status},
    );
    if (response['success'] == true) {
      return await getCallbackRequest(callbackId);
    }
    throw Exception(response['message'] ?? 'Failed to update callback status');
  }

  /// Assign callback to agent
  Future<CallbackRequest> assignCallback(String callbackId, {String? agentId}) async {
    final queryParams = <String, dynamic>{};
    if (agentId != null) queryParams['agent_id'] = agentId;

    final response = await ApiService.post(
      '/callbacks/$callbackId/assign',
      {},
    );
    if (response['success'] == true) {
      return await getCallbackRequest(callbackId);
    }
    throw Exception(response['message'] ?? 'Failed to assign callback');
  }

  /// Complete callback request
  Future<CallbackRequest> completeCallback(
    String callbackId, {
    String? resolution,
    String? resolutionCategory,
    int? satisfactionRating,
  }) async {
    final response = await ApiService.post(
      '/callbacks/$callbackId/complete',
      {
        if (resolution != null) 'resolution': resolution,
        if (resolutionCategory != null) 'resolution_category': resolutionCategory,
        if (satisfactionRating != null) 'satisfaction_rating': satisfactionRating,
      },
    );
    if (response['success'] == true) {
      return await getCallbackRequest(callbackId);
    }
    throw Exception(response['message'] ?? 'Failed to complete callback');
  }
}

