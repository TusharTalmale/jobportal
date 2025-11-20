// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationComment _$JobApplicationCommentFromJson(
  Map<String, dynamic> json,
) => JobApplicationComment(
  id: json['id'],
  text: json['text'] as String,
  authorId: (json['authorId'] as num?)?.toInt(),
  authorName: json['authorName'] as String?,
  status: json['status'] as String? ?? 'visible',
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$JobApplicationCommentToJson(
  JobApplicationComment instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'status': instance.status,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
