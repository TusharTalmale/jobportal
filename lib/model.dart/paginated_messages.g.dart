// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_messages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedMessages _$PaginatedMessagesFromJson(Map<String, dynamic> json) =>
    PaginatedMessages(
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      messages:
          (json['messages'] as List<dynamic>)
              .map((e) => Message.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$PaginatedMessagesToJson(PaginatedMessages instance) =>
    <String, dynamic>{
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };
