import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable(explicitToJson: true)
class UserProfile {
  final int id;
  String fullName;
  String location;
  String email;
  String phoneNumber;
  String countryCode;
  String? imageUrl;
  String gender;
  String? dateOfBirth;
  String aboutMe;
  String userType;
  List<WorkExperience> workExperiences;
  List<Education> educations;
  List<Language> languages;
  List<String> skills;
  List<Appreciation> appreciations;
  List<Resume> resumes;
  int followers;
  int following;

  UserProfile({
    required this.id, // Changed to int
    required this.fullName,
    required this.location,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
    this.imageUrl,
    this.gender = 'male',
    this.dateOfBirth,
    this.aboutMe = '',
    this.userType = 'user',
    this.workExperiences = const [],
    this.educations = const [],
    this.languages = const [],
    this.skills = const [],
    this.appreciations = const [],
    this.resumes = const [],
    this.followers = 0,
    this.following = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? location,
    String? email,
    String? phoneNumber,
    String? countryCode,
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
  }) {
    return UserProfile(
      id: this.id,
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
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

// ============= MOCK DATA =============
class MockProfileData {
  static UserProfile getMockUserProfile() {
    return UserProfile(
      id: 1,
      fullName: 'Brandone Louis',
      location: 'California, United states',
      email: 'brandonelouis@gmail.com',
      phoneNumber: '619 3456 7890',
      countryCode: '+1',
      gender: 'male',
      imageUrl: null,
      dateOfBirth: '1995-08-20',
      aboutMe:
          'Passionate UI/UX Designer with 5+ years of experience creating beautiful and functional digital experiences.',
      followers: 120000,
      following: 23000,
      workExperiences: [
        WorkExperience(
          id: '1',
          jobTitle: 'Manager',
          company: 'Amazon Inc',
          startDate: DateTime(2015, 1),
          endDate: DateTime(2022, 2),
          isCurrentPosition: false,
          description:
              'Managed cross-functional teams and led product initiatives.',
        ),
      ],
      educations: [
        Education(
          id: '1',
          levelOfEducation: 'Bachelor of Information Technology',
          institutionName: 'University of Oxford',
          fieldOfStudy: 'Information Technology',
          startDate: DateTime(2010, 9),
          endDate: DateTime(2013, 8),
          isCurrentPosition: false,
        ),
      ],
      languages: [
        Language(
          id: '1',
          name: 'Indonesian',
          oralLevel: 10,
          writtenLevel: 10,
          isFirstLanguage: true,
        ),
        Language(
          id: '2',
          name: 'English',
          oralLevel: 8,
          writtenLevel: 8,
          isFirstLanguage: false,
        ),
      ],
      skills: [
        'Leadership',
        'Teamwork',
        'Visioner',
        'Target oriented',
        'Consistent',
        'Good communication skills',
      ],
      appreciations: [
        Appreciation(
          id: '1',
          title: 'Young Scientist',
          organization: 'Wireless Symposium (RWS)',
          date: DateTime(2014),
        ),
      ],
      resumes: [
        Resume(
          id: '1',
          fileName: 'Jamet kudasi - CV - UI/UX Designer',
          size: '867 Kb',
          uploadDate: DateTime(2022, 2, 14, 11, 30),
        ),
      ],
    );
  }
}
