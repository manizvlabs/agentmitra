// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chatbot_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get messageId => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError; // 'user' or 'bot'
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get messageType =>
      throw _privateConstructorUsedError; // 'text', 'quick_reply', 'suggestion'
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool? get isRead => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String messageId,
      String sessionId,
      String content,
      String sender,
      DateTime timestamp,
      String? messageType,
      Map<String, dynamic>? metadata,
      bool? isRead});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? sessionId = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? messageType = freezed,
    Object? metadata = freezed,
    Object? isRead = freezed,
  }) {
    return _then(_value.copyWith(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messageType: freezed == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String messageId,
      String sessionId,
      String content,
      String sender,
      DateTime timestamp,
      String? messageType,
      Map<String, dynamic>? metadata,
      bool? isRead});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
    Object? sessionId = null,
    Object? content = null,
    Object? sender = null,
    Object? timestamp = null,
    Object? messageType = freezed,
    Object? metadata = freezed,
    Object? isRead = freezed,
  }) {
    return _then(_$ChatMessageImpl(
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      messageType: freezed == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isRead: freezed == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.messageId,
      required this.sessionId,
      required this.content,
      required this.sender,
      required this.timestamp,
      this.messageType,
      final Map<String, dynamic>? metadata,
      this.isRead})
      : _metadata = metadata;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String messageId;
  @override
  final String sessionId;
  @override
  final String content;
  @override
  final String sender;
// 'user' or 'bot'
  @override
  final DateTime timestamp;
  @override
  final String? messageType;
// 'text', 'quick_reply', 'suggestion'
  final Map<String, dynamic>? _metadata;
// 'text', 'quick_reply', 'suggestion'
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? isRead;

  @override
  String toString() {
    return 'ChatMessage(messageId: $messageId, sessionId: $sessionId, content: $content, sender: $sender, timestamp: $timestamp, messageType: $messageType, metadata: $metadata, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      messageId,
      sessionId,
      content,
      sender,
      timestamp,
      messageType,
      const DeepCollectionEquality().hash(_metadata),
      isRead);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String messageId,
      required final String sessionId,
      required final String content,
      required final String sender,
      required final DateTime timestamp,
      final String? messageType,
      final Map<String, dynamic>? metadata,
      final bool? isRead}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get messageId;
  @override
  String get sessionId;
  @override
  String get content;
  @override
  String get sender;
  @override // 'user' or 'bot'
  DateTime get timestamp;
  @override
  String? get messageType;
  @override // 'text', 'quick_reply', 'suggestion'
  Map<String, dynamic>? get metadata;
  @override
  bool? get isRead;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) {
  return _ChatSession.fromJson(json);
}

/// @nodoc
mixin _$ChatSession {
  String get sessionId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String? get customerId => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  String? get status =>
      throw _privateConstructorUsedError; // 'active', 'ended', 'transferred'
  String? get topic => throw _privateConstructorUsedError;
  int? get messageCount => throw _privateConstructorUsedError;
  Map<String, dynamic>? get context => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatSessionCopyWith<ChatSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSessionCopyWith<$Res> {
  factory $ChatSessionCopyWith(
          ChatSession value, $Res Function(ChatSession) then) =
      _$ChatSessionCopyWithImpl<$Res, ChatSession>;
  @useResult
  $Res call(
      {String sessionId,
      String agentId,
      String? customerId,
      DateTime startedAt,
      DateTime? endedAt,
      String? status,
      String? topic,
      int? messageCount,
      Map<String, dynamic>? context});
}

/// @nodoc
class _$ChatSessionCopyWithImpl<$Res, $Val extends ChatSession>
    implements $ChatSessionCopyWith<$Res> {
  _$ChatSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? agentId = null,
    Object? customerId = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = freezed,
    Object? topic = freezed,
    Object? messageCount = freezed,
    Object? context = freezed,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCount: freezed == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatSessionImplCopyWith<$Res>
    implements $ChatSessionCopyWith<$Res> {
  factory _$$ChatSessionImplCopyWith(
          _$ChatSessionImpl value, $Res Function(_$ChatSessionImpl) then) =
      __$$ChatSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      String agentId,
      String? customerId,
      DateTime startedAt,
      DateTime? endedAt,
      String? status,
      String? topic,
      int? messageCount,
      Map<String, dynamic>? context});
}

