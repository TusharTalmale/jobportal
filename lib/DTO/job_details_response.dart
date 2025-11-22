import 'package:jobportal/model.dart/job.dart';
import 'package:json_annotation/json_annotation.dart';

part 'job_details_response.g.dart';

@JsonSerializable(explicitToJson: true)
class JobDetailsResponse {
  final Job job;
  final List<Job> similarJobs;

  JobDetailsResponse({required this.job, required this.similarJobs});

  factory JobDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$JobDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JobDetailsResponseToJson(this);
}
