import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/job.dart';
import 'package:retrofit/retrofit.dart';

part 'job_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class JobApiService {
  factory JobApiService(Dio dio, {String baseUrl}) = _JobApiService;

  @GET(ApiConstants.jobs)
  Future<List<Job>> getAllJobs();

  @GET(ApiConstants.jobById)
  Future<Job> getJobById(@Path("id") int id);

  @POST(ApiConstants.jobs)
  @MultiPart()
  Future<Job> createJob(
    @Part() Map<String, dynamic> data, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFile,
  });

  @PUT(ApiConstants.jobById)
  @MultiPart()
  Future<Job> updateJob(
    @Path("id") int id,
    @Part() Map<String, dynamic> data, {
    @Part(name: "resumeFile") List<MultipartFile>? resumeFile,
  });

  @DELETE(ApiConstants.jobById)
  Future<void> deleteJob(@Path("id") int id);
}
