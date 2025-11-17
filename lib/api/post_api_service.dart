import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:retrofit/retrofit.dart';

part 'post_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class PostApiService {
  factory PostApiService(Dio dio, {String baseUrl}) = _PostApiService;

  // --- Post Endpoints ---

  @GET("/api/posts")
  Future<PaginatedPostsResponse> getAllPosts({
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
  });

  @GET("/api/posts/{postId}")
  Future<CompanyPost> getPostById(@Path("postId") int postId);

  @GET("/api/company/{companyId}/posts")
  Future<PaginatedPostsResponse> getPostsByCompany(
    @Path("companyId") int companyId, {
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
  });

  @POST("/api/posts/{postId}/toggle-like")
  Future<dynamic> togglePostLike(
    @Path("postId") int postId,
    @Body() Map<String, int> body, // e.g., {"userId": 1}
  );

  // --- Comment Endpoints ---

  @POST("/api/posts/{postId}/comments")
  Future<Comment> addComment(
    @Path("postId") int postId,
    @Body() Map<String, dynamic> body, // {"userId": 1, "text": "..."}
  );

  @POST("/api/comments/{commentId}/replies")
  Future<Comment> addReplyToComment(
    @Path("commentId") int commentId,
    @Body() Map<String, dynamic> body, // {"userId": 1, "text": "..."}
  );

  @POST("/api/comments/{commentId}/toggle-like")
  Future<dynamic> toggleCommentLike(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body, // {"userId": 1}
  );

  @DELETE("/api/comments/{commentId}")
  Future<void> deleteComment(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body, // {"userId": 1} for authorization
  );
}
