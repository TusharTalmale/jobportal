import 'package:json_annotation/json_annotation.dart';

import 'job.dart';

part 'company.g.dart';

@JsonSerializable(explicitToJson: true)
class Company {
  final int id;
  final String companyName;
  final String? location;
  final String? companyLogo;
  final String? aboutCompany;
  final String? website;
  final String? companySize;
  final String? headOffice;
  final String? companyType;
  final int? establishedSince;
  final String? specialization;
  @JsonKey(name: 'company_gallery')
  final List<String>? companyGallery;
  final int? followersCount;
  final String? industry;
  final String? email;
  final String? phone;
  final String? linkedin;
  final String? instagram;
  final List<int>? followersIds;
  @JsonKey(name: 'companyJobs')
  final List<Job>? companyJobs;

  Company({
    required this.id,
    required this.companyName,
    this.location,
    this.companyLogo,
    this.aboutCompany,
    this.website,
    this.companySize,
    this.headOffice,
    this.companyType,
    this.establishedSince,
    this.specialization,
    this.companyGallery,
    this.followersCount,
    this.industry,
    this.email,
    this.phone,
    this.linkedin,
    this.instagram,
    this.followersIds,
    this.companyJobs,
  });

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
