// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_details_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobDetailsResponse _$JobDetailsResponseFromJson(Map<String, dynamic> json) =>
    JobDetailsResponse(
      job: Job.fromJson(json['job'] as Map<String, dynamic>),
      similarJobs:
          (json['similarJobs'] as List<dynamic>)
              .map((e) => Job.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$JobDetailsResponseToJson(JobDetailsResponse instance) =>
    <String, dynamic>{
      'job': instance.job.toJson(),
      'similarJobs': instance.similarJobs.map((e) => e.toJson()).toList(),
    };
