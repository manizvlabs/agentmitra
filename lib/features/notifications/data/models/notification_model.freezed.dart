// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) {
  return _NotificationModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;
  String? get actionRoute => throw _privateConstructorUsedError;
  String? get actionText => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) then) =
      _$NotificationModelCopyWithImpl<$Res, NotificationModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      DateTime timestamp,
      NotificationType type,
      NotificationPriority priority,
      bool isRead,
      String? actionUrl,
      String? actionRoute,
      String? actionText,
      String? imageUrl,
      Map<String, dynamic>? data,
      String? senderId,
      String? category});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res, $Val extends NotificationModel>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? timestamp = null,
    Object? type = null,
    Object? priority = null,
    Object? isRead = null,
    Object? actionUrl = freezed,
    Object? actionRoute = freezed,
    Object? actionText = freezed,
    Object? imageUrl = freezed,
    Object? data = freezed,
    Object? senderId = freezed,
    Object? category = freezed,
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
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionText: freezed == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationModelImplCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$$NotificationModelImplCopyWith(_$NotificationModelImpl value,
          $Res Function(_$NotificationModelImpl) then) =
      __$$NotificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String body,
      DateTime timestamp,
      NotificationType type,
      NotificationPriority priority,
      bool isRead,
      String? actionUrl,
      String? actionRoute,
      String? actionText,
      String? imageUrl,
      Map<String, dynamic>? data,
      String? senderId,
      String? category});
}

