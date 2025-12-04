import 'package:jobportal/model.dart/company.dart';
import 'package:json_annotation/json_annotation.dart';
part 'api_paginated_companies_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ApiPaginatedCompaniesResponse {
  final bool? success;

  @JsonKey(name: 'data')
  final List<Company> companies;

  final Pagination pagination;

  ApiPaginatedCompaniesResponse({
    this.success,
    required this.companies,
    required this.pagination,
  });

  factory ApiPaginatedCompaniesResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiPaginatedCompaniesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApiPaginatedCompaniesResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNext;
  final bool hasPrev;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNext,
    required this.hasPrev,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
