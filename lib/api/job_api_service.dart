// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:dio/dio.dart';
import 'package:jobportal/DTO/api_paginated_jobs_response.dart';
import 'package:jobportal/DTO/job_details_response.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:retrofit/retrofit.dart';

part 'job_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class JobApiService {
  factory JobApiService(Dio dio, {String baseUrl}) = _JobApiService;

  @GET(ApiConstants.jobs)
  Future<List<Job>> getAllJobs();

  // 🔥 UPDATED
  @GET(ApiConstants.jobById) // "/Job/{id}"
  Future<JobDetailsResponse> getJobDetails(@Path("id") int id , @Query("userId") int userId);

  @GET(ApiConstants.jobsByPagination)
  Future<ApiPaginatedJobsResponse> getJobsPaginated(
    @Query("page") int page,
    @Query("limit") int limit, {
    @Query("search") String? search,
    @Query("jobType") String? jobType,
    @Query("workpLaceType") String? workpLaceType,
    @Query("companyId") int? companyId,
    @Query("city") String? city,
    @Query("minSalary") int? minSalary,
    @Query("maxSalary") int? maxSalary,
    @Query("specialization") String? specialization,
    @Query("experience") String? experience,
    @Query("postedDate") String? postedDate,
    @Query("userId") int? userId,  // 👈 required manual userId
  });

  @POST(ApiConstants.jobs)
  @MultiPart()
  Future<Job> createJob(
    @Part(name: "title") String title,
    @Part(name: "description") String description,
    @Part(name: "companyId") int companyId,
    @Part(name: "location") String location,
    @Part(name: "type") String type,
    @Part(name: "salary") double salary, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFile,
  });

  @PUT(ApiConstants.jobById)
  @MultiPart()
  Future<Job> updateJob(
    @Path("id") int id,
    @Part(name: "title") String title,
    @Part(name: "description") String description,
    @Part(name: "companyId") int companyId,
    @Part(name: "location") String location,
    @Part(name: "type") String type,
    @Part(name: "salary") double salary, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFile,
  });

  @DELETE(ApiConstants.jobById)
  Future<void> deleteJob(@Path("id") int id);
}
