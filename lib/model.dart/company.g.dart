// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  id: (json['id'] as num).toInt(),
  companyName: json['companyName'] as String,
  location: json['location'] as String?,
  companyLogo: json['companyLogo'] as String?,
  aboutCompany: json['aboutCompany'] as String?,
  website: json['website'] as String?,
  companySize: json['companySize'] as String?,
  headOffice: json['headOffice'] as String?,
  companyType: json['companyType'] as String?,
  establishedSince: (json['establishedSince'] as num?)?.toInt(),
  specialization: json['specialization'] as String?,
  companyGallery:
      (json['company_gallery'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  followersCount: (json['followersCount'] as num?)?.toInt(),
  industry: json['industry'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  linkedin: json['linkedin'] as String?,
  instagram: json['instagram'] as String?,
  followersIds:
      (json['followersIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  companyJobs:
      (json['companyJobs'] as List<dynamic>?)
          ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'id': instance.id,
  'companyName': instance.companyName,
  'location': instance.location,
  'companyLogo': instance.companyLogo,
  'aboutCompany': instance.aboutCompany,
  'website': instance.website,
  'companySize': instance.companySize,
  'headOffice': instance.headOffice,
  'companyType': instance.companyType,
  'establishedSince': instance.establishedSince,
  'specialization': instance.specialization,
  'company_gallery': instance.companyGallery,
  'followersCount': instance.followersCount,
  'industry': instance.industry,
  'email': instance.email,
  'phone': instance.phone,
  'linkedin': instance.linkedin,
  'instagram': instance.instagram,
  'followersIds': instance.followersIds,
  'companyJobs': instance.companyJobs?.map((e) => e.toJson()).toList(),
};
