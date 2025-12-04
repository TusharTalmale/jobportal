import 'dart:convert';

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

@JsonKey(fromJson: _tagsFromJson, defaultValue: [])
final List<String> tags;


  @JsonKey(defaultValue: 0)
  int likesCount;

@JsonKey(fromJson: _intListFromJson, defaultValue: [])
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

  @JsonKey(defaultValue: false)
  bool isLiked;
  
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
    this.isLiked = false,
  });

  factory CompanyPost.fromJson(Map<String, dynamic> json) =>
      _$CompanyPostFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyPostToJson(this);

  static List<String> _tagsFromJson(dynamic value) {
  if (value == null) return [];

  // Case 1: Already a List
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }

  // Case 2: Backend sent a JSON string
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      return [];
    }
  }

  return [];
}

static List<int> _intListFromJson(dynamic value) {
  if (value == null) return [];

  // Case 1: Already a List<int>
  if (value is List) {
    return value.map((e) => int.tryParse(e.toString()) ?? 0).toList();
  }

  // Case 2: String "[1,2,3]"
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((e) => int.tryParse(e.toString()) ?? 0).toList();
      }
    } catch (_) {
      return [];
    }
  }

  return [];
}

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




@JsonSerializable()
class PostLikeResponse {
  final String action;
  final int likesCount;

  PostLikeResponse(this.action, this.likesCount);

  factory PostLikeResponse.fromJson(Map<String, dynamic> json) =>
      _$PostLikeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PostLikeResponseToJson(this);
}

