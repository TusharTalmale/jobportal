import 'package:flutter/material.dart';

import 'package:jobportal/api/post_api_service.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/provider/api_client.dart';
import 'package:jobportal/socket_service/local_storage_service.dart';
import '../api/company_api_service.dart';

class NetworkProvider with ChangeNotifier {
  final PostApiService _postApiService = ApiClient().postApiService;
  final CompanyApiService _companyApiService = ApiClient().companyApiService;
  final LocalStorageService _storageService = LocalStorageService();

  // -----------------------------
  // Core State
  // -----------------------------
  List<CompanyPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasNext = true;

  Map<int, List<CompanyPost>> _companyPosts = {};
  Map<int, bool> _companyPostsLoading = {};
  Map<int, int> _companyPostsCurrentPage = {};
  Map<int, int> _companyPostsTotalPages = {};

  CompanyPost? _currentPost;
  bool _isPostDetailLoading = false;

  int? _currentUserId;
  String _userType = 'user';

  // -----------------------------
  // Constructor
  // -----------------------------
  NetworkProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _currentUserId = _storageService.getUserId();
      _userType = _storageService.getUserType() ?? 'user';
    } catch (_) {}
    await fetchPosts();
  }

  // -----------------------------
  // Getters
  // -----------------------------
  List<CompanyPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get canLoadMorePosts => _hasNext;
  int? get currentUserId => _currentUserId;

  CompanyPost? get currentPost => _currentPost;
  bool get isPostDetailLoading => _isPostDetailLoading;

  List<CompanyPost> getPostsForCompany(int id) =>
      _companyPosts[id] ?? [];

  bool isCompanyPostsLoading(int id) =>
      _companyPostsLoading[id] ?? false;

  bool canLoadMoreCompanyPosts(int id) {
    return (_companyPostsCurrentPage[id] ?? 1) <
        (_companyPostsTotalPages[id] ?? 1);
  }

  // -----------------------------
  // Fetch Feed Posts
  // -----------------------------
  Future<void> fetchPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _posts.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final resp = await _postApiService.getAllPosts(
        page: _currentPage,
        userId: _currentUserId,
      );

      _posts.addAll(resp.data.posts);
      _hasNext = resp.data.hasNext;
      _currentPage = resp.data.currentPage + 1;
    } catch (e) {
      _errorMessage = "Could not load posts";
    }

    _isLoading = false;
    notifyListeners();
  }

  // -----------------------------
  // Fetch Company Posts
  // -----------------------------
  Future<void> fetchPostsByCompany(int companyId,
      {bool isRefresh = false}) async {
    _companyPostsLoading[companyId] = true;
    notifyListeners();

    try {
      if (isRefresh) {
        _companyPosts[companyId] = [];
        _companyPostsCurrentPage[companyId] = 1;
      }

      final page = _companyPostsCurrentPage[companyId] ?? 1;

      final resp = await _postApiService.getPostsByCompany(
        companyId,
        page: page,
        userId: _currentUserId,
      );

      _companyPosts[companyId] ??= [];
      _companyPosts[companyId]!.addAll(resp.data.posts);
      _companyPostsTotalPages[companyId] = resp.data.totalPages;

      if (resp.data.hasNext) {
        _companyPostsCurrentPage[companyId] = resp.data.currentPage + 1;
      }
    } catch (e) {
      print("Company posts error: $e");
    }

    _companyPostsLoading[companyId] = false;
    notifyListeners();
  }

  void loadMorePosts() {
    if (_hasNext && !_isLoading) fetchPosts();
  }

  void loadMoreCompanyPosts(int companyId) {
    if (canLoadMoreCompanyPosts(companyId) &&
        !isCompanyPostsLoading(companyId)) {
      fetchPostsByCompany(companyId);
    }
  }

  // -----------------------------
  // Post Detail
  // -----------------------------
  Future<void> fetchPostById(int postId) async {
    _isPostDetailLoading = true;
    notifyListeners();

    try {
      _currentPost = await _postApiService.getPostById(postId);
    } catch (_) {
      _errorMessage = "Failed to load post";
    }

    _isPostDetailLoading = false;
    notifyListeners();
  }

  // -----------------------------
  // Like/Unlike Post
  // -----------------------------
  Future<void> toggleLike(int postId, int userId) async {
    CompanyPost? post = _findPost(postId);

    if (post == null) return;

    final oldLiked = post.isLiked;
    final oldCount = post.likesCount;

    // optimistic
    post.isLiked = !post.isLiked;
    post.likesCount += post.isLiked ? 1 : -1;
    notifyListeners();

    try {
      final res = await _postApiService.togglePostLike(
        postId,
        {"userId": userId},
      );

      post.likesCount = res.likesCount;
      post.isLiked = res.action == "liked";
    } catch (_) {
      post.isLiked = oldLiked;
      post.likesCount = oldCount;
    }

    notifyListeners();
  }

  CompanyPost? _findPost(int postId) {
    for (var p in _posts) {
      if (p.id == postId) return p;
    }
    for (var list in _companyPosts.values) {
      for (var p in list) {
        if (p.id == postId) return p;
      }
    }
    if (_currentPost?.id == postId) return _currentPost;
    return null;
  }

  // -----------------------------
  // Follow / Unfollow Company
  // -----------------------------
  Future<void> toggleFollowCompany(Company company) async {
    if (_currentUserId == null) return;

    final oldStatus = company.isFollowed;
    final oldCount = company.followersCount ?? 0;

    company.isFollowed = !company.isFollowed;
    company.followersCount =
        (company.followersCount ?? 0) + (company.isFollowed ? 1 : -1);

    notifyListeners();

    try {
      await _companyApiService.toggleFollowCompany(
        company.id,
        _currentUserId!,
      );
    } catch (_) {
      company.isFollowed = oldStatus;
      company.followersCount = oldCount;
      notifyListeners();
    }
  }

  // -----------------------------
  // Comments
  // -----------------------------
  Future<Comment?> addComment(int postId, String text, int userId) async {
    try {
      final comment = await _postApiService.addComment(
        postId,
        {"text": text, "userId": userId},
      );

      CompanyPost? post = _findPost(postId);
      if (post != null) {
        post.commentsCount++;
        (post.comments ??= []).insert(0, comment);
        notifyListeners();
      }

      return comment;
    } catch (_) {
      return null;
    }
  }

  Future<Comment?> addReplyToComment(
      int parentId, String text, int userId) async {
    try {
      final reply = await _postApiService.addReplyToComment(
        parentId,
        {"text": text, "userId": userId},
      );

      _addReplyRecursive(_currentPost?.comments, parentId, reply);

      notifyListeners();
      return reply;
    } catch (_) {
      return null;
    }
  }

  bool _addReplyRecursive(
      List<Comment>? comments, int parentId, Comment reply) {
    if (comments == null) return false;

    for (var c in comments) {
      if (c.id == parentId) {
        c.replies.add(reply);
        return true;
      }
      if (_addReplyRecursive(c.replies, parentId, reply)) {
        return true;
      }
    }
    return false;
  }

  Future<void> toggleCommentLike(Comment c, int userId) async {
    final oldLiked = c.isLikedByUser;
    final oldCount = c.likesCount;

    c.isLikedByUser = !c.isLikedByUser;
    c.likesCount += c.isLikedByUser ? 1 : -1;

    notifyListeners();

    try {
      final res =
          await _postApiService.toggleCommentLike(c.id, {'userId': userId});

      c.isLikedByUser = res.action == "liked";
      c.likesCount = res.likesCount;
    } catch (_) {
      c.isLikedByUser = oldLiked;
      c.likesCount = oldCount;
    }

    notifyListeners();
  }

  Future<void> deleteComment(int commentId, int postId, int userId) async {
    try {
      await _postApiService.deleteComment(
        commentId,{'userId' : currentUserId!}
      );

      CompanyPost? post = _findPost(postId);

      if (post != null) {
        _removeCommentRecursive(post.comments, commentId);
        post.commentsCount--;
        notifyListeners();
      }
    } catch (_) {}
  }

  bool _removeCommentRecursive(List<Comment>? comments, int id) {
    if (comments == null) return false;

    int idx = comments.indexWhere((c) => c.id == id);
    if (idx != -1) {
      comments.removeAt(idx);
      return true;
    }

    for (var c in comments) {
      if (_removeCommentRecursive(c.replies, id)) {
        return true;
      }
    }

    return false;
  }

  Future<Comment?> updateComment(
      int commentId, String text, int userId) async {
    try {
      final updated = await _postApiService.updateComment(
        commentId,
        {'text': text, 'userId': userId},
      );

      _updateCommentRecursive(_currentPost?.comments, updated);
      notifyListeners();

      return updated;
    } catch (_) {
      return null;
    }
  }

  bool _updateCommentRecursive(
      List<Comment>? comments, Comment updated) {
    if (comments == null) return false;

    for (var i = 0; i < comments.length; i++) {
      if (comments[i].id == updated.id) {
        comments[i] = updated;
        return true;
      }
      if (_updateCommentRecursive(comments[i].replies, updated)) {
        return true;
      }
    }
    return false;
  }

Future<List<Comment>> loadComments(int postId) async {
  try {
    final userId = _currentUserId;

    final response = await _postApiService.getCommentsforPost(
      postId,
      userId!,
    );

    return response;
  } catch (e) {
    debugPrint("Failed loading comments: $e");
    return [];
  }
}

  
}
