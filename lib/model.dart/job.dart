import 'dart:convert';

import 'package:jobportal/model.dart/company.dart';
import 'package:json_annotation/json_annotation.dart';
part 'job.g.dart';

@JsonSerializable(explicitToJson: true)
class Job {
  final int id;
  final String jobTitle;

  final String? jobLocation;

  // Salary breakdown
  final String? salaryType;
  final String? minSalary;
  final String? maxSalary;
 final String? salary;
  final String? jobType;

  @JsonKey(name: 'workpLaceType')
  final String? workpLaceType;

  final String? position;
  final String? qualification;
  final String? experience;
  final String? specialization;
  final String? facilities;
  final String? jobDescription;
  final String? requirements;

  @JsonKey(name: 'companyId')
  final int? companyId;

  @JsonKey(fromJson: _toDouble)
  final double? lattitude;

  @JsonKey(fromJson: _toDouble)
  final double? longitude;

  final int? postedBy;
  final DateTime? postedAt;
  final DateTime? expiresAt;

  @JsonKey(fromJson: _intList, defaultValue: [])
  final List<int> applicantsIds;

  final String? status;
  final int? viewsCount;

  @JsonKey(defaultValue: false)
  final bool isApplied;

  @JsonKey(defaultValue: false)
  final bool isExpired;

  @JsonKey(defaultValue: 'none')
  final String applicationStatus;

  final int? totalApplications;
  final int? shortlistedCount;
  final int? rejectedCount;
  final int? pendingCount;
  final int? selectedCount;

  @JsonKey(defaultValue: false)
  final bool promoteJob;

  final Company? company;

  Job({
    required this.id,
    required this.jobTitle,
    this.jobLocation,
    this.salaryType,
    this.minSalary,
    this.maxSalary,
    this.salary,
    this.jobType,
    this.workpLaceType,
    this.position,
    this.qualification,
    this.experience,
    this.specialization,
    this.facilities,
    this.jobDescription,
    this.requirements,
    this.companyId,
    this.lattitude,
    this.longitude,
    this.postedBy,
    this.postedAt,
    this.expiresAt,
    this.applicantsIds = const [],
    this.status,
    this.viewsCount,
    this.isApplied = false,
    this.isExpired = false,
    this.applicationStatus = 'none',
    this.totalApplications,
    this.shortlistedCount,
    this.rejectedCount,
    this.pendingCount,
    this.selectedCount,
    this.promoteJob = false,
    this.company,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<int> _intList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => int.tryParse("$e") ?? 0).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => int.tryParse("$e") ?? 0).toList();
        }
      } catch (_) {}
    }
    return [];
  }
}
