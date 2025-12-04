// Provider
import 'package:flutter/material.dart';
import 'package:jobportal/DTO/api_paginated_jobs_response.dart';
import 'package:jobportal/DTO/company_details_response.dart';
import 'package:jobportal/DTO/job_details_response.dart';
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
  List<Job> _jobs = []; // Holds the currently loaded (paginated) jobs
  bool _isLoading = false;
  String? _errorMessage;

  // --- Job Details State ---
  Job? _selectedJob;
  bool _isJobLoading = false;

  // --- Company Details State ---
  Company? _selectedCompany;
  List<Job> _selectedCompanyJobs = [];
  bool _isCompanyDetailsLoading = false;


  // --- Pagination State ---
  int _currentPage = 1;
  bool _hasNextPage = true;
  bool _isLoadMore = false;

  // Authenticated user info
  int? _currentUserId;
  String _userType = 'user';

  final List<Job> _savedJobs = [];
  final List<Job> _appliedJobs = []; // Add state for applied jobs
  final List<Job> _recentJobs = [];

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

  
  }

  /// Load user data from storage and fetch jobs
  Future<void> _loadUserDataAndFetchJobs() async {
    try {
      _currentUserId = _storageService.getUserId();
      _userType = _storageService.getUserType() ?? 'user';
      // Fetch initial set of jobs
      await loadFirstPage();
      await loadCompaniesFirstPage(); // Load initial companies
      await _loadRecentJobs();
      await _loadUserJobs(); // Load user jobs AFTER the first page of jobs is available
    } catch (e) {
      print('Error loading user data: $e');
      await loadFirstPage();
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
  bool get isJobLoading => _isJobLoading;
  Job? get selectedJob => _selectedJob;
  String? get errorMessage => _errorMessage;
  // --- Getters for Company Details ---
  Company? get selectedCompany => _selectedCompany;
  List<Job> get selectedCompanyJobs => _selectedCompanyJobs;
  bool get isCompanyDetailsLoading => _isCompanyDetailsLoading;

  List<Job> get filteredJobs => _jobs; // Returns the server-filtered list
  List<Job> get savedJobs => _savedJobs;
  List<Job> get appliedJobs => _appliedJobs;
  List<Job> get recentJobs => _recentJobs;
  List<Company> get allCompanies => _companies;
  Map<String, Set<String>> get activeFilters => _activeFilters;
  int? get currentUserId => _currentUserId;
  String get userType => _userType;

  // --- State for Similar Jobs ---
  List<Job> _similarJobs = [];
  List<Job> get similarJobs => _similarJobs;

  /// Converts UI-friendly date strings to backend-compatible query parameters.
  String? _convertPostedDate(String value) {
    switch (value) {
      case "Recent":
        return "24h";
      case "Last week":
        return "7d";
      case "Last month":
        return "30d";
      default:
        return null; // For "Any time"
    }
  }


// Company Pagination State
List<Company> _companies = [];
bool _companyLoading = false;
bool _companyLoadMore = false;

int _companyPage = 1;
bool _companyHasNext = true;

List<Company> get companies => _companies;
bool get isCompanyLoading => _companyLoading;
bool get isCompanyLoadingMore => _companyLoadMore;

  // --- Job Details Method ---
  Future<void> getJobById(int jobId) async {
    _isJobLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Explicitly type the response for better readability and type safety.
      final JobDetailsResponse response = await _jobApiService.getJobDetails(
        jobId,  _currentUserId!,
      );

      _selectedJob = response.job;
      _similarJobs = response.similarJobs;

      await addRecentJob(response.job);
    } catch (e) {
      _errorMessage = "Failed to load job details: ${e.toString()}";
    }

    _isJobLoading = false;
    notifyListeners();
  }

 
  Future<void> fetchCompanyDetails(int companyId) async {
    _isCompanyDetailsLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentUserId == null) {
        throw Exception("User not authenticated to fetch company details.");
      }
      final CompanyDetailsResponse response = await _companyApiService.getCompanyById(
        companyId,
        _currentUserId!,
      );
      _selectedCompany = response.data.company;
      _selectedCompanyJobs = response.data.jobs;
    } catch (e) {
      _errorMessage = "Failed to load company details: ${e.toString()}";
    }

    _isCompanyDetailsLoading = false;
    notifyListeners();
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
    final savedJobIdsString = await _storageService.getString('savedJobIds');
    if (savedJobIdsString != null && savedJobIdsString.isNotEmpty) {
      final savedJobIds = savedJobIdsString.split(',');
      // This will only populate saved jobs from the currently loaded page.
      // For a full list, a dedicated API endpoint would be needed.
      _savedJobs.clear();
      _savedJobs.addAll(
        _jobs.where((j) => savedJobIds.contains(j.id.toString())),
      );
    }

    // Load applied jobs
    final appliedJobIdsString = await _storageService.getString('appliedJobIds');
    if (appliedJobIdsString != null && appliedJobIdsString.isNotEmpty) {
      final appliedJobIds = appliedJobIdsString.split(',');
      _appliedJobs.clear();
      _appliedJobs.addAll(
        _jobs.where((j) => appliedJobIds.contains(j.id.toString())),
      );
    }
    notifyListeners();
  }

  Future<void> _saveRecentJobs() async {
    // Store a list of job IDs
    final recentJobIds = _recentJobs.map((job) => job.id.toString()).toList();
    await _storageService.saveString('recentJobIds', recentJobIds.join(','));
  }

  Future<void> _loadRecentJobs() async {
    final recentJobIdsString = await _storageService.getString('recentJobIds');

    if (recentJobIdsString != null && recentJobIdsString.isNotEmpty) {
      // Reconstruct the _recentJobs list from the saved IDs
      final recentJobIds = recentJobIdsString.split(',');
      final loadedJobs = <Job>[];
      for (final id in recentJobIds) {
        // Find the job from the main list of all jobs
        final job = _jobs.where((j) => j.id.toString() == id).firstOrNull;
        if (job != null) {
          loadedJobs.add(job);
        }
      }
      _recentJobs.addAll(loadedJobs);
      notifyListeners();
    }
  }

  // ------------------------------------------------------
  //                 PAGINATION METHODS
  // ------------------------------------------------------

  /// Fetch first page (fresh load)
  Future<void> loadFirstPage({
    bool isFilterAction = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ApiPaginatedJobsResponse response =
          await _jobApiService.getJobsPaginated(
        1,
        10,
        userId: _currentUserId!,
        search: designationController.text.isNotEmpty ? designationController.text : null,
        jobType: _jobTypes.isNotEmpty ? _jobTypes.join(',') : null,
        workpLaceType: _workplace != "On-site" ? _workplace : null,
        city: _cities.isNotEmpty ? _cities.join(',') : null,
        minSalary: _salaryRange.start.round(),
        maxSalary: _salaryRange.end.round(),
        specialization:
            _specialization.isNotEmpty ? _specialization.join(',') : null,
        experience: _experience != "No experience" ? _experience : null,
        postedDate: _convertPostedDate(_lastUpdate),
      );

      _jobs.clear();
      _jobs.addAll(response.jobs);

      _currentPage = response.pagination.currentPage;
      _hasNextPage = response.pagination.hasNext;
    } catch (e) {
      _errorMessage = "Failed to load jobs";
      print("❌ loadFirstPage error: $e");
    }

    _isLoading = false;
    notifyListeners();
    if (!isFilterAction) {
      _applyFilters();
    }
  }

