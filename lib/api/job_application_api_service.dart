import 'package:dio/dio.dart';
import 'package:jobportal/model.dart/job_application_comment.dart';
import 'package:retrofit/retrofit.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/application_response.dart';
import 'package:jobportal/model.dart/job_application.dart';

part 'job_application_api_service.g.dart';

/// Production-grade Retrofit service for Job Application API
@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class JobApplicationApiService {
  factory JobApplicationApiService(Dio dio, {String baseUrl}) =
      _JobApplicationApiService;

  /// Get all job applications with job and applicant details
  @GET(ApiConstants.applyJob)
  Future<List<JobApplication>> getAllApplications();

  /// Get a specific job application by ID
  @GET(ApiConstants.applyJobById)
  Future<JobApplication> getApplicationById(@Path("id") int id);

  /// Create a new job application with file upload
  @POST(ApiConstants.applyJob)
  @MultiPart()
  Future<ApplicationResponse> createApplication(
    @Part(name: "jobID") int jobId,
    @Part(name: "userID") int userId, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFiles,
  });

  /// Update a job application
  @PUT(ApiConstants.applyJobById)
  @MultiPart()
  Future<JobApplication> updateApplication(
    @Path("id") int id,
    @Part(name: "userID") int userId, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFiles,
  });

  /// Delete a job application
  @DELETE(ApiConstants.applyJobById)
  Future<void> deleteApplication(@Path("id") int id);

  /// Change application status (applied, withdrawn, shortlisted, interviewed, rejected, hired)
  @PUT(ApiConstants.applyJobStatus)
  Future<JobApplication> changeApplicationStatus(
    @Path("id") int id,
    @Body() UpdateApplicationStatusRequest request,
  );

  /// Withdraw a job application
  @PUT(ApiConstants.applyJobWithdraw)
  Future<JobApplication> withdrawApplication(
    @Path("id") int id,
    @Body() WithdrawApplicationRequest request,
  );

  /// Add a comment to the application
  @POST(ApiConstants.applyJobComment)
  Future<JobApplicationComment> addComment(
    @Path("id") int id,
    @Body() AddCommentRequest request,
  );

  /// Update comment status (visible/hidden)
  @PUT(ApiConstants.applyJobCommentStatus)
  Future<JobApplicationComment> updateCommentStatus(
    @Path("id") int id,
    @Path("commentId") String commentId,
    @Body() UpdateCommentStatusRequest request,
  );

  /// Share/unshare profile with employer
  @PUT(ApiConstants.applyJobShareProfile)
  Future<JobApplication> shareProfile(
    @Path("id") int id,
    @Body() ShareProfileRequest request,
  );

  /// Add or update review notes
  @PUT(ApiConstants.applyJobReview)
  Future<JobApplication> addReviewNotes(
    @Path("id") int id,
    @Body() AddReviewNotesRequest request,
  );
}