/// @nodoc
class __$$ChatSessionImplCopyWithImpl<$Res>
    extends _$ChatSessionCopyWithImpl<$Res, _$ChatSessionImpl>
    implements _$$ChatSessionImplCopyWith<$Res> {
  __$$ChatSessionImplCopyWithImpl(
      _$ChatSessionImpl _value, $Res Function(_$ChatSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? agentId = null,
    Object? customerId = freezed,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? status = freezed,
    Object? topic = freezed,
    Object? messageCount = freezed,
    Object? context = freezed,
  }) {
    return _then(_$ChatSessionImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      agentId: null == agentId
          ? _value.agentId
          : agentId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: freezed == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: freezed == endedAt
          ? _value.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      topic: freezed == topic
          ? _value.topic
          : topic // ignore: cast_nullable_to_non_nullable
              as String?,
      messageCount: freezed == messageCount
          ? _value.messageCount
          : messageCount // ignore: cast_nullable_to_non_nullable
              as int?,
      context: freezed == context
          ? _value._context
          : context // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatSessionImpl implements _ChatSession {
  const _$ChatSessionImpl(
      {required this.sessionId,
      required this.agentId,
      this.customerId,
      required this.startedAt,
      this.endedAt,
      this.status,
      this.topic,
      this.messageCount,
      final Map<String, dynamic>? context})
      : _context = context;

  factory _$ChatSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSessionImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String agentId;
  @override
  final String? customerId;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final String? status;
// 'active', 'ended', 'transferred'
  @override
  final String? topic;
  @override
  final int? messageCount;
  final Map<String, dynamic>? _context;
  @override
  Map<String, dynamic>? get context {
    final value = _context;
    if (value == null) return null;
    if (_context is EqualUnmodifiableMapView) return _context;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChatSession(sessionId: $sessionId, agentId: $agentId, customerId: $customerId, startedAt: $startedAt, endedAt: $endedAt, status: $status, topic: $topic, messageCount: $messageCount, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSessionImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.messageCount, messageCount) ||
                other.messageCount == messageCount) &&
            const DeepCollectionEquality().equals(other._context, _context));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      agentId,
      customerId,
      startedAt,
      endedAt,
      status,
      topic,
      messageCount,
      const DeepCollectionEquality().hash(_context));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      __$$ChatSessionImplCopyWithImpl<_$ChatSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSessionImplToJson(
      this,
    );
  }
}

abstract class _ChatSession implements ChatSession {
  const factory _ChatSession(
      {required final String sessionId,
      required final String agentId,
      final String? customerId,
      required final DateTime startedAt,
      final DateTime? endedAt,
      final String? status,
      final String? topic,
      final int? messageCount,
      final Map<String, dynamic>? context}) = _$ChatSessionImpl;

