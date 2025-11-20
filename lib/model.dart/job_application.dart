import 'package:json_annotation/json_annotation.dart';
import 'job_application_comment.dart';

part 'job_application.g.dart';

/// Enum for job application status
enum ApplicationStatus {
  @JsonValue('applied')
  applied,
  @JsonValue('withdrawn')
  withdrawn,
  @JsonValue('shortlisted')
  shortlisted,
  @JsonValue('interviewed')
  interviewed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('hired')
  hired,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get value {
    switch (this) {
      case ApplicationStatus.applied:
        return 'applied';
      case ApplicationStatus.withdrawn:
        return 'withdrawn';
      case ApplicationStatus.shortlisted:
        return 'shortlisted';
      case ApplicationStatus.interviewed:
        return 'interviewed';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.hired:
        return 'hired';
    }
  }

  static ApplicationStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'applied':
        return ApplicationStatus.applied;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'interviewed':
        return ApplicationStatus.interviewed;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'hired':
        return ApplicationStatus.hired;
      default:
        return ApplicationStatus.applied;
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.interviewed:
        return 'Interviewed';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
    }
  }
}

@JsonSerializable(explicitToJson: true)
class JobApplication {
  /// Unique application identifier
  @JsonKey(name: 'id')
  final int id;

  /// Foreign key to Job
  @JsonKey(name: 'jobID')
  final int jobId;

  /// Foreign key to User
  @JsonKey(name: 'userID')
  final int userId;

  /// Application status (applied, withdrawn, shortlisted, interviewed, rejected, hired)
  @JsonKey(name: 'status')
  final String status;

  /// Resume file URLs
  @JsonKey(name: 'resumeFile')
  final List<String>? resumeFiles;

  /// Whether profile is shared with employer
  @JsonKey(name: 'sharedProfile')
  final bool sharedProfile;

  /// Comments on the application
  @JsonKey(name: 'comments')
  final List<JobApplicationComment>? comments;

  /// Review notes from recruiter/HR
  @JsonKey(name: 'reviewNotes')
  final String? reviewNotes;

  /// Application creation timestamp
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  /// Last update timestamp
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  /// Nested job details (optional) - kept as dynamic for flexibility with nested objects
  @JsonKey(name: 'jobDetails', includeIfNull: false)
  final dynamic jobDetails;

  /// Nested applicant details (optional) - kept as dynamic for flexibility with nested objects
  @JsonKey(name: 'applicant', includeIfNull: false)
  final dynamic applicant;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.status,
    this.resumeFiles,
    this.sharedProfile = false,
    this.comments,
    this.reviewNotes,
    this.createdAt,
    this.updatedAt,
    this.jobDetails,
    this.applicant,
  });

  /// Factory constructor for JSON deserialization
  factory JobApplication.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$JobApplicationToJson(this);

  /// Get application status as enum
  ApplicationStatus get applicationStatus =>
      ApplicationStatusExtension.fromString(status);

  /// Check if application is still active (not withdrawn or final state)
  bool get isActive => status != 'withdrawn' && status != 'rejected';

  /// Check if application needs action
  bool get requiresAction => status == 'applied' || status == 'interviewed';

  /// Copy with method for immutability
  JobApplication copyWith({
    int? id,
    int? jobId,
    int? userId,
    String? status,
    List<String>? resumeFiles,
    bool? sharedProfile,
    List<JobApplicationComment>? comments,
    String? reviewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic jobDetails,
    dynamic applicant,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      resumeFiles: resumeFiles ?? this.resumeFiles,
      sharedProfile: sharedProfile ?? this.sharedProfile,
      comments: comments ?? this.comments,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      jobDetails: jobDetails ?? this.jobDetails,
      applicant: applicant ?? this.applicant,
    );
  }

  /// Get days since application was created
  int? get daysSinceApplication {
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt!).inDays;
  }

  /// Get total number of comments
  int get commentCount => comments?.length ?? 0;

  /// Get visible comments only
  List<JobApplicationComment> get visibleComments =>
      comments?.where((c) => c.status == 'visible').toList() ?? [];

  @override
  String toString() =>
      'JobApplication(id: $id, jobId: $jobId, userId: $userId, status: $status, sharedProfile: $sharedProfile, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplication &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          jobId == other.jobId &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ jobId.hashCode ^ userId.hashCode;
}

/// Request/Response wrapper for API calls
@JsonSerializable(explicitToJson: true)
class CreateJobApplicationRequest {
  @JsonKey(name: 'jobID')
  final int jobId;

  @JsonKey(name: 'userID')
  final int userId;

  /// Resume files (handled separately in multipart)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String>? resumeFiles;

  const CreateJobApplicationRequest({
    required this.jobId,
    required this.userId,
    this.resumeFiles,
  });

  factory CreateJobApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJobApplicationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateJobApplicationRequestToJson(this);
}

/// Update status request
@JsonSerializable()
class UpdateApplicationStatusRequest {
  @JsonKey(name: 'status')
  final String status;

  const UpdateApplicationStatusRequest({required this.status});

  factory UpdateApplicationStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateApplicationStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateApplicationStatusRequestToJson(this);
}

/// Withdraw application request
@JsonSerializable()
class WithdrawApplicationRequest {
  @JsonKey(name: 'userId')
  final int userId;

  const WithdrawApplicationRequest({required this.userId});

  factory WithdrawApplicationRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawApplicationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$WithdrawApplicationRequestToJson(this);
}

/// Add comment request
@JsonSerializable()
class AddCommentRequest {
  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'authorId')
  final int authorId;

  @JsonKey(name: 'status')
  final String status;

  const AddCommentRequest({
    required this.text,
    required this.authorId,
    this.status = 'visible',
  });

  factory AddCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$AddCommentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddCommentRequestToJson(this);
}

/// Update comment status request
@JsonSerializable()
class UpdateCommentStatusRequest {
  @JsonKey(name: 'status')
  final String status;

  const UpdateCommentStatusRequest({required this.status});

  factory UpdateCommentStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCommentStatusRequestToJson(this);
}

/// Share profile request
@JsonSerializable()
class ShareProfileRequest {
  @JsonKey(name: 'shared')
  final bool shared;

  const ShareProfileRequest({required this.shared});

  factory ShareProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$ShareProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ShareProfileRequestToJson(this);
}

/// Add review notes request
@JsonSerializable()
class AddReviewNotesRequest {
  @JsonKey(name: 'notes')
  final String notes;

  const AddReviewNotesRequest({required this.notes});

  factory AddReviewNotesRequest.fromJson(Map<String, dynamic> json) =>
      _$AddReviewNotesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddReviewNotesRequestToJson(this);
}
