import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable(explicitToJson: true)
class Comment {
  final int id;
  final String text;
  final int postId;
  final int userId;
  final int? parentId;

  @JsonKey(defaultValue: 0)
  int likesCount;

  @JsonKey(defaultValue: [])
  final List<int> likedBy;

  @JsonKey(defaultValue: false)
  bool isLikedByUser;

  @JsonKey(defaultValue: [])
  List<Comment> replies;

  final DateTime createdAt;

  @JsonKey(name: "user")
  final CommentUser? user;

  Comment({
    required this.id,
    required this.text,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.likesCount,
    required this.likedBy,
    this.isLikedByUser = false,
    this.replies = const [],
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
@JsonSerializable()
class CommentUser {
  final int id;

  @JsonKey(name: "fullName")
  final String fullName;

  @JsonKey(name: "image_url")
  final dynamic imageUrl; // <-- IMPORTANT

  CommentUser({
    required this.id,
    required this.fullName,
    this.imageUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) =>
      _$CommentUserFromJson(json);

  Map<String, dynamic> toJson() => _$CommentUserToJson(this);
}
