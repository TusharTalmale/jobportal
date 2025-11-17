import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/company.dart';

part 'job.g.dart';

@JsonSerializable(explicitToJson: true)
class Job {
  final int id;
  final String jobTitle;
  final String? jobLocation;
  final String? salary;
  final String? jobType;
  final String? workpLaceType;
  final String? position;
  final String? qualification;
  final String? experience;
  final String? specialization;
  final String? facilities;
  final String? jobDescription;
  final String? requirements;
  @JsonKey(name: 'comapnyID') // Correctly maps the backend typo
  final int? companyId;
  final double latitude;
  final double longitude;

  final int? postedBy;
  final DateTime? postedAt;
  final DateTime? expiresAt;
  final List<int>? applicantsIds;
  final String? status;
  final int? viewsCount;

  @JsonKey(name: 'company')
  final Company? company;

  Job({
    required this.id,
    required this.jobTitle,
    this.jobLocation,
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
    this.company,
    this.latitude = 0.0, // Default value
    this.longitude = 0.0, // Default value
    this.postedBy,
    this.postedAt,
    this.expiresAt,
    this.applicantsIds,
    this.status,
    this.viewsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

  Map<String, dynamic> toJson() => _$JobToJson(this);
}
