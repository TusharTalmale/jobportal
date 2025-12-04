import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jobportal/api/job_application_api_service.dart';
import 'package:jobportal/model.dart/job_application.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';

class JobApplicationProvider extends ChangeNotifier {
  // API & Local Storage
  final JobApplicationApiService _api = ApiClient().jobApplicationApiService;
  final LocalStorageService _storage = LocalStorageService();

  // Pagination State
  List<JobApplication> _applications = [];
  List<JobApplication> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadMore = false;
  bool get isLoadMore => _isLoadMore;

  int _page = 1;
  bool _hasNext = true;

  // User Data
  int? _currentUserId;
  int get userId => _currentUserId!;

  JobApplicationProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    _currentUserId = _storage.getUserId();
  }

  // -------------------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------------------
  Future<void> loadFirstPage() async {
    if (_currentUserId == null) return;

    _applications.clear();
    _page = 1;
    _hasNext = true;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getAppliedJobsPaginated(userId, 1, 10);

      _applications = res.applications;
      _hasNext = res.pagination.hasNext;
      _page = 2;
    } catch (e) {
      print("❌ First page error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // LOAD MORE (INFINITE SCROLL)
  // -------------------------------------------------------------
  Future<void> loadMore() async {
    if (!_hasNext || _isLoadMore) return;

    _isLoadMore = true;
    notifyListeners();

    try {
      final res = await _api.getAppliedJobsPaginated(userId, _page, 10);

      _applications.addAll(res.applications);
      _hasNext = res.pagination.hasNext;
      _page++;
    } catch (e) {
      print("❌ loadMore error: $e");
    }

    _isLoadMore = false;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // APPLY JOB (with multipart)
  // -------------------------------------------------------------
  Future<bool> applyForJob({
    required int jobId,
    List<String>? resumePaths,
  }) async {
    if (_currentUserId == null) return false;

    try {
      List<MultipartFile>? files;
      if (resumePaths != null && resumePaths.isNotEmpty) {
        files = await _prepareMultipart(resumePaths);
      }

      final res = await _api.createApplication(
        jobId,
        userId,
        resumeFiles: files,
      );

      /// Add newly created application at the top
      _applications.insert(0, res.application);
      notifyListeners();

      return true;
    } catch (e) {
      print("❌ Apply job error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // WITHDRAW APPLICATION
  // -------------------------------------------------------------
  Future<bool> withdraw(int applicationId) async {
    try {
      final res = await _api.withdrawApplication(
        applicationId,
        WithdrawApplicationRequest(userId: userId),
      );

      _updateItem(res);
      return true;
    } catch (e) {
      print("❌ Withdraw error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // CHANGE STATUS
  // -------------------------------------------------------------
  Future<bool> updateStatus(int id, String newStatus) async {
    try {
      final res = await _api.changeApplicationStatus(
        id,
        UpdateApplicationStatusRequest(status: newStatus),
      );

      _updateItem(res);
      return true;
    } catch (e) {
      print("❌ Status update error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // ADD COMMENT
  // -------------------------------------------------------------
  Future<bool> addComment(int id, String text) async {
    try {
      await _api.addComment(
        id,
        AddCommentRequest(
          text: text,
          authorId: userId,
        ),
      );
      return true;
    } catch (e) {
      print("❌ Add comment error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // UPDATE COMMENT
  // -------------------------------------------------------------
  Future<bool> updateCommentStatus(
      int appId, String commentId, String status) async {
    try {
      await _api.updateCommentStatus(
        appId,
        commentId,
        UpdateCommentStatusRequest(status: status),
      );
      return true;
    } catch (e) {
      print("❌ Update comment error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // SHARE PROFILE
  // -------------------------------------------------------------
  Future<bool> toggleShare(int id, bool value) async {
    try {
      final res = await _api.shareProfile(
        id,
        ShareProfileRequest(shared: value),
      );
      _updateItem(res);
      return true;
    } catch (e) {
      print("❌ Share profile error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // REVIEW NOTES
  // -------------------------------------------------------------
  Future<bool> addReviewNotes(int id, String notes) async {
    try {
      final res = await _api.addReviewNotes(
        id,
        AddReviewNotesRequest(notes: notes),
      );
      _updateItem(res);
      return true;
    } catch (e) {
      print("❌ Review notes error: $e");
      return false;
    }
  }

  // -------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------
  Future<List<MultipartFile>> _prepareMultipart(List<String> paths) async {
    return Future.wait(
      paths.map(
        (p) async => MultipartFile.fromFile(p, filename: p.split('/').last),
      ),
    );
  }

  void _updateItem(JobApplication updated) {
    final index = _applications.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _applications[index] = updated;
      notifyListeners();
    }
  }


  
}
