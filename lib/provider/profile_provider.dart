import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/services/local_storage_service.dart';
import 'package:jobportal/provider/api_client.dart';

class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();
  final _api = ApiClient().profileApiService;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  UserProfile? get userProfile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // New files to upload with profile update
  File? _newProfileImage;
  File? get newProfileImage => _newProfileImage;

  File? _newResumeFile;
  File? get newResumeFile => _newResumeFile;

  ProfileProvider() {
    _loadProfileFromStorage();
  }

  // ==========================
  // INIT / STORAGE
  // ==========================

  Future<void> _loadProfileFromStorage() async {
    try {
      final userData = _storageService.getUserData();
      if (userData != null) {
        _profile = UserProfile.fromJson(userData);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading profile from storage: $e');
    }
  }

  Future<void> fetchProfile() async {
    final userId = _storageService.getUserId();
    if (userId == null) {
      _errorMessage = "User not logged in.";
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final fetchedProfile = await _api.getProfile(userId);
      _profile = fetchedProfile;
      await _saveProfileToStorage();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      print('Error loading profile from network: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveProfileToStorage() async {
    try {
      if (_profile == null) return;
      await _storageService.saveUserData(_profile!.toJson());
    } catch (e) {
      print('Error saving profile to storage: $e');
    }
  }

  // ==========================
  // HELPERS
  // ==========================

  WorkExperience? getWorkExperienceForEdit(int? index) {
    final p = _profile;
    if (p != null &&
        index != null &&
        index >= 0 &&
        index < (p.workExperiences?.length ?? 0)) {
      return p.workExperiences![index];
    }
    return null;
  }

  Appreciation? getAppreciationForEdit(int? index) {
    final p = _profile;
    if (p != null &&
        index != null &&
        index >= 0 &&
        index < (p.appreciations?.length ?? 0)) {
      return p.appreciations![index];
    }
    return null;
  }

  // ==========================
  // ABOUT ME
  // ==========================

  String _editingAboutMe = '';
  String get editingAboutMe => _editingAboutMe;

  void initializeAboutMeForm() {
    _editingAboutMe = _profile?.aboutMe ?? '';
    notifyListeners();
  }

  void updateEditingAboutMe(String text) {
    _editingAboutMe = text;
    notifyListeners();
  }

  void disposeAboutMeForm() {
    _editingAboutMe = '';
  }

  void saveAboutMe() {
    if (_profile == null) return;
    _profile = _profile!.copyWith(aboutMe: _editingAboutMe);
    updateProfileData();
    notifyListeners();
  }

  // ==========================
  // BASIC INFO
  // ==========================

  UserProfile? _editingBasicInfo;
  UserProfile? get editingBasicInfo => _editingBasicInfo;

  void initializeBasicInfoForm() {
    _editingBasicInfo = _profile?.copyWith();
    notifyListeners();
  }

  void updateEditingBasicInfo({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? location,
    String? gender,
  }) {
    if (_editingBasicInfo == null) return;
    _editingBasicInfo = _editingBasicInfo!.copyWith(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      location: location,
      gender: gender,
    );
    notifyListeners();
  }

  void saveBasicInfo() {
    if (_editingBasicInfo == null) return;
    _profile = _editingBasicInfo!;
    updateProfileData();
    notifyListeners();
  }

  // ==========================
  // IMAGE & RESUME FILES
  // ==========================

  void setNewProfileImage(File? image) {
    _newProfileImage = image;
    notifyListeners();
  }

  void setNewResumeFile(File? file) {
    _newResumeFile = file;
    notifyListeners();
  }

  // ==========================
  // WORK EXPERIENCE
  // ==========================

  final GlobalKey<FormState> workExperienceFormKey = GlobalKey<FormState>();
  WorkExperience? _editingWorkExperience;
  WorkExperience? get editingWorkExperience => _editingWorkExperience;
  int? _editingWorkExperienceIndex;

  void addWorkExperience(WorkExperience experience) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      workExperiences: [..._profile!.workExperiences ?? [], experience],
    );
    updateProfileData();
    notifyListeners();
  }

  void updateWorkExperience(int index, WorkExperience experience) {
    if (_profile == null) return;
    final updatedList =
        List<WorkExperience>.from(_profile!.workExperiences ?? []);
    updatedList[index] = experience;
    _profile = _profile!.copyWith(workExperiences: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void removeWorkExperience(int index) {
    if (_profile == null) return;
    final updatedList =
        List<WorkExperience>.from(_profile!.workExperiences ?? []);
    updatedList.removeAt(index);
    _profile = _profile!.copyWith(workExperiences: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void initializeWorkExperienceForm(int? index) {
    _editingWorkExperienceIndex = index;
    if (_profile == null) return;

    if (index != null && index < (_profile!.workExperiences?.length ?? 0)) {
      final exp = _profile!.workExperiences![index];
      _editingWorkExperience = exp.copyWith();
    } else {
      _editingWorkExperience = WorkExperience(
        id: DateTime.now().toIso8601String(),
        jobTitle: '',
        company: '',
        startDate: DateTime.now(),
        isCurrentPosition: false,
        description: '',
      );
    }
    notifyListeners();
  }

  void updateEditingWorkExperience({
    String? jobTitle,
    String? company,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentPosition,
  }) {
    if (_editingWorkExperience == null) return;
    _editingWorkExperience = _editingWorkExperience!.copyWith(
      jobTitle: jobTitle ?? _editingWorkExperience!.jobTitle,
      company: company ?? _editingWorkExperience!.company,
      description: description ?? _editingWorkExperience!.description,
      startDate: startDate ?? _editingWorkExperience!.startDate,
      endDate: isCurrentPosition == true
          ? null
          : endDate ?? _editingWorkExperience!.endDate,
      isCurrentPosition:
          isCurrentPosition ?? _editingWorkExperience!.isCurrentPosition,
    );
    notifyListeners();
  }

  void saveWorkExperience() {
    if (!workExperienceFormKey.currentState!.validate()) return;
    if (_editingWorkExperience == null) return;

    final newExp = _editingWorkExperience!;
    _editingWorkExperienceIndex == null
        ? addWorkExperience(newExp)
        : updateWorkExperience(_editingWorkExperienceIndex!, newExp);
  }

  void disposeWorkExperienceForm() {
    _editingWorkExperience = null;
    _editingWorkExperienceIndex = null;
  }

  // ==========================
  // EDUCATION
  // ==========================

  final GlobalKey<FormState> educationFormKey = GlobalKey<FormState>();
  Education? _editingEducation;
  Education? get editingEducation => _editingEducation;
  int? _editingEducationIndex;

  void addEducation(Education education) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      educations: [..._profile!.educations ?? [], education],
    );
    updateProfileData();
    notifyListeners();
  }

  void updateEducation(int index, Education education) {
    if (_profile == null) return;
    final updatedList = List<Education>.from(_profile!.educations ?? []);
    updatedList[index] = education;
    _profile = _profile!.copyWith(educations: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void removeEducation(int index) {
    if (_profile == null) return;
    final updatedList = List<Education>.from(_profile!.educations ?? []);
    updatedList.removeAt(index);
    _profile = _profile!.copyWith(educations: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void initializeEducationForm(int? index) {
    _editingEducationIndex = index;
    if (_profile == null) return;

    if (index != null && index < (_profile!.educations?.length ?? 0)) {
      final edu = _profile!.educations![index];
      _editingEducation = edu.copyWith();
    } else {
      _editingEducation = Education(
        id: DateTime.now().toIso8601String(),
        levelOfEducation: '',
        institutionName: '',
        fieldOfStudy: '',
        startDate: DateTime.now(),
        isCurrentPosition: false,
        description: '',
      );
    }
    notifyListeners();
  }

  void updateEditingEducation({
    String? levelOfEducation,
    String? institutionName,
    String? fieldOfStudy,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrentPosition,
  }) {
    if (_editingEducation == null) return;
    _editingEducation = _editingEducation!.copyWith(
      levelOfEducation:
          levelOfEducation ?? _editingEducation!.levelOfEducation,
      institutionName:
          institutionName ?? _editingEducation!.institutionName,
      fieldOfStudy: fieldOfStudy ?? _editingEducation!.fieldOfStudy,
      description: description ?? _editingEducation!.description,
      startDate: startDate ?? _editingEducation!.startDate,
      endDate: isCurrentPosition == true
          ? null
          : endDate ?? _editingEducation!.endDate,
      isCurrentPosition:
          isCurrentPosition ?? _editingEducation!.isCurrentPosition,
    );
    notifyListeners();
  }

  void saveEducation() {
    if (!educationFormKey.currentState!.validate()) return;
    if (_editingEducation == null) return;

    final newEdu = _editingEducation!;
    _editingEducationIndex == null
        ? addEducation(newEdu)
        : updateEducation(_editingEducationIndex!, newEdu);
  }

  void disposeEducationForm() {
    _editingEducation = null;
    _editingEducationIndex = null;
  }

  // ==========================
  // LANGUAGES
  // ==========================

  Language? _editingLanguage;
  Language? get editingLanguage => _editingLanguage;
  int? _editingLanguageIndex;

  final List<String> availableLanguages = const [
    'Arabic',
    'Indonesian',
    'Malaysian',
    'English',
    'French',
    'German',
    'Hindi',
    'Italian',
    'Japanese',
    'Korean',
  ];

  void addLanguage(Language language) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      languages: [..._profile!.languages ?? [], language],
    );
    updateProfileData();
    notifyListeners();
  }

  void updateLanguage(int index, Language language) {
    if (_profile == null) return;
    final updatedList = List<Language>.from(_profile!.languages ?? []);
    updatedList[index] = language;
    _profile = _profile!.copyWith(languages: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void removeLanguage(int index) {
    if (_profile == null) return;
    final updatedList = List<Language>.from(_profile!.languages ?? []);
    updatedList.removeAt(index);
    _profile = _profile!.copyWith(languages: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void initializeLanguageForm(int? index) {
    _editingLanguageIndex = index;
    if (_profile == null) return;

    if (index != null && index < (_profile!.languages?.length ?? 0)) {
      final lang = _profile!.languages![index];
      _editingLanguage = lang.copyWith();
    } else {
      _editingLanguage = Language(
        id: '',
        name: 'English',
        oralLevel: 5,
        writtenLevel: 5,
        isFirstLanguage: false,
      );
    }
    notifyListeners();
  }

  void updateEditingLanguage({
    String? name,
    int? oralLevel,
    int? writtenLevel,
    bool? isFirstLanguage,
  }) {
    if (_editingLanguage == null) return;
    _editingLanguage = _editingLanguage!.copyWith(
      name: name,
      oralLevel: oralLevel,
      writtenLevel: writtenLevel,
      isFirstLanguage: isFirstLanguage,
    );
    notifyListeners();
  }

  void saveLanguage() {
    if (_editingLanguage == null) return;

    final newLang = _editingLanguage!.copyWith(
      id: _editingLanguage!.id.isEmpty
          ? DateTime.now().toIso8601String()
          : _editingLanguage!.id,
    );

    _editingLanguageIndex == null
        ? addLanguage(newLang)
        : updateLanguage(_editingLanguageIndex!, newLang);
  }

  // ==========================
  // SKILLS
  // ==========================

  String _newSkillText = '';
  final List<String> _skillsToAdd = [];
  List<String> get skillsToAdd => _skillsToAdd;

  void initializeSkillsForm() {
    _newSkillText = '';
    _skillsToAdd.clear();
    if (_profile != null) {
      _skillsToAdd.addAll(_profile!.skills ?? []);
    }
    notifyListeners();
  }

  void updateNewSkillText(String text) {
    _newSkillText = text;
    notifyListeners();
  }

  void addSkillToLocalList([String? skill]) {
    final skillToAdd = skill ?? _newSkillText.trim();
    if (skillToAdd.isNotEmpty && !_skillsToAdd.contains(skillToAdd)) {
      _skillsToAdd.add(skillToAdd);
      _newSkillText = '';
      notifyListeners();
    }
  }

  void removeSkillFromLocalList(int index) {
    _skillsToAdd.removeAt(index);
    notifyListeners();
  }

  void saveSkills() {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      skills: List<String>.from(_skillsToAdd),
    );
    updateProfileData();
  }

  void disposeSkillsForm() {
    _newSkillText = '';
    _skillsToAdd.clear();
  }

  // ==========================
  // APPRECIATIONS
  // ==========================

  final GlobalKey<FormState> appreciationFormKey = GlobalKey<FormState>();
  Appreciation? _editingAppreciation;
  Appreciation? get editingAppreciation => _editingAppreciation;
  int? _editingAppreciationIndex;

  void addAppreciation(Appreciation appreciation) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      appreciations: [..._profile!.appreciations ?? [], appreciation],
    );
    updateProfileData();
    notifyListeners();
  }

  void updateAppreciation(int index, Appreciation appreciation) {
    if (_profile == null) return;
    final updatedList =
        List<Appreciation>.from(_profile!.appreciations ?? []);
    updatedList[index] = appreciation;
    _profile = _profile!.copyWith(appreciations: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void removeAppreciation(int index) {
    if (_profile == null) return;
    final updatedList =
        List<Appreciation>.from(_profile!.appreciations ?? []);
    updatedList.removeAt(index);
    _profile = _profile!.copyWith(appreciations: updatedList);
    updateProfileData();
    notifyListeners();
  }

  void initializeAppreciationForm(int? index) {
    _editingAppreciationIndex = index;
    if (_profile == null) return;

    if (index != null && index < (_profile!.appreciations?.length ?? 0)) {
      _editingAppreciation = _profile!.appreciations![index].copyWith();
    } else {
      _editingAppreciation = Appreciation(
        id: '',
        title: '',
        organization: '',
        date: DateTime.now(),
      );
    }
    notifyListeners();
  }

  void updateEditingAppreciation({
    String? title,
    String? organization,
    DateTime? date,
  }) {
    if (_editingAppreciation == null) return;
    _editingAppreciation = _editingAppreciation!.copyWith(
      title: title,
      organization: organization,
      date: date,
    );
    notifyListeners();
  }

  void saveAppreciation() {
    if (!appreciationFormKey.currentState!.validate()) return;
    if (_editingAppreciation == null) return;

    final newAppreciation = _editingAppreciation!.copyWith(
      id: _editingAppreciationIndex != null
          ? _profile!.appreciations![_editingAppreciationIndex!].id
          : DateTime.now().toIso8601String(),
    );

    _editingAppreciationIndex == null
        ? addAppreciation(newAppreciation)
        : updateAppreciation(_editingAppreciationIndex!, newAppreciation);
  }

  void disposeAppreciationForm() {
    _editingAppreciation = null;
    _editingAppreciationIndex = null;
  }

  // ==========================
  // RESUMES
  // ==========================

  void addResume(Resume resume) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(
      resumes: [..._profile!.resumes ?? [], resume],
    );
    updateProfileData();
  }

  void removeResume(String resumeId) {
    if (_profile == null) return;
    final updatedList = List<Resume>.from(_profile!.resumes ?? []);
    updatedList.removeWhere((r) => r.id == resumeId);
    _profile = _profile!.copyWith(resumes: updatedList);
    updateProfileData();
  }

  // ==========================
  // CENTRAL UPDATE (BACKEND)
  // ==========================

  Future<bool> updateProfileData() async {
    if (_profile == null) {
      _errorMessage = "Cannot update profile. No user data loaded.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _storageService.getUserId();
      if (userId == null) throw Exception("User not logged in.");

      final formData = FormData();

      void addIfNotNull(String key, dynamic value) {
        if (value != null && value != "" && value != "null") {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      }

      // Basic fields
      addIfNotNull('fullName', _profile!.fullName);
      addIfNotNull('email', _profile!.email);
      addIfNotNull('phoneNumber', _profile!.phoneNumber);
      addIfNotNull('location', _profile!.location);
      addIfNotNull('gender', _profile!.gender);
      addIfNotNull('aboutMe', _profile!.aboutMe);

      // Full lists (server replaces whole JSON arrays)
      addIfNotNull(
        'workExperience',
        jsonEncode(
          (_profile!.workExperiences ?? [])
              .map((e) => e.toJson())
              .toList(),
        ),
      );

      addIfNotNull(
        'education',
        jsonEncode(
          (_profile!.educations ?? []).map((e) => e.toJson()).toList(),
        ),
      );

      addIfNotNull(
        'languages',
        jsonEncode(
          (_profile!.languages ?? []).map((e) => e.toJson()).toList(),
        ),
      );

      addIfNotNull(
        'skills',
        jsonEncode(_profile!.skills ?? []),
      );

      addIfNotNull(
        'appreciations',
        jsonEncode(
          (_profile!.appreciations ?? [])
              .map((e) => e.toJson())
              .toList(),
        ),
      );

      // Files
      if (_newProfileImage != null) {
        formData.files.add(
          MapEntry(
            'image_url',
            await MultipartFile.fromFile(
              _newProfileImage!.path,
              filename: _newProfileImage!.path.split('/').last,
            ),
          ),
        );
      }

      if (_newResumeFile != null) {
        formData.files.add(
          MapEntry(
            'resume',
            await MultipartFile.fromFile(
              _newResumeFile!.path,
              filename: _newResumeFile!.path.split('/').last,
            ),
          ),
        );
      }

      // API call
      final updatedProfile = await _api.updateProfile(userId, formData);

      // Replace local copy with backend truth
      _profile = updatedProfile;
      await _saveProfileToStorage();

      _newProfileImage = null;
      _newResumeFile = null;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to update profile: $e";
      notifyListeners();
      return false;
    }
  }

  // ==========================
  // RESET
  // ==========================

  void resetProfile() {
    _profile = null;
    _errorMessage = null;
    _storageService.clearAllData();
    notifyListeners();
  }
}
