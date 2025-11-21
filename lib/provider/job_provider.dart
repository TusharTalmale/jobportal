// Provider
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jobportal/api/api_response.dart';
import 'package:jobportal/api/job_api_service.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';

import '../api/company_api_service.dart';
import '../model.dart/company.dart';

class JobProvider extends ChangeNotifier {
  // --- API Service ---
  final JobApiService _jobApiService = ApiClient().jobApiService;
  final CompanyApiService _companyApiService = ApiClient().companyApiService;
  final LocalStorageService _storageService = LocalStorageService();

  // --- State ---
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  List<Company> _allCompanies = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Authenticated user info
  int? _currentUserId;
  String _userType = 'user';

  final List<Job> _savedJobs = [];
  final List<Job> _appliedJobs = []; // Add state for applied jobs
  final List<Job> _recentJobs = [];
  String _designationFilter = '';
  String _locationFilter = '';

  // --- Controllers for search fields ---
  final TextEditingController designationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // --- Filter States (moved from FilterProvider concept) ---
  String _lastUpdate = "Any time";
  String _workplace = "On-site";
  List<String> _jobTypes = []; // Multi-select
  List<String> _positions =
      []; // Multi-select, but original UI was single-select
  List<String> _cities = []; // Multi-select
  RangeValues _salaryRange = const RangeValues(5, 40); // Default to full range
  String _experience = "No experience";
  List<String> _specialization = []; // Multi-select

  // --- Temporary Filter States for editing in FilterPage ---
  String? _tempLastUpdate;
  String? _tempWorkplace;
  List<String>? _tempJobTypes;
  List<String>? _tempPositions;
  List<String>? _tempCities;
  RangeValues? _tempSalaryRange;
  String? _tempExperience;
  List<String>? _tempSpecialization;

  // --- Active Filters Map (for quick lookup and UI display) ---
  final Map<String, Set<String>> _activeFilters = {};

  // --- Available Options (for UI to build dynamically) ---
  final List<String> _availableLastUpdates = [
    "Recent",
    "Last week",
    "Last month",
    "Any time",
  ];
  final List<String> _availableWorkplaces = ["On-site", "Hybrid", "Remote"];
  final List<String> _availableJobTypesOptions = [
    "Apprenticeship",
    "Part-time",
    "Full time",
    "Contract",
    "Project-based",
  ];
  final List<String> _availablePositionsOptions = [
    "Junior",
    "Senior",
    "Leader",
    "Manager",
  ];
  final List<String> _availableCitiesOptions = [
    "California, USA",
    "Texaz, USA",
    "New York, USA",
    "Florida, USA",
  ];
  final List<String> _availableExperiencesOptions = [
    "No experience",
    "Less than a year",
    "1–3 years",
    "3–5 years",
    "5–10 years",
    "More than 10 years",
  ];
  final List<String> _availableSpecializationsOptions = [
    "Design",
    "Finance",
    "Education",
    "Health",
    "Restaurant",
    "Programmer",
  ];

  // --- Constructor ---
  JobProvider() {
    _loadUserDataAndFetchJobs();

    // Add listeners to update filters when text changes
    designationController.addListener(() {
      setDesignationFilter(designationController.text);
    });
    locationController.addListener(() {
      setLocationFilter(locationController.text);
    });
  }

  /// Load user data from storage and fetch jobs
  Future<void> _loadUserDataAndFetchJobs() async {
    try {
      _currentUserId = _storageService.getUserId();
      _userType = _storageService.getUserType() ?? 'user';
      // Fetch jobs first, then load user-specific data that depends on allJobs
      await fetchJobs();
    } catch (e) {
      print('Error loading user data: $e');
      await fetchJobs();
    }
  }

