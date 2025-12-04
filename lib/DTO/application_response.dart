import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/job_application.dart';

part 'application_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ApplicationResponse {
  final String message;
  final JobApplication application;

  ApplicationResponse({required this.message, required this.application});

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplicationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedApplicationsResponse {
  final bool success;
  final String message;

  @JsonKey(name: 'data')
  final List<JobApplication> applications;

  final Pagination pagination;

  PaginatedApplicationsResponse({
    required this.success,
    required this.message,
    required this.applications,
    required this.pagination,
  });

  factory PaginatedApplicationsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedApplicationsResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PaginatedApplicationsResponseToJson(this);
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