import 'package:json_annotation/json_annotation.dart';
import 'package:jobportal/model.dart/job_application.dart';

part 'application_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ApplicationResponse {
  final String message;
  final JobApplication application;

  ApplicationResponse({required this.message, required this.application});

  factory ApplicationResponse.fromJson(Map<String, dynamic> json) =>
      _$ApplicationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationResponseToJson(this);
}