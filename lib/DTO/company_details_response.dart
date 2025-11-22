import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/company.dart';
import 'package:jobportal/model.dart/job.dart';

part 'company_details_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CompanyDetailsResponse {
  final Company company;
  final List<Job> jobs;

  CompanyDetailsResponse({
    required this.company,
    required this.jobs,
  });

  factory CompanyDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$CompanyDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDetailsResponseToJson(this);
}
