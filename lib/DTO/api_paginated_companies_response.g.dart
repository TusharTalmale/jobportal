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
