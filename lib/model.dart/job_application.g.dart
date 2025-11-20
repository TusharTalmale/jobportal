// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplication _$JobApplicationFromJson(
  Map<String, dynamic> json,
) => JobApplication(
  id: (json['id'] as num).toInt(),
  jobId: (json['jobID'] as num).toInt(),
  userId: (json['userID'] as num).toInt(),
  status: json['status'] as String,
  resumeFiles:
      (json['resumeFile'] as List<dynamic>?)?.map((e) => e as String).toList(),
  sharedProfile: json['sharedProfile'] as bool? ?? false,
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map(
            (e) => JobApplicationComment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  reviewNotes: json['reviewNotes'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  jobDetails: json['jobDetails'],
  applicant: json['applicant'],
);

Map<String, dynamic> _$JobApplicationToJson(JobApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobID': instance.jobId,
      'userID': instance.userId,
      'status': instance.status,
      'resumeFile': instance.resumeFiles,
      'sharedProfile': instance.sharedProfile,
      'comments': instance.comments?.map((e) => e.toJson()).toList(),
      'reviewNotes': instance.reviewNotes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      if (instance.jobDetails case final value?) 'jobDetails': value,
      if (instance.applicant case final value?) 'applicant': value,
    };

CreateJobApplicationRequest _$CreateJobApplicationRequestFromJson(
  Map<String, dynamic> json,
) => CreateJobApplicationRequest(
  jobId: (json['jobID'] as num).toInt(),
  userId: (json['userID'] as num).toInt(),
);

Map<String, dynamic> _$CreateJobApplicationRequestToJson(
  CreateJobApplicationRequest instance,
) => <String, dynamic>{'jobID': instance.jobId, 'userID': instance.userId};

UpdateApplicationStatusRequest _$UpdateApplicationStatusRequestFromJson(
  Map<String, dynamic> json,
) => UpdateApplicationStatusRequest(status: json['status'] as String);

Map<String, dynamic> _$UpdateApplicationStatusRequestToJson(
  UpdateApplicationStatusRequest instance,
) => <String, dynamic>{'status': instance.status};

WithdrawApplicationRequest _$WithdrawApplicationRequestFromJson(
  Map<String, dynamic> json,
) => WithdrawApplicationRequest(userId: (json['userId'] as num).toInt());

Map<String, dynamic> _$WithdrawApplicationRequestToJson(
  WithdrawApplicationRequest instance,
) => <String, dynamic>{'userId': instance.userId};

AddCommentRequest _$AddCommentRequestFromJson(Map<String, dynamic> json) =>
    AddCommentRequest(
      text: json['text'] as String,
      authorId: (json['authorId'] as num).toInt(),
      status: json['status'] as String? ?? 'visible',
    );

Map<String, dynamic> _$AddCommentRequestToJson(AddCommentRequest instance) =>
    <String, dynamic>{
      'text': instance.text,
      'authorId': instance.authorId,
      'status': instance.status,
    };

UpdateCommentStatusRequest _$UpdateCommentStatusRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCommentStatusRequest(status: json['status'] as String);

Map<String, dynamic> _$UpdateCommentStatusRequestToJson(
  UpdateCommentStatusRequest instance,
) => <String, dynamic>{'status': instance.status};

ShareProfileRequest _$ShareProfileRequestFromJson(Map<String, dynamic> json) =>
    ShareProfileRequest(shared: json['shared'] as bool);

Map<String, dynamic> _$ShareProfileRequestToJson(
  ShareProfileRequest instance,
) => <String, dynamic>{'shared': instance.shared};

AddReviewNotesRequest _$AddReviewNotesRequestFromJson(
  Map<String, dynamic> json,
) => AddReviewNotesRequest(notes: json['notes'] as String);

Map<String, dynamic> _$AddReviewNotesRequestToJson(
  AddReviewNotesRequest instance,
) => <String, dynamic>{'notes': instance.notes};