/// @nodoc
class __$$NotificationModelImplCopyWithImpl<$Res>
    extends _$NotificationModelCopyWithImpl<$Res, _$NotificationModelImpl>
    implements _$$NotificationModelImplCopyWith<$Res> {
  __$$NotificationModelImplCopyWithImpl(_$NotificationModelImpl _value,
      $Res Function(_$NotificationModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? timestamp = null,
    Object? type = null,
    Object? priority = null,
    Object? isRead = null,
    Object? actionUrl = freezed,
    Object? actionRoute = freezed,
    Object? actionText = freezed,
    Object? imageUrl = freezed,
    Object? data = freezed,
    Object? senderId = freezed,
    Object? category = freezed,
  }) {
    return _then(_$NotificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as NotificationPriority,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionText: freezed == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationModelImpl extends _NotificationModel {
  const _$NotificationModelImpl(
      {required this.id,
      required this.title,
      required this.body,
      required this.timestamp,
      required this.type,
      required this.priority,
      this.isRead = false,
      this.actionUrl,
      this.actionRoute,
      this.actionText,
      this.imageUrl,
      final Map<String, dynamic>? data,
      this.senderId,
      this.category})
      : _data = data,
        super._();

  factory _$NotificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime timestamp;
  @override
  final NotificationType type;
  @override
  final NotificationPriority priority;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? actionUrl;
  @override
  final String? actionRoute;
  @override
  final String? actionText;
  @override
  final String? imageUrl;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? senderId;
  @override
  final String? category;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, timestamp: $timestamp, type: $type, priority: $priority, isRead: $isRead, actionUrl: $actionUrl, actionRoute: $actionRoute, actionText: $actionText, imageUrl: $imageUrl, data: $data, senderId: $senderId, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl) &&
            (identical(other.actionRoute, actionRoute) ||
                other.actionRoute == actionRoute) &&
            (identical(other.actionText, actionText) ||
                other.actionText == actionText) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      timestamp,
      type,
      priority,
      isRead,
      actionUrl,
      actionRoute,
      actionText,
      imageUrl,
      const DeepCollectionEquality().hash(_data),
      senderId,
      category);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      __$$NotificationModelImplCopyWithImpl<_$NotificationModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationModel extends NotificationModel {
  const factory _NotificationModel(
      {required final String id,
      required final String title,
      required final String body,
      required final DateTime timestamp,
      required final NotificationType type,
      required final NotificationPriority priority,
      final bool isRead,
      final String? actionUrl,
      final String? actionRoute,
      final String? actionText,
      final String? imageUrl,
      final Map<String, dynamic>? data,
      final String? senderId,
      final String? category}) = _$NotificationModelImpl;
  const _NotificationModel._() : super._();

  factory _NotificationModel.fromJson(Map<String, dynamic> json) =
      _$NotificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime get timestamp;
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  bool get isRead;
  @override
  String? get actionUrl;
  @override
  String? get actionRoute;
  @override
  String? get actionText;
  @override
  String? get imageUrl;
  @override
  Map<String, dynamic>? get data;
  @override
  String? get senderId;
  @override
  String? get category;
  @override
  @JsonKey(ignore: true)
  _$$NotificationModelImplCopyWith<_$NotificationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationSettings _$NotificationSettingsFromJson(Map<String, dynamic> json) {
  return _NotificationSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationSettings {
  bool get enablePushNotifications => throw _privateConstructorUsedError;
  bool get enablePolicyNotifications => throw _privateConstructorUsedError;
  bool get enablePaymentReminders => throw _privateConstructorUsedError;
  bool get enableClaimUpdates => throw _privateConstructorUsedError;
  bool get enableRenewalNotices => throw _privateConstructorUsedError;
  bool get enableMarketingNotifications => throw _privateConstructorUsedError;
  bool get enableSound => throw _privateConstructorUsedError;
  bool get enableVibration => throw _privateConstructorUsedError;
  bool get showBadge => throw _privateConstructorUsedError;
  bool get quietHoursEnabled => throw _privateConstructorUsedError;
  String? get quietHoursStart =>
      throw _privateConstructorUsedError; // HH:MM format
  String? get quietHoursEnd =>
      throw _privateConstructorUsedError; // HH:MM format
  List<String> get enabledTopics => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationSettingsCopyWith<NotificationSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSettingsCopyWith<$Res> {
  factory $NotificationSettingsCopyWith(NotificationSettings value,
          $Res Function(NotificationSettings) then) =
      _$NotificationSettingsCopyWithImpl<$Res, NotificationSettings>;
  @useResult
  $Res call(
      {bool enablePushNotifications,
      bool enablePolicyNotifications,
      bool enablePaymentReminders,
      bool enableClaimUpdates,
      bool enableRenewalNotices,
      bool enableMarketingNotifications,
      bool enableSound,
      bool enableVibration,
      bool showBadge,
      bool quietHoursEnabled,
      String? quietHoursStart,
      String? quietHoursEnd,
      List<String> enabledTopics});
}

/// @nodoc
class _$NotificationSettingsCopyWithImpl<$Res,
        $Val extends NotificationSettings>
    implements $NotificationSettingsCopyWith<$Res> {
  _$NotificationSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enablePushNotifications = null,
    Object? enablePolicyNotifications = null,
    Object? enablePaymentReminders = null,
    Object? enableClaimUpdates = null,
    Object? enableRenewalNotices = null,
    Object? enableMarketingNotifications = null,
    Object? enableSound = null,
    Object? enableVibration = null,
    Object? showBadge = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
    Object? enabledTopics = null,
  }) {
    return _then(_value.copyWith(
      enablePushNotifications: null == enablePushNotifications
          ? _value.enablePushNotifications
          : enablePushNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePolicyNotifications: null == enablePolicyNotifications
          ? _value.enablePolicyNotifications
          : enablePolicyNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePaymentReminders: null == enablePaymentReminders
          ? _value.enablePaymentReminders
          : enablePaymentReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enableClaimUpdates: null == enableClaimUpdates
          ? _value.enableClaimUpdates
          : enableClaimUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRenewalNotices: null == enableRenewalNotices
          ? _value.enableRenewalNotices
          : enableRenewalNotices // ignore: cast_nullable_to_non_nullable
              as bool,
      enableMarketingNotifications: null == enableMarketingNotifications
          ? _value.enableMarketingNotifications
          : enableMarketingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSound: null == enableSound
          ? _value.enableSound
          : enableSound // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _value.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      showBadge: null == showBadge
          ? _value.showBadge
          : showBadge // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: freezed == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as String?,
      quietHoursEnd: freezed == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledTopics: null == enabledTopics
          ? _value.enabledTopics
          : enabledTopics // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationSettingsImplCopyWith<$Res>
    implements $NotificationSettingsCopyWith<$Res> {
  factory _$$NotificationSettingsImplCopyWith(_$NotificationSettingsImpl value,
          $Res Function(_$NotificationSettingsImpl) then) =
      __$$NotificationSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool enablePushNotifications,
      bool enablePolicyNotifications,
      bool enablePaymentReminders,
      bool enableClaimUpdates,
      bool enableRenewalNotices,
      bool enableMarketingNotifications,
      bool enableSound,
      bool enableVibration,
      bool showBadge,
      bool quietHoursEnabled,
      String? quietHoursStart,
      String? quietHoursEnd,
      List<String> enabledTopics});
}

/// @nodoc
class __$$NotificationSettingsImplCopyWithImpl<$Res>
    extends _$NotificationSettingsCopyWithImpl<$Res, _$NotificationSettingsImpl>
    implements _$$NotificationSettingsImplCopyWith<$Res> {
  __$$NotificationSettingsImplCopyWithImpl(_$NotificationSettingsImpl _value,
      $Res Function(_$NotificationSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enablePushNotifications = null,
    Object? enablePolicyNotifications = null,
    Object? enablePaymentReminders = null,
    Object? enableClaimUpdates = null,
    Object? enableRenewalNotices = null,
    Object? enableMarketingNotifications = null,
    Object? enableSound = null,
    Object? enableVibration = null,
    Object? showBadge = null,
    Object? quietHoursEnabled = null,
    Object? quietHoursStart = freezed,
    Object? quietHoursEnd = freezed,
    Object? enabledTopics = null,
  }) {
    return _then(_$NotificationSettingsImpl(
      enablePushNotifications: null == enablePushNotifications
          ? _value.enablePushNotifications
          : enablePushNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePolicyNotifications: null == enablePolicyNotifications
          ? _value.enablePolicyNotifications
          : enablePolicyNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enablePaymentReminders: null == enablePaymentReminders
          ? _value.enablePaymentReminders
          : enablePaymentReminders // ignore: cast_nullable_to_non_nullable
              as bool,
      enableClaimUpdates: null == enableClaimUpdates
          ? _value.enableClaimUpdates
          : enableClaimUpdates // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRenewalNotices: null == enableRenewalNotices
          ? _value.enableRenewalNotices
          : enableRenewalNotices // ignore: cast_nullable_to_non_nullable
              as bool,
      enableMarketingNotifications: null == enableMarketingNotifications
          ? _value.enableMarketingNotifications
          : enableMarketingNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      enableSound: null == enableSound
          ? _value.enableSound
          : enableSound // ignore: cast_nullable_to_non_nullable
              as bool,
      enableVibration: null == enableVibration
          ? _value.enableVibration
          : enableVibration // ignore: cast_nullable_to_non_nullable
              as bool,
      showBadge: null == showBadge
          ? _value.showBadge
          : showBadge // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursEnabled: null == quietHoursEnabled
          ? _value.quietHoursEnabled
          : quietHoursEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      quietHoursStart: freezed == quietHoursStart
          ? _value.quietHoursStart
          : quietHoursStart // ignore: cast_nullable_to_non_nullable
              as String?,
      quietHoursEnd: freezed == quietHoursEnd
          ? _value.quietHoursEnd
          : quietHoursEnd // ignore: cast_nullable_to_non_nullable
              as String?,
      enabledTopics: null == enabledTopics
          ? _value._enabledTopics
          : enabledTopics // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSettingsImpl extends _NotificationSettings {
  const _$NotificationSettingsImpl(
      {this.enablePushNotifications = true,
      this.enablePolicyNotifications = true,
      this.enablePaymentReminders = true,
      this.enableClaimUpdates = true,
      this.enableRenewalNotices = true,
      this.enableMarketingNotifications = false,
      this.enableSound = true,
      this.enableVibration = true,
      this.showBadge = true,
      this.quietHoursEnabled = false,
      this.quietHoursStart,
      this.quietHoursEnd,
      final List<String> enabledTopics = const ['en']})
      : _enabledTopics = enabledTopics,
        super._();

  factory _$NotificationSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool enablePushNotifications;
  @override
  @JsonKey()
  final bool enablePolicyNotifications;
  @override
  @JsonKey()
  final bool enablePaymentReminders;
  @override
  @JsonKey()
  final bool enableClaimUpdates;
  @override
  @JsonKey()
  final bool enableRenewalNotices;
  @override
  @JsonKey()
  final bool enableMarketingNotifications;
  @override
  @JsonKey()
  final bool enableSound;
  @override
  @JsonKey()
  final bool enableVibration;
  @override
  @JsonKey()
  final bool showBadge;
  @override
  @JsonKey()
  final bool quietHoursEnabled;
  @override
  final String? quietHoursStart;
// HH:MM format
  @override
  final String? quietHoursEnd;
// HH:MM format
  final List<String> _enabledTopics;
// HH:MM format
  @override
  @JsonKey()
  List<String> get enabledTopics {
    if (_enabledTopics is EqualUnmodifiableListView) return _enabledTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabledTopics);
  }

  @override
  String toString() {
    return 'NotificationSettings(enablePushNotifications: $enablePushNotifications, enablePolicyNotifications: $enablePolicyNotifications, enablePaymentReminders: $enablePaymentReminders, enableClaimUpdates: $enableClaimUpdates, enableRenewalNotices: $enableRenewalNotices, enableMarketingNotifications: $enableMarketingNotifications, enableSound: $enableSound, enableVibration: $enableVibration, showBadge: $showBadge, quietHoursEnabled: $quietHoursEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, enabledTopics: $enabledTopics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSettingsImpl &&
            (identical(
                    other.enablePushNotifications, enablePushNotifications) ||
                other.enablePushNotifications == enablePushNotifications) &&
            (identical(other.enablePolicyNotifications,
                    enablePolicyNotifications) ||
                other.enablePolicyNotifications == enablePolicyNotifications) &&
            (identical(other.enablePaymentReminders, enablePaymentReminders) ||
                other.enablePaymentReminders == enablePaymentReminders) &&
            (identical(other.enableClaimUpdates, enableClaimUpdates) ||
                other.enableClaimUpdates == enableClaimUpdates) &&
            (identical(other.enableRenewalNotices, enableRenewalNotices) ||
                other.enableRenewalNotices == enableRenewalNotices) &&
            (identical(other.enableMarketingNotifications,
                    enableMarketingNotifications) ||
                other.enableMarketingNotifications ==
                    enableMarketingNotifications) &&
            (identical(other.enableSound, enableSound) ||
                other.enableSound == enableSound) &&
            (identical(other.enableVibration, enableVibration) ||
                other.enableVibration == enableVibration) &&
            (identical(other.showBadge, showBadge) ||
                other.showBadge == showBadge) &&
            (identical(other.quietHoursEnabled, quietHoursEnabled) ||
                other.quietHoursEnabled == quietHoursEnabled) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            const DeepCollectionEquality()
                .equals(other._enabledTopics, _enabledTopics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enablePushNotifications,
      enablePolicyNotifications,
      enablePaymentReminders,
      enableClaimUpdates,
      enableRenewalNotices,
      enableMarketingNotifications,
      enableSound,
      enableVibration,
      showBadge,
      quietHoursEnabled,
      quietHoursStart,
      quietHoursEnd,
      const DeepCollectionEquality().hash(_enabledTopics));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith =>
          __$$NotificationSettingsImplCopyWithImpl<_$NotificationSettingsImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSettingsImplToJson(
      this,
    );
  }
}

abstract class _NotificationSettings extends NotificationSettings {
  const factory _NotificationSettings(
      {final bool enablePushNotifications,
      final bool enablePolicyNotifications,
      final bool enablePaymentReminders,
      final bool enableClaimUpdates,
      final bool enableRenewalNotices,
      final bool enableMarketingNotifications,
      final bool enableSound,
      final bool enableVibration,
      final bool showBadge,
      final bool quietHoursEnabled,
      final String? quietHoursStart,
      final String? quietHoursEnd,
      final List<String> enabledTopics}) = _$NotificationSettingsImpl;
  const _NotificationSettings._() : super._();

  factory _NotificationSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationSettingsImpl.fromJson;

  @override
  bool get enablePushNotifications;
  @override
  bool get enablePolicyNotifications;
  @override
  bool get enablePaymentReminders;
  @override
  bool get enableClaimUpdates;
  @override
  bool get enableRenewalNotices;
  @override
  bool get enableMarketingNotifications;
  @override
  bool get enableSound;
  @override
  bool get enableVibration;
  @override
  bool get showBadge;
  @override
  bool get quietHoursEnabled;
  @override
  String? get quietHoursStart;
  @override // HH:MM format
  String? get quietHoursEnd;
  @override // HH:MM format
  List<String> get enabledTopics;
  @override
  @JsonKey(ignore: true)
  _$$NotificationSettingsImplCopyWith<_$NotificationSettingsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

NotificationHistory _$NotificationHistoryFromJson(Map<String, dynamic> json) {
  return _NotificationHistory.fromJson(json);
}

/// @nodoc
mixin _$NotificationHistory {
  List<NotificationModel> get notifications =>
      throw _privateConstructorUsedError;
  DateTime get lastSync => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NotificationHistoryCopyWith<NotificationHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationHistoryCopyWith<$Res> {
  factory $NotificationHistoryCopyWith(
          NotificationHistory value, $Res Function(NotificationHistory) then) =
      _$NotificationHistoryCopyWithImpl<$Res, NotificationHistory>;
  @useResult
  $Res call(
      {List<NotificationModel> notifications,
      DateTime lastSync,
      int totalCount,
      int unreadCount});
}

/// @nodoc
class _$NotificationHistoryCopyWithImpl<$Res, $Val extends NotificationHistory>
    implements $NotificationHistoryCopyWith<$Res> {
  _$NotificationHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? lastSync = null,
    Object? totalCount = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationModel>,
      lastSync: null == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationHistoryImplCopyWith<$Res>
    implements $NotificationHistoryCopyWith<$Res> {
  factory _$$NotificationHistoryImplCopyWith(_$NotificationHistoryImpl value,
          $Res Function(_$NotificationHistoryImpl) then) =
      __$$NotificationHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<NotificationModel> notifications,
      DateTime lastSync,
      int totalCount,
      int unreadCount});
}

/// @nodoc
class __$$NotificationHistoryImplCopyWithImpl<$Res>
    extends _$NotificationHistoryCopyWithImpl<$Res, _$NotificationHistoryImpl>
    implements _$$NotificationHistoryImplCopyWith<$Res> {
  __$$NotificationHistoryImplCopyWithImpl(_$NotificationHistoryImpl _value,
      $Res Function(_$NotificationHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? lastSync = null,
    Object? totalCount = null,
    Object? unreadCount = null,
  }) {
    return _then(_$NotificationHistoryImpl(
      notifications: null == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationModel>,
      lastSync: null == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalCount: null == totalCount
          ? _value.totalCount
          : totalCount // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationHistoryImpl extends _NotificationHistory {
  const _$NotificationHistoryImpl(
      {required final List<NotificationModel> notifications,
      required this.lastSync,
      this.totalCount = 0,
      this.unreadCount = 0})
      : _notifications = notifications,
        super._();

  factory _$NotificationHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationHistoryImplFromJson(json);

  final List<NotificationModel> _notifications;
  @override
  List<NotificationModel> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  final DateTime lastSync;
  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int unreadCount;

  @override
  String toString() {
    return 'NotificationHistory(notifications: $notifications, lastSync: $lastSync, totalCount: $totalCount, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationHistoryImpl &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.lastSync, lastSync) ||
                other.lastSync == lastSync) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_notifications),
      lastSync,
      totalCount,
      unreadCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationHistoryImplCopyWith<_$NotificationHistoryImpl> get copyWith =>
      __$$NotificationHistoryImplCopyWithImpl<_$NotificationHistoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationHistoryImplToJson(
      this,
    );
  }
}

abstract class _NotificationHistory extends NotificationHistory {
  const factory _NotificationHistory(
      {required final List<NotificationModel> notifications,
      required final DateTime lastSync,
      final int totalCount,
      final int unreadCount}) = _$NotificationHistoryImpl;
  const _NotificationHistory._() : super._();

  factory _NotificationHistory.fromJson(Map<String, dynamic> json) =
      _$NotificationHistoryImpl.fromJson;

  @override
  List<NotificationModel> get notifications;
  @override
  DateTime get lastSync;
  @override
  int get totalCount;
  @override
  int get unreadCount;
  @override
  @JsonKey(ignore: true)
  _$$NotificationHistoryImplCopyWith<_$NotificationHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
