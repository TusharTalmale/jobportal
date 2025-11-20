// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String?,
  location: json['location'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  isVerified: json['isVerified'] as bool? ?? false,
  authProvider: json['authProvider'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  imageUrl: const ImageUrlConverter().fromJson(json['image_url']),
  gender: json['gender'] as String?,
  dateOfBirth: json['dateOfBirth'] as String?,
  aboutMe: json['aboutMe'] as String?,
  userType: json['userType'] as String?,
  workExperiences:
      (json['workExperience'] as List<dynamic>?)
          ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
          .toList(),
  educations:
      (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList(),
  languages:
      (json['languages'] as List<dynamic>?)
          ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
          .toList(),
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  appreciations:
      (json['appreciations'] as List<dynamic>?)
          ?.map((e) => Appreciation.fromJson(e as Map<String, dynamic>))
          .toList(),
  resumes:
      (json['resume'] as List<dynamic>?)
          ?.map((e) => Resume.fromJson(e as Map<String, dynamic>))
          .toList(),
  followers: (json['followers'] as num?)?.toInt() ?? 0,
  following: (json['following'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserProfileToJson(
  UserProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'location': instance.location,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'image_url': const ImageUrlConverter().toJson(instance.imageUrl),
  'gender': instance.gender,
  'dateOfBirth': instance.dateOfBirth,
  'aboutMe': instance.aboutMe,
  'workExperience': instance.workExperiences?.map((e) => e.toJson()).toList(),
  'education': instance.educations?.map((e) => e.toJson()).toList(),
  'languages': instance.languages?.map((e) => e.toJson()).toList(),
  'skills': instance.skills,
  'appreciations': instance.appreciations?.map((e) => e.toJson()).toList(),
  'resume': instance.resumes?.map((e) => e.toJson()).toList(),
  'userType': instance.userType,
  'followers': instance.followers,
  'following': instance.following,
  'isVerified': instance.isVerified,
  'authProvider': instance.authProvider,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

WorkExperience _$WorkExperienceFromJson(Map<String, dynamic> json) =>
    WorkExperience(
      id: json['id'] as String,
      jobTitle: json['jobTitle'] as String,
      company: json['company'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      isCurrentPosition: json['isCurrentPosition'] as bool? ?? false,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$WorkExperienceToJson(WorkExperience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobTitle': instance.jobTitle,
      'company': instance.company,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isCurrentPosition': instance.isCurrentPosition,
      'description': instance.description,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
  id: json['id'] as String,
  levelOfEducation: json['levelOfEducation'] as String,
  institutionName: json['institutionName'] as String,
  fieldOfStudy: json['fieldOfStudy'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  isCurrentPosition: json['isCurrentPosition'] as bool? ?? false,
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
  'id': instance.id,
  'levelOfEducation': instance.levelOfEducation,
  'institutionName': instance.institutionName,
  'fieldOfStudy': instance.fieldOfStudy,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'isCurrentPosition': instance.isCurrentPosition,
  'description': instance.description,
};

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
  id: json['id'] as String,
  name: json['name'] as String,
  oralLevel: (json['oralLevel'] as num).toInt(),
  writtenLevel: (json['writtenLevel'] as num).toInt(),
  isFirstLanguage: json['isFirstLanguage'] as bool? ?? false,
);

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'oralLevel': instance.oralLevel,
  'writtenLevel': instance.writtenLevel,
  'isFirstLanguage': instance.isFirstLanguage,
};

Appreciation _$AppreciationFromJson(Map<String, dynamic> json) => Appreciation(
  id: json['id'] as String,
  title: json['title'] as String,
  organization: json['organization'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$AppreciationToJson(Appreciation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'organization': instance.organization,
      'date': instance.date.toIso8601String(),
    };

Resume _$ResumeFromJson(Map<String, dynamic> json) => Resume(
  id: json['id'] as String,
  fileName: json['fileName'] as String,
  size: json['size'] as String,
  uploadDate: DateTime.parse(json['uploadDate'] as String),
);

Map<String, dynamic> _$ResumeToJson(Resume instance) => <String, dynamic>{
  'id': instance.id,
  'fileName': instance.fileName,
  'size': instance.size,
  'uploadDate': instance.uploadDate.toIso8601String(),
};
