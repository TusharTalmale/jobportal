// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationResponse _$ApplicationResponseFromJson(Map<String, dynamic> json) =>
    ApplicationResponse(
      message: json['message'] as String,
      application: JobApplication.fromJson(
        json['application'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ApplicationResponseToJson(
  ApplicationResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'application': instance.application.toJson(),
};

PaginatedApplicationsResponse _$PaginatedApplicationsResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedApplicationsResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  applications:
      (json['data'] as List<dynamic>)
          .map((e) => JobApplication.fromJson(e as Map<String, dynamic>))
          .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedApplicationsResponseToJson(
  PaginatedApplicationsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.applications.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['currentPage'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
  totalItems: (json['totalItems'] as num?)?.toInt(),
  hasNext: json['hasNext'] as bool?,
  hasPrev: json['hasPrev'] as bool?,
  limit: (json['limit'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalItems': instance.totalItems,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
      'limit': instance.limit,
    };
