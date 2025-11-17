import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/api/api_response.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiConstants.signupSendOtp)
  Future<MessageResponse> signupSendOtp(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signupVerifyOtp)
  Future<AuthResponse> signupVerifyOtp(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.loginSendOtp)
  Future<MessageResponse> loginSendOtp(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.loginVerifyOtp)
  Future<AuthResponse> loginVerifyOtp(@Body() Map<String, dynamic> body);
}
