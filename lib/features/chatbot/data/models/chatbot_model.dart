import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatbot_model.freezed.dart';
part 'chatbot_model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String messageId,
    required String sessionId,
    required String content,
    required String sender, // 'user' or 'bot'
    required DateTime timestamp,
    String? messageType, // 'text', 'quick_reply', 'suggestion'
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}

@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String sessionId,
    required String agentId,
    String? customerId,
    required DateTime startedAt,
    DateTime? endedAt,
    String? status, // 'active', 'ended', 'transferred'
    String? topic,
    int? messageCount,
    Map<String, dynamic>? context,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) => _$ChatSessionFromJson(json);
}

@freezed
class ChatbotResponse with _$ChatbotResponse {
  const factory ChatbotResponse({
    required String responseId,
    required String message,
    List<String>? quickReplies,
    String? intent,
    double? confidence,
    Map<String, dynamic>? metadata,
    bool? requiresAgent,
    String? escalationReason,
  }) = _ChatbotResponse;

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) => _$ChatbotResponseFromJson(json);
}

@freezed
class QuickReply with _$QuickReply {
  const factory QuickReply({
    required String id,
    required String title,
    String? payload,
    String? action,
  }) = _QuickReply;

  factory QuickReply.fromJson(Map<String, dynamic> json) => _$QuickReplyFromJson(json);
}

@freezed
class ChatbotIntent with _$ChatbotIntent {
  const factory ChatbotIntent({
    required String name,
    required double confidence,
    Map<String, dynamic>? entities,
    Map<String, dynamic>? metadata,
  }) = _ChatbotIntent;

  factory ChatbotIntent.fromJson(Map<String, dynamic> json) => _$ChatbotIntentFromJson(json);
}
