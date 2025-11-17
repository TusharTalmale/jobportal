import 'package:dio/dio.dart';
import 'package:jobportal/api/auth_api_service.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/api/company_api_service.dart';
import 'package:jobportal/api/job_api_service.dart';
import 'package:jobportal/api/post_api_service.dart';

/// A singleton class to manage the Dio instance and API services.
/// This ensures that we have a single point of configuration for networking.
class ApiClient {
  // Private constructor to prevent direct instantiation.
  ApiClient._internal();

  // The single, static, private instance of the class.
  static final ApiClient _instance = ApiClient._internal();

  // A factory constructor that returns the singleton instance.
  factory ApiClient() => _instance;

  // The single Dio instance used throughout the app.
  // All configurations like base URL, timeouts, and interceptors are set here.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  )..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // Getter for the authentication API service.
  AuthApiService get authApiService => AuthApiService(_dio);

  // Getter for the job API service.
  JobApiService get jobApiService => JobApiService(_dio);

  // Getter for the company API service.
  CompanyApiService get companyApiService => CompanyApiService(_dio);

  // Getter for the post API service.
  PostApiService get postApiService => PostApiService(_dio);
}