Future<void> loadMore() async {
  if (!_hasNextPage || _isLoadMore) return;

  _isLoadMore = true;
  notifyListeners();

  try {
    final response = await _jobApiService.getJobsPaginated(
      _currentPage + 1,
      10,
      userId: _currentUserId!,
      search: designationController.text.isNotEmpty ? designationController.text : null,
      jobType: _jobTypes.isNotEmpty ? _jobTypes.join(',') : null,
      workpLaceType: _workplace != "On-site" ? _workplace : null,
      city: _cities.isNotEmpty ? _cities.join(',') : null,
      minSalary: _salaryRange.start.round(),
      maxSalary: _salaryRange.end.round(),
      specialization:
          _specialization.isNotEmpty ? _specialization.join(',') : null,
      experience: _experience != "No experience" ? _experience : null,
      postedDate: _convertPostedDate(_lastUpdate),
    );

    _jobs.addAll(response.jobs);

    _currentPage = response.pagination.currentPage;
    _hasNextPage = response.pagination.hasNext;
  } catch (e) {
    print("❌ loadMore error: $e");
  }

  _isLoadMore = false;
  notifyListeners();
}
Future<void> loadCompaniesFirstPage({String? search}) async {
  _companyLoading = true;
  notifyListeners();

  try {
    final response = await _companyApiService.getCompaniesPaginated(
      1,
      10,
      search: search,
      userId: _currentUserId!,
    );

    _companies.clear();
    _companies.addAll(response.companies);

    _companyPage = response.pagination.currentPage;
    _companyHasNext = response.pagination.hasNext;
  } catch (e) {
    print("❌ loadCompaniesFirstPage error: $e");
  }

  _companyLoading = false;
  notifyListeners();
}

Future<void> loadMoreCompanies() async {
  if (!_companyHasNext || _companyLoadMore) return;

  _companyLoadMore = true;
  notifyListeners();

  try {
    final response = await _companyApiService.getCompaniesPaginated(
      _companyPage + 1,
      10,
      userId: _currentUserId!,
    );

    _companies.addAll(response.companies);

    _companyPage = response.pagination.currentPage;
    _companyHasNext = response.pagination.hasNext;
  } catch (e) {
    print("❌ loadMoreCompanies error: $e");
  }

  _companyLoadMore = false;
  notifyListeners();
}

  // --- Filter Methods ---
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

    // With pagination, true filtering should happen on the backend.
    // Here, we'll trigger a new fetch with the available API query params.
    // This now simply triggers a new fetch from the server with all the
    // currently set filters.
    loadFirstPage(isFilterAction: true);

    // The notifyListeners() call is handled by loadFirstPage()
  }

  @override
  void dispose() {
    designationController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
