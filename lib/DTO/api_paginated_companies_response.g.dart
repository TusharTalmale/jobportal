// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_paginated_companies_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiPaginatedCompaniesResponse _$ApiPaginatedCompaniesResponseFromJson(
  Map<String, dynamic> json,
) => ApiPaginatedCompaniesResponse(
  success: json['success'] as bool?,
  companies:
      (json['data'] as List<dynamic>)
          .map((e) => Company.fromJson(e as Map<String, dynamic>))
          .toList(),
  pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiPaginatedCompaniesResponseToJson(
  ApiPaginatedCompaniesResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.companies.map((e) => e.toJson()).toList(),
  'pagination': instance.pagination.toJson(),
};

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['currentPage'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  totalItems: (json['totalItems'] as num).toInt(),
  hasNext: json['hasNext'] as bool,
  hasPrev: json['hasPrev'] as bool,
  limit: (json['limit'] as num).toInt(),
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
