// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApplicationResponse _$ApplicationResponseFromJson(Map<String, dynamic> json) =>
    ApplicationResponse(
      message: json['message'] as String,
      application: JobApplication.fromJson(
        json['application'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ApplicationResponseToJson(
  ApplicationResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'application': instance.application.toJson(),
};
