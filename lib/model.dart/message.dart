import 'package:jobportal/model.dart/job.dart';

enum MessageSender { user, company }
enum MessageType { text, file, job }

class Message {
  final String id;
  final MessageSender sender;
  final MessageType type;
  final String? text; // Nullable for file/job messages
  final DateTime timestamp;
  final String? repliedToMessageId; // ID of the message this one is replying to
  final String? fileUrl; // For file messages
  final String? fileName; // For file messages
  final Job? jobData; // For job sharing messages

  Message({
    required this.id,
    required this.sender,
    this.type = MessageType.text,
    this.text,
    required this.timestamp,
    this.repliedToMessageId,
    this.fileUrl,
    this.fileName,
    this.jobData,
  });
}