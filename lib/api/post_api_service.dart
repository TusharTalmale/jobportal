import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/company_post.dart';
import 'package:jobportal/model.dart/comment.dart';
import 'package:retrofit/retrofit.dart';

part 'post_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class PostApiService {
  factory PostApiService(Dio dio, {String baseUrl}) = _PostApiService;

  @GET(ApiConstants.posts)
  Future<PaginatedPostsResponse> getAllPosts({
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
    @Query("userId") int? userId,
  });

  @GET(ApiConstants.companyPosts)
  Future<PaginatedPostsResponse> getPostsByCompany(
    @Path("companyId") int companyId, {
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
    @Query("userId") int? userId,
  });

  @GET(ApiConstants.postById)
  Future<CompanyPost> getPostById(@Path("postId") int postId);

  @POST(ApiConstants.togglePostLike)
  Future<PostLikeResponse> togglePostLike(
    @Path("postId") int postId,
    @Body() Map<String, int> body,
  );

  @POST(ApiConstants.postComments)
  Future<Comment> addComment(
    @Path("postId") int postId,
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.commentReplies)
  Future<Comment> addReplyToComment(
    @Path("commentId") int commentId,
    @Body() Map<String, dynamic> body,
  );

  @POST(ApiConstants.toggleCommentLike)
  Future<PostLikeResponse> toggleCommentLike(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body,
  );

  @GET("/api/posts/{postId}/comments/user-likes")
  Future<List<Comment>> getCommentsforPost(
    @Path("postId") int postId,
    @Query("userId") int userId,
  );
  @DELETE("/api/comments/{commentId}")
  Future<void> deleteComment(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body,
  );

  @PUT(ApiConstants.deleteComment)
  Future<Comment> updateComment(
    @Path("commentId") int commentId,
    @Body() Map<String, dynamic> body, // {"text": "...", "userId": 1}
  );
}