  // --- Getters for Filter States ---
  String get lastUpdate => _lastUpdate;
  String get workplace => _workplace;
  List<String> get jobTypes => List.unmodifiable(_jobTypes);
  List<String> get positions => List.unmodifiable(_positions);
  List<String> get cities => List.unmodifiable(_cities);
  RangeValues get salaryRange => _salaryRange;
  String get experience => _experience;
  List<String> get specialization => List.unmodifiable(_specialization);

  // --- Getters for Temporary Filter States ---
  String? get tempLastUpdate => _tempLastUpdate;
  String? get tempWorkplace => _tempWorkplace;
  List<String> get tempJobTypes => List.unmodifiable(_tempJobTypes ?? []);
  List<String> get tempPositions => List.unmodifiable(_tempPositions ?? []);
  List<String> get tempCities => List.unmodifiable(_tempCities ?? []);
  RangeValues? get tempSalaryRange => _tempSalaryRange;
  String? get tempExperience => _tempExperience;
  List<String> get tempSpecialization =>
      List.unmodifiable(_tempSpecialization ?? []);

  // --- Getters for Available Options ---
  List<String> get availableLastUpdates => _availableLastUpdates;
  List<String> get availableWorkplaces => _availableWorkplaces;
  List<String> get availableJobTypes => _availableJobTypesOptions;
  List<String> get availablePositions => _availablePositionsOptions;
  List<String> get availableCities => _availableCitiesOptions;
  List<String> get availableExperiences => _availableExperiencesOptions;
  List<String> get availableSpecializations => _availableSpecializationsOptions;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Job> get filteredJobs => _filteredJobs;
  List<Job> get savedJobs => _savedJobs;
  List<Job> get appliedJobs => _appliedJobs;
  List<Job> get recentJobs => _recentJobs;
  List<Company> get allCompanies => _allCompanies;
  Map<String, Set<String>> get activeFilters => _activeFilters;
  int? get currentUserId => _currentUserId;
  String get userType => _userType;

  // --- Job Details Method ---
  Job? getJobById(int id) {
    // Find the job from the master list of all jobs.
    return _allJobs.where((job) => job.id == id).firstOrNull;
  }

  // --- Company Details Method ---
  Company? getCompanyById(int id) {
    return _allCompanies.where((company) => company.id == id).firstOrNull;
  }

  // --- Saved Jobs Methods ---
  bool isJobSaved(Job job) {
    return _savedJobs.any((savedJob) => savedJob.id == job.id);
  }

  void toggleSaveJob(Job job) {
    if (isJobSaved(job)) {
      _savedJobs.removeWhere((j) => j.id == job.id);
    } else {
      _savedJobs.add(job);
    }
    _saveSavedJobs(); // Persist changes
    notifyListeners();
  }

  void removeJobFromSaved(Job job) {
    _savedJobs.removeWhere((j) => j.id == job.id);
    _saveSavedJobs(); // Persist changes
    notifyListeners();
  }

  void deleteAllJobs() {
    _savedJobs.clear();
    _saveSavedJobs(); // Persist changes
    notifyListeners();
  }

  // --- Applied Jobs Methods ---
  bool isJobApplied(Job job) {
    return _appliedJobs.any((appliedJob) => appliedJob.id == job.id);
  }

  void addAppliedJob(Job job) {
    if (!isJobApplied(job)) {
      _appliedJobs.add(job);
      _saveAppliedJobs(); // Persist changes
      notifyListeners();
    }
  }

  void removeJobFromApplied(Job job) {
    _appliedJobs.removeWhere((j) => j.id == job.id);
    _saveAppliedJobs(); // Persist changes
    notifyListeners();
  }

  void deleteAllAppliedJobs() {
    _appliedJobs.clear();
    _saveAppliedJobs(); // Persist changes
    notifyListeners();
  }

  // --- Recent Jobs Methods ---
  Future<void> addRecentJob(Job job) async {
    // Remove if it already exists to avoid duplicates and move it to the top.
    _recentJobs.removeWhere((j) => j.id == job.id);

    // Add to the beginning of the list.
    _recentJobs.insert(0, job);

    // Ensure the list does not exceed the limit.
    if (_recentJobs.length > 5) {
      _recentJobs.removeLast();
    }
    await _saveRecentJobs();
    notifyListeners();
  }

