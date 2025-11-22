import 'package:jobportal/DTO/pagination.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:json_annotation/json_annotation.dart';
 
part 'api_paginated_jobs_response.g.dart';
@JsonSerializable(explicitToJson: true)
class ApiPaginatedJobsResponse {
  final bool? success;

  @JsonKey(name: 'data')
  final List<Job> jobs;

  final Pagination pagination;

  ApiPaginatedJobsResponse({
    this.success,
    required this.jobs,
    required this.pagination,
  });

  factory ApiPaginatedJobsResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiPaginatedJobsResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ApiPaginatedJobsResponseToJson(this);
}
