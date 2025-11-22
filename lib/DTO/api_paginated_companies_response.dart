import 'package:jobportal/DTO/pagination.dart';
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

  Map<String, dynamic> toJson() =>
      _$ApiPaginatedCompaniesResponseToJson(this);
}