  // --- Persistence Methods ---
  Future<void> _saveSavedJobs() async {
    final savedJobIds = _savedJobs.map((job) => job.id.toString()).toList();
    await _storageService.saveString('savedJobIds', savedJobIds.join(','));
  }

  Future<void> _saveAppliedJobs() async {
    final appliedJobIds = _appliedJobs.map((job) => job.id.toString()).toList();
    await _storageService.saveString('appliedJobIds', appliedJobIds.join(','));
  }

  Future<void> _loadUserJobs() async {
    // Load saved jobs
    final savedJobIdsString = _storageService.getString('savedJobIds');
    if (savedJobIdsString != null && savedJobIdsString.isNotEmpty) {
      final savedJobIds = savedJobIdsString.split(',');
      _savedJobs.addAll(
        _allJobs.where((j) => savedJobIds.contains(j.id.toString())),
      );
    }

    // Load applied jobs
    final appliedJobIdsString = _storageService.getString('appliedJobIds');
    if (appliedJobIdsString != null && appliedJobIdsString.isNotEmpty) {
      final appliedJobIds = appliedJobIdsString.split(',');
      _appliedJobs.addAll(
        _allJobs.where((j) => appliedJobIds.contains(j.id.toString())),
      );
    }
  }

  Future<void> _saveRecentJobs() async {
    // Store a list of job IDs
    final recentJobIds = _recentJobs.map((job) => job.id.toString()).toList();
    await _storageService.saveString('recentJobIds', recentJobIds.join(','));
  }

  Future<void> _loadRecentJobs() async {
    final recentJobIdsString = _storageService.getString('recentJobIds');

    if (recentJobIdsString != null && recentJobIdsString.isNotEmpty) {
      // Reconstruct the _recentJobs list from the saved IDs
      final recentJobIds = recentJobIdsString.split(',');
      final loadedJobs = <Job>[];
      for (final id in recentJobIds) {
        // Find the job from the main list of all jobs
        final job = _allJobs.where((j) => j.id.toString() == id).firstOrNull;
        if (job != null) {
          loadedJobs.add(job);
        }
      }
      _recentJobs.addAll(loadedJobs);
      notifyListeners();
    }
  }

  // --- API Methods ---
  Future<void> fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch jobs and companies in parallel for better performance
      final responses = await Future.wait([
        _jobApiService.getAllJobs(),
        _companyApiService.getAllCompanies(),
      ]);

      _allJobs = responses[0] as List<Job>;
      _allCompanies = responses[1] as List<Company>;

      _filteredJobs = List.from(_allJobs); // Initialize filtered list

      // Load user-specific jobs after all jobs are available
      await _loadRecentJobs(); // Load recent jobs after fetching all jobs
      await _loadUserJobs(); // Load saved and applied jobs

