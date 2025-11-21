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
  @JsonKey(defaultValue: const [])
  List<int> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<int>? mentionedUserIds;

  // Nested data from API responses
  final UserInfo? user;
  List<Comment>? replies;

  Comment({
    required this.id,
    required this.text,
    required this.postId,
    required this.userId,
    this.parentId,
    this.likesCount = 0,
    required this.likedBy,
    required this.createdAt,
    required this.updatedAt,
    this.mentionedUserIds,
    this.user,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class UserInfo {
  final int id;
  final String? name;
  final String? profilePicture;

  UserInfo({required this.id, this.name, this.profilePicture});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
