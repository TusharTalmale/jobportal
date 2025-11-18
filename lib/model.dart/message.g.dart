// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: (json['id'] as num).toInt(),
  conversationId: json['conversationId'] as String,
  senderId: (json['senderId'] as num).toInt(),
  senderType: $enumDecode(_$MessageSenderEnumMap, json['senderType']),
  messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
  text: json['text'] as String?,
  repliedToMessageId: (json['repliedToMessageId'] as num?)?.toInt(),
  fileUrl: json['fileUrl'] as String?,
  fileName: json['fileName'] as String?,
  jobId: (json['jobId'] as num?)?.toInt(),
  readAt:
      json['readAt'] == null ? null : DateTime.parse(json['readAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  jobData:
      json['Job'] == null
          ? null
          : Job.fromJson(json['Job'] as Map<String, dynamic>),
  repliedTo:
      json['RepliedTo'] == null
          ? null
          : Message.fromJson(json['RepliedTo'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversationId': instance.conversationId,
  'senderId': instance.senderId,
  'senderType': _$MessageSenderEnumMap[instance.senderType]!,
  'messageType': _$MessageTypeEnumMap[instance.messageType]!,
  'text': instance.text,
  'repliedToMessageId': instance.repliedToMessageId,
  'fileUrl': instance.fileUrl,
  'fileName': instance.fileName,
  'jobId': instance.jobId,
  'readAt': instance.readAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'Job': instance.jobData?.toJson(),
  'RepliedTo': instance.repliedTo?.toJson(),
};

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.company: 'company',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.file: 'file',
  MessageType.job: 'job',
};
