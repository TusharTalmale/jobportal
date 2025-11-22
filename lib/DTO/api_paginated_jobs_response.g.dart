// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_paginated_jobs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiPaginatedJobsResponse _$ApiPaginatedJobsResponseFromJson(
  Map<String, dynamic> json,
) => ApiPaginatedJobsResponse(
  success: json['success'] as bool?,
  jobs:
      (json['data'] as List<dynamic>)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiPaginatedJobsResponseToJson(
  ApiPaginatedJobsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.jobs.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};
