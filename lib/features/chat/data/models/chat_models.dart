/// Chat and chatbot data models

class ChatSession {
  final String sessionId;
  final String agentId;
  final String? customerId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? status;
  final String? topic;
  final int? messageCount;
  final Map<String, dynamic>? context;

  ChatSession({
    required this.sessionId,
    required this.agentId,
    this.customerId,
    this.startedAt,
    this.endedAt,
    this.status,
    this.topic,
    this.messageCount,
    this.context,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['session_id'] ?? '',
      agentId: json['agent_id'] ?? '',
      customerId: json['customer_id'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      status: json['status'],
      topic: json['topic'],
      messageCount: json['message_count'],
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'agent_id': agentId,
      if (customerId != null) 'customer_id': customerId,
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      if (status != null) 'status': status,
      if (topic != null) 'topic': topic,
      if (messageCount != null) 'message_count': messageCount,
      if (context != null) 'context': context,
    };
  }
}

class ChatMessage {
  final String messageId;
  final String sessionId;
  final String content;
  final String sender;
  final DateTime timestamp;
  final String? messageType;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.messageId,
    required this.sessionId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.messageType,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['message_id'] ?? json['id'] ?? '',
      sessionId: json['session_id'] ?? '',
      content: json['content'] ?? json['message'] ?? '',
      sender: json['sender'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      messageType: json['message_type'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'session_id': sessionId,
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      if (messageType != null) 'message_type': messageType,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class ChatAnalytics {
  final String sessionId;
  final int totalMessages;
  final int userMessages;
  final int botMessages;
  final double averageResponseTime;
  final String? topIntent;
  final Map<String, int> intentDistribution;
  final DateTime sessionStart;
  final DateTime? sessionEnd;

  ChatAnalytics({
    required this.sessionId,
    required this.totalMessages,
    required this.userMessages,
    required this.botMessages,
    required this.averageResponseTime,
    this.topIntent,
    required this.intentDistribution,
    required this.sessionStart,
    this.sessionEnd,
  });

  factory ChatAnalytics.fromJson(Map<String, dynamic> json) {
    return ChatAnalytics(
      sessionId: json['session_id'] ?? '',
      totalMessages: json['total_messages'] ?? 0,
      userMessages: json['user_messages'] ?? 0,
      botMessages: json['bot_messages'] ?? 0,
      averageResponseTime: (json['average_response_time'] ?? 0.0).toDouble(),
      topIntent: json['top_intent'],
      intentDistribution: Map<String, int>.from(json['intent_distribution'] ?? {}),
      sessionStart: DateTime.parse(json['session_start'] ?? DateTime.now().toIso8601String()),
      sessionEnd: json['session_end'] != null ? DateTime.parse(json['session_end']) : null,
    );
  }
}

class KnowledgeBaseArticle {
  final String articleId;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeBaseArticle({
    required this.articleId,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeBaseArticle.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseArticle(
      articleId: json['article_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
