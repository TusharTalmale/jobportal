import 'package:json_annotation/json_annotation.dart';
part 'user_profile.g.dart';

class ImageUrlConverter implements JsonConverter<String?, dynamic> {
  const ImageUrlConverter();

  @override
  String? fromJson(dynamic json) {
    if (json is Map<String, dynamic> && json.containsKey('url')) {
      return json['url'] as String?;
    }
    return json as String?;
  }

  @override
  dynamic toJson(String? object) => object;
}


@JsonSerializable(explicitToJson: true)
class UserProfile {
  final int id;

  @JsonKey(name: 'fullName')
  String? fullName;

  @JsonKey(name: 'location')
  String? location;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'phoneNumber')
  String? phoneNumber;

  @JsonKey(name: 'image_url')
  @ImageUrlConverter()
  String? imageUrl;

  @JsonKey(name: 'gender')
  String? gender;

  @JsonKey(name: 'dateOfBirth')
  String? dateOfBirth;

  @JsonKey(name: 'aboutMe')
  String? aboutMe;

  // LIST FIELDS (your main issue)
  @JsonKey(name: 'workExperience')
  List<WorkExperience>? workExperiences;

  @JsonKey(name: 'education')
  List<Education>? educations;

  @JsonKey(name: 'languages')
  List<Language>? languages;

  @JsonKey(name: 'skills')
  List<String>? skills;

  @JsonKey(name: 'appreciations')
  List<Appreciation>? appreciations;

  @JsonKey(name: 'resume')
  List<Resume>? resumes;

  final String? userType;

  int followers;
  int following;
  final bool isVerified;
  final String? authProvider;
  final String? createdAt;
  final String? updatedAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.location,
    this.email,
    this.phoneNumber,
    this.isVerified = false,
    this.authProvider,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.gender,
    this.dateOfBirth,
    this.aboutMe,
    this.userType,
    this.workExperiences,
    this.educations,
    this.languages,
    this.skills,
    this.appreciations,
    this.resumes,
    this.followers = 0,
    this.following = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    int? id,
    String? fullName,
    String? location,
    String? email,
    String? phoneNumber,
    String? imageUrl,
    String? gender,
    String? dateOfBirth,
    String? aboutMe,
    String? userType,
    List<WorkExperience>? workExperiences,
    List<Education>? educations,
    List<Language>? languages,
    List<String>? skills,
    List<Appreciation>? appreciations,
    List<Resume>? resumes,
    int? followers,
    int? following,
    bool? isVerified,
    String? authProvider,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      aboutMe: aboutMe ?? this.aboutMe,
      userType: userType ?? this.userType,
      workExperiences: workExperiences ?? this.workExperiences,
      educations: educations ?? this.educations,
      languages: languages ?? this.languages,
      skills: skills ?? this.skills,
      appreciations: appreciations ?? this.appreciations,
      resumes: resumes ?? this.resumes,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isVerified: isVerified ?? this.isVerified,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class WorkExperience {
  final String id;
  String jobTitle;
  String company;
  DateTime startDate;
  DateTime? endDate;
  bool isCurrentPosition;
  String description;

  WorkExperience({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.startDate,
    this.endDate,
    this.isCurrentPosition = false,
    this.description = '',
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) =>
      _$WorkExperienceFromJson(json);

  Map<String, dynamic> toJson() => _$WorkExperienceToJson(this);

  WorkExperience copyWith({
    String? id,
    String? jobTitle,
    String? company,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentPosition,
    String? description,
  }) {
    return WorkExperience(
      id: id ?? this.id,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentPosition: isCurrentPosition ?? this.isCurrentPosition,
      description: description ?? this.description,
    );
  }
}

@JsonSerializable()
class Education {
  final String id;
  String levelOfEducation;
  String institutionName;
  String fieldOfStudy;
  DateTime startDate;
  DateTime? endDate;
  bool isCurrentPosition;
  String description;

  Education({
    required this.id,
    required this.levelOfEducation,
    required this.institutionName,
    required this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.isCurrentPosition = false,
    this.description = '',
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  Map<String, dynamic> toJson() => _$EducationToJson(this);

  Education copyWith({
    String? id,
    String? levelOfEducation,
    String? institutionName,
    String? fieldOfStudy,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentPosition,
    String? description,
  }) {
    return Education(
      id: id ?? this.id,
      levelOfEducation: levelOfEducation ?? this.levelOfEducation,
      institutionName: institutionName ?? this.institutionName,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrentPosition: isCurrentPosition ?? this.isCurrentPosition,
      description: description ?? this.description,
    );
  }
}

@JsonSerializable()
class Language {
  final String id;
  String name;
  int oralLevel;
  int writtenLevel;
  bool isFirstLanguage;

  Language({
    required this.id,
    required this.name,
    required this.oralLevel,
    required this.writtenLevel,
    this.isFirstLanguage = false,
  });

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  Language copyWith({
    String? id,
    String? name,
    int? oralLevel,
    int? writtenLevel,
    bool? isFirstLanguage,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
      oralLevel: oralLevel ?? this.oralLevel,
      writtenLevel: writtenLevel ?? this.writtenLevel,
      isFirstLanguage: isFirstLanguage ?? this.isFirstLanguage,
    );
  }
}

@JsonSerializable()
class Appreciation {
  final String id;
  String title;
  String organization;
  DateTime date;

  Appreciation({
    required this.id,
    required this.title,
    required this.organization,
    required this.date,
  });

  factory Appreciation.fromJson(Map<String, dynamic> json) =>
      _$AppreciationFromJson(json);

  Map<String, dynamic> toJson() => _$AppreciationToJson(this);

  Appreciation copyWith({
    String? id,
    String? title,
    String? organization,
    DateTime? date,
  }) {
    return Appreciation(
      id: id ?? this.id,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      date: date ?? this.date,
    );
  }
}

@JsonSerializable()
class Resume {
  final String id;
  String fileName;
  String size;
  DateTime uploadDate;

  Resume({
    required this.id,
    required this.fileName,
    required this.size,
    required this.uploadDate,
  });

  factory Resume.fromJson(Map<String, dynamic> json) => _$ResumeFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeToJson(this);

  Resume copyWith({
    String? id,
    String? fileName,
    String? size,
    DateTime? uploadDate,
  }) {
    return Resume(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      size: size ?? this.size,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
}
