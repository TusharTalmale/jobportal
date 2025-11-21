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

  @GET(ApiConstants.posts)
  Future<PaginatedPostsResponse> getAllPosts({
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
  });

  @GET(ApiConstants.postById)
  Future<CompanyPost> getPostById(@Path("postId") int postId);

  @GET(ApiConstants.companyPosts)
  Future<PaginatedPostsResponse> getPostsByCompany(
    @Path("companyId") int companyId, {
    @Query("page") int page = 1,
    @Query("limit") int limit = 15,
  });

  @POST(ApiConstants.togglePostLike)
  Future<dynamic> togglePostLike(
    @Path("postId") int postId,
    @Body() Map<String, int> body, // e.g., {"userId": 1}
  );

  // --- Comment Endpoints ---

  @POST(ApiConstants.postComments)
  Future<Comment> addComment(
    @Path("postId") int postId,
    @Body() Map<String, dynamic> body, // {"userId": 1, "text": "..."}
  );

  @POST(ApiConstants.commentReplies)
  Future<Comment> addReplyToComment(
    @Path("commentId") int commentId,
    @Body() Map<String, dynamic> body, // {"userId": 1, "text": "..."}
  );

  @POST(ApiConstants.toggleCommentLike)
  Future<dynamic> toggleCommentLike(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body, // {"userId": 1}
  );

  @DELETE(ApiConstants.deleteComment)
  Future<void> deleteComment(
    @Path("commentId") int commentId,
    @Body() Map<String, int> body, // {"userId": 1} for authorization
  );

  // --- Bulk & Additional Endpoints ---

  @POST(ApiConstants.posts)
  @MultiPart()
  Future<CompanyPost> createPost(
    @Part(name: "title") String title,
    @Part(name: "description") String? description,
    @Part(name: "companyId") int companyId,
    @Part(name: "postType") String postType, {
    @Part(name: "fileUrl") List<MultipartFile>? fileUrl,
    @Part(name: "tags") List<String>? tags,
  });

  @PUT(ApiConstants.postById)
  @MultiPart()
  Future<CompanyPost> updatePost(
    @Path("postId") int postId,
    @Part(name: "title") String title,
    @Part(name: "description") String? description,
    @Part(name: "postType") String postType, {
    @Part(name: "fileUrl") List<MultipartFile>? fileUrl,
    @Part(name: "tags") List<String>? tags,
  });

  @DELETE(ApiConstants.postById)
  Future<void> deletePost(@Path("postId") int postId);

  @PUT(ApiConstants.deleteComment)
  Future<Comment> updateComment(
    @Path("commentId") int commentId,
    @Body() Map<String, dynamic> body, // {"text": "...", "userId": 1}
  );
}
