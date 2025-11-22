// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyPost _$CompanyPostFromJson(Map<String, dynamic> json) => CompanyPost(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  fileUrl: json['fileUrl'] as String?,
  postType:
      $enumDecodeNullable(
        _$PostTypeEnumMap,
        json['postType'],
        unknownValue: PostType.text,
      ) ??
      PostType.text,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
  likedBy:
      (json['likedBy'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
  companyId: (json['companyId'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  company:
      json['company'] == null
          ? null
          : CompanyInfo.fromJson(json['company'] as Map<String, dynamic>),
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
  isLiked: json['isLiked'] as bool? ?? false,
);

Map<String, dynamic> _$CompanyPostToJson(CompanyPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'fileUrl': instance.fileUrl,
      'postType': _$PostTypeEnumMap[instance.postType]!,
      'tags': instance.tags,
      'likesCount': instance.likesCount,
      'likedBy': instance.likedBy,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'companyId': instance.companyId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'company': instance.company?.toJson(),
      'comments': instance.comments?.map((e) => e.toJson()).toList(),
      'isLiked': instance.isLiked,
    };

const _$PostTypeEnumMap = {
  PostType.text: 'text',
  PostType.image: 'image',
  PostType.video: 'video',
  PostType.link: 'link',
  PostType.document: 'document',
};

PaginatedPostsResponse _$PaginatedPostsResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedPostsResponse(
  success: json['success'] as bool,
  data: PostsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedPostsResponseToJson(
  PaginatedPostsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

PostsData _$PostsDataFromJson(Map<String, dynamic> json) => PostsData(
  totalItems: (json['totalItems'] as num).toInt(),
  posts:
      (json['posts'] as List<dynamic>)
          .map((e) => CompanyPost.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalPages: (json['totalPages'] as num).toInt(),
  currentPage: (json['currentPage'] as num).toInt(),
  hasNext: json['hasNext'] as bool? ?? false,
  hasPrev: json['hasPrev'] as bool? ?? false,
);

Map<String, dynamic> _$PostsDataToJson(PostsData instance) => <String, dynamic>{
  'totalItems': instance.totalItems,
  'posts': instance.posts.map((e) => e.toJson()).toList(),
  'totalPages': instance.totalPages,
  'currentPage': instance.currentPage,
  'hasNext': instance.hasNext,
  'hasPrev': instance.hasPrev,
};

CompanyInfo _$CompanyInfoFromJson(Map<String, dynamic> json) => CompanyInfo(
  id: (json['id'] as num).toInt(),
  companyName: json['companyName'] as String,
  companyLogo: json['companyLogo'] as String?,
);

Map<String, dynamic> _$CompanyInfoToJson(CompanyInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'companyLogo': instance.companyLogo,
    };

PostLikeResponse _$PostLikeResponseFromJson(Map<String, dynamic> json) =>
    PostLikeResponse(
      json['action'] as String,
      (json['likesCount'] as num).toInt(),
    );

Map<String, dynamic> _$PostLikeResponseToJson(PostLikeResponse instance) =>
    <String, dynamic>{
      'action': instance.action,
      'likesCount': instance.likesCount,
    };
