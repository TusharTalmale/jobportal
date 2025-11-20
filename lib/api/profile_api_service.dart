
import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/user_profile.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ProfileApiService {
  factory ProfileApiService(Dio dio, {String baseUrl}) = _ProfileApiService;

  @GET(ApiConstants.userById)
  Future<UserProfile> getProfile(@Path("id") int userId);

  @PUT(ApiConstants.userById)
  @MultiPart()
  Future<UserProfile> updateProfile(
    @Path("id") int userId,
    @Body() FormData formData,
  );
}
