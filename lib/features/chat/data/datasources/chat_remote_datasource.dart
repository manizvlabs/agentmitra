import '../../../../core/services/api_service.dart';
import '../../../../shared/constants/api_constants.dart';
import '../models/chat_models.dart';

class ChatRemoteDataSource {
  /// Get chat health status
  Future<Map<String, dynamic>> getChatHealth() async {
    return await ApiService.get(ApiConstants.chat.replaceAll('/chat', '/chat/health'));
  }

  /// Create new chat session
  Future<ChatSession> createChatSession({
    required String agentId,
    String? customerId,
    String? topic,
  }) async {
    final sessionData = {
      'agent_id': agentId,
      if (customerId != null) 'customer_id': customerId,
      if (topic != null) 'topic': topic,
    };

    final response = await ApiService.post(ApiConstants.chatSessions, sessionData);
    return ChatSession.fromJson(response);
  }

  /// Get chat session by ID
  Future<ChatSession> getChatSession(String sessionId) async {
    final response = await ApiService.get(ApiConstants.chatSession(sessionId));
    return ChatSession.fromJson(response);
  }

  /// Get chat sessions for agent
  Future<List<ChatSession>> getChatSessions({
    String? agentId,
    String? status,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (agentId != null) queryParams['agent_id'] = agentId;
    if (status != null) queryParams['status'] = status;

    final response = await ApiService.get(
      ApiConstants.chatSessions,
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => ChatSession.fromJson(json))
        .toList();
  }

  /// Send message in chat session
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
    required String sender,
    String? messageType,
  }) async {
    final messageData = {
      'session_id': sessionId,
      'content': content,
      'sender': sender,
      if (messageType != null) 'message_type': messageType,
    };

    final response = await ApiService.post(
      ApiConstants.chatSessionMessages(sessionId),
      messageData,
    );
    return ChatMessage.fromJson(response);
  }

  /// Get messages for chat session
  Future<List<ChatMessage>> getChatMessages(String sessionId, {
    int limit = 50,
  }) async {
    final response = await ApiService.get(
      ApiConstants.chatSessionMessages(sessionId),
      queryParameters: {'limit': limit.toString()},
    );

    return (response as List<dynamic>)
        .map((json) => ChatMessage.fromJson(json))
        .toList();
  }

  /// End chat session
  Future<void> endChatSession(String sessionId) async {
    await ApiService.post(ApiConstants.chatSession(sessionId).replaceAll('/sessions/', '/sessions/') + '/end', {});
  }

  /// Get chat session analytics
  Future<ChatAnalytics> getChatSessionAnalytics(String sessionId) async {
    final response = await ApiService.get(ApiConstants.chatSessionAnalytics(sessionId));
    return ChatAnalytics.fromJson(response);
  }

  /// Get overall chat analytics
  Future<Map<String, dynamic>> getChatAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    return await ApiService.get(
      ApiConstants.chat.replaceAll('/chat', '/chat/analytics'),
      queryParameters: queryParams,
    );
  }

  /// Search knowledge base
  Future<List<KnowledgeBaseArticle>> searchKnowledgeBase(String query, {
    String? category,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'q': query,
      'limit': limit.toString(),
    };
    if (category != null) queryParams['category'] = category;

    final response = await ApiService.get(
      ApiConstants.chat.replaceAll('/chat', '/chat/knowledge-base/search'),
      queryParameters: queryParams,
    );

    return (response['articles'] as List<dynamic>?)
        ?.map((json) => KnowledgeBaseArticle.fromJson(json))
        .toList() ?? [];
  }

  /// Get knowledge base articles
  Future<List<KnowledgeBaseArticle>> getKnowledgeBaseArticles({
    String? category,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    queryParams['limit'] = limit.toString();

    final response = await ApiService.get(
      ApiConstants.chat.replaceAll('/chat', '/chat/knowledge-base/articles'),
      queryParameters: queryParams,
    );

    return (response as List<dynamic>)
        .map((json) => KnowledgeBaseArticle.fromJson(json))
        .toList();
  }
}
