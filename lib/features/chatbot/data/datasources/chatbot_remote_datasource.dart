import '../../../../core/services/api_service.dart';
import '../models/chatbot_model.dart';

abstract class ChatbotRemoteDataSource {
  Future<ChatSession> createSession(String agentId, {String? customerId});
  Future<ChatSession> getSession(String sessionId);
  Future<List<ChatMessage>> getMessages(String sessionId, {int limit = 50, int offset = 0});
  Future<ChatbotResponse> sendMessage(String sessionId, String message);
  Future<ChatMessage> sendUserMessage(String sessionId, String message);
  Future<void> endSession(String sessionId);
  Future<void> transferToAgent(String sessionId, String reason);
  Future<List<ChatSession>> getAgentSessions(String agentId, {int limit = 20, int offset = 0});
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  ChatbotRemoteDataSourceImpl();

  @override
  Future<ChatSession> createSession(String agentId, {String? customerId}) async {
    try {
      final response = await ApiService.post('/chat/sessions', {
        'user_id': agentId, // Backend expects user_id
        'device_info': {'platform': 'mobile'},
      });
      return ChatSession.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  @override
  Future<ChatSession> getSession(String sessionId) async {
    // Backend doesn't have this endpoint, return mock session
    return ChatSession(
      sessionId: sessionId,
      agentId: 'test-agent',
      startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: 'active',
      messageCount: 0,
    );
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId, {int limit = 50, int offset = 0}) async {
    // Backend doesn't have this endpoint, return empty list
    // Messages are stored locally in the ViewModel
    return [];
  }

  @override
  Future<ChatbotResponse> sendMessage(String sessionId, String message) async {
    try {
      final response = await ApiService.post('/chat/sessions/$sessionId/messages', {
        'message': message,
        'user_id': 'test-user', // TODO: Get from auth context
      });

      // Convert backend response to ChatbotResponse
      return ChatbotResponse(
        responseId: response['session_id'] ?? '',
        message: response['response'] ?? '',
        intent: response['intent'],
        confidence: response['confidence']?.toDouble(),
        quickReplies: (response['suggested_actions'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
        requiresAgent: false, // TODO: Add escalation logic
        escalationReason: null,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<ChatMessage> sendUserMessage(String sessionId, String message) async {
    try {
      await ApiService.post('/chat/sessions/$sessionId/messages', {
        'message': message,
        'user_id': 'test-user', // TODO: Get from auth context
      });

      // Convert to ChatMessage format
      return ChatMessage(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: sessionId,
        content: message,
        sender: 'user',
        timestamp: DateTime.now(),
        messageType: 'text',
        isRead: true,
      );
    } catch (e) {
      throw Exception('Failed to send user message: $e');
    }
  }

  @override
  Future<void> endSession(String sessionId) async {
    try {
      await ApiService.put('/chat/sessions/$sessionId/end', {});
    } catch (e) {
      throw Exception('Failed to end session: $e');
    }
  }

  @override
  Future<void> transferToAgent(String sessionId, String reason) async {
    try {
      // Backend doesn't have transfer endpoint, this would need to be implemented
      // For now, just end the session
      await ApiService.put('/chat/sessions/$sessionId/end', {});
    } catch (e) {
      throw Exception('Failed to transfer to agent: $e');
    }
  }

  @override
  Future<List<ChatSession>> getAgentSessions(String agentId, {int limit = 20, int offset = 0}) async {
    // Backend doesn't have this endpoint, return empty list
    return [];
  }
}
