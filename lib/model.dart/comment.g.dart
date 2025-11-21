// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
  id: (json['id'] as num).toInt(),
  text: json['text'] as String,
  postId: (json['postId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  parentId: (json['parentId'] as num?)?.toInt(),
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  likedBy:
      (json['likedBy'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  mentionedUserIds:
      (json['mentionedUserIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  user:
      json['user'] == null
          ? null
          : UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'postId': instance.postId,
  'userId': instance.userId,
  'parentId': instance.parentId,
  'likesCount': instance.likesCount,
  'likedBy': instance.likedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'mentionedUserIds': instance.mentionedUserIds,
  'user': instance.user?.toJson(),
  'replies': instance.replies?.map((e) => e.toJson()).toList(),
};

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String?,
  profilePicture: json['profilePicture'] as String?,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'profilePicture': instance.profilePicture,
};
