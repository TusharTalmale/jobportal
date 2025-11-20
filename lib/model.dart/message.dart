import 'package:jobportal/model.dart/job.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonEnum(valueField: 'value')
enum MessageSender {
  @JsonValue('user')
  user('user'),
  @JsonValue('company')
  company('company');

  final String value;
  const MessageSender(this.value);
}

@JsonEnum(valueField: 'value')
enum MessageType {
  @JsonValue('text')
  text('text'),
  @JsonValue('file')
  file('file'),
  @JsonValue('job')
  job('job');

  final String value;
  const MessageType(this.value);
}

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
