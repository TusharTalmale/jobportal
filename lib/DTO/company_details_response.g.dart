// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompanyDetailsResponse _$CompanyDetailsResponseFromJson(
  Map<String, dynamic> json,
) => CompanyDetailsResponse(
  company: Company.fromJson(json['company'] as Map<String, dynamic>),
  jobs:
      (json['jobs'] as List<dynamic>)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CompanyDetailsResponseToJson(
  CompanyDetailsResponse instance,
) => <String, dynamic>{
  'company': instance.company.toJson(),
  'jobs': instance.jobs.map((e) => e.toJson()).toList(),
};
