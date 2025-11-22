import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:jobportal/api/api_response.dart';
import 'package:jobportal/api/post_api_service.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';

class NetworkProvider with ChangeNotifier {
  // --- API Service ---
  final PostApiService _postApiService = ApiClient().postApiService;
  final LocalStorageService _storageService = LocalStorageService();

  // --- State ---
  final Set<int> _following = {};
  final Set<int> _likedPosts = {};
  final Set<int> _likedComments = {};

  // For the main feed
  List<CompanyPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = true;

  // For company-specific posts (e.g., on a company detail page)
  Map<int, List<CompanyPost>> _companyPosts = {};
  Map<int, bool> _companyPostsLoading = {};
  Map<int, int> _companyPostsCurrentPage = {};
  Map<int, int> _companyPostsTotalPages = {};

  // For the post detail screen
  CompanyPost? _currentPost;
  bool _isPostDetailLoading = false;

  // Authenticated user info
  int? _currentUserId;
  String _userType = 'user';

  // --- Constructor ---
  NetworkProvider() {
    _loadUserDataAndFetchPosts();
  }

  /// Load user data from storage and fetch posts
  Future<void> _loadUserDataAndFetchPosts() async {
    try {
      _currentUserId = _storageService.getUserId();
      _userType = _storageService.getUserType() ?? 'user';
      await fetchPosts();
    } catch (e) {
      print('Error loading user data: $e');
      await fetchPosts();
    }
  }

  // --- Getters ---
  UnmodifiableSetView<int> get following => UnmodifiableSetView(_following);
  UnmodifiableSetView<int> get likedPosts => UnmodifiableSetView(_likedPosts);
  UnmodifiableSetView<int> get likedComments =>
      UnmodifiableSetView(_likedComments);
  List<CompanyPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canLoadMorePosts => _hasNext;
  int? get currentUserId => _currentUserId;
  String get userType => _userType;

  // Getters for company-specific posts
  List<CompanyPost> getPostsForCompany(int companyId) =>
      _companyPosts[companyId] ?? [];
  bool isCompanyPostsLoading(int companyId) =>
      _companyPostsLoading[companyId] ?? false;
  bool canLoadMoreCompanyPosts(int companyId) {
    return (_companyPostsCurrentPage[companyId] ?? 1) <
        (_companyPostsTotalPages[companyId] ?? 1);
  }

  // Getters for post detail
  CompanyPost? get currentPost => _currentPost;
  bool get isPostDetailLoading => _isPostDetailLoading;

  // --- Methods ---

  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _posts.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _postApiService.getAllPosts(page: _currentPage);

      // Add posts
      _posts.addAll(response.data.posts);

