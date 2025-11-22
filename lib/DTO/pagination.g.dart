// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
  currentPage: (json['currentPage'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
  totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
  hasNext: json['hasNext'] as bool,
  hasPrev: json['hasPrev'] as bool,
  limit: (json['limit'] as num).toInt(),
);

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalItems': instance.totalItems,
      'totalJobs': instance.totalJobs,
      'hasNext': instance.hasNext,
      'hasPrev': instance.hasPrev,
      'limit': instance.limit,
    };
