import 'package:flutter/material.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:jobportal/services/local_storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService();

  UserProfile _profile = MockProfileData.getMockUserProfile();
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile get profile => _profile;
  UserProfile? get userProfile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize profile from local storage
  Future<void> initializeFromStorage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = _storageService.getUserData();
      if (userData != null) {
        _profile = UserProfile.fromJson(userData);
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading profile: $e';
      print('Error loading profile from storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save profile to local storage
  Future<void> _saveProfileToStorage() async {
    try {
      await _storageService.saveUserData(_profile.toJson());
    } catch (e) {
      print('Error saving profile to storage: $e');
    }
  }

  WorkExperience? getWorkExperienceForEdit(int? index) {
    if (index != null &&
        index >= 0 &&
        index < _profile.workExperiences.length) {
      return _profile.workExperiences[index];
    }
    return null;
  }

  Appreciation? getAppreciationForEdit(int? index) {
    if (index != null && index >= 0 && index < _profile.appreciations.length) {
      return _profile.appreciations[index];
    }
    return null;
  }

  // --- About Me Form ---
  String _editingAboutMe = '';
  String get editingAboutMe => _editingAboutMe;

  // --- Basic Info Form ---
  UserProfile? _editingBasicInfo;
  UserProfile? get editingBasicInfo => _editingBasicInfo;

  // --- Skills Form ---
  String _newSkillText = '';
  final List<String> _skillsToAdd = [];
  List<String> get skillsToAdd => _skillsToAdd;
  // --- Temporary State for Work Experience Form ---
  final GlobalKey<FormState> workExperienceFormKey = GlobalKey<FormState>();
  WorkExperience? _editingWorkExperience;
  WorkExperience? get editingWorkExperience => _editingWorkExperience;
  int? _editingWorkExperienceIndex;

  void initializeAboutMeForm() {
    _editingAboutMe = _profile.aboutMe;
    notifyListeners();
  }

  void initializeBasicInfoForm() {
    _editingBasicInfo = _profile.copyWith();
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

  void updateEditingAboutMe(String text) {
    _editingAboutMe = text;
    notifyListeners();
  }

  void disposeAboutMeForm() {
    _editingAboutMe = '';
  }

  void saveAboutMe() {
    _profile = _profile.copyWith(aboutMe: _editingAboutMe);
    _saveProfileToStorage();
    notifyListeners();
  }

  void saveBasicInfo() {
    if (_editingBasicInfo == null) return;
    _profile = _editingBasicInfo!;
    _saveProfileToStorage();
    notifyListeners();
  }

  void addWorkExperience(WorkExperience experience) {
    _profile = _profile.copyWith(
      workExperiences: [..._profile.workExperiences, experience],
    );
    _saveProfileToStorage();
    notifyListeners();
  }

  void updateWorkExperience(int index, WorkExperience experience) {
    final updatedList = List<WorkExperience>.from(_profile.workExperiences);
    updatedList[index] = experience;
    _profile = _profile.copyWith(workExperiences: updatedList);
    _saveProfileToStorage();
    notifyListeners();
  }

  void removeWorkExperience(int index) {
    final updatedList = List<WorkExperience>.from(_profile.workExperiences);
    updatedList.removeAt(index);
    _profile = _profile.copyWith(workExperiences: updatedList);
    _saveProfileToStorage();
    notifyListeners();
  }

  // --- Work Experience Form Methods ---

  void initializeWorkExperienceForm(int? index) {
    _editingWorkExperienceIndex = index;
    if (index != null && index < _profile.workExperiences.length) {
      final exp = _profile.workExperiences[index];
      // Create a copy for editing
      _editingWorkExperience = exp.copyWith();
    } else {
      // Create a new object for adding
      _editingWorkExperience = WorkExperience(
        id: '',
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
      endDate:
          isCurrentPosition == true
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

  void addEducation(Education education) {
    _profile = _profile.copyWith(
      educations: [..._profile.educations, education],
    );
    notifyListeners();
  }

  void updateEducation(int index, Education education) {
    final updatedList = List<Education>.from(_profile.educations);
    updatedList[index] = education;
    _profile = _profile.copyWith(educations: updatedList);
    notifyListeners();
  }

  void removeEducation(int index) {
    final updatedList = List<Education>.from(_profile.educations);
    updatedList.removeAt(index);
    _profile = _profile.copyWith(educations: updatedList);
    notifyListeners();
  }

  void addLanguage(Language language) {
    _profile = _profile.copyWith(languages: [..._profile.languages, language]);
    notifyListeners();
  }

  void updateLanguage(int index, Language language) {
    final updatedList = List<Language>.from(_profile.languages);
    updatedList[index] = language;
    _profile = _profile.copyWith(languages: updatedList);
    notifyListeners();
  }

  void removeLanguage(int index) {
    final updatedList = List<Language>.from(_profile.languages);
    updatedList.removeAt(index);
    _profile = _profile.copyWith(languages: updatedList);
    notifyListeners();
  }

  // --- Temporary State for Education Form ---
  final GlobalKey<FormState> educationFormKey = GlobalKey<FormState>();
  Education? _editingEducation;
  Education? get editingEducation => _editingEducation;
  int? _editingEducationIndex;

  void initializeEducationForm(int? index) {
    _editingEducationIndex = index;
    if (index != null && index < _profile.educations.length) {
      final edu = _profile.educations[index];
      _editingEducation = edu.copyWith();
    } else {
      _editingEducation = Education(
        id: '',
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
      levelOfEducation: levelOfEducation ?? _editingEducation!.levelOfEducation,
      institutionName: institutionName ?? _editingEducation!.institutionName,
      fieldOfStudy: fieldOfStudy ?? _editingEducation!.fieldOfStudy,
      description: description ?? _editingEducation!.description,
      startDate: startDate ?? _editingEducation!.startDate,
      endDate:
          isCurrentPosition == true
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

    final newEdu = Education(
      id:
          _editingEducationIndex != null
              ? _profile.educations[_editingEducationIndex!].id
              : DateTime.now().toString(),
      levelOfEducation: _editingEducation!.levelOfEducation,
      institutionName: _editingEducation!.institutionName,
      fieldOfStudy: _editingEducation!.fieldOfStudy,
      startDate: _editingEducation!.startDate,
      endDate: _editingEducation!.endDate,
      isCurrentPosition: _editingEducation!.isCurrentPosition,
      description: _editingEducation!.description,
    );

    _editingEducationIndex == null
        ? addEducation(newEdu)
        : updateEducation(_editingEducationIndex!, newEdu);
  }

  void disposeEducationForm() {
    _editingEducation = null;
  }

  void disposeWorkExperienceForm() {
    _editingWorkExperience = null;
  }

  // --- End of Work Experience Form Methods ---

  // --- Language Form State and Methods ---
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

  void initializeLanguageForm(int? index) {
    _editingLanguageIndex = index;
    if (index != null && index < _profile.languages.length) {
      final lang = _profile.languages[index];
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
    final newLang = Language(
      id:
          _editingLanguageIndex != null
              ? _profile.languages[_editingLanguageIndex!].id
              : DateTime.now().toString(),
      name: _editingLanguage!.name,
      oralLevel: _editingLanguage!.oralLevel,
      writtenLevel: _editingLanguage!.writtenLevel,
      isFirstLanguage: _editingLanguage!.isFirstLanguage,
    );
    _editingLanguageIndex == null
        ? addLanguage(newLang)
        : updateLanguage(_editingLanguageIndex!, newLang);
  }
  // --- End of Language Form Methods ---

  void initializeSkillsForm() {
    _newSkillText = '';
    _skillsToAdd.clear();
    _skillsToAdd.addAll(_profile.skills);
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
    _profile = _profile.copyWith(skills: List<String>.from(_skillsToAdd));
    notifyListeners();
  }

  void disposeSkillsForm() {
    _newSkillText = '';
    _skillsToAdd.clear();
  }

  void addAppreciation(Appreciation appreciation) {
    _profile = _profile.copyWith(
      appreciations: [..._profile.appreciations, appreciation],
    );
    notifyListeners();
  }

  void updateAppreciation(int index, Appreciation appreciation) {
    final updatedList = List<Appreciation>.from(_profile.appreciations);
    updatedList[index] = appreciation;
    _profile = _profile.copyWith(appreciations: updatedList);
    notifyListeners();
  }

  void removeAppreciation(int index) {
    final updatedList = List<Appreciation>.from(_profile.appreciations);
    updatedList.removeAt(index);
    _profile = _profile.copyWith(appreciations: updatedList);
    notifyListeners();
  }

  // --- Appreciation Form State and Methods ---
  final GlobalKey<FormState> appreciationFormKey = GlobalKey<FormState>();
  Appreciation? _editingAppreciation;
  Appreciation? get editingAppreciation => _editingAppreciation;
  int? _editingAppreciationIndex;

  void initializeAppreciationForm(int? index) {
    _editingAppreciationIndex = index;
    if (index != null && index < _profile.appreciations.length) {
      _editingAppreciation = _profile.appreciations[index].copyWith();
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
      id:
          _editingAppreciationIndex != null
              ? _profile.appreciations[_editingAppreciationIndex!].id
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

  void addResume(Resume resume) {
    _profile = _profile.copyWith(resumes: [..._profile.resumes, resume]);
    notifyListeners();
  }

  void removeResume(String resumeId) {
    final updatedList = List<Resume>.from(_profile.resumes);
    updatedList.removeWhere((r) => r.id == resumeId);
    _profile = _profile.copyWith(resumes: updatedList);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetProfile() {
    _profile = MockProfileData.getMockUserProfile();
    _errorMessage = null;
    notifyListeners();
  }
}
