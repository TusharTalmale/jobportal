import 'package:jobportal/model.dart/job.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum MessageSender { user, company }

enum MessageType { text, file, job }

@JsonSerializable(explicitToJson: true)
class Message {
  final int id;
  final String conversationId;
  final int senderId;
  final MessageSender senderType;
  final MessageType messageType;
  final String? text;
  final int? repliedToMessageId;
  final String? fileUrl; // For file messages
  final String? fileName; // For file messages
  final int? jobId; // For job sharing messages
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: 'Job')
  final Job? jobData;
  @JsonKey(name: 'RepliedTo')
  final Message? repliedTo;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.messageType,
    this.text,
    this.repliedToMessageId,
    this.fileUrl,
    this.fileName,
    this.jobId,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.jobData,
    this.repliedTo,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
