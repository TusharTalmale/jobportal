import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/comment.dart';

part 'company_post.g.dart';

enum PostType { text, image, video, link, document }

@JsonSerializable(explicitToJson: true)
class CompanyPost {
  final int id;
  final String title;
  final String? description;
  final String? fileUrl;

  @JsonKey(defaultValue: PostType.text, unknownEnumValue: PostType.text)
  final PostType postType;

  @JsonKey(defaultValue: [])
  final List<String> tags;

  @JsonKey(defaultValue: 0)
  int likesCount;

  @JsonKey(defaultValue: [])
  List<int> likedBy;

  @JsonKey(defaultValue: 0)
  int commentsCount;

  @JsonKey(defaultValue: 0)
  int sharesCount;

  final int companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final CompanyInfo? company;
  List<Comment>? comments;

  CompanyPost({
    required this.id,
    required this.title,
    this.description,
    this.fileUrl,
    required this.postType,
    required this.tags,
    required this.likesCount,
    required this.likedBy,
    required this.commentsCount,
    required this.sharesCount,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.company,
    this.comments,
  });

  factory CompanyPost.fromJson(Map<String, dynamic> json) =>
      _$CompanyPostFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyPostToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedPostsResponse {
  final bool success;
  final PostsData data;

  PaginatedPostsResponse({
    required this.success,
    required this.data,
  });

  factory PaginatedPostsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPostsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedPostsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostsData {
  final int totalItems;
  final List<CompanyPost> posts;
  final int totalPages;
  final int currentPage;
    @JsonKey(defaultValue: false)
  final bool hasNext;

  @JsonKey(defaultValue: false)
  final bool hasPrev;
  PostsData({
    required this.totalItems,
    required this.posts,
    required this.totalPages,
    required this.currentPage,
    this.hasNext = false,
    this.hasPrev = false,
  
  });

  factory PostsData.fromJson(Map<String, dynamic> json) =>
      _$PostsDataFromJson(json);

  Map<String, dynamic> toJson() => _$PostsDataToJson(this);
}

@JsonSerializable()
class CompanyInfo {
  final int id;
  final String companyName;
  final String? companyLogo;

  CompanyInfo({
    required this.id,
    required this.companyName,
    this.companyLogo,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) =>
      _$CompanyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyInfoToJson(this);
}
