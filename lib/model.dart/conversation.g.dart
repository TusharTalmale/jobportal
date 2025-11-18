// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: json['id'] as String,
  userId: (json['userId'] as num).toInt(),
  companyId: (json['companyId'] as num).toInt(),
  company:
      json['Company'] == null
          ? null
          : Company.fromJson(json['Company'] as Map<String, dynamic>),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'companyId': instance.companyId,
      'Company': instance.company?.toJson(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'unreadCount': instance.unreadCount,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
