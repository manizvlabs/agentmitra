// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      priority: $enumDecode(_$NotificationPriorityEnumMap, json['priority']),
      isRead: json['isRead'] as bool? ?? false,
      actionUrl: json['actionUrl'] as String?,
      actionRoute: json['actionRoute'] as String?,
      actionText: json['actionText'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      senderId: json['senderId'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$NotificationModelImplToJson(
        _$NotificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'priority': _$NotificationPriorityEnumMap[instance.priority]!,
      'isRead': instance.isRead,
      'actionUrl': instance.actionUrl,
      'actionRoute': instance.actionRoute,
      'actionText': instance.actionText,
      'imageUrl': instance.imageUrl,
      'data': instance.data,
      'senderId': instance.senderId,
      'category': instance.category,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.policy: 'policy',
  NotificationType.payment: 'payment',
  NotificationType.claim: 'claim',
  NotificationType.renewal: 'renewal',
  NotificationType.general: 'general',
  NotificationType.marketing: 'marketing',
  NotificationType.system: 'system',
};

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.medium: 'medium',
  NotificationPriority.high: 'high',
  NotificationPriority.critical: 'critical',
};

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsImpl(
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      enablePolicyNotifications:
          json['enablePolicyNotifications'] as bool? ?? true,
      enablePaymentReminders: json['enablePaymentReminders'] as bool? ?? true,
      enableClaimUpdates: json['enableClaimUpdates'] as bool? ?? true,
      enableRenewalNotices: json['enableRenewalNotices'] as bool? ?? true,
      enableMarketingNotifications:
          json['enableMarketingNotifications'] as bool? ?? false,
      enableSound: json['enableSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      showBadge: json['showBadge'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      enabledTopics: (json['enabledTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['en'],
    );

Map<String, dynamic> _$$NotificationSettingsImplToJson(
        _$NotificationSettingsImpl instance) =>
    <String, dynamic>{
      'enablePushNotifications': instance.enablePushNotifications,
      'enablePolicyNotifications': instance.enablePolicyNotifications,
      'enablePaymentReminders': instance.enablePaymentReminders,
      'enableClaimUpdates': instance.enableClaimUpdates,
      'enableRenewalNotices': instance.enableRenewalNotices,
      'enableMarketingNotifications': instance.enableMarketingNotifications,
      'enableSound': instance.enableSound,
      'enableVibration': instance.enableVibration,
      'showBadge': instance.showBadge,
      'quietHoursEnabled': instance.quietHoursEnabled,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'enabledTopics': instance.enabledTopics,
    };

_$NotificationHistoryImpl _$$NotificationHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationHistoryImpl(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastSync: DateTime.parse(json['lastSync'] as String),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$NotificationHistoryImplToJson(
        _$NotificationHistoryImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'lastSync': instance.lastSync.toIso8601String(),
      'totalCount': instance.totalCount,
      'unreadCount': instance.unreadCount,
    };
