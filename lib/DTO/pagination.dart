import 'package:json_annotation/json_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable()
class Pagination {
  final int currentPage;
  final int totalPages;

  @JsonKey(defaultValue: 0)
  final int totalItems;

  @JsonKey(defaultValue: 0)
  final int? totalJobs;

  final bool hasNext;
  final bool hasPrev;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.totalJobs,
    required this.hasNext,
    required this.hasPrev,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
