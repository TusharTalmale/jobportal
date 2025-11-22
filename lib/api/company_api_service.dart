import 'package:dio/dio.dart';
import 'package:jobportal/DTO/api_paginated_companies_response.dart';
import 'package:jobportal/DTO/company_details_response.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:retrofit/retrofit.dart';

part 'company_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class CompanyApiService {
  factory CompanyApiService(Dio dio, {String baseUrl}) = _CompanyApiService;

  @GET(ApiConstants.companies)
  Future<List<Company>> getAllCompanies();

  @GET("/api/company/{id}")
  Future<CompanyDetailsResponse> getCompanyById(
    @Path("id") int id,
    @Query("userId") int userId,
  );
  @GET(ApiConstants.companiesByPagination)
  Future<ApiPaginatedCompaniesResponse> getCompaniesPaginated(
    @Query("page") int page,
    @Query("limit") int limit, {
    @Query("search") String? search,
    @Query("userId") int? userId,
  });

  @POST(ApiConstants.companies)
  @MultiPart()
  Future<Company> createCompany(
    @Part(name: "name") String name,
    @Part(name: "industry") String industry,
    @Part(name: "description") String description,
    @Part(name: "website") String website, {
    @Part(name: "companyLogo") List<MultipartFile>? companyLogo,
    @Part(name: "company_gallery") List<MultipartFile>? companyGallery,
  });

  @PUT(ApiConstants.companyById)
  @MultiPart()
  Future<Company> updateCompany(
    @Path("id") int id,
    @Part(name: "name") String name,
    @Part(name: "industry") String industry,
    @Part(name: "description") String description,
    @Part(name: "website") String website, {
    @Part(name: "companyLogo") List<MultipartFile>? companyLogo,
    @Part(name: "company_gallery") List<MultipartFile>? companyGallery,
  });

  @DELETE(ApiConstants.companyById)
  Future<void> deleteCompany(@Path("id") int id);

    // Toggle follow
  @POST("/api/company/{companyId}/user/{userId}/toggle-follow")
  Future<void> toggleFollowCompany(
    @Path("companyId") int companyId,
    @Path("userId") int userId,
  );

  // Get companies followed by user
  @GET("/api/user/{userId}/followed-companies")
  Future<List<Company>> getFollowedCompanies(
    @Path("userId") int userId,
  );
}
