// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      messageId: json['messageId'] as String,
      sessionId: json['sessionId'] as String,
      content: json['content'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageType: json['messageType'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool?,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'sessionId': instance.sessionId,
      'content': instance.content,
      'sender': instance.sender,
      'timestamp': instance.timestamp.toIso8601String(),
      'messageType': instance.messageType,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
    };

_$ChatSessionImpl _$$ChatSessionImplFromJson(Map<String, dynamic> json) =>
    _$ChatSessionImpl(
      sessionId: json['sessionId'] as String,
      agentId: json['agentId'] as String,
      customerId: json['customerId'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      status: json['status'] as String?,
      topic: json['topic'] as String?,
      messageCount: (json['messageCount'] as num?)?.toInt(),
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChatSessionImplToJson(_$ChatSessionImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'agentId': instance.agentId,
      'customerId': instance.customerId,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'status': instance.status,
      'topic': instance.topic,
      'messageCount': instance.messageCount,
      'context': instance.context,
    };

_$ChatbotResponseImpl _$$ChatbotResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatbotResponseImpl(
      responseId: json['responseId'] as String,
      message: json['message'] as String,
      quickReplies: (json['quickReplies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      intent: json['intent'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      requiresAgent: json['requiresAgent'] as bool?,
      escalationReason: json['escalationReason'] as String?,
    );

Map<String, dynamic> _$$ChatbotResponseImplToJson(
        _$ChatbotResponseImpl instance) =>
    <String, dynamic>{
      'responseId': instance.responseId,
      'message': instance.message,
      'quickReplies': instance.quickReplies,
      'intent': instance.intent,
      'confidence': instance.confidence,
      'metadata': instance.metadata,
      'requiresAgent': instance.requiresAgent,
      'escalationReason': instance.escalationReason,
    };

_$QuickReplyImpl _$$QuickReplyImplFromJson(Map<String, dynamic> json) =>
    _$QuickReplyImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      payload: json['payload'] as String?,
      action: json['action'] as String?,
    );

Map<String, dynamic> _$$QuickReplyImplToJson(_$QuickReplyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'payload': instance.payload,
      'action': instance.action,
    };

_$ChatbotIntentImpl _$$ChatbotIntentImplFromJson(Map<String, dynamic> json) =>
    _$ChatbotIntentImpl(
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      entities: json['entities'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ChatbotIntentImplToJson(_$ChatbotIntentImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'confidence': instance.confidence,
      'entities': instance.entities,
      'metadata': instance.metadata,
    };