      print('✅ Jobs loaded: ${_allJobs.length}');
      print('✅ Companies loaded: ${_allCompanies.length}');
      print('✅ Filtered jobs: ${_filteredJobs.length}');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        _errorMessage = errorResponse.error;
      } else {
        _errorMessage =
            'An unexpected network error occurred. Please try again.';
      }
      print('❌ DioException: $_errorMessage');
      // In case of error, ensure lists are empty
      _allJobs = [];
      _filteredJobs = [];
      _allCompanies = [];
    } catch (e) {
      _errorMessage = 'An unknown error occurred: $e';
      print('❌ Exception: $_errorMessage');
      _allJobs = [];
      _filteredJobs = [];
      _allCompanies = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // --- Filter Methods ---
  void setDesignationFilter(String designation) {
    _designationFilter = designation;
    _applyFilters();
  }

  void setLocationFilter(String location) {
    _locationFilter = location;
    _applyFilters();
  }

  /// Initializes the temporary filter states with the current active filters.
  /// This should be called when the filter page is opened.
  void initFilterEditing() {
    _tempLastUpdate = _lastUpdate;
    _tempWorkplace = _workplace;
    _tempJobTypes = List.from(_jobTypes);
    _tempPositions = List.from(_positions);
    _tempCities = List.from(_cities);
    _tempSalaryRange = _salaryRange;
    _tempExperience = _experience;
    _tempSpecialization = List.from(_specialization);
  }

  // --- Setters for FilterPage to update selections ---
  void setLastUpdate(String value) {
    _tempLastUpdate = value;
    notifyListeners();
  }

  void setWorkplace(String value) {
    _tempWorkplace = value;
    notifyListeners();
  }

  void toggleJobType(String value) {
    _tempJobTypes ??= [];
    if (_tempJobTypes!.contains(value)) {
      _tempJobTypes!.remove(value);
    } else {
      _tempJobTypes!.add(value);
    }
    notifyListeners();
  }

  void setPositionLevel(String value) {
    _tempPositions = [value];
    notifyListeners();
  }

  void toggleCity(String value) {
    _tempCities ??= [];
    if (_tempCities!.contains(value)) {
      _tempCities!.remove(value);
    } else {
      _tempCities!.add(value);
    }
    notifyListeners();
  }

  void setSalaryRange(RangeValues values) {
    _tempSalaryRange = values;
    notifyListeners();
  }

  void setExperience(String value) {
    _tempExperience = value;
    notifyListeners();
  }

  void toggleSpecialization(String value) {
    _tempSpecialization ??= [];
    if (_tempSpecialization!.contains(value)) {
      _tempSpecialization!.remove(value);
    } else {
      _tempSpecialization!.add(value);
    }
    notifyListeners();
  }

  void clearFilters() {
    _designationFilter = '';
    _locationFilter = '';

    // Reset both active and temporary filters to their initial/default states
    _lastUpdate = "Any time";
    _workplace = "On-site";
    _jobTypes = []; // Reset to empty for multi-select
    _positions = []; // Reset to empty for multi-select
    _cities = []; // Reset to empty for multi-select
    _salaryRange = const RangeValues(5, 40); // Reset to full range
    _experience = "No experience";
    _specialization = []; // Reset to empty for multi-select
    _activeFilters.clear(); // Clear the active filters map

    // Also reset the temporary filters so the UI on the filter page updates
    initFilterEditing();

    _applyFilters();
  }

  /// This method is called when the "APPLY NOW" button is pressed on the filter page.
  /// It commits the temporary filter values to the active ones and applies them.
  void applyFilters() {
    _lastUpdate = _tempLastUpdate ?? _lastUpdate;
    _workplace = _tempWorkplace ?? _workplace;
    _jobTypes = List.from(_tempJobTypes ?? []);
    _positions = List.from(_tempPositions ?? []);
    _cities = List.from(_tempCities ?? []);
    _salaryRange = _tempSalaryRange ?? _salaryRange;
    _experience = _tempExperience ?? _experience;
    _specialization = List.from(_tempSpecialization ?? []);

    _applyFilters();
    // No need to call notifyListeners() here as _applyFilters() does it.
  }

  void _applyFilters() {
    // Populate _activeFilters BEFORE filtering
    _activeFilters.clear();
    if (_jobTypes.isNotEmpty) {
      _activeFilters['jobType'] = Set.from(_jobTypes);
    }
    if (_positions.isNotEmpty) {
      _activeFilters['position'] = Set.from(_positions);
    }
    if (_cities.isNotEmpty) {
      _activeFilters['city'] = Set.from(_cities);
    }
    if (_specialization.isNotEmpty) {
      _activeFilters['specialization'] = Set.from(_specialization);
    }

    _filteredJobs =
        _allJobs.where((job) {
          // 1. Text field filters (existing)
          final titleMatch =
              _designationFilter.isEmpty ||
              job.jobTitle.toLowerCase().contains(
                _designationFilter.toLowerCase(),
              );
          final locationMatch =
              _locationFilter.isEmpty ||
              (job.jobLocation ?? '').toLowerCase().contains(
                _locationFilter.toLowerCase(),
              );

          if (!titleMatch || !locationMatch) {
            return false;
          }

          // 2. Last Update filter
          bool lastUpdateMatch = true;
          if (_lastUpdate != "Any time" && job.postedAt != null) {
            final now = DateTime.now();
            final difference = now.difference(job.postedAt!);
            if (_lastUpdate == "Recent" && difference.inHours >= 24) {
              lastUpdateMatch = false;
            } else if (_lastUpdate == "Last week" && difference.inDays >= 7) {
              lastUpdateMatch = false;
            } else if (_lastUpdate == "Last month" && difference.inDays >= 30) {
              lastUpdateMatch = false;
            }
          }
          if (!lastUpdateMatch) return false;

          // 3. Workplace filter
          if (_workplace.isNotEmpty && _workplace != "On-site") {
            // Assuming "On-site" is default and we only filter if changed
            final workplaceMatch =
                (job.workpLaceType ?? '').toLowerCase() ==
                _workplace.toLowerCase();
            if (!workplaceMatch) return false;
          }

          // 4. Job Type filter (multi-select)
          final jobTypeMatch =
              _jobTypes.isEmpty ||
              _jobTypes.any(
                (type) =>
                    (job.jobType ?? '').toLowerCase() == type.toLowerCase(),
              );
          if (!jobTypeMatch) return false;

          // 5. Position Level filter (multi-select, but original UI was single)
          final positionMatch =
              _positions.isEmpty ||
              _positions.any((pos) {
                final positionName =
                    pos.toLowerCase() == 'leader' ? 'lead' : pos.toLowerCase();
                return (job.position ?? '').toLowerCase() ==
                    positionName.toLowerCase();
              });
          if (!positionMatch) return false;

          // 6. City filter (multi-select)
          // NOTE: This filter was based on 'fullLocation'. We'll use 'jobLocation' instead.
          final cityMatch =
              _cities.isEmpty ||
              _cities.any(
                (city) => (job.jobLocation ?? '').toLowerCase().contains(
                  city
                      .split(',')
                      .first
                      .toLowerCase(), // Match just the city name
                ),
              );
          if (!cityMatch) return false;

          // 7. Salary Range filter
          bool salaryMatch = true;
          if (job.salary != null) {
            // Example salary: "$15K/Mo". We extract the number.
            final salaryString = job.salary!.replaceAll(RegExp(r'[^0-9]'), '');
            if (salaryString.isNotEmpty) {
              final salaryK = int.tryParse(salaryString);
              if (salaryK != null) {
                // Assuming the range slider is also in 'K' units.
                if (salaryK < _salaryRange.start.round() ||
                    salaryK > _salaryRange.end.round()) {
                  salaryMatch = false;
                }
              }
            }
          }
          if (!salaryMatch) return false;

          // 8. Experience filter
          // Assuming job.experienceLevel exists in Job model (e.g., "5-10 years")
          if (_experience.isNotEmpty && _experience != "No experience") {
            final experienceMatch =
                (job.experience ?? '').toLowerCase() ==
                _experience.toLowerCase();
            if (!experienceMatch) return false;
          }

          // 9. Specialization filter (multi-select)
          final specializationMatch =
              _specialization.isEmpty ||
              _specialization.any(
                (spec) =>
                    (job.specialization ?? '').toLowerCase() ==
                    spec.toLowerCase(),
              );
          if (!specializationMatch) return false;

          return true;
        }).toList();

    print('🔍 Filtered jobs: ${_filteredJobs.length} from ${_allJobs.length}');
    notifyListeners();
  }

  @override
  void dispose() {
    designationController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
