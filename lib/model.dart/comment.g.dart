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
  isLikedByUser: json['isLikedByUser'] as bool? ?? false,
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  user:
      json['user'] == null
          ? null
          : CommentUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'postId': instance.postId,
  'userId': instance.userId,
  'parentId': instance.parentId,
  'likesCount': instance.likesCount,
  'likedBy': instance.likedBy,
  'isLikedByUser': instance.isLikedByUser,
  'replies': instance.replies.map((e) => e.toJson()).toList(),
  'createdAt': instance.createdAt.toIso8601String(),
  'user': instance.user?.toJson(),
};

CommentUser _$CommentUserFromJson(Map<String, dynamic> json) => CommentUser(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  imageUrl: json['image_url'],
);

Map<String, dynamic> _$CommentUserToJson(CommentUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'image_url': instance.imageUrl,
    };
