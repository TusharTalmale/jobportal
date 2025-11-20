import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:jobportal/api/api_constants.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:retrofit/retrofit.dart';

part 'company_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class CompanyApiService {
  factory CompanyApiService(Dio dio, {String baseUrl}) = _CompanyApiService;

  @GET(ApiConstants.companies)
  Future<List<Company>> getAllCompanies();

  @GET(ApiConstants.companyById)
  Future<Company> getCompanyById(@Path("id") int id);

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
}