  factory _ChatSession.fromJson(Map<String, dynamic> json) =
      _$ChatSessionImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get agentId;
  @override
  String? get customerId;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  String? get status;
  @override // 'active', 'ended', 'transferred'
  String? get topic;
  @override
  int? get messageCount;
  @override
  Map<String, dynamic>? get context;
  @override
  @JsonKey(ignore: true)
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatbotResponse _$ChatbotResponseFromJson(Map<String, dynamic> json) {
  return _ChatbotResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatbotResponse {
  String get responseId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String>? get quickReplies => throw _privateConstructorUsedError;
  String? get intent => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  bool? get requiresAgent => throw _privateConstructorUsedError;
  String? get escalationReason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatbotResponseCopyWith<ChatbotResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatbotResponseCopyWith<$Res> {
  factory $ChatbotResponseCopyWith(
          ChatbotResponse value, $Res Function(ChatbotResponse) then) =
      _$ChatbotResponseCopyWithImpl<$Res, ChatbotResponse>;
  @useResult
  $Res call(
      {String responseId,
      String message,
      List<String>? quickReplies,
      String? intent,
      double? confidence,
      Map<String, dynamic>? metadata,
      bool? requiresAgent,
      String? escalationReason});
}

/// @nodoc
class _$ChatbotResponseCopyWithImpl<$Res, $Val extends ChatbotResponse>
    implements $ChatbotResponseCopyWith<$Res> {
  _$ChatbotResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responseId = null,
    Object? message = null,
    Object? quickReplies = freezed,
    Object? intent = freezed,
    Object? confidence = freezed,
    Object? metadata = freezed,
    Object? requiresAgent = freezed,
    Object? escalationReason = freezed,
  }) {
    return _then(_value.copyWith(
      responseId: null == responseId
          ? _value.responseId
          : responseId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      quickReplies: freezed == quickReplies
          ? _value.quickReplies
          : quickReplies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      intent: freezed == intent
          ? _value.intent
          : intent // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      requiresAgent: freezed == requiresAgent
          ? _value.requiresAgent
          : requiresAgent // ignore: cast_nullable_to_non_nullable
              as bool?,
      escalationReason: freezed == escalationReason
          ? _value.escalationReason
          : escalationReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatbotResponseImplCopyWith<$Res>
    implements $ChatbotResponseCopyWith<$Res> {
  factory _$$ChatbotResponseImplCopyWith(_$ChatbotResponseImpl value,
          $Res Function(_$ChatbotResponseImpl) then) =
      __$$ChatbotResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String responseId,
      String message,
      List<String>? quickReplies,
      String? intent,
      double? confidence,
      Map<String, dynamic>? metadata,
      bool? requiresAgent,
      String? escalationReason});
}

/// @nodoc
class __$$ChatbotResponseImplCopyWithImpl<$Res>
    extends _$ChatbotResponseCopyWithImpl<$Res, _$ChatbotResponseImpl>
    implements _$$ChatbotResponseImplCopyWith<$Res> {
  __$$ChatbotResponseImplCopyWithImpl(
      _$ChatbotResponseImpl _value, $Res Function(_$ChatbotResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? responseId = null,
    Object? message = null,
    Object? quickReplies = freezed,
    Object? intent = freezed,
    Object? confidence = freezed,
    Object? metadata = freezed,
    Object? requiresAgent = freezed,
    Object? escalationReason = freezed,
  }) {
    return _then(_$ChatbotResponseImpl(
      responseId: null == responseId
          ? _value.responseId
          : responseId // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      quickReplies: freezed == quickReplies
          ? _value._quickReplies
          : quickReplies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      intent: freezed == intent
          ? _value.intent
          : intent // ignore: cast_nullable_to_non_nullable
              as String?,
      confidence: freezed == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      requiresAgent: freezed == requiresAgent
          ? _value.requiresAgent
          : requiresAgent // ignore: cast_nullable_to_non_nullable
              as bool?,
      escalationReason: freezed == escalationReason
          ? _value.escalationReason
          : escalationReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatbotResponseImpl implements _ChatbotResponse {
  const _$ChatbotResponseImpl(
      {required this.responseId,
      required this.message,
      final List<String>? quickReplies,
      this.intent,
      this.confidence,
      final Map<String, dynamic>? metadata,
      this.requiresAgent,
      this.escalationReason})
      : _quickReplies = quickReplies,
        _metadata = metadata;

  factory _$ChatbotResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatbotResponseImplFromJson(json);

  @override
  final String responseId;
  @override
  final String message;
  final List<String>? _quickReplies;
  @override
  List<String>? get quickReplies {
    final value = _quickReplies;
    if (value == null) return null;
    if (_quickReplies is EqualUnmodifiableListView) return _quickReplies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? intent;
  @override
  final double? confidence;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final bool? requiresAgent;
  @override
  final String? escalationReason;

  @override
  String toString() {
    return 'ChatbotResponse(responseId: $responseId, message: $message, quickReplies: $quickReplies, intent: $intent, confidence: $confidence, metadata: $metadata, requiresAgent: $requiresAgent, escalationReason: $escalationReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatbotResponseImpl &&
            (identical(other.responseId, responseId) ||
                other.responseId == responseId) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality()
                .equals(other._quickReplies, _quickReplies) &&
            (identical(other.intent, intent) || other.intent == intent) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.requiresAgent, requiresAgent) ||
                other.requiresAgent == requiresAgent) &&
            (identical(other.escalationReason, escalationReason) ||
                other.escalationReason == escalationReason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      responseId,
      message,
      const DeepCollectionEquality().hash(_quickReplies),
      intent,
      confidence,
      const DeepCollectionEquality().hash(_metadata),
      requiresAgent,
      escalationReason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatbotResponseImplCopyWith<_$ChatbotResponseImpl> get copyWith =>
      __$$ChatbotResponseImplCopyWithImpl<_$ChatbotResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatbotResponseImplToJson(
      this,
    );
  }
}

abstract class _ChatbotResponse implements ChatbotResponse {
  const factory _ChatbotResponse(
      {required final String responseId,
      required final String message,
      final List<String>? quickReplies,
      final String? intent,
      final double? confidence,
      final Map<String, dynamic>? metadata,
      final bool? requiresAgent,
      final String? escalationReason}) = _$ChatbotResponseImpl;

  factory _ChatbotResponse.fromJson(Map<String, dynamic> json) =
      _$ChatbotResponseImpl.fromJson;

  @override
  String get responseId;
  @override
  String get message;
  @override
  List<String>? get quickReplies;
  @override
  String? get intent;
  @override
  double? get confidence;
  @override
  Map<String, dynamic>? get metadata;
  @override
  bool? get requiresAgent;
  @override
  String? get escalationReason;
  @override
  @JsonKey(ignore: true)
  _$$ChatbotResponseImplCopyWith<_$ChatbotResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuickReply _$QuickReplyFromJson(Map<String, dynamic> json) {
  return _QuickReply.fromJson(json);
}

/// @nodoc
mixin _$QuickReply {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get payload => throw _privateConstructorUsedError;
  String? get action => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuickReplyCopyWith<QuickReply> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuickReplyCopyWith<$Res> {
  factory $QuickReplyCopyWith(
          QuickReply value, $Res Function(QuickReply) then) =
      _$QuickReplyCopyWithImpl<$Res, QuickReply>;
  @useResult
  $Res call({String id, String title, String? payload, String? action});
}

/// @nodoc
class _$QuickReplyCopyWithImpl<$Res, $Val extends QuickReply>
    implements $QuickReplyCopyWith<$Res> {
  _$QuickReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? payload = freezed,
    Object? action = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuickReplyImplCopyWith<$Res>
    implements $QuickReplyCopyWith<$Res> {
  factory _$$QuickReplyImplCopyWith(
          _$QuickReplyImpl value, $Res Function(_$QuickReplyImpl) then) =
      __$$QuickReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String? payload, String? action});
}

/// @nodoc
class __$$QuickReplyImplCopyWithImpl<$Res>
    extends _$QuickReplyCopyWithImpl<$Res, _$QuickReplyImpl>
    implements _$$QuickReplyImplCopyWith<$Res> {
  __$$QuickReplyImplCopyWithImpl(
      _$QuickReplyImpl _value, $Res Function(_$QuickReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? payload = freezed,
    Object? action = freezed,
  }) {
    return _then(_$QuickReplyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuickReplyImpl implements _QuickReply {
  const _$QuickReplyImpl(
      {required this.id, required this.title, this.payload, this.action});

  factory _$QuickReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuickReplyImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? payload;
  @override
  final String? action;

  @override
  String toString() {
    return 'QuickReply(id: $id, title: $title, payload: $payload, action: $action)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuickReplyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.payload, payload) || other.payload == payload) &&
            (identical(other.action, action) || other.action == action));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, payload, action);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuickReplyImplCopyWith<_$QuickReplyImpl> get copyWith =>
      __$$QuickReplyImplCopyWithImpl<_$QuickReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuickReplyImplToJson(
      this,
    );
  }
}

abstract class _QuickReply implements QuickReply {
  const factory _QuickReply(
      {required final String id,
      required final String title,
      final String? payload,
      final String? action}) = _$QuickReplyImpl;

  factory _QuickReply.fromJson(Map<String, dynamic> json) =
      _$QuickReplyImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get payload;
  @override
  String? get action;
  @override
  @JsonKey(ignore: true)
  _$$QuickReplyImplCopyWith<_$QuickReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatbotIntent _$ChatbotIntentFromJson(Map<String, dynamic> json) {
  return _ChatbotIntent.fromJson(json);
}

/// @nodoc
mixin _$ChatbotIntent {
  String get name => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  Map<String, dynamic>? get entities => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatbotIntentCopyWith<ChatbotIntent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatbotIntentCopyWith<$Res> {
  factory $ChatbotIntentCopyWith(
          ChatbotIntent value, $Res Function(ChatbotIntent) then) =
      _$ChatbotIntentCopyWithImpl<$Res, ChatbotIntent>;
  @useResult
  $Res call(
      {String name,
      double confidence,
      Map<String, dynamic>? entities,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ChatbotIntentCopyWithImpl<$Res, $Val extends ChatbotIntent>
    implements $ChatbotIntentCopyWith<$Res> {
  _$ChatbotIntentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? confidence = null,
    Object? entities = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      entities: freezed == entities
          ? _value.entities
          : entities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatbotIntentImplCopyWith<$Res>
    implements $ChatbotIntentCopyWith<$Res> {
  factory _$$ChatbotIntentImplCopyWith(
          _$ChatbotIntentImpl value, $Res Function(_$ChatbotIntentImpl) then) =
      __$$ChatbotIntentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      double confidence,
      Map<String, dynamic>? entities,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ChatbotIntentImplCopyWithImpl<$Res>
    extends _$ChatbotIntentCopyWithImpl<$Res, _$ChatbotIntentImpl>
    implements _$$ChatbotIntentImplCopyWith<$Res> {
  __$$ChatbotIntentImplCopyWithImpl(
      _$ChatbotIntentImpl _value, $Res Function(_$ChatbotIntentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? confidence = null,
    Object? entities = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$ChatbotIntentImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      entities: freezed == entities
          ? _value._entities
          : entities // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatbotIntentImpl implements _ChatbotIntent {
  const _$ChatbotIntentImpl(
      {required this.name,
      required this.confidence,
      final Map<String, dynamic>? entities,
      final Map<String, dynamic>? metadata})
      : _entities = entities,
        _metadata = metadata;

  factory _$ChatbotIntentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatbotIntentImplFromJson(json);

  @override
  final String name;
  @override
  final double confidence;
  final Map<String, dynamic>? _entities;
  @override
  Map<String, dynamic>? get entities {
    final value = _entities;
    if (value == null) return null;
    if (_entities is EqualUnmodifiableMapView) return _entities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ChatbotIntent(name: $name, confidence: $confidence, entities: $entities, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatbotIntentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(other._entities, _entities) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      confidence,
      const DeepCollectionEquality().hash(_entities),
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatbotIntentImplCopyWith<_$ChatbotIntentImpl> get copyWith =>
      __$$ChatbotIntentImplCopyWithImpl<_$ChatbotIntentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatbotIntentImplToJson(
      this,
    );
  }
}

abstract class _ChatbotIntent implements ChatbotIntent {
  const factory _ChatbotIntent(
      {required final String name,
      required final double confidence,
      final Map<String, dynamic>? entities,
      final Map<String, dynamic>? metadata}) = _$ChatbotIntentImpl;

  factory _ChatbotIntent.fromJson(Map<String, dynamic> json) =
      _$ChatbotIntentImpl.fromJson;

  @override
  String get name;
  @override
  double get confidence;
  @override
  Map<String, dynamic>? get entities;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$ChatbotIntentImplCopyWith<_$ChatbotIntentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
