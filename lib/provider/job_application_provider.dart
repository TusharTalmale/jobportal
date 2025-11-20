import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jobportal/api/job_application_api_service.dart';
import 'package:jobportal/model.dart/job_application.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/services/local_storage_service.dart';

/// Production-grade Provider for managing Job Applications
class JobApplicationProvider extends ChangeNotifier {
  // --- API Service ---
  final JobApplicationApiService _jobApplicationApiService =
      ApiClient().jobApplicationApiService;
  final LocalStorageService _storageService = LocalStorageService();

  // --- State Management ---
  List<JobApplication> _allApplications = [];
  List<JobApplication> _filteredApplications = [];
  List<JobApplication> _userApplications = [];
  List<JobApplication> _savedApplications = [];

  JobApplication? _selectedApplication;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  int? _currentUserId;
  String _userType = 'user'; // 'user' or 'employer'

  // --- Filter States ---
  String _statusFilter =
      'all'; // all, applied, shortlisted, interviewed, rejected, hired
  String _sortBy = 'recent'; // recent, oldest, status

  // --- Getters ---
  List<JobApplication> get allApplications => _allApplications;
  List<JobApplication> get filteredApplications => _filteredApplications;
  List<JobApplication> get userApplications => _userApplications;
  List<JobApplication> get savedApplications => _savedApplications;

  JobApplication? get selectedApplication => _selectedApplication;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int? get currentUserId => _currentUserId;
  String get userType => _userType;

  int get applicationCount => _userApplications.length;
  int get activeApplicationCount =>
      _userApplications.where((app) => app.isActive).length;
  int get shortlistedCount =>
      _userApplications.where((app) => app.status == 'shortlisted').length;
  int get rejectedCount =>
      _userApplications.where((app) => app.status == 'rejected').length;
  int get hiredCount =>
      _userApplications.where((app) => app.status == 'hired').length;

  String get statusFilter => _statusFilter;
  String get sortBy => _sortBy;

  // --- Constructor ---
  JobApplicationProvider() {
    _initializeUser();
  }

  /// Initialize user data from local storage
  Future<void> _initializeUser() async {
    try {
      _currentUserId = await _storageService.getUserId();
      _userType = await _storageService.getUserType() ?? 'user';
    } catch (e) {
      _errorMessage = 'Failed to initialize user: $e';
      notifyListeners();
    }
  }

  /// Set current user (useful after login)
  void setCurrentUser(int userId, String userType) {
    _currentUserId = userId;
    _userType = userType;
    notifyListeners();
  }

  // ============================================================================
  // CRUD OPERATIONS
  // ============================================================================