      // Update pagination
      _totalPages = response.data.totalPages;
      _hasNext = response.data.hasNext;
      // ALWAYS update current page for next call
      _currentPage = (response.data.currentPage) + 1;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final errorResponse = ErrorResponse.fromJson(e.response!.data);
        _errorMessage = errorResponse.error;
      } else {
        _errorMessage = 'An unexpected network error occurred.';
      }
    } catch (e) {
      _errorMessage = 'An unknown error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostsByCompany(
    int companyId, {
    bool isRefresh = false,
  }) async {
    _companyPostsLoading[companyId] = true;
    if (isRefresh) {
      _companyPosts[companyId] = [];
      _companyPostsCurrentPage[companyId] = 1;
    }
    notifyListeners();

    try {
      final page = _companyPostsCurrentPage[companyId] ?? 1;
      final response = await _postApiService.getPostsByCompany(
        companyId,
        page: page,
      );

      _companyPosts[companyId] ??= [];

      _companyPosts[companyId]!.addAll(response.data.posts);
      _companyPostsTotalPages[companyId] = response.data.totalPages;

      if (response.data.hasNext) {
        _companyPostsCurrentPage[companyId] = (response.data.currentPage) + 1;
      }
    } catch (e) {
      // Handle error
      print('Error fetching company posts: $e');
    } finally {
      _companyPostsLoading[companyId] = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostById(int postId) async {
    _isPostDetailLoading = true;
    _currentPost = null;
    notifyListeners();

    try {
      final post = await _postApiService.getPostById(postId);
      _currentPost = post;
    } catch (e) {
      _errorMessage = 'Failed to load post details.';
      print('Error loading post details: $e');
    } finally {
      _isPostDetailLoading = false;
      notifyListeners();
    }
  }

  void loadMoreCompanyPosts(int companyId) {
    if (canLoadMoreCompanyPosts(companyId) &&
        !isCompanyPostsLoading(companyId)) {
      fetchPostsByCompany(companyId);
    }
  }

  void loadMorePosts() {
    // Corrected pagination check
    if (_hasNext && !_isLoading) {
      fetchPosts();
    }
  }

  Future<void> toggleLike(int postId, int userId) async {
    // Find the post from any of our lists to update it directly.
    CompanyPost? post;
    int postIndexInMainList = _posts.indexWhere((p) => p.id == postId);

    if (postIndexInMainList != -1) {
      post = _posts[postIndexInMainList];
    } else if (_currentPost?.id == postId) {
      post = _currentPost;
    } else {
      // Check company-specific post lists
      for (var list in _companyPosts.values) {
        int postIndexInCompanyList = list.indexWhere((p) => p.id == postId);
        if (postIndexInCompanyList != -1) {
          post = list[postIndexInCompanyList];
          break;
        }
      }
    }

    if (post == null) return; // Post not found, do nothing.

    final isLiked = _likedPosts.contains(postId);
    final originalLikesCount = post.likesCount;

    // Optimistically update UI
    if (isLiked) {
      _likedPosts.remove(postId);
      post.likesCount--;
    } else {
      _likedPosts.add(postId);
      post.likesCount++;
    }
    notifyListeners();

    try {
      final dynamic response = await _postApiService.togglePostLike(postId, {
        'userId': userId,
      });
      // Sync with the exact count from the backend response
      if (response is Map<String, dynamic> &&
          response.containsKey('likesCount')) {
        post.likesCount = response['likesCount'];
        notifyListeners();
      }
    } catch (e) {
      // Revert UI on failure
      if (isLiked) {
        _likedPosts.add(postId);
      } else {
        _likedPosts.remove(postId);
      }
      post.likesCount = originalLikesCount; // Revert to original count
      notifyListeners();
      // Optionally show an error message
    }
  }

  void toggleFollow(int companyId) {
    _following.contains(companyId)
        ? _following.remove(companyId)
        : _following.add(companyId);
    notifyListeners();
  }

  Future<Comment?> addComment(int postId, String text, int userId) async {
    try {
      final newComment = await _postApiService.addComment(postId, {
        'text': text,
        'userId': userId,
      });

      // Update the post's comment count
      CompanyPost? targetPost;
      int postIndexInMainList = _posts.indexWhere((p) => p.id == postId);

      if (postIndexInMainList != -1) {
        targetPost = _posts[postIndexInMainList];
      } else if (_currentPost?.id == postId) {
        targetPost = _currentPost;
      }

      if (targetPost != null) {
        targetPost.commentsCount++;
        (targetPost.comments ??= []).insert(0, newComment);
        notifyListeners();
      }

      return newComment;
    } catch (e) {
      debugPrint("Failed to add comment: $e");
      return null;
    }
  }

  Future<Comment?> addReplyToComment(
    int parentCommentId,
    String text,
    int userId,
  ) async {
    try {
      final newReply = await _postApiService.addReplyToComment(
        parentCommentId,
        {'text': text, 'userId': userId},
      );

      // Helper to recursively find the parent comment and add the reply
      bool findAndAddReply(List<Comment>? comments) {
        if (comments == null) return false;
        for (var comment in comments) {
          if (comment.id == parentCommentId) {
            (comment.replies ??= []).add(newReply);
            return true;
          }
          if (findAndAddReply(comment.replies)) {
            return true;
          }
        }
        return false;
      }

      // Update the UI for the currently viewed post
      if (_currentPost != null && findAndAddReply(_currentPost!.comments)) {
        notifyListeners();
      }

      return newReply;
    } catch (e) {
      debugPrint("Failed to add reply: $e");
      return null;
    }
  }

  Future<void> toggleCommentLike(int commentId, int userId) async {
    final isLiked = _likedComments.contains(commentId);

    // Optimistic UI update
    if (isLiked) {
      _likedComments.remove(commentId);
    } else {
      _likedComments.add(commentId);
    }
    notifyListeners();

    try {
      await _postApiService.toggleCommentLike(commentId, {'userId': userId});
    } catch (e) {
      // Revert on failure
      if (isLiked) {
        _likedComments.add(commentId);
      } else {
        _likedComments.remove(commentId);
      }
      notifyListeners();
    }
  }

  Future<void> deleteComment(int commentId, int postId, int userId) async {
    try {
      await _postApiService.deleteComment(commentId, {'userId': userId});

      // Find and update the post
      CompanyPost? targetPost;
      int postIndex = _posts.indexWhere((p) => p.id == postId);

      if (postIndex != -1) {
        targetPost = _posts[postIndex];
      } else if (_currentPost?.id == postId) {
        targetPost = _currentPost;
      }

      if (targetPost != null) {
        // Remove the comment and decrement count
        final initialCount = targetPost.comments?.length ?? 0;
        targetPost.comments?.removeWhere((c) => c.id == commentId);

        // Also remove from nested replies
        targetPost.comments?.forEach(
          (c) => c.replies?.removeWhere((r) => r.id == commentId),
        );

        final removedCount = initialCount - (targetPost.comments?.length ?? 0);
        targetPost.commentsCount =
            targetPost.commentsCount > removedCount
                ? targetPost.commentsCount - removedCount
                : 0;

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to delete comment: $e");
    }
  }

  Future<Comment?> updateComment(
    int commentId,
    String newText,
    int userId,
  ) async {
    try {
      final updatedComment = await _postApiService.updateComment(commentId, {
        'text': newText,
        'userId': userId,
      });

      // Find and update the comment in the local data
      bool findAndUpdateComment(List<Comment>? comments) {
        if (comments == null) return false;
        for (var i = 0; i < comments.length; i++) {
          if (comments[i].id == commentId) {
            comments[i] = updatedComment;
            return true;
          }
          if (findAndUpdateComment(comments[i].replies)) {
            return true;
          }
        }
        return false;
      }

      if (_currentPost != null &&
          findAndUpdateComment(_currentPost!.comments)) {
        notifyListeners();
      }

      // Also check main posts list
      for (var post in _posts) {
        if (findAndUpdateComment(post.comments)) {
          notifyListeners();
          break;
        }
      }

      return updatedComment;
    } catch (e) {
      debugPrint("Failed to update comment: $e");
      return null;
    }
  }
}
