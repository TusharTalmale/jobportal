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

  Map<String, dynamic> toJson() => _$PaginatedApplicationsResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int? currentPage;
  final int? totalPages;
  final int? totalItems;
  final bool? hasNext;
  final bool? hasPrev;
  final int? limit;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalItems,
    this.hasNext,
    this.hasPrev,
    this.limit,
  });
  
factory Pagination.fromJson(Map<String, dynamic> json) {
  return Pagination(
    currentPage: json['currentPage'] is num ? json['currentPage'] as int? : int.tryParse(json['currentPage']?.toString() ?? ''),
    totalPages: json['totalPages'] is num ? json['totalPages'] as int? : int.tryParse(json['totalPages']?.toString() ?? ''),
    totalItems: json['totalItems'] is num ? json['totalItems'] as int? : int.tryParse(json['totalItems']?.toString() ?? ''),
    hasNext: json['hasNext'] as bool? ?? false,
    hasPrev: json['hasPrev'] as bool? ?? false,
    limit: json['limit'] is num ? json['limit'] as int? : int.tryParse(json['limit']?.toString() ?? ''),
  );
}

  Map<String, dynamic> toJson() => _$PaginationToJson(this);

  /// Add default fallback values
  int get safeCurrentPage => currentPage ?? 1;
  int get safeTotalPages => totalPages ?? 1;
  bool get safeHasNext => hasNext ?? false;
  bool get safeHasPrev => hasPrev ?? false;
  int get safeLimit => limit ?? 10;
}