  /// Get all job applications
  Future<void> getAllApplications() async {
    _setLoading(true);
    _clearMessages();
    try {
      final applications = await _jobApplicationApiService.getAllApplications();
      _allApplications = applications;
      _filterAndSort();
      _setSuccess('Applications loaded successfully');
    } on DioException catch (e) {
      _setError('Failed to load applications: ${e.message}');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get applications for current user
  Future<void> getUserApplications() async {
    if (_currentUserId == null) {
      _setError('User not logged in');
      return;
    }

    _setLoading(true);
    _clearMessages();
    try {
      final allApps = await _jobApplicationApiService.getAllApplications();
      _userApplications =
          allApps.where((app) => app.userId == _currentUserId).toList();
      _filteredApplications = _userApplications;
      _filterAndSort();
      _setSuccess('Your applications loaded');
    } on DioException catch (e) {
      _setError('Failed to load your applications: ${e.message}');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get specific application by ID
  Future<void> getApplicationById(int applicationId) async {
    _setLoading(true);
    _clearMessages();
    try {
      final application = await _jobApplicationApiService.getApplicationById(
        applicationId,
      );
      _selectedApplication = application;
      _setSuccess('Application loaded');
    } on DioException catch (e) {
      _setError('Failed to load application: ${e.message}');
    } catch (e) {
      _setError('Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new job application
  Future<bool> createApplication({
    required int jobId,
    required int userId,
    List<String>? resumeFilePaths,
  }) async {
    _setLoading(true);
    _clearMessages();
    try {
      List<MultipartFile>? resumeFiles;
      if (resumeFilePaths != null && resumeFilePaths.isNotEmpty) {
        resumeFiles = await _prepareMultipartFiles(resumeFilePaths);
      }

      final response = await _jobApplicationApiService.createApplication(
        jobId,
        userId,
        resumeFiles: resumeFiles,
      );

      if (response.containsKey('newapplyJob')) {
        final newApplication = JobApplication.fromJson(response['newapplyJob']);
        _userApplications.add(newApplication);
      }

      _filterAndSort();
      _setSuccess('Application submitted successfully!');
      return true;
    } on DioException catch (e) {
      _setError('Failed to create application: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update job application
  Future<bool> updateApplication({
    required int applicationId,
    required int userId,
    List<String>? resumeFilePaths,
  }) async {
    _setLoading(true);
    _clearMessages();
    try {
      if (_currentUserId == null) throw Exception("User not authenticated");

      List<MultipartFile>? resumeFiles;
      if (resumeFilePaths != null && resumeFilePaths.isNotEmpty) {
        resumeFiles = await _prepareMultipartFiles(resumeFilePaths);
      }

      final updatedApplication = await _jobApplicationApiService
          .updateApplication(
            applicationId,
            userId,
            resumeFiles: resumeFiles,
          );

      _updateApplicationInList(updatedApplication);
      _setSuccess('Application updated successfully!');
      return true;
    } on DioException catch (e) {
      _setError('Failed to update application: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete job application
  Future<bool> deleteApplication(int applicationId) async {
    _setLoading(true);
    _clearMessages();
    try {
      await _jobApplicationApiService.deleteApplication(applicationId);

      _userApplications.removeWhere((app) => app.id == applicationId);
      _filterAndSort();
      _setSuccess('Application deleted successfully!');
      return true;
    } on DioException catch (e) {
      _setError('Failed to delete application: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // STATUS MANAGEMENT
  // ============================================================================

  /// Change application status
  Future<bool> changeApplicationStatus(
    int applicationId,
    String newStatus,
  ) async {
    _setLoading(true);
    _clearMessages();
    try {
      final request = UpdateApplicationStatusRequest(status: newStatus);
      final updatedApplication = await _jobApplicationApiService
          .changeApplicationStatus(applicationId, request);

      _updateApplicationInList(updatedApplication);
      _setSuccess('Status updated to ${newStatus}');
      return true;
    } on DioException catch (e) {
      _setError('Failed to update status: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Withdraw application
  Future<bool> withdrawApplication(int applicationId) async {
    _setLoading(true);
    _clearMessages();
    try {
      if (_currentUserId == null) {
        _setError('User not authenticated');
        return false;
      }

      final request = WithdrawApplicationRequest(userId: _currentUserId!);
      final updatedApplication = await _jobApplicationApiService
          .withdrawApplication(applicationId, request);

      _updateApplicationInList(updatedApplication);
      _setSuccess('Application withdrawn successfully');
      return true;
    } on DioException catch (e) {
      _setError('Failed to withdraw application: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // COMMENT MANAGEMENT
  // ============================================================================

  /// Add comment to application
  Future<bool> addComment(int applicationId, String text, int authorId) async {
    _setLoading(true);
    _clearMessages();
    try {
      final request = AddCommentRequest(
        text: text,
        authorId: authorId,
        status: 'visible',
      );

      await _jobApplicationApiService.addComment(applicationId, request);

      // Refresh application to get updated comments
      await getApplicationById(applicationId);
      _setSuccess('Comment added successfully');
      return true;
    } on DioException catch (e) {
      _setError('Failed to add comment: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update comment status
  Future<bool> updateCommentStatus(
    int applicationId,
    String commentId,
    String newStatus,
  ) async {
    _setLoading(true);
    _clearMessages();
    try {
      final request = UpdateCommentStatusRequest(status: newStatus);

      await _jobApplicationApiService.updateCommentStatus(
        applicationId,
        commentId,
        request,
      );

      _setSuccess('Comment status updated');
      return true;
    } on DioException catch (e) {
      _setError('Failed to update comment: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // PROFILE SHARING
  // ============================================================================

  /// Share or unshare profile with employer
  Future<bool> toggleShareProfile(int applicationId, bool share) async {
    _setLoading(true);
    _clearMessages();
    try {
      final request = ShareProfileRequest(shared: share);
      final updatedApplication = await _jobApplicationApiService.shareProfile(
        applicationId,
        request,
      );

      _updateApplicationInList(updatedApplication);
      _setSuccess(share ? 'Profile shared' : 'Profile unshared');
      return true;
    } on DioException catch (e) {
      _setError('Failed to update profile sharing: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // REVIEW NOTES
  // ============================================================================

  /// Add or update review notes
  Future<bool> addReviewNotes(int applicationId, String notes) async {
    _setLoading(true);
    _clearMessages();
    try {
      final request = AddReviewNotesRequest(notes: notes);
      final updatedApplication = await _jobApplicationApiService.addReviewNotes(
        applicationId,
        request,
      );

      _updateApplicationInList(updatedApplication);
      _setSuccess('Review notes added');
      return true;
    } on DioException catch (e) {
      _setError('Failed to add review notes: ${e.message}');
      return false;
    } catch (e) {
      _setError('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================================
  // FILTERING & SORTING
  // ============================================================================

  /// Set status filter
  void setStatusFilter(String status) {
    _statusFilter = status;
    _filterAndSort();
  }

  /// Set sort order
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _filterAndSort();
  }

  /// Apply filters and sorting
  void _filterAndSort() {
    // Apply status filter
    _filteredApplications = _userApplications;

    if (_statusFilter != 'all') {
      _filteredApplications =
          _filteredApplications
              .where((app) => app.status == _statusFilter)
              .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'oldest':
        _filteredApplications.sort(
          (a, b) => (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          ),
        );
        break;
      case 'status':
        _filteredApplications.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'recent':
      default:
        _filteredApplications.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );
    }

    notifyListeners();
  }

  /// Search applications by job title or company
  List<JobApplication> searchApplications(String query) {
    if (query.isEmpty) return _filteredApplications;

    return _filteredApplications
        .where(
          (app) {
            final lowerCaseQuery = query.toLowerCase();
            final jobTitleMatch = (app.jobDetails?.jobTitle ?? '')
                .toLowerCase()
                .contains(lowerCaseQuery);
            final applicantNameMatch = (app.applicant?.fullName ?? '')
                .toLowerCase()
                .contains(lowerCaseQuery);
            return jobTitleMatch || applicantNameMatch;
          },
        )
        .toList();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Prepare multipart files for upload
  Future<List<MultipartFile>> _prepareMultipartFiles(
    List<String> filePaths,
  ) async {
    List<MultipartFile> multipartFiles = [];

    for (String filePath in filePaths) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          multipartFiles.add(
            await MultipartFile.fromFile(
              filePath,
              filename: file.path.split('/').last,
            ),
          );
        }
      } catch (e) {
        _errorMessage = 'Error preparing file: $e';
      }
    }

    return multipartFiles;
  }

  /// Update application in list
  void _updateApplicationInList(JobApplication updatedApp) {
    final index = _userApplications.indexWhere(
      (app) => app.id == updatedApp.id,
    );
    if (index != -1) {
      _userApplications[index] = updatedApp;
      if (_selectedApplication?.id == updatedApp.id) {
        _selectedApplication = updatedApp;
      }
      _filterAndSort();
    }
  }

  /// Clear error and success messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Set success message
  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clearData() {
    _allApplications = [];
    _filteredApplications = [];
    _userApplications = [];
    _selectedApplication = null;
    _clearMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    clearData();
    super.dispose();
  }
}
