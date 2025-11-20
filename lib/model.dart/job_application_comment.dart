import 'package:json_annotation/json_annotation.dart';

part 'job_application_comment.g.dart';

@JsonSerializable(explicitToJson: true)
class JobApplicationComment {
  @JsonKey(name: 'id')
  final dynamic id; // Can be string or int from backend

  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'authorId')
  final int? authorId;

  @JsonKey(name: 'authorName')
  final String? authorName;

  @JsonKey(name: 'status')
  final String status; // 'visible', 'hidden', etc.

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const JobApplicationComment({
    required this.id,
    required this.text,
    this.authorId,
    this.authorName,
    this.status = 'visible',
    this.createdAt,
    this.updatedAt,
  });

  factory JobApplicationComment.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationCommentFromJson(json);

  Map<String, dynamic> toJson() => _$JobApplicationCommentToJson(this);

  JobApplicationComment copyWith({
    dynamic id,
    String? text,
    int? authorId,
    String? authorName,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobApplicationComment(
      id: id ?? this.id,
      text: text ?? this.text,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'JobApplicationComment(id: $id, text: $text, authorId: $authorId, status: $status, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplicationComment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          authorId == other.authorId &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ authorId.hashCode ^ status.hashCode;
}
