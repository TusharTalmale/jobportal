import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/job.dart';

part 'company_details_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CompanyDetailsResponse {
  final bool success;
  final CompanyDetails data;

  CompanyDetailsResponse({
    required this.success,
    required this.data,
  });

  factory CompanyDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CompanyDetails {
  final Company company;
  final List<Job> jobs;

  CompanyDetails({
    required this.company,
    required this.jobs,
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailsToJson(this);
}
