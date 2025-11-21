import 'package:dio/dio.dart';
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
  final Dio dio;

  ChatbotRemoteDataSourceImpl(this.dio);

  @override
  Future<ChatSession> createSession(String agentId, {String? customerId}) async {
    try {
      final response = await dio.post('/api/v1/chatbot/sessions', data: {
        'agent_id': agentId,
        if (customerId != null) 'customer_id': customerId,
      });
      return ChatSession.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create chat session: $e');
    }
  }

  @override
  Future<ChatSession> getSession(String sessionId) async {
    try {
      final response = await dio.get('/api/v1/chatbot/sessions/$sessionId');
      return ChatSession.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get chat session: $e');
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await dio.get(
        '/api/v1/chatbot/sessions/$sessionId/messages',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final List<dynamic> data = response.data['messages'] ?? [];
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<ChatbotResponse> sendMessage(String sessionId, String message) async {
    try {
      final response = await dio.post('/api/v1/chatbot/sessions/$sessionId/messages', data: {
        'message': message,
        'sender': 'user',
      });
      return ChatbotResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<ChatMessage> sendUserMessage(String sessionId, String message) async {
    try {
      final response = await dio.post('/api/v1/chatbot/sessions/$sessionId/messages', data: {
        'message': message,
        'sender': 'user',
      });
      return ChatMessage.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send user message: $e');
    }
  }

  @override
  Future<void> endSession(String sessionId) async {
    try {
      await dio.put('/api/v1/chatbot/sessions/$sessionId/end');
    } catch (e) {
      throw Exception('Failed to end session: $e');
    }
  }

  @override
  Future<void> transferToAgent(String sessionId, String reason) async {
    try {
      await dio.post('/api/v1/chatbot/sessions/$sessionId/transfer', data: {
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to transfer to agent: $e');
    }
  }

  @override
  Future<List<ChatSession>> getAgentSessions(String agentId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await dio.get(
        '/api/v1/chatbot/agents/$agentId/sessions',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final List<dynamic> data = response.data['sessions'] ?? [];
      return data.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get agent sessions: $e');
    }
  }
}
