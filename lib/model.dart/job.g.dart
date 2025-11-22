// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
  id: (json['id'] as num).toInt(),
  jobTitle: json['jobTitle'] as String,
  jobLocation: json['jobLocation'] as String?,
  salary: json['salary'] as String?,
  jobType: json['jobType'] as String?,
  workpLaceType: json['workpLaceType'] as String?,
  position: json['position'] as String?,
  qualification: json['qualification'] as String?,
  experience: json['experience'] as String?,
  specialization: json['specialization'] as String?,
  facilities: json['facilities'] as String?,
  jobDescription: json['jobDescription'] as String?,
  requirements: json['requirements'] as String?,
  companyId: (json['companyId'] as num?)?.toInt(),
  lattitude: _toDouble(json['lattitude']),
  longitude: _toDouble(json['longitude']),
  postedBy: (json['postedBy'] as num?)?.toInt(),
  postedAt:
      json['postedAt'] == null
          ? null
          : DateTime.parse(json['postedAt'] as String),
  expiresAt:
      json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
  applicantsIds: Job._intList(json['applicantsIds']),
  status: json['status'] as String?,
  viewsCount: (json['viewsCount'] as num?)?.toInt(),
  isApplied: json['isApplied'] as bool? ?? false,
  isExpired: json['isExpired'] as bool? ?? false,
  applicationStatus: json['applicationStatus'] as String? ?? 'none',
  company:
      json['company'] == null
          ? null
          : Company.fromJson(json['company'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
  'id': instance.id,
  'jobTitle': instance.jobTitle,
  'jobLocation': instance.jobLocation,
  'salary': instance.salary,
  'jobType': instance.jobType,
  'workpLaceType': instance.workpLaceType,
  'position': instance.position,
  'qualification': instance.qualification,
  'experience': instance.experience,
  'specialization': instance.specialization,
  'facilities': instance.facilities,
  'jobDescription': instance.jobDescription,
  'requirements': instance.requirements,
  'companyId': instance.companyId,
  'lattitude': instance.lattitude,
  'longitude': instance.longitude,
  'postedBy': instance.postedBy,
  'postedAt': instance.postedAt?.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'applicantsIds': instance.applicantsIds,
  'status': instance.status,
  'viewsCount': instance.viewsCount,
  'isApplied': instance.isApplied,
  'isExpired': instance.isExpired,
  'applicationStatus': instance.applicationStatus,
  'company': instance.company?.toJson(),
};
